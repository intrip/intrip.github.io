---
layout: post
title: 'laravel form handling with event-driven code'
date: 2014-01-07 21:54:00
categories: ['laravel']
---
Hello guys, how many times you have created a form that has to handle many complicated tasks? If the answer is "**many**" i have one way for handling that in a very fashioned way based on **events** using laravel framework 4+. The proof of concept in OOP is the **"Chain of responsabiity"** design pattern. Imagine now that when we process a form we want to execute a list of action consequently, in the case one of them would fail we will return an error, otherwise we return a success message. <!-- more -->As an example i will show you how to create a simple contact form. What that form should handle? 
<ol>
<li>Validate user data</li>
<li>Save user data into db</li>
<li>Send email to the contact mail</li>
<li>Eventually send a notification mail to the user</li>
<li> Some other stuff</li>
</ol>

Keep in mind ther every of thoose steps may land in failure: for example validation or the server couldn't send the email.
let's keep this as simple as possible to focus on the base concept.
Let's start by creating a form, (for that i use the [way/form package](https://packagist.org/packages/way/form) ).
Create a new file view called form1.blade.php in app/views folder.
Fill it with the given code:

	{% raw %}{{Form::open(array('url' => URL::action("HomeController@postContact"), 'method' => 'post') )}} {% endraw %}
	{% raw %}{{FormField::name(array('label' => "Name*") )}} {% endraw %}
	<span class="text-danger">{% raw %}{{$errors->first('name')}} {% endraw %}</span>
	{% raw %}{{FormField::email(array('label' => 'Email*') )}} {% endraw %}
	<span class="text-danger">{% raw %}{{$errors->first('email')}} {% endraw %}</span>
	{% raw %}{{FormField::body(array('label' => 'Message*' ))}} {% endraw %}
	<span class="text-danger">{% raw %}{{$errors->first('body')}} {% endraw %}</span>
	{% raw %}{{Form::submit('Send message', array("class"=>"btn btn-large btn-primary"))}} {% endraw %}
	{% raw %}{{Form::close()}} {% endraw %}

This will create a simple form looking like this:

![file]({{ "/assets/img/image-1389133286160.png" | relative_url }})

At this point we need to create the controller actions(one for get and one for post) and then register them in the route files. Lets start creating them in the controller. Open the file "app/controllers/HomeController.php" and fill it with the given values:

```php
public function getContact()
{
            return View::make('form1');
}

public function postContact()
{
    	// todo 
    	// validate data
    	// save user data
    	// send emails
    	// some other stuff
    	// return to getContact with success or error
}
```
	
Now lets register the routes, open file app/routes.php and fill it with this code:

```php
Route::post('/contact','HomeController@postContact');
Route::get('/contact','HomeController@getContact');
```

As you can see what we did until now is a common approach to create a form with laravel, in the postContact is where we usualy handle all the stuff related to the form. As you imagine putting them right inside the post method may be working when you do simple stuff but as the code is growing you will find a lot of issues. Here comes the fun part: **form handling with event-driven code**.

Let's change the post method in this way:

```php
public function postContact()
{
    // grab the data
    $input = Input::all();
    // create empty messages
    $messages = new Illuminate\Support\MessageBag();

    // if all events execute successfully
    if (Event::fire('post.submit', array($input, $messages)) )
    {
        // return to the form with success messages
        return Redirect::action('HomeController@getContact')->with('message', $messages);
    }
    else
    {
        // return to the form with errors
        return Redirect::action('HomeController@getContact')->with('errors', $messages)->withInput();
    }

}
```

Instead of executing one action after another what we do is to throw an event (in this case post.submit); when an event is thrown it can be catched by events listener, thoose listener will try to execute some operations: if they execute them successfully they will return true, otherwise they will set an error message and return false. In the case all the events listening execute with success the controller will redirect to getContact with success, otherwise it will redirect to getContact with error messages. 
At this point come naturally two questions: where are binded thoose event listener and what action you associate with them?
The first answer is: you could put them everywhere, but a good position for them could be in the constructor of the controller; if you prefer you can also put them in a serviceProvider (in the boot method). In this example i'll bind them in the controller construct like that:
  
```php
public function __construct()
{
    // validate data
    Event::listen('post.submit', "EventHandling\\ValidateForm@run",1);
    // save user data
    Event::listen('post.submit', "EventHandling\\SaveData@run",0);
    // add more events for...
    // send emails
    // some other stuff

}
```

As you can se some other action are just written as comment, that's because this article is mainly a proof of concept and you should implement them as your needs. Now lets see how is scructured a base event handler, for example: "EventHandling\\ValidateForm".

```php
<?php namespace EventHandling;

class ValidateForm
{
 public function run($input, $messages)
  {
  // validate the code
  // or do a bunch of stuff
  // if something goes wrong
  // set the message: in this case error message
  $messages->add("email", "email error");
  // stop the other events
  return false;

  // otherwise
  return true;
  }
}
```
	
This method is also a dummy method but is enough to show the concept, what we do here is get the form input and the messages array. Inside the run method we just do some actions(for example validate the data) and then in case of success return true, otherwhise we set the error message and return false. In the case we return false the propagation to the other methods it's stopped. In this way we can execute many action in sequence. In case you write the database with your event handler you should start a transaction before firing the "post.submit" in the postContact() method of the controller and then , otherwise rollback to the previous state.

This way of handling form is also good for testabiliby. In fact you can swap the event listener with a mock and test the controller. Then you can test every EventHandler in isolation and have a complete testability for the form.
Here is an example on how to do a simple test on the controller:

```php
/**
 * Simple test to check form redirect.
 *
 * @return void
 */
public function testSubmitPost()
{
  Event::shouldReceive('listen','listen,','fire');

  $this->call('POST', '/contact');

  $this->assertRedirectedToAction('HomeController@getContact');
}
```

As you can see with  "Event::shouldReceive('listen','listen,','fire')" we simply mock the events, at this point if you need you can swap the implementations with your own mock.
Thats' it for now folks! If you have some question write a comment below and i'll be happy to answer your question! And remember to <a href="https://twitter.com/JacopoBeschi" class="twitter-follow-button" data-show-count="false" data-lang="en"> Follow me</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
