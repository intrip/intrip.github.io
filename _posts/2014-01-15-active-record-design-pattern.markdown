---
layout: post
title: 'Active Record Design pattern'
date: 2014-01-15 13:26:00
categories: ['design pattern']
---
Hello folks, in this article i'll briefly explain the **Active record** design pattern. Active record is one of the **data access pattern** which helps you to map your domain model (Object) into Relational Database. Basically with active record, every istance of your class correspond to one row in a table of the database (one to one relationship).
The active record basic usage consist in extending the abstract active record class from your model class. With this pattern the biggest advantage it's simplicity, in fact this pattern is used in many ORM, for example Laravel ORM Eloquent, Yii ORM, FuelPHP ORM or Ruby on Rails ORM. I'll show you how that works with a simple example. 
<!-- more -->
I've created a class that implement the active record pattern(keep in mind it's really simple and to be used well need to be expanded). As i'm used to do i'll explain that by examples, now imagine we have the MobilePhone Class, which have the following attributes:

<ul>
<li><b>name</b></li>
<li><b>company</b></li>
</ul>

We want to save that data into a Database with the Active record pattern class. The table associated to the class can be created with the following script:

	CREATE TABLE IF NOT EXISTS `phone` (
  	`id` int(11) NOT NULL AUTO_INCREMENT,
  	`name` varchar(255) NOT NULL,
  	`company` varchar(255) NOT NULL,
  	PRIMARY KEY (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 

The table class have this code:

	class MobilePhone extends ActiveRecordModel
	{
    protected $table_name = 'phone';
    protected $username ='root';
    protected $password = 'root';
    protected $hostname = 'localhost';
    protected $dbname = 'activerecord';
	}

As you can see the MobilePhone class extends ActiveRecordModel and has some proprieties to know how to connect to the database.  
<h3>Insert data</h3>
You can insert a new MobilePhone with the following code.

	// create a new phone
	$phone = new MobilePhone(array(
   	 "name" => "cool phone",
   	 "company" => "nekia"
	));

	// save it
	$phone->save();
	
This looks really simple, lets take a look on how the ActiveRecordModel lets you do that:

	abstract class ActiveRecordModel
	{
    /**
     * The attributes that belongs to the table
     * @var  Array
     */
    protected $attributes = array();
    /**
     * Table name
     * @var  String
     */
    protected $table_name;
    /**
     * Username
     * @var String
     */
    protected $username;
    /**
     * password
     * @var  String
     */
    protected $password;
    /**
     * The DBMS hostname
     * @var  String
     */
    protected $hostname;
    /**
     * The database name
     * @var  String
     */
    protected $dbname;
    /**
     * The DBMS connection port
     * @var  String
     */
    protected $port = "3306";

    protected $id_name = 'id';
  
    function __construct(Array $attributes = null) {
        $this->attributes = $attributes;
    }
    public function __set($key, $value)
    {
        $this->setAttribute($key, $value);
    }
    public function newInstance(array $data)
    {
        $class_name = get_class($this);
        return new  $class_name($data);
    }

    /**
     * Save the model
     * @return bool
     */
    public function save()
    {
        try
        {
            if(array_key_exists($this->id_name, $this->attributes))
            {
                $attributes = $this->attributes;
                unset($attributes[$this->id_name]);
                $this->update($attributes);
            }
            else
            {
                $id = $this->insert($this->attributes);
                $this->setAttribute($this->id_name, $id);
            }
        }
        catch(ErrorException $e)
        {
            return false;
        }

        return true;
    }

    /**
     * Used to prepare the PDO statement
     *
     * @param $connection
     * @param $values
     * @param $type
     * @return mixed
     * @throws InvalidArgumentException
     */
    protected function prepareStatement($connection, $values, $type)
    {
        if($type == "insert")
        {
        $sql = "INSERT INTO {$this->table_name} (";
        foreach ($values as $key => $value) {
            $sql.="{$key}";
            if($value != end($values) )
                $sql.=",";
        }
        $sql.=") VALUES(";
        foreach ($values as $key => $value) {
            $sql.=":{$key}";
            if($value != end($values) )
                $sql.=",";
        }
        $sql.=")";
        }
        elseif($type == "update")
        {
            $sql = "UPDATE {$this->table_name} SET ";
            foreach ($values as $key => $value) {
                $sql.="{$key} =:{$key}";
                if($value != end($values))
                    $sql.=",";
            }
            $sql.=" WHERE {$this->id_name}=:{$this->id_name}";
        }
        else
        {
            throw new InvalidArgumentException("PrepareStatement need to be insert,update or delete");
        }

        return $connection->prepare($sql);
    }

    /**
     * Used to insert a new record
     * @param array $values
     * @throws ErrorException
     */
    public function insert(array $values)
    {
        $connection = $this->getConnection();
        $statement = $this->prepareStatement($connection, $values, "insert");
        foreach($values as $key => $value)
        {
            $statement->bindValue(":{$key}", $value);
        }

        $success = $statement->execute($values);
        if(! $success)
            throw new ErrorException;

        return $connection->lastInsertId();
    }

    /**
     * Get the connection to the database
     *
     * @throws  PDOException
     */
    protected function getConnection()
    {
        try {
            $conn = new PDO("mysql:host={$this->hostname};dbname={$this->dbname};port=$this->port", $this->username, $this->password);
            $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

            return $conn;
        } catch(PDOException $e) {
            echo 'ERROR: ' . $e->getMessage();
        }
    }
}

What the ActiveRecordClass does when we set the attributes is to call the magic method "__set()" which will set the values in his protected $attributes properties array (they are the same as the columns in the table); in this particular case we setted the data in the constructor which instantly populated the **$attributes** array (check __construct() method). 
Then we call the save method, that method calls the insert method passing him the values contained in **$attributes**, the insert method will create a new connection and then insert a new row filling the column values with the corresponding **$key->value** pairs of the $attributes array then returns the id of the new row which is setted as property in the $attributes by the save method.

<h3>Update data</h3>
After you have created a new model you can change his proprieties in the database with the update method: you can just call $model->update(array("newvalue"=>"value)) or you can set the proprerty with $model->newvalue = "value" and then call $model->save(), you will get the same result in the end.

Here is an example:

	$phone->name = "new name!";
	$phone->save();

Here is the update method:

	abstract class ActiveRecordModel
	...
	 /**
     * Update the current row with new values
     *
     * @param array $values
     * @return bool
     * @throws ErrorException
     * @throws BadMethodCallException
     */
    public function update(array $values)
    {
        if( ! isset($this->attributes[$this->id_name]))
            throw new BadMethodCallException("Cannot call update on an object non already fetched");

        $connection = $this->getConnection();
        $statement = $this->prepareStatement($connection, $values, "update");
        foreach($values as $key => $value)
        {
            $statement->bindValue(":{$key}", $value);
        }
        $statement->bindValue(":{$this->id_name}", $this->attributes[$this->id_name]);
        $success = $statement->execute();

        // update the current values
        foreach($values as $key => $value)
        {
            $this->setAttribute($key, $value);
        }

        if(! $success)
            throw new ErrorException;

        return true;
    }
	
As you can see the update method create a new update statement from the given $attributes(check the code before), then run the statement and update the data in his **$attributes** array.

<h3>Find and update</h3>
You can also use the find method or where method to get a class corresponding to a given id or a list of classes corrisponding to a certain condition. 
Here is an example:

	$same_phone = $phone->find(77);

We find a phone with an id equal to 77.

The code of the ActiveRecordModel is that:

	abstract class ActiveRecordModel
	...
	 /**
     * Find a row given the id
     *
     * @param $id
     * @return null|Mixed
     */
    public function find($id)
    {
        $conn = $this->getConnection();
        $query = $conn->query("SELECT * FROM {$this->table_name} WHERE  {$this->id_name}= " . $conn->quote($id));
        $obj = $query->fetch(PDO::FETCH_ASSOC);

        return ($obj) ? $this->newInstance($obj) : null;
    }

In case you want a where condition you can do like that:

	$phone = $phone->where("company='nekia'");
	
you can see the code below:
	
	abstract class ActiveRecordModel
	....
    /**
     * Find rows given a where condition
     *
     * @param $where_cond
     * @return null|PDOStatement
     */
    public function where($where_cond)
    {
        $conn = $this->getConnection();
        $query = $conn->query("SELECT * FROM {$this->table_name} WHERE {$where_cond}");
        $objs = $query->fetchAll(PDO::FETCH_ASSOC);
        // the model instantiated
        $models = array();

        if(! empty($objs))
        {
            foreach($objs as $obj)
            {
                $models[] = $this->newInstance($obj);
            }
        }

        return $models;
    }

As you saw in this examples the basic concept of ActiveRecord is to make a one-to-one relationshib between the instance of the class and the row in the database, we also map the attributes of the table in the database with the **attributes** property of the model and we use them as data for the queries. Note that because this example is really simple we build query "on the fly" with the help of php PDO class, but you can create a query class that handles the creation of the query and inject him in the ActiveRecordModel class.

If you are interested you can **[<span class="glyphicon glyphicon-download"></span> download the code here](/code/ActiveRecordModel.zip)**.

<h3>Architectural stuff</h3>
To dig deeper into some architectural approach, this pattern is really simple to use and understand. However its simpliciy lacks flexibility, in fact when you handle one table at time this approach is fine but when you need to handle some classess nested within others, or some more complex **Object model** you will have a lot of problems with that pattern; in this situation you should use the **Data Mapper** pattern. Handling relationships aswell it's not that simple: there are some approaches to handle that based on returning new classes that rappresent the relation in the database, but its much harder to set that up with this pattern than with the Data Mapper one. In fact the biggest problem with the ActiveRecord is the high coupling (created by inheritance) between the classes in the Object model and the classes that handle the access to the data which makes handling of complicated tasks much harder; that's not happening with the Data Mapper because you istantiate a new class the handles the mapping of the data instead of inheriting from another class.

That's it for today folks. If you have any question please fill a comment below. Enjoy!

If you liked this article: <a href="https://twitter.com/JacopoBeschi" class="twitter-follow-button" data-show-count="false" data-lang="en">Follow me</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>