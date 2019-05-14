---
layout: post
title: 'SOLID Design principles and Php: Interface Segregation'
date: 2014-02-24 20:48:00
categories: ['design pattern','laravel','solid']
---
Ok guys we're almost done with the SOLID principles series, today we talk about the interface segregation principle. The **Interface segregation** principle says: "A client should not be forced to implement and interface that doesn't use". As we are used let's explain that with an example. Imagine we are using the [repository pattern](http://martinfowler.com/eaaCatalog/repository.html) to save some objects. 
<!-- more -->


The repository will implement a RepositoryInterface:

	<?php 
	/**
 	*	 Interface BaseRepositoryInterface
 	*
 	*/
	interface BaseRepositoryInterface 
	{
    	/**
     	* Create a new object
     	* @return mixed
     	*/
    	public function create(array $data);

	  /**
	   * Update a new object
	   * @param id
	   * @param array $data
	   * @return mixed
	   */
	  public function update($id, array $data);
  
	  /**
	   * Deletes a new object
	   * @param $id
	   * @return mixed
	   */
	  public function delete($id);
  
	  /**
	   * Find a model by his id
	   * @param $id
	   * @return mixed
	   */
	  public function find($id);
  
	  /**
	   * Obtains all models
	   * @return mixed
	   */
	  public function all();
	}
	
Let's now create an **Eloquent** implementation of that:

	<?php 
	 /**
    * Class EloquentBaseRepository
    *
	*/
	  
	 use BaseRepositoryInterface;
	 use Event;

	class EloquentBaseRepository implements BaseRepositoryInterface
	{
	  /**
	   * The name of the model: needs to be eloquent model
	   * @var String
	   */
	  protected $model_name;
  
	  public function __construct($model_name = null)
	  {
		  if($model_name) $this->model_name = $model_name;
	  }
  
	  /**
	   * Create a new object
	   *
	   * @return mixed
	   */
	  public function create(array $data)
	  {
		  $model = $this->model_name;
		  return $model::create($data);
	  }
  
	  /**
	   * Update a new object
	   * @param       id
	   * @param array $data
	   * @return mixed
	   * @throws \Illuminate\Database\Eloquent\ModelNotFoundException
	   */
	  public function update($id, array $data)
	  {
		  $obj = $this->find($id);
		  Event::fire('repository.updating', [$obj]);
		  $obj->update($data);
		  return $obj;
	  }
  
	  /**
	   * Deletes a new object
	   * @param $id
	   * @return mixed
	   * @throws \Illuminate\Database\Eloquent\ModelNotFoundException
	   */
	  public function delete($id)
	  {
		  $obj = $this->find($id);
		  Event::fire('repository.deleting', [$obj]);
		  return $obj->delete();
	  }
  
	  /**
	   * Find a model by his id
	   * @param $id
	   * @return mixed
	   * @throws \Illuminate\Database\Eloquent\ModelNotFoundException
	   */
	  public function find($id)
	  {
		  $model = $this->model_name;
		  return $model::findOrFail($id);
	  }
  
	  /**
	   * Obtains all models
	   * @return mixed
	   */
	  public function all()
	  {
		  $model = $this->model_name;
		  return $model::all();
	  }
	}	 
	
Perfect, for now everything looks great. But what now imagine we need to save producs, and they need to be saved in different languages. What we could do is just extend The **EloquentBaseRepository** Class and add some more methods to the **BaseRepositoryInterface**. But by doing that we will violate the **Interface Segregation** principle. I'll show you why, take a look and the new interface:

	interface BaseRepositoryInterface 
	{
	....
		/*
		* @param $slug_lang the variable used to identify a class by his language
		*/
	    public function findBySlugLang($slug_lang);
		
Now the EloquentBaseRepository need to implement that method, but actually... it doesn't need that, the method is needed only for the ProductRepository which needs to be saved in different languages. 
So what we need to do is: create another interface and implement that only in the **ProductRepository**, so let's create a **MultilanguageRepositoryInterface**:

	interface MultilanguageRepositoryInterface
	{
        /*
        * @param $slug_lang the variable used to identify a class by his language
        */
        public function findBySlugLang($slug_lang);
	}
	
And then what we will do in the ProductRepository is to implement both the interfaces and extends the **EloquentBaseRepository**:

	Class PropuctRepository extends EloquentBaseRepository implements MultilanguageRepositoryInterface, BaseRepositoryInterface
	{
		public function findBySlugLang($slug_lang)
		{
			// code goes here
		}
	}
	
Prefect, now we are respecting the SOLID design principles. And as you can see they are all based on reparating the part of the code to get less coupling and easyer ways to swap implementations! 

That's it for today guys. Enjoy!