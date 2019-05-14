---
layout: post
title: 'Devise remote authentication with rails 4.2'
date: 2015-04-08 21:19:00
categories: ['devise','ruby','ruby on rails']
---
Hello guys, I've been trying to make remote authentication working with devise and i found this useful post: [devise remote authentication](http://4trabes.com/2012/10/31/remote-authentication-with-devise/). The problem is that the post example wasn't working correctly with new devise versions (3.4.x); 
In this post I'll explain you the changes that you need to do to make it work with devise 3.4.
<!-- more -->
Note: Before reading the following part read the other article.
The problem are the changes to Devise Authenticatable class regarding the serialization methods. In order to make it work you need to use the following code in your RemoteAuthenticatable Strategy:

	module Devise
  		module Models
    		module RemoteAuthenticatable

  	        module ClassMethods

		   def serialize_from_session(username, password)
			 resource = User.new
			 resource.username = username
			 resource.password = password
			 resource
		   end

		   def serialize_into_session(resource)
			 #IMP you can only pass two params, no more because of this code :
		 	 # devise.rb.466      args = key[-2, 2]
	 		 [resource.username, resource.password]
		   end
		 end
  
	  	 end
		end
	end
	
What happens is that devise passes the result of serialize_into_session to serialize_from_session but it fetches only the last 2 items of the return value: "args = key[-2,2]".
for this reason you need to pass the needed information in a two item array in order to make this work (if you need more data replace the items with an hash). In this example we use the username to identify in a unique way the user and then we create an user with the given username when we deserialize the item (you can also have a custom method that fetches the model form a temporary memory data or a model saved in the database).  
I hope you found this article useful! If you have any question feel free to ask me (will help to increase the quality of the post).
Happy coding and enjoy ruby!
