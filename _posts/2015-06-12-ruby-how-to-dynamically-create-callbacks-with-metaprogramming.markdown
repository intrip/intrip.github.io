---
layout: post
title: 'Ruby: Dynamically create callbacks with metaprogramming'
date: 2015-06-12 18:35:00
categories: ['metaprogramming',ruby',ruby on rails']
---
Hello guys, in this post I'll explain you how you can handle callbacks with metaprogramming on ruby on rails. But before going deeper into detail you should ask me the reason of that: why shall you use callbacks instead of using general oop techniques? 
For example in a classic oop design given that you have:

	Class X
	   def method_x(*args)
	 	  #do something
	   end
  	end
<!-- more -->
if you want to do something after calling method x you can easilly override the method in a module like this:

	module X
		def method_x(*args)
			super(*args)
			# do something more
		end
	end

And then include the module X in your class X.
So why should you handle that with metaprogramming? As first in certain situations you cannot override the method using a classical oop approach, for example when you are already leveraging some metaprogramming to dynamically create a method_x inside an included module like this:

	module Y
		def self.included(base)
			base.instance_eval do
				def method_x(*args)
					# do something
				end
			end
		end
	 end
	
In that case the method_x is dynamically created and you cannot override it easilly and use the "super" classical oop, therefore you need to handle that with a callback. Callbacks also allow you to handle that in a more fashioned and readable way. 	
Let me show you how can you do an after_method_x callback:
Firs of all include the Callbacks method i've created:

	module Callbacks
  		extend ActiveSupport::Concern

	  module ClassMethods
		  def do_after(method)
			guid = SecureRandom.uuid
			define_method("#{guid}") do |*args|
			  yield self, __send__("#{guid}_#{method}", *args), *args
			end
			alias_method "#{guid}_#{method}", method
			alias_method enum, "#{guid}"
		  end
		end
	 end
	 
When you use the method do_after it creates a new method using guid to ensure uniqueness, that method yields self allowing to pass a custom block, and then calls the original method aliased as #{guid}_#{method}.
To use that in your class you coud do like this:

	Class X
	  	include Callbacks
		do_after(:method_x) do |klass, result, *args|
			# do wathever you like here in the block
		end
	 end

And we have handled a do_after leveraging metaprogramming. I let you imagine the other hooks by yourself.
Have fun and Happy coding!
