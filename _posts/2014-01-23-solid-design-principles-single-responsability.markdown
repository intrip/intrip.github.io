---
layout: post
title: 'SOLID Design principles and Php: Single responsability'
date: 2014-01-23 07:23:00
categories: ['design pattern','laravel','solid']
---
Hello guys, this is the first article (of 5) About **SOLID** design principles. Solid design principles was written by **Uncle Bob Martin** with the objective to help building quality code. 
But how can you say that you have written good code? You could say: when the code works its good code, but in fact that's not; in fact the biggest quality of software are that it's easy to **replicate** and easy to **modify**. <!-- more -->
When you have fear to change a certain in code (because something may break) than that's bad code; code should be **easy** to modify!
All thoose principles are based on making code less coupled as possible to allow easy modification and can be summarized in one single phrase: "Program the interface!". 
As i first approached SOLID principles they was looking a bit complicated and overwhelming, but after i understood them they changed the way i make software in a better way. If you are a developer in my opinion you should know thoose principles: belive me or not they will change your life! 
Let's talk about **Single responsability**. 
The principle of single responsability says: **"A class should have one and only one reason to change"**. So when you build a class you should ask yourself: shall this class do that? Or should this class change in order to modify this beaviour? Let's dig into that with an example. 
A commom approach of programmer that use MVC pattern is that they tend to put all the business logic in the controller and the data acces into the model. The role of the controller is **not** to hold the application logic but instead to catch the http request data and to respond with some other data, the controller should be **totally ignorant** about what we do with the data. Here is a classical example(Using Laravel) that doest not respect Single responsability principle:

  	class PhotoController
  	{
		public function postPhoto()
		{	
			// check authentication
			if(Auth::guest())
				return Redirect::to('/login);
				
			// get the data
			$input = Input::all();
			
			// validate data
			$validator = new Validator(array("name"=>"required", "description" => "required"));
			if( ! $validator->make($input))
				return Redirect::to('/photo')->withErrors($validator->getMessage());
			
			// save data into db
			$this->savePhoto($input);
			
			return Redirect::to('/photo')->with(array("message" => "you have succesfully created a new photo";)
		}
		
		protected function savePhoto(array $input)
		{
			DB::table('photo')->insert(array("name" => $input["name"], "description" => $input["description"]);
		}
	}
	
Now look at the code and answer to thoose questions: shall the controller save the data? Shall the controller check for authentication? Shall the controller need to be changed if we change the authentication method? The answer to all this question is the same: **NO**.

The controller should only get the input, and answer with some output but not process the data. Anyways you could tell me: hey bud, this code works why should i change it? Why is not good code? The answer is: decoupling! Coupled code is one of the first problems with programming: coupled code is evil and will cause you a lot of trouble, plus this code is hard to test because all the functionality are putted all together. 
So how can you decouple the code? Well, you should split the responsabilities and put every of them in a separate class. For example we should start by creating a repository to handle the part of saving the data. We should add a filter to that route so that we don't check for authentication inside the controller method. And about validation we should create a custom validation class to inject in the constructor of the controller. Look now at the code below:

	class PhotoController
  	{
		protected $repo;
		protected $v;
	
		public function __construct(Validator $v, Repository $r)
		{
			$this->repo = $r;
			$this->v = $v;
			$this->beforeFilter('auth', array('on' => 'photo'));
		}
	
		public function postPhoto()
		{					
			// get the data
			$input = Input::all();
			
			// validate data
			if( ! $this->v->validate($input))
				return Redirect::to('/photo')->withErrors($validator->getMessage());
			
			// save data into db
			$this->repo->create($input);
			
			return Redirect::to('/photo')->with(array("message" => "you have succesfully created a new photo";)
		}
	}
	
This looks much better but we could do something more, what we can do is make a service class to handle the creation of a new photo:

	interface FormServiceInterface
	{
		/**
		* @throws ValidationExeption
		*/
		public function processData();
		public function getErrors();
	}

	Class PhotoCreatorService implements FormServiceInterface
	{
			protected $v;
			protected $input;
			protected $errors;
			
			public function __construct(Validator $v, $input)
			{
				$this->v = $v;
				$this->input = $input;
			}
			
			public function processData()
			{
				// validate data
				if( ! $this->v->validate($input))
				{
					$this->errors = $v->getMessage();
					throw new ValidationException();
				}	
				// save data into db
				$this->repo->create($input);
			}
			
			public function getErrors()
			{
				return $this->errors;
			}
	}
	
What we do here is to validate the data, if something goes wrong we throw an Exception and set the error otherwise we just save the data.
Now how the controller will look like? Let's see:

	class PhotoController
  	{
		protected $repo;
		protected $v;
		protected $photo_service;
		
		public function __construct(Validator $v, Repository $r)
		{
			$this->repo = $r;
			$this->v = $v;
			$this->photo_service = new PhotoService($this->v, $this->r);
			$this->beforeFilter('auth', array('on' => 'photo'));
		}
	
		public function postPhoto()
		{					
			// get the data
			$input = Input::all();
			
			try
			{
				$this->photo_service->processData($input);
			}
			catch(ErrorException $e)
			{
				$errors = $this->photo_service->getErrors();
				return Redirect::to('/photo')->withErrors($errors);
			}
			
			return Redirect::to('/photo')->with(array("message" => "you have succesfully created a new photo";)
		}
	}
	
The controller code now is much more cleaner, what we do in fact is that: we try to process the data, if something goes wrong we return an error message, otherwise we return a success message. The role of the controller now is only to get the input and respond with some data, the controller is totally ignorant about what we do with the data! The service will just handle processing the data with the help of the validators and of the repository. The code now is much more decoupled, easier to test and to extend and we have respected **Single Responsability principle**.

That's it folks, stay tuned for new articles!

If you liked this article: <a href="https://twitter.com/JacopoBeschi" class="twitter-follow-button" data-show-count="false" data-lang="en">Follow me</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
