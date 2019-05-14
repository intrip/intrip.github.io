---
layout: post
title: '4 simple rules for better writing method and variables'
date: 2014-05-14 21:37:00
categories: ['design pattern','programming rules']
---
Programming is an art and programmers are artists. As any artist anyone has a different approach for crafting, besides that there are some common rules that would help you writing better software. In fact is really important to write software not just that "works" but also that is easy to read and unterstand. In fact Brian Kerninghan (C creator) has written: <br/>
<!-- more -->
"*Good programming is not learned from generalities, but by seeing how significant programs can be made clean, easy to read, easy to maintain and modify, human-engineered, efficient, and reliable, by the application of common sense and good programming practices. Careful study and imitation of good programs leads to better writing.*" <br/>
You may now say that for you writing software easy to read is not that important, but in fact you are wrong.
<br/>
If you read software hard to understand the next time you read that code to make some changes you will have an hard time and spend more time than intended. Writing unreadable code is even worst if you work in a team: imagine if your team partner need to edit some code you wrote days ago in a "bad way", how you think he would feel? How many times you to saw some rot code and said: "what the hell is that?" and how you think your life as programmer would be if that won't happen to you anymore? <br/>
In fact writing understandable software is really important and i think that don't respecting this rule is **unprofessional**.  <br/>
So now i think you agree with my opinion, but now comes the hard part: how can you write code easy to understand? The answer is not simple at all, in fact you need a lot of practise and experience to achieve that goal. But the title of this post is: "4 simple rules for writing method and variables", so now we will focus on simple rules for writing better methods and variables. 

When i started programming i was using few methods and my methods were really long, after a while i realized that this is not a good approach: as time pass the code will come more complex and hard to understand. <br/>
A good way to make code more readable is to extract every set of istruction (that can be extracted) into a method; you may ask now: "Ok i got it but when i should stop extracting?". You should keep extracting your code until you can't extract anymore, Uncle Bob calls that method: "Extract till you drop!".  <br/>
This methods works really well and make your code more more readable **only and only** if you write good method names! A method name should describe fully his beavior, when you need to write a comment to explain what a method does you have already failed. In fact sometimes you really need to write comments, but try to be as much explanatory as you can using good methods and variable names.  
Now comes the second quesiton: how long my method names should be? This land to two answer that are 2 of the 4 rules that i was talking:<br/>
**1. Method names should be long when their scope is short<br/>
2. Method names should be short when their scope is long**<br/>
So why that? The answer is, if you have a public method used frequently outside of your class then you don't like a really long name, but if you use a method inside your class his scope is short and is really important to explain better his behavior without writing many useless comments. In fact the other problem with comments is that they get out of date really fast.<br/>
About variable names, for them the rule is the opposite of methods:<br/>
**
1. Variable names should be short when they have a short scope<br/>
2. Variable names should be long when they have a long scope<br/>
**
In fact variables with a short scope are easy to find so you don't need to write a super long name, instead variables with a longer scope are hard to find and the name would be better if it's more self explanatory.
I want to share with you a really simple example of what i've said. Imagine you have a code like this:<br/>

	Class example {
	....
	if(! $this->errors->isEmpty())
	{
		throw new Exception($this->errors->getMessage());
	}
	
The code checks for errors and then throws a new exception if find any. But now let's extract some code into methods (if you use an ide is really fast to do that with the refactoring techniques).

	Class example {
	....
	if(! $this->foundAnyErrors())
	{
		throw new Exception($this->getErrorMessages());
	}
	
	protected function foundAnyErrors()
	{
		return $this->errors->isEmpty();
	}
	
	protected function getErrorMessages()
	{
		return $this->errors->getMessage();
	}
	
Isn't the code here more readable? You may say: "hey, you have 3 methods now, you're code is slower!". In fact that is true, but in 99% of the cases that little overhead is worth it for the gain in code clarity and reusability. 
By extracting this logic to methods not only we made the code more readble but also we made id more reusable: we could use this methods anywhere in our class now!<br/>
So here we are, we talked about code readability, functions and method naming. We're done for now, if you have any question feel free to ask me and i'll be happy to answer you!
