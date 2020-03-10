---
layout: post
title: 'Abstracting SQL union with ActiveRecord'
date: 2020-02-20 18:00:00
categories: ['ruby on rails', 'activerecord']
---

Sometimes you might need to use SQL UNION in your application, in this article we explan you how to
abstract SQL union creation within ActiveRecord.

The main idea is to create an abstaction which receives in input an array of ActiveRecord relations
and then transform the given array into SQL, eventually we'll use `ActiveRecord.from` method in order
to load the given SQL as an ActiveRecord relation.

Please note that I extracted this examples from [gitlab](https://gitlab.com/) codebase.

```ruby
module Gitlab
  module SQL
    # Class for building SQL UNION statements.
    #
    # ORDER BYs are dropped from the relations as the final sort order is not
    # guaranteed any way.
    #
    # Example usage:
    #
    #     union = Gitlab::SQL::Union.new([user.personal_projects, user.projects])
    #     sql   = union.to_sql
    #
    #     Project.from("(#{union}) projects")
    class Union
      def initialize(relations, remove_duplicates: true)
        @relations = relations
        @remove_duplicates = remove_duplicates
      end

      def to_sql
        # Some relations may include placeholders for prepared statements, these
        # aren't incremented properly when joining relations together this way.
        # By using "unprepared_statements" we remove the usage of placeholders
        # (thus fixing this problem), at a slight performance cost.
        fragments = ActiveRecord::Base.connection.unprepared_statement do
          @relations.map { |rel| rel.reorder(nil).to_sql }.reject(&:blank?)
        end

        if fragments.any?
          "(" + fragments.join(")\n#{union_keyword}\n(") + ")"
        else
          'NULL'
        end
      end

      def union_keyword
        @remove_duplicates ? 'UNION' : 'UNION ALL'
      end
    end
  end
end
```

With the above class you can create very quiclky an UNION given an array of AR relations, for
example as explained in the comment you can do:

```ruby
union = Gitlab::SQL::Union.new([user.personal_projects, user.projects])
sql   = union.to_sql

projects = Project.from("(#{union}) projects")
```

Worth noting that we are dealing always with AR relations which imples that the query is run only if
needed; this also implies that the AR relation can be used as parameter to other queries.

Also note that this code will run without loading data in memory (until is needed) thus the code is performant!

