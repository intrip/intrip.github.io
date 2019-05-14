---
layout: post
title: 'PHP: why and when static is evil'
date: 2014-11-09 22:35:00
categories: ['design pattern','programming rules']
---
Hello guys, many pepole asked me in various situation if they should use static in their code, for this reason i decided to briefly explain why static is generally a bad choiceh and in which cases you can use it.
<!-- more -->
Before explaining you when and when not to use static you need to know the difference between static and istance variables.
The difference is that with a static variable his value will remain the same for the full execution of the process, anytime you access it. With an instance variable instead that values is binded to the instance of the class (the object!) and can be different for every new istance of the class. Let's make and example:

	<?php 
		Class A
		{
			public static $static_var;
			public $instance_var;
		}

		$a1 = new A;
		$a1::$static_var = "static!";
		$a1->instance_var = "a1";
		$a2 = new A;
		$a2->instance_var = "a2";
		
		echo $a1->instance_var;
		echo $a2->instance_var;
		echo $a1::$static_var;
	    echo $a1::$static_var
		
		// here's the output
		"a1"
		"a2"
		"static!"
		"static!"
		
So as you can see the static value is binded to the class and not the instance. So now i'm goint to point the problems of static variables. 
One big problem is that static state is hard to test! In fact whant you make your unit tests you cannot change a static part of the class and stub it, because by doing that you change is use in all the process, and in all the subsequent tests that will be run in the SUT(Suite under test).
The second reason is that you cannot compose object and handle dependency in a dynamic way (everyting is global and doesn't change) and because OOP is the best tool to manage software depencency you basically loose all the advantages of OOP. 
But now you may say: "What are static state made for?" well in fact there is one case where you can use static variable and the answer is quite obvious, when you need a global state in all the application process. For instance if you want to set the user information available globally in the application (assuming you won't change them only for a part of the software). Also for all the laravel developers keep in mind that Facades are not static they are instance object binded with the IOC container!
I'd like to go deeper in the details but i'm out of time for now.

Have a nice time and be proud of yourself: you're coders!
