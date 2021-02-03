---
layout: post
title: 'SOLID Design principles and Php: Liskov substitution'
date: 2014-02-10 19:52:00
categories: ['design pattern','solid']
---
Hello everybody, today we talk about the third letter (L) of **SOLID** principles: Liskov substitution. This principle has a mathematical definition pretty hard to understand, but in practise it says: every time you create a subclass of a superclass that subclass should be substitutable in every place where the original class took place. Let's dig in with an example. Imagine we create a player class. 
    <!-- more -->
```php
Class player
{
	public function play($file)
	{
		// play the file...
	}
	
}

Class mp3player
{
	public function play($file)
	{
		if(pathinfo($file, PATHINFO_EXTENSION) != "mp3")
			throw new InvalidArgumentException; // here we violate LSP
	
		// play the file...
	}
}
```

What we do here in our concrete player is to check for the extension and throw an exception if the file extension is not correct; that **violates** the Liskov substutution principle! In fact here we had a greater precondition than we defined in the superclass. This code cannot be substituted with the original one  because we may throw an exception; in the old implementation we didn't know about that exception so we didn't handle that, this will land in corrupted code break!
Let's do another example, imagine we create a suite of classes to fetch images:

```php
interface FetchImageInterface
{
	/**
	 * Fetches images from directory
	 * @param String $directory
	 * @return array $images
	 */
	public function fetch($directory);
}
```

Now we create an implementation: jpgfetcher.

```php
class JpegFetcher implements FetcherImageInterface
{
/**
* {@inheritdoc}
*/
public function fetch($directory)
{
		$images = [];

		if ($handle = opendir($directory)) {
		   /* Questa è la maniera corretta di eseguire un loop all'interno di una directory. */
		   while (false !== ($file = readdir($handle))) { 
			  $images[] = $file;
		   }
		
		   closedir($handle); 
	   }	
		
		return (count($images) > 1) ? $images : $images[0]; // here we violate LSP
	}
}
```

The problem here is that we check for the lenght of the data and we return an array or an item depending on it's size, but the client class expects an array not an item! That will create code breakage and violates LSP again! So to conclude this short article the interface is a contract, respect the contract and program the interface, if you follow that you will not violate LSP principle! Keep in mind php is not a strong typed language so you can't force implementation return value, but you can put the expected return values in the comment (as the example above **FetcherImageInterface**).
Stay tuned for the followup: **Interface Segregation**!
