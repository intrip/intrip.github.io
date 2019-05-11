---
layout: post
title: 'Coffeescript Model class with attr_accessor rails alike'
date: 2015-02-21 14:39:00
categories: ['coffeescript']
---
Nowadays I've been toying around with the fabolous coffeescript language and I've created a basic model class. <br/>
This class allow you to use attr_accessor method as you can do in Ruby.
If you don't know what attr_accessor is you can take a look here: [Ruby attr_accessor](http://ruby-doc.org/core-2.2.0/Module.html#method-i-attr_accessor).<br/> 
Briefly what attr_accessor does is to let you access object attributes in "object.attribute" form (which in javascript is built in) but more importantly let you add a constrain on read/write permission of that attribute!
In fact if you want the attribute to be readonly you need to use the "attr_reader" method, in the opposite case you need to use the "attr_writer" method. If you don't want to add any constraint you can use the "attr_accessor". 
<!-- more -->

Here is the code of the model:

	# this creates a root namespace that works with browser or node.js
	root = exports ? this
	#uppercase the first letter	
	root.namespace.ucFirst = (field) ->
		field.charAt(0).toUpperCase() + string.slice(1);
	
	root.namespace.Model = class Model
	  get: (field) ->
		# call getter if exists
		getter = "get#{root.namespace.ucFirst(field)}"
		return this[getter]() if (typeof this[getter] == "function")
		@attributes[field]
	
	  set: (field, value) ->
		# call setter if exists
		setter = "set#{root.namespace.ucFirst(field)}"
		return this[setter](value) if (typeof this[setter] == "function")
		@attributes[field]=value
	
	  defineAttribute: (field, type) ->
		@attributes ||= {}
		prop = {}
		prop[field] = {}
		prop[field].get = () -> @get(field, originalGetter) unless type == "writer"
		prop[field].set = (value) -> @set(field, value) unless type == "reader"
		Object.defineProperties(@ , prop)
	
	  attr_accessor: (field) ->
		@defineAttribute(field, "all")
	
	  attr_reader: (field) ->
		@defineAttribute(field, "reader")
	
	  attr_writer: (field) ->
		@defineAttribute(field, "writer")

What this code does is to create the methods: "attr_writer, attr_reader, attr_accessor". In order to use this model you need to inherit from him in your class with "extends root.namespace.Model". 
Here is an example of usage:

	class Test extends root.namespace.Model
		constructor: () ->
			@attr_reader "readonly"
			@attr_writer "writeonly"
			@attr_accessor "accessor"
			
		getTest: ->
			"test"
	
	test = new Test
	# write the attribute but cannot read from him
	test.writeonly = "write"
	# can read from outside but cannot write	
	console.log test.readonly	
	# can read and write data
	test.accessor = "writable and readable"
	console.log test.accessor
	#if you have a get"AttributeName" method or set"AttributeName" method it gets called instead of fetching the attribute
	console.log test.test 	# writes "test"
	
That's all forks. If you have any question or comment feel free to use the disquis form below.
Enjoy.
	

	