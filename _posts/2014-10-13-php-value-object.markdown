---
layout: post
title: 'PHP Value Object'
date: 2014-10-13 20:16:00
categories: ['design pattern']
---
Let's talk about, Value objects. The first thing to undersdand is why and when they are needed. Generally when you save some data you pair with a variable/attribute a value. In every programming language there are many type of values, for example strings,numbers and so on; imagine now that you need to save the number of apples and user have bought:

	<?php 
	$total_apples = 20;
	<!-- more -->
	
What we did here was to set on a variable the number of our $total_apples: "20". This code is fine but in certain cases what we need is to associate a behavior with that simple number (or any other basic value). Imagine we want to save a monetary value:

	<?php
	$payment = 20.20;

Here we will encounter many problems, the first one is the currency: in which currency we are working? how can we switch between currencies? How can we add value to the payment? What we have to do to handle the problem is to add many helper classes that manipulate that number for our needs, but that's **not** good. The right solution to this kind of problems is to create a Value Object: "an object that rappresent a value and allow easy manipulation of his content". When a value object is created is immutable and you can do operation on his value trough the value object only.
How can you create a value object? Here is a minimistic example for the money problem:

	<?php 
	Class Money {
		public function __construct($amount, $currency)
		{
			$this->amount = $amount;
        	$this->currency = $currency;
		}
	}
	
	  public function getCurrency()
	  {
		  return $this->currency;
	  }
  
	  public function getAmount()
	  {
		  return $this->amount;
	  }
	  
	  public function compare(Money $other)
	  {
		  if($this->currency != $other->getCurrency())
		  {
			  throw new InvalidArgumentException("You cannot compare money of different currency");
		  }
		  if ($this->amount < $other->amount) {
			  return -1;
		  } elseif ($this->amount == $other->amount) {
			  return 0;
		  } else {
			  return 1;
		  }
	  }
	  
	 public function add(Money $addend)
     {
         if($this->currency != $other->getCurrency())
		  {
			  throw new InvalidArgumentException("You cannot compare money of different currency");
		  }

        return new self($this->amount + $addend->amount, $this->currency);
     }
	
	}
	
This is a really minimistic implementation but the most important concept is that a with this object we can compare money and do some operations with them easilly and the value stored in the object is handled but the value object class. As you can see the value object is immutable: in fact every time we need to change his value we create a new value object(add method). This is really important to avoid [aliasing problems](http://c2.com/cgi/wiki?ValueObjectsCanBeMutable). 
If you want to see a fully implemented value object class for Money take alook here: [PHP Value Object implementation] (https://github.com/mathiasverraes/money/blob/master/lib/Money/Money.php)   
Stay tuned and enjoy!  
