---
layout: post
title: 'Testing for custom Rails validators with Rspec and metaprogramming'
date: 2015-04-25 09:45:00
categories: ['metaprogramming',ruby on rails',testing']
---
Hello guys, some days ago I've made a custom validator for Rails and I wanted to test that it was used correctly in my model (which uses ActiveModel::Model). 
As a brief preface you have to know that to test for the common Rails validators you can use the [shoulda matchers](https://github.com/thoughtbot/shoulda-matchers) library. 
<!-- more -->
But in my case what I've done is to unit test the validator (I won't discuss about that) and then I've made a custom matcher to verify that the given classes uses the validator correctly. In order to test for the validator presence in the model I've leveraged Ruby metaprogramming. Here is the code where the custom validator is used:

	Class MyModel 
		include ActiveModel::Model
		
		validates_with MyValidator, attributes: :urr

And here is the custom matcher code: 
	
	 RSpec::Matchers.define :have_my_validator do |attr_name|
      # Check for all the callback that have MyValidator on the given attribute attr_name
      match do |actual|
        validator = actual._validate_callbacks.select {|callback|
          callback.filter.attributes == [attr_name.to_sym] &&
              callback.filter.class == MyValidator
        }
        expect(validator.size).to be > 0
      end
    end
	
What the matcher does is to:

1. Fetch the list of all the validation used in the model
2. Search for a validator fo MyValidator class and that is applied on a given attribute name
3. If any is found the test passes otherwise it fails.

You can use the validator as following:
	      expect(object).to have_my_validator(:urr)
		  
You can also be more DRY and extract the class name as a parameter and then use it to match any kind of validator.

That's all for now. Happy coding!



