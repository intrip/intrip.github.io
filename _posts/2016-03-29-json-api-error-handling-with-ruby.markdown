---
layout: post
title: 'JSON API error handling with ruby'
date: 2016-03-29 07:33:00
categories: ['rest',ruby',ruby on rails']
---
Hello folks, after being inactive for a while I am finally back!  
This post is about a technique that I found useful for general error handling with REST API and ruby on rails, but the concept works for any programming language/framework.
Most of the time programmers handles api errors without a general pattern, that's bad because it's obvious that is more error prone, by using a general pattern you can also do some interestic automatic operations such as error logging and messaging to a monitoring service. 
<!-- more -->
The base of the approach that i've choose is handling errors with Exceptions(that's what they are made for actually). What we do is create a general exception handler that given an exception name and data will return a particular error response as json depending on which kind of exception was thrown. 
The basic idea is to configure the error handler with and exception name associated to a configuration hash.
In order to make things smoother and be as DRY as possible I've made a ruby gem and pushed it to rubygems, if you are interested you can [take a look at the docs here](https://github.com/intrip/jsonapi_errors)

