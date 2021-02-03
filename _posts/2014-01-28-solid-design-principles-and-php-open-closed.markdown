---
layout: post
title: 'SOLID Design principles and Php: Open closed'
date: 2014-01-28 19:59:00
categories: ['design pattern','solid']
---
In this article we talk about the O in SOLID principles: **Open closed**. The Open closed principle says that: a class should be open for extension but closed for modification, what that means? Well, in practise when you make a class you could expand it for adding new features but not modify it for changing his beahvior, instead you should separate the extensible behavior behind an interface and flip the dependencies. What that means? I'll drive into that with an example. Let's say we are writing a business application to handle building information in a certain country. Let's create a class to handle small apartments:

<!-- more -->
```php
Class SmallAparment extends Appartment
{
	protected $area;
	protected $zip;
	protected $address;
	protected $base_coefficent = 1.22;

	public function __construct($area, $zip, $address)
	{
		$this->area = $area;
		$this->zip = $zip;
		$this->address = $address
	}
	
	public function getArea()
	{
		return $this->area;
	}
}
```

Now imagine that we want to calculate taxes for small appartments, to do that we  create the "AppartmentTaxCalculator" class.

```php
class AppartmentTaxCalculator
{	
	public function calculateTax(array $apartments)
	{
		$total = 0;
		foreach($appartments as $appartment)
		{
			$total+= $apartment->getArea() * $appartment->base_coefficent;
	    }
		
		return $total;
	}
}
```
	
Allright, for now everything looks fine: we calculate the tax for each appartment and sum up all the taxes. Now imagine we want to calculate the tax of medium apartment aswell, in that case the formula would be **area * base_coefficent + 10**. How we could do that? Well, we can say: let's add and if statement and check for the istance of the class depending on that we do the calculation; how many time we used that solution? The code will look like this:

```php
class AppartmentTaxCalculator
{	
	public function calculateTax(array $apartments)
	{
		$total = 0;
		foreach($appartments as $appartment)
		{
			if(is_a($apartment, 'SmallApartment'))
				$total += $apartment->getArea() * $apartment->base_coefficent;
			else
				// here we are breaking open closed principle!!!
				$total += $apartment->getArea() * $apartment->base_coefficent + 10;
       }
	   
	   return $total;
	}
}
```

But doing like that we **BREAKED** the Open closed principle! At the state of the code right now maybie it's not a big deal, but imagine what will happen if we start to use 10 or more type of appartment classes: that if will become a **Big IF**, the code will start to get complicated and hard to handle.
But fortunatelly there is a way to fix that, what Uncle Bob said was: " you should separate the extensible behavior behind an interface and flip the dependencies". Here is how we can do that following the Open closed principle: we need to find the extensible behavior, in that case is the function "calculateTax", create and interface for that and swap the dependencies. Let's start by creating the interface:

```php
interface TaxCalculate
{
	/**
	* Calculate a tax for a single appartment
	* @param Appartment
	* @return Integer
	*/
	public function calculateTax();
}
```

Now we need to implement the interface in every type of Appartment Class, here is for example with the MediumAppartment:

```php
Class MediumAparment extends Appartment implements TaxCalculate
{
	protected $area;
	protected $zip;
	protected $address;
	protected $base_coefficent = 1.22;
	
	public function __construct($area, $zip, $address)
	{
		$this->area = $area;
		$this->zip = $zip;
		$this->address = $address
	}
	
	public function getArea()
	{
		return $this->area;
	}
	
	public function calculateTax()
	{
			return $this->area * $this->base_coefficent + 10; 
	}
}
```

And finally here is our **ApartmentTaxCalculator** class:

```php
class AppartmentTaxCalculator
{	
	public function calculateTax(array $apartments)
	{
		$total = 0;
		foreach($appartments as $appartment)
		{
			$total+=$appartment->calculateTax();
       }
	   return $total;
	}
}
```

Now we can add as many apartment classes we want, the calculator will do the same: the code is open for extension and closed for modification! Once again what we  was **Program the interface**. I will never stress that enough how much important is to use interfaces in your code!

That's it for today! Happy coding!
