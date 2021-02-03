---
layout: post
title: 'Php Laravel Single table inheritance'
date: 2014-01-06 00:00:00
categories: ['design pattern','laravel']
---
As i came into OOP (Object-oriented-programming) i started to learn the concept of  "**Inheritance**".  Inheritance itself is a cool stuff, but problems come when you need to save that object structure into a relational database: for example Mysql.
This article is one of a series that will explain the best-practise approaches to solve that problem.<!-- more -->
 Before going deeper into details i have to say that thoose concepts come from Martin fowler book: "Pattern of enterprise architecture" which i advise to anybody who wanna increase his skills in OOP Architectures. 
There are four ways to do that:

<ol>
<li>Single table inheritance</li>
<li>Class table inheritance</li>
<li>Concrete table inheritance</li>
<li>Semistructured data</li>
</ol>

In this article i'll talk about the first and easiest of them: **Single table inheritance**.

<h3>Single table inheritance</h3>
Single table inheritance is based on mapping all the class hierarchy on a single table and using a custom field to define which type of class is saved in each row. I'll explain that with a simple example.
Imagine the hierarchy of animals and in particular dogs and cats, they both are pets and but they are also animals. Imagine now that every animal have the attribute sex, pet have name and dog collar.
Here is the UML diagram of the class structure:

 ![file]({{ "/assets/img/image-1387843145287.png" | relative_url }})

And here is the code that creates the structure in the db following the pattern:
```sql
CREATE TABLE ANIMALS (ID int NOT NULL AUTO_INCREMENT, Sex Varchar(255), Name Varchar(255), Collar Varcar(255), Type Varchar(50), PRIMARY KEY ID);
```

What we are doing is to map every node of the hierarchy on the same table, the table contains all the attributes in the hierarchy and also the attribute: "Type" to disntinguish the type of data being saved. 

To be more clear here is an example of the code to insert a new dog:
```sql
INSERT INTO ANIMALS (Type, Sex, Name, Collar) VALUES ("Dog", "M", "Bobby", "black");
```
And here is and example to insert a new cat:
```sql
INSERT INTO ANIMALS (Type, Sex, Name, Collar) VALUES ("Cat","M", "Tom" );
```

The advantages of **Single table inheritance** are:
<ul>
<li>Is simple</li>
<li>Moving column between hierarchy doesnt require db changes</li>
<li>Fits well with Active record pattern (Planning an article for that)</li>
</ul>
 The weakness of this implementation are:
 <ul>
<li>There is no metadata to define which attribute belongs to wich subtype: looking table diretly is a bit weird</li>
<li>The table will quiclky become a bottleneck if you create many hierarchies</li>
<li>You waste some space with empty columns(depending on dmbs compression of nulls)</li>
</ul>

To handle this problem automatically with **Laravel Framework** i've created a package called **"laravel-single-table-inheritance"** that you can find [here on github](https://github.com/intrip/laravel-single-table-inheritance).
If you want to understand more about object oriented inheritance follow the guide with [Class table inheritance]({% post_url 2014-01-07-php-class-table-inheritance %})


If you liked this article: <a href="https://twitter.com/JacopoBeschi" class="twitter-follow-button" data-show-count="false" data-lang="en">Follow me</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
