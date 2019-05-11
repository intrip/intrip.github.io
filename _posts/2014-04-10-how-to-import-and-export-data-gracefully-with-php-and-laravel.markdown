---
layout: post
title: 'How to import and export data gracefully with php and laravel'
date: 2014-04-10 21:52:00
categories: ['laravel']
---
Hello guys, during my career i've come across the problem of **importing** and **exporting** data from and to different formats many multiple times. For this reason i want to share with you my general approach to solve this problem. 
The process of importing and exporting data mainly is just a process of data trasforming; for this reason the import and export operations can be seen as the same of **data transformation**.
<!-- more -->
After realising that i started to think a smart way to solve the problem gracefully. What i decided to do is to separate the process in three parts:

1. Reading data from a format 
2. Trasforming data into a general format
3. Saving data into another format

So every kind of import/export operation can be splitted in thoose 3 parts. At this point i decided to create two interface, one for reading data and one for saving data (keep this code mainly as a proof of concept). The interface for reading the data will be this:

	interface Reader 
	{
    /**
     * Open stream from a source
     *      A source can be anything: for instance a db, a file, or a socket
     * @param $source
     * @return void
     * @throws \Palmabit\Library\Exceptions\CannotOpenFileException
     */
    public function open($source);

    /**
     * Reads a single element from the source
     *    then return a Object instance
     * @return \StdClass object instance
     */
    public function readElement();

    /**
     * Read all the objects from the source
     * @return \ArrayIterator
     */
    public function readElements();

    /**
     * Obtains all the objects readed as StdClass
     * reflecting an imperative mapping of key => value
     * @return \ArrayIterator
     */
    public function getObjects();

    /**
     * Obtains all the objects readed as Istantiated Class
     * @return \ArrayIterator
     */
    public function getObjectsIstantiated();

    /**
     * Obtains the class name of the objects to istantiate
     * @return mixed
     */
    public function getIstantiatedObjectsClassName();

    /**
     * Set the StdClass objects
     * @param array $objects
     * @return mixed
     */
    public function setObjects(array $objects);

    /**
     * Creates the actual real instance of the required objects
     * @return \ArrayIterator
     */
    public function IstantiateObjects();
	}
	
The concept in this interface is that with a reader implementation you can **open** a certain source of data, then **read** an arbitrary amount of data, and then transform that data to a general object. In this interface i've merged the responsability to read data with the one of trasforming data (point 1 and 2 above). That's not the best (break single responsability principle), in fact what you can do is split the responsability between two interfaces instead; you could try that as an your own. 
Now comes the last part: the save of the data. This will be handled with the Saver interface:

	use ArrayIterator;

	interface Saver
	{
    /**
     * Handle saving the array of data
     * @param \ArrayIterator $objects
     * @return mixed
     */
    public function save(ArrayIterator $objects);
	}	 
	
This interface is pretty simple and handles the save of the data. What i did then was to try to generalize some part of the process, in fact the part that transform data in a general object should be reused in most of the implementation; for this reason i've created the Reader class:

	use InvalidArgumentException;
	use Palmabit\Library\ImportExport\Interfaces\Reader as ReaderInterface;
	use ArrayIterator, Exception;

	abstract class Reader implements ReaderInterface
	{
	  /**
	   * The objects as StdClass
	   * @var \ArrayIterator
	   */
	  protected $objects;
	  /**
	   * Objects as real usable class
	   * @var \ArrayIterator
	   */
	  protected $objects_istantiated;
	  /**
	   * @var String
	   */
	  protected $istantiated_objects_class_name;
  
	  /**
	   * @return \ArrayIterator
	   */
	  public function getObjects()
	  {
		  return $this->objects;
	  }
  
	  /**
	   * @return \ArrayIterator
	   */
	  public function getObjectsIstantiated()
	  {
		  return $this->objects_istantiated;
	  }
  
	  /**
	   * Assuming that we can pass all the proprieties to that object as an array
	   * we istantiate each of that StdClass as a IstantiatedObject
	   * @return \ArrayIterator
	   * @throws \Exception
	   */
	  public function istantiateObjects()
	  {
		  $this->validateObjectClassName();
  
		  $objects_iterator = new ArrayIterator;
  
		  $this->appendObjectDataToIterator($objects_iterator);
  
		  $this->objects_istantiated = $objects_iterator;
		  return $this->objects_istantiated;
	  }
  
	  private function validateObjectClassName()
	  {
		  if (!$this->istantiated_objects_class_name) throw new Exception("You need to set istantiated_object_class_name");
  
		  if (!class_exists($this->istantiated_objects_class_name)) throw new InvalidArgumentException("The class name to istantiate given is not valid.");
	  }
  
	  /**
	   * @param $objects_iterator
	   */
	  private function appendObjectDataToIterator($objects_iterator)
	  {
		  if ($this->objects) foreach ($this->objects as $object) {
			  $data_array = $this->transformObjectDataToArray($object);
			  $object = $this->istantiateObjectClass($data_array);
  
			  $objects_iterator->append($object);
		  }
	  }
  
	  /**
	   * @return String
	   */
	  public function getIstantiatedObjectsClassName()
	  {
		  return $this->istantiated_objects_class_name;
	  }
  
	  /**
	   * @param array $objects
	   */
	  public function setObjects(array $objects)
	  {
		  $this->objects = $objects;
	  }
  
	  /**
	   * @param $object
	   * @return array
	   */
	  private function transformObjectDataToArray($object)
	  {
		  $data_array = get_object_vars($object);
  
		  return $data_array;
	  }
  
	  /**
	   * @param $data_array
	   * @return mixed
	   */
	  private function istantiateObjectClass($data_array)
	  {
		  $object = new $this->istantiated_objects_class_name($data_array);
  
		  return $object;
	  }
	}

As you can see this class is abstract, in fact it sould not be istantiated on his own. What the saver class is doing in fact is to create a new ArrayIterator, then create various instance of **istantiated_objects_class_name**, fill them with the data readed and append them to this iterator. This is the process of **trasforming the data**. At this point the last part that we need to do is just to actually create an implementation of reader and saver classes. In this example i've created a csvFileReader and an eloquentDbSaver. Here is the source of the csvFileReader:

	use ArrayIterator;
	use Palmabit\Library\ImportExport\Reader;
	use SplFileObject;

	class CsvFileReader extends Reader
	{
	  /**
	   * @var \SplFileObject
	   */
	  protected $spl_file_object;
	  /**re
	   * @var string
	   */
	  protected $delimiter = ",";
	  /**
	   * @var Array
	   */
	  protected $columns_name;
  
	  /**
	   * Open stream from a source
	   *      A source can be anything: for instance a db, a file, or a socket
	   *
	   * @param String $path
	   * @return void
	   * @throws \Palmabit\Library\Exceptions\CannotOpenFileException
	   */
	  public function open($path)
	  {
		  $this->spl_file_object = new SplFileObject($path);
		  $this->spl_file_object->setCsvControl($this->delimiter);
		  $this->columns_name = $this->spl_file_object->fgetcsv();
  
	  }
  
	  /**
	   * Reads a single element from the source
	   *    then return a Object instance
	   *
	   * @return \StdClass|false object instance
	   */
	  public function readElement()
	  {
		  $csv_line_data = $this->spl_file_object->fgetcsv();
		  if($csv_line_data)
		  {
			  $csv_line = array_combine($this->columns_name, $csv_line_data);
			  // we cast it to StdClass
			  return (object)$csv_line;
		  }
		  else
		  {
			  return false;
		  }
	  }
  
	  /**
	   * Read all the objects from the source
	   *
	   * @return \ArrayIterator
	   */
	  public function readElements()
	  {
		  $iterator = new ArrayIterator;
		  do
		  {
			  $object = $this->readElement();
			  if($object) $iterator->append($object);
		  }while((boolean)$object);
  
		  $this->objects = $iterator;
		  return $this->objects;
	  }
  
	  /**
	   * @param string $delimiter
	   */
	  public function setDelimiter($delimiter)
	  {
		  $this->delimiter = $delimiter;
	  }
  
	  /**
	   * @return string
	   */
	  public function getDelimiter()
	  {
		  return $this->delimiter;
	  }
	}
	
That class actually implements the resting methods from the Reader interface, and uses SplFileObject to read data from a Csv file. There is one thing missing: we didn't set the **$istantiated_objects_class_name** variable, we should write the name of the class we want to instantiate, here is an example(UserCsvFileReader):

	class UserCsvFileReader extends CsvFileReader
	{
   		protected $istantiated_objects_class_name = '\Palmabit\Authentication\Models\UserDbImportSaver';
	}
	
The saver class is this:

	use ArrayIterator;
	use Palmabit\Library\ImportExport\Interfaces\Saver;

	class EloquentDbSaver implements Saver
	{
	  public function save(ArrayIterator $objects)
	  {
		  foreach ($objects as $object)
		  {
			  if( ! $object->save()) return false;
		  }
  
		  return true;
	  }
	} 
	
What it actually does is just to call save on all the object classes, in fact eloquent has already his way to save data of an Eloquent class. Well, you could say: how we know this is an eloquent class? In fact we don't know that but we expect that as it's an EloquentDbSaver. With other implementatios we would do some different operation to save the data. 
What you could say is: hey we just read data from a csv and save that into a db, why you doing all that interfaces and abstract classes? Well the advantage is this: now we can create as many implementation of reading and saving data with any format we want; for example we can create an EloquentDbReader, a csvFileSaver or a JsonFileSaver and so on. This code was written in TDD but for this purpose i didn't show the test of each class, but if you are interested you can download the full sources (with the tests) [<i class="fa fa-download"></i> here](http://www.jacopobeschi.com/code/import_export_jb.zip).

I hope you enjoy the article. 
Happy coding!