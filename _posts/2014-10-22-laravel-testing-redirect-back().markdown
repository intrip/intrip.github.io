---
layout: post
title: 'Laravel Testing Redirect::back()'
date: 2014-10-22 22:38:00
categories: ['laravel',testing']
---
Hello guys, sometimes in your functional test you need to test a redirect, this is pretty easy to test except for the Laravel Redirect::back() method. I've found out that this is hard to test and the only solution to solve the problem is to fake a HTTP_REFERRER value. 
<!-- more -->
But keep in mind that in general the best approach is to don't use many Redirect::back() and instead use the redirect to a certain route, in fact is much more clearer from the test perspective to assert a redirect to a given route instead of a fake one.
Anyways here's the solution:

	<?php
	
	public function testRedirect(){
	
	$fake_url = "/fake";
	$this->call('GET', '/url, [], [], ['HTTP_REFERER' => $fake_url]);
	
	$this->assertRedirectedTo($fake_url);
	}
	
Enjoy!