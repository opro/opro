## Stop, Read This

If you want to use this, do so at your own risk. I'm vetting it on some development and production applications, when it is ready for consumption and contribution, I'll remove this. If you want to be notified when that happens let me know [@schneems](http://twitter.com/schneems). For now this should be considered a toy, and enjoyed as such :)

## Opro

A Rails Engine that turns your app into an [Oauth](http://oauth.net/2/) Provider.

## Why would I use this?

Lets say you've built a Rails app, awesome. Now you want to build a mobile app on say, the iPhone; cool. You start throwing around `#to_json` like nobody's business, but then you realize you need to authenticate users somehow. "Basic Auth!!", you exclaim, but then you realize that's not the most secure solution. You also realize that some users already signed up with Facebook & Twitter so they don't have a username/password combo. What ever shall you do?

Wouldn't it be great if we could have a token exchange where the user goes to a mobile web view and grants permission, and then we return back an auth token just like the big boys (Facebook, Twitter, *cough* Foursquare *cough*). With Opro, we can add this functionality pretty easily. We'll use your existing authentication strategy and provide some end integration points for your clients to use out of the box.


## Install

Gemfile

```ruby
  gem 'opro'
```

Then run

```shell
  $ bundle install
```

and don't forget

```shell
  $ rails g opro:install
```

This will put a file in `initializers/opro.rb` and generate some migrations.


Now we're ready to migrate the database

```shell
  $ rake db:migrate
````

This will add `Oauth::AccessGrant` and `Oauth::ClientApplication` to your database

## Setup

Go to `initializers/opro.rb` and configure your app for your authentication scheme.

```ruby
  Opro.setup do |config|
    config.auth_strategy = :devise
  end
```

If you're not using devise you can manually configure your own auth strategy. In the future I plan on adding more auth strategies, ping me or submit a pull request for your desired authentication scheme.

```ruby
  Opro.setup do |config|
    config.login_method             { |controller, current_user| controller.sign_in(current_user, :bypass => true) }
    config.logout_method            { |controller, current_user| controller.sign_out(current_user) }
    config.authenticate_user_method { |controller| controller.authenticate_user! }
  end
```

Now in your controllers you can allow OAuth access using the same syntax of the rails `before_filter`

```ruby
  class UsersController < ApplicationController
    allow_oauth!  :only => [:show]
  end
```


You can also disallow OAuth on specific actions. Disallowing will always over-ride allowing.


```ruby
  class ProductsController < ApplicationController
    disallow_oauth!   :only => [:create]
  end
```

By default all OAuth access is blacklisted. To whitelist all access, add `allow_oauth!` to your `ApplicationController` (this is not recommended). The best practice is to add allow or disallow code to each controller.

That should be all you need to do to get setup, congrats you're now able to authenticate users using OAuth!!


## Use it

Opro comes with built in documentation, so if you start your server you can view them at http://localhost:3000/oauth_docs. If you're reading this on Github you can jump right to the [Quick Start](https://github.com/schneems/opro/blob/master/app/views/oauth/docs/markdown/quick_start.md.erb) guide. This guide will walk you through creating your first OAuth client application, giving access to that app as a logged in user, getting an access token for that user, and using that token to access the server as an authenticated user!


## Assumptions

* You have a user model and that is what your authenticating
* You're using Active::Record

If you submit a _good_ pull request for other adapters, or for generalizing the resource we're authenticating, you'll make me pretty happy.


## About

If you have a question file an issue or, find me on the Twitters [@schneems](http://twitter.com/schneems).

This project rocks and uses MIT-LICENSE.