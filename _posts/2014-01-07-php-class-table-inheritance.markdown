---
layout: post
title: 'Php class table inheritance'
date: 2014-01-07 20:07:00
categories: ['design pattern']
---
In the previous article i talked about [Single table inheritance](/post/php-laravel-single-table-inheritance) which is one of the four ways to map inheritance into RDBMS (Relational Database Management System). As stated in the other article this pattern comes from Marwin fowler PoEAA Book. In this one we talk about **Class table inheritance**. Class table inheritance is an approach that consist in creating a table for each class in the object-model. 
<!-- more -->
To explain that let's use the example used in the other post: 
imagine the hierarchy of animals and in particular dogs and cats, they both are pets and but they are also animals. Imagine now that every animal have the attribute sex, pet have name and dog collar.
Here is the UML diagram of the class structure:

 ![file]({{ "/assets/img/image-1387843145287.png" | relative_url }})

And here is the code that creates the structure in the db following the pattern:

```sql
CREATE TABLE ANIMAL (ID int NOT NULL AUTO_INCREMENT, Sex Varchar(255), PRIMARY KEY ID);
```

```sql
CREATE TABLE PET (ID int NOT NULL, Name Varchar(255), PRIMARY KEY ID, FOREIGN KEY (ID) REFERENCES ANIMAL(ID) );
```

```sql
CREATE TABLE DOG (ID int NOT NULL, Collar Varchar(255), PRIMARY KEY ID, FOREIGN KEY (ID) REFERENCES PET(ID) );
```

```sql
CREATE TABLE CAT (ID int NOT NULL, PRIMARY KEY ID, FOREIGN KEY (ID) REFERENCES PET(ID) );
```

As you can see with **Class table inheritance** we create a table for every class; note that we use the **ID** of every subclass as a foreign key for the parent class, in this way we have the same key for the set of tables rappresenting the same leaf class in the hierarchy.

The advantages of this approach are:

<ul>
<li>You don't waste any space: every column is relative to the right class.</li>
<li>It's easy to see the relation between database and classes.</li>
</ul>

There are some disadvantages with this approach aswell:

<ul>
<li>Every time you load or save an object you need to check multiple tables (Many joins)</li>
<li>Moving fields up and down with the hierarchy requires db changes</li>
<li>The top table class may become a bottleneck</li>
</ul>

If you use Laravel framework and want to implement that with his ORM Eloquent you may land in some big troubles: in fact this pattern doesn't fit well with Active Record (Pattern used by Eloquent). Aniways i'm planning to write and article explaining how you can implement that (Mostly proof of concept). My strong advise in the case you wanna use this pattern is to use that with [Doctrine ORM](http://docs.doctrine-project.org/en/latest/reference/inheritance-mapping.html). Aniways there are some other orm that support that built-in like [propel orm](http://propelorm.org/).

Well, that's all for today. Enjoy!

If you liked this article: <a href="https://twitter.com/JacopoBeschi" class="twitter-follow-button" data-show-count="false" data-lang="en">Follow me</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>

