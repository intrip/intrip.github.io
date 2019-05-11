---
layout: post
title: 'Strong Typing vs Duck Typing PHP, C#, Ruby'
date: 2014-12-27 17:17:00
categories: ['programming rules']
---
If you have heard of strong and weak typing but doesn't know the main difference and advantages/disadvantages of both the paradigms in this article I'll try to help you having a better undestanding of the overall concept.
The first thing you need to understand is what types are. When you save some data in the memory you can associate to that space of memory a data-type, by associating a type you can have different behavior when manipulating that piece of data. In an object orientet language generally there are two main categories of data:

<!-- more -->

1) simple data: such as string, int, float;
2) object data: the type of the object
In non object oriented languages you only use simple data. 
Here is an example in c# that show how data types influence behavior when manipulating data:

	 		// a string contaning text data
            string text = "some text";
            // output: some text and some more text
            Console.WriteLine(text + " and some more text");
            // a int number
            int number1 = 200;
            // here i use the + operator on a int and a string, the compiler automatically convert the number into a string
            // in this case the + operator is the string operator and concatenates the strings
            string number2 = number1 + "Some text";
            // output: 200Some text
            Console.WriteLine(number2);
            // here the + operator is the sum operator and calculate it's sum
            int number3 = number1 + 10;
            // output: 210
            Console.WriteLine(number3);
			
Data type is a way to associate different behavior to different values. 
In a strong typed language when you pass a variable to a method (or more generally a function) you need to tell the receiver the type of that variable: if  it's an object his class, if it's a simple type his data type. As i said the compiler need to know the type of that data in order to manipulate it. With duck typed languages that restriction is not needed, you can pass variable containing any type of data to the method and the interpreter will handle that data depending on his value. How can you achive that? By using certain special rules that differ for each language called "transoformation rules"; depending on the value of the variables the interpreter will infer his type and do different operations do the data. Here is an example in php:

	// as you can see we don't say that text is a string
	$text = "text";
	// output: text10
	echo $text . 10;
	
In this example the interpreter will use the number 10 as a text and appends that to the "text" string.
By using a duck typed language also appear the concept of a falsy/truthy value; they rappresent values that are interpreted as boolean false/true in an if statement. While in strong typed language you can only put a boolean expression in an if statement in a duck typed language you can put anything and the interpreter will use the result as a boolean value. For example in php a truthy is: booelan, true and anything except 0 null and false. In ruby instead a truthy is anything except false or nil.
Here is an example:
	ruby: 
	truthy = 10
	# output: this is truthy
	puts "this is truthy" if truthy

	php
	$truthy = "lalalal";
	if($truthy)
		echo "this is a truthy"

	c#
	int a = 10;
	// you cannot do that in  c# will throw a compiler error!
	if(a)
		Console.write("This is not possible");

Now that you know what is a truthy and a falsy and the main difference between strong and duck typed programming I'll show you the main advantages/disadvantages.

With a strong typed language:
	1. better performance
	2. with type check at compile time you have less programming errors

The better performance is something completely true, in fact the strong typed language are compiled languages and as the compiler knows the various data type it can do some better optimization; so if you need high performance you may have to go for a strong typed language (unless you need to scale it and in that case you may go with a functional language instead such as clojure or erlang). 
The point 2 is true aswell but you need to be aware that runtime error will still happen, so you are have still a free room for mistakes and the error that you can find at compile-time are small and easy to fix, while runtime errors are the most dangerous ones!

With a duck typed language instead:
	1. After some experience you find the code less verbose and more easy to understand
	2. Easy metaprogrammming
	3. Development is faster without the make/compile time
	
In fact i find myself an easier time understanding duck typed language and also can write more behavior with less code because or the language being less verbose in general (especially with ruby). Development time is aswell faster because of no compile time.
About metaprogramming it's a good feature if it's used properly but can land to disaster if misused. A good example of metaprogramming is how Rails Active record creates automatically the method to access his attributes at runtime depending on your database schema.
The last but not least important thing are interfaces: interfaces are created for strong typed language and their purpose is to try to detach the dependency method->class by showing the messages that they transfer; by using interfaces you can swap the implementation and be sure that the message exchanged between objects is correct. In a duck typed language you don't need interfaces, that leto you have less boilerplate and more flexible code but you have to be aware of finding the code dependency yourself, so you pay the bill for more flexibility you have to be more careful! Keep in mind testing in duck typed language is even more needed because of that flexibility. Ruby community for example have focused a lot on testing in order to help keeping the code clean and easy to extend. 
Thats the last post of 2014 so Happy new year everybody!


	
