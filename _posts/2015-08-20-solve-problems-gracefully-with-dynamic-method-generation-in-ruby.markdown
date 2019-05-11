---
layout: post
title: 'Solve problems gracefully with dynamic method generation in ruby'
date: 2015-08-20 19:46:00
categories: ['metaprogramming',rspec',ruby']
---
Days ago i was writing an Rspec macro to gracefully handle authenticated api via a token. At the start i begun creating a couple of methods, each for every Rest verb: 
	module RequestMacros
	  def get_authorized(uri, user)
		get uri, nil, {'X-Api-Token' => user.api_token}
	  end
	
	  def post_authorized(uri, data, user, headers = {})
		post uri, data, headers.merge({'X-Api-Token' => user.api_token})
	  end
<!-- more -->

	  def patch_authorized(uri, data, user, headers = {})
		patch uri, data, headers.merge({'X-Api-Token' => user.api_token})
	  end
	
	  def put_authorized(uri, data, user, headers = {})
		put uri, data, headers.merge({'X-Api-Token' => user.api_token})
	  end
	
	  def delete_authorized(uri, user)
		delete uri, nil, {'X-Api-Token' => user.api_token}
	  end
	end
	
As you can see from the code above there is some code duplication, in fact the authorized methods get,delete and post,patch,puth shares the same code besides the fact that the method called is different, for example post_authorized calls post etc. In a general OOP approach we could just extract the logic into a shared method that accepts the verb name to be called and then makes a call with that name. But this time i decided to leverage some ruby metaprogramming technique. In the code below we dynamically create in pair the get,delete and post,patch,put methods; in fact the only thing that changes is the method name #{m}. Here is the code:

	module RequestMacros
	  %w(get delete).each do |m|
		class_eval <<-eoc
		  def #{m}_authorized(uri, user)
			  #{m} uri, nil, {'X-Api-Token' => user.api_token}
		  end
		eoc
	  end
	
	  %w(post patch put).each do |m|
		class_eval <<-eoc
		  def #{m}_authorized(uri, data, user, headers = {})
		  	#{m} uri, data, headers.merge({'X-Api-Token' => user.api_token})
		  end
		eoc
	  end
	end
	
What we just did is with every verb make a method verb_authorized that calls verb, we couldn't do that without ruby metaprogramming tools! Leveraging metaprogramming allow us to build readable and compact code in a very fascinating way. That's all for today, happy coding!