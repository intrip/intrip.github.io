---
layout: post
title: 'Javascript multiple inheritance with ES5 and AngularJs'
date: 2016-03-31 12:55:00
categories: ['design pattern','javascript']
---
In this article I'll show you how you can use multiple inheritance(trait) with Javascript EcmaScript 5 and AngularJS 1.0.
AngularJS offer you a method: _angular.extend_ that allow you to extend any object with the values and methods of other objects.
In this article I show you how you can create a Dog. Dog is an animal but is also a mammal, for this reason a Dog needs to extend animal and also Mammal classes.
Below is the code to create a Dog:

<!-- more -->

	(function(){
	app.Animal = function(){};
	app.Animal.prototype = {
		animal: function(){
			return "Hello i am an animal";
		}
	};

	app.Mammal = function(){};
	app.Mammal.prototype = {
		mammal: function(){
			return "I am a mammal";
		}
	};

	app.Dog = function(){};
	app.Dog.prototype = {
		dog: function () {
			return "I am a dog";
		}
	};
	// dog is an animal but also a mammal
	angular.extend(app.Dog.prototype, app.Animal.prototype, app.Mammal.prototype);
	// wrap to not pollute the global namespace
	})(window.app || (window.app ={}));

	var dog = new app.Dog();
	
	// Hello I am an animal
	console.info(dog.animal());
	// Hello I am a mammal
	console.info(dog.mammal());
	// Hello I am a dog
	console.info(dog.dog());
	
As you can see you can extend multiple classes (Mammal and Animal) from the Dog class.
Here it is! Now you know that you can easily implement traits in Javascript using angular.extend() method.
Happy coding!