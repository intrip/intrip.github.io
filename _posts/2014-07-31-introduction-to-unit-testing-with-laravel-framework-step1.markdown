---
layout: post
title: 'Introduction to Unit testing with Laravel framework: step1'
date: 2014-07-31 13:17:00
categories: ['laravel',testing']
---
When i first came into programming i didn't even know what self tested code was and how much it's important for a developer. This article is for developers that want to start unit testing with laravel framework or php in general.
Before going into details i'd like to explain you briefly what is unit testing and automated code tests. Automated code tests are programs that verify automatically that your application works as expected.
Why self tested code is important? For multiple reasons, the most important is that removes the "fear of change" and for this reason help you refactoring your code and improving it.
<!-- more -->
There are various kind of automated tests:

1. Acceptance test
2. Integration test
3. **Unit test**

In this article i'll start teaching you Unit tests. Unit test are the part of automated test that test the internal part of your code, in an "unit" prospective.
What that means? That means that an unit test should test only a unit/part of your code, in an object oriented language that can be associated to a single class. Allright so unit test tests a single class? What if my class need the support of other neighbors classes? What if my class touches the database?
In fact you have two options: 

1. Test you class in isolation and Mock the rest (Mockist way)
2. Also touch external part of your unit on your tests

Evey approach have his advantage and disadvantage but that's a more advanced topic.
There are 2 main tools for unit testing in php: phpunit and phpspec. In this article i explain you phpunit because it's the most common tool used in this case.
To start with unit test you need to [install phpunit](http://phpunit.de/getting-started.html)
Now you need to write your first test class. So where do i put my test class?
As laravel philosophy you could put them anywhere you want, but as my advice you should put them in a tests directory and Laravel already made this for you! Its the _app/tests/_ foder.
So now let's create the test class:
	
	<?php
	class ExampleTest extends \PHPUnit_Framework_TestCase{
	
		/*
		 * @test
		*/
		public function itWorks()
		{
			$this->assertTrue(true);
		}
	}
	
As you can see our test class extends _\PHPUnit_Framework_TestCase_. I've created a dummy test there, as you can see the test has a docblock comment @test, this comment is needed in order to understand that this function is a test, if you prefer you could also name your method with a prefix **tests** instead. 
In the test function i've created and assert, this code in fact just verify that true, is true; obviously this is just for te sake of showing you how to write a test. If you run phpunit you will see that your test passes. 
Every unit test should be separated in three parts:
1. Arrange: in this part you prepare the system for your test, for example if you need to find a record in the db you create a fake record in it.
2. Act: we run the function that needs to be tested, in the case of the query we just run the query
3. Assert: in this part we just verify that our action was landed succesfully, for instance we could check that the record was found.
I'll talk you more about this in the following article.
Before closing the day i'd like to point you one more thing: our first class is not integrating with laravel framework and for this reason we can't call any of his fancy functions. If you want to use laravel within your test class you need to extend laravel TestCase class. 

	<?php 
	class ExampleTest extends \Illuminate\Foundation\Testing\TestCase{
	
		/*
		 * @test
		*/
		public function itWorks()
		{
			// here you can use laravel framework!
			$this->assertTrue(true);
		}
	}
	
Allright, that's enough for today; in the next article i'll explain you how to setup your test, the AAA rule and we'll go with a real example.
But for now, have a nice day!