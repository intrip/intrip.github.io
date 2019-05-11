---
layout: post
title: 'Different caching strategies for Rails.cache and ActionController::Caching'
date: 2017-06-19 15:10:00
categories: ['ruby on rails']
---
If you need to use different caching strategies for your Rails.cache and your ActionController::Cache (used for fragment caching) just put the following in your `config/environments/env.rb` file:

```
     config.action_controller.perform_caching = true
     # this is used for your Fragment cache
     config.action_controller.cache_store = :file_store, 'action_controller_tore_path'
     # this is used for Rails.cache
     config.cache_store = :file_store, 'cache_store_path'
```