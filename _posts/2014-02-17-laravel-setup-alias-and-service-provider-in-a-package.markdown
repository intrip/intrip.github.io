---
layout: post
title: 'Laravel setup alias and service provider in a package'
date: 2014-02-17 22:12:00
categories: ['laravel']
---
Hello folks. This article is just a **brief** explanation on how you can create new run-time alias and load service provider within your laravel package.
If you want to load other service provider from the package you have to use this command inside the register method if your **service provider**:
<!-- more -->


	public function register()
	{
			....
			// load custom service providers
	        $this->app->register('Service\Provider\Path');
	}

If you want to load custom aliases you have to use this command inside the register method if your **service provider**:


	public function register()
	{
		....
		// register aliases
        AliasLoader::getInstance()->alias("Alias",'Full\Class\Path');
	}
	
I told you this is a **brief** article  :-) . That's it for today! Happy coding!