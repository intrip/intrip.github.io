---
layout: post
title: 'Thinner Rails Model with the Finder Pattern'
date: 2017-03-20 09:17:00
categories: ['design pattern',ruby',ruby on rails']
---
Hello everybody, today I want to share with you a pattern learned from **gitlab**: the **finder** pattern.

Most of the time when you want to find an item based on a set of different conditions you do something like this:

	class Project
  		def issues_for_user_filtered_by(user, filter)
    		# A lot of logic not related to project model itself
  		end
	end

By doing that you end up having a lot of methods that does not really belong to the Model logic.
A better solution is through the **finder** pattern: 

	issues = IssuesFinder.new(project, user, filter).execute
	
What the finder does is to accept a set of parameters and return an `ActiveRecord::Associations::CollectionProxy` that you can use for further filtering/mapping operations.

You can find a complete example of a finder [following this link](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/app/finders/issuable_finder.rb)


