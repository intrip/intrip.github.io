---
layout: post
title: 'How to effectively use composer artifacts'
date: 2014-04-29 20:53:00
categories: ['management']
---
Hello guys, some days ago i had to setup a private composer repository without using a VCS. After reading the original documentation i encountered some issues. 
For this reason i decided to make a post on my website that explains better the overall process.
<!-- more -->
The first thing you need to do is to setup a version of your composer package, so open the composer.json file and add the tag: "**version: version_number**". 
After that you need to zip the whole package directory: the zip file should contain only the file of your composer package, excluding the vendor name and the package directories. <br/>
For example let's assume you have a package in "**workbench/vendor/package_name**" what you have to do is to create a zip file named **vendor-package_name-version.zip** that contains all the files inside the **package_name** folder (excluding the folder itself).
At this point you have to create a directory in the same folder of your composer.json application file, in this example i call it "**artifacts**. In that directory you put your package.zip file. Now in your main composer.json you have to add the following lines:

	"repositories": [
        {
            "type": "artifact",
            "url": "artifacts/"
        }
    ],
	
And then add the dependency on your require field:

	"require": {
        "vendor/package_name": "version"
    }
	
At this point all you have to do is run **composer update** and you'll be done. Have a nice day!<br/>
If you have any doubts don't hesitate to write a comment below: i'll be happy to answer any of your questions!
