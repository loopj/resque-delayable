resque-delayable
================

A resque plugin which adds a new method `rdelay` to objects. Methods called 
with `rdelay` are executed asynchronously by resque, allowing your code to 
continue.

Features
--------
- Adds `rdelay` instance and class methods to your models. Works with 
  ActiveRecord, Mongoid and MongoMapper objects out of the box
- Works with resque-scheduler. Schedule method execution for the future, 
  `obj.rdelay(:run_in => 5.minutes).method`
- Get `rdelay` on any class methods with `include ResqueDelayable`
- Create a custom seralizer plugin to get `rdelay` on your own instance methods

Installation
------------
- Add `gem "resque-delayable"` to your `Gemfile` or `gem install resque-delayable`

Examples
--------

    class User
      include ResqueDelayable
      
      def self.recompute_caches() ...
      def get(name) ...
      def send_welcome_email ...
    end

    # Works with any serializable instance. ActiveRecord, Mongoid & MongoMapper
    # are supported out of the box
    u = User.get("james")
    u.rdelay.send_welcome_email

    # Works with all class methods
    User.rdelay.recompute_caches


Contributing to resque-delayable
--------------------------------
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Copyright (c) 2011 James Smith. See LICENSE.txt for
further details.

