## Opro

A production ready Rails Engine that turns your app into an [Oauth2](http://oauth.net/2/) Provider.

  * [Demo OAuth Provider app with Opro](http://opro-demo.herokuapp.com/) on Heroku
  * [Built in Opro docs](http://opro-demo.herokuapp.com/oauth_docs)

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

This will put a file in `initializers/opro.rb` and generate some migrations, and add `mount_opro_oauth` to your routes.


Now we're ready to migrate the database

```shell
    $ rake db:migrate
````

This will add `Opro::Oauth::AuthGrant` and `Opro::Oauth::ClientApp` to your database. An iPhone app would need to register for a `client_id` and `client_secret` before using Oauth as a ClientApp. Once created they could get authorization from users by going through the oauth flow, thus creating AuthGrants. In other words a ClientApp has many users through AuthGrants.

## Setup

Go to `initializers/opro.rb` and configure your app for your authentication scheme, if you're not using devise see "Custom Auth" below.

```ruby
      Opro.setup do |config|
        config.auth_strategy = :devise
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

By default all OAuth access is blacklisted. To whitelist all access, add `allow_oauth!` to your `ApplicationController` (this is not recommended). The best practice is to add `allow_oauth!` or `disallow_oauth` to each and every controller.

That should be all you need to do to get setup, congrats you're now able to authenticate users using OAuth!!


## Use it

Opro comes with built in documentation, so if you start your server you can view them at [http://localhost:3000/oauth_docs](http://localhost:3000/oauth_docs). Or you can [view the guide](http://opro-demo.herokuapp.com/oauth_docs) on the example app. This guide will walk you through creating your first OAuth client application, giving access to that app as a logged in user, getting an access token for that user, and using that token to access the server as an authenticated user!

## Custom Auth

If you're not using devise you can manually configure your own auth strategy. In the future I plan on adding more auth strategies, ping me or submit a pull request for your desired authentication scheme.

```ruby
      Opro.setup do |config|
        config.login_method             { |controller, current_user| controller.sign_in(current_user, :bypass => true) }
        config.logout_method            { |controller, current_user| controller.sign_out(current_user) }
        config.authenticate_user_method { |controller| controller.authenticate_user! }
      end
```

## Permissions

When a user auth's with a client they automatically are granting read permission to any action that you `allow_oauth!`. Read only clients are restricted to using GET requests. By default Opro will ask users for write permission on a client by client application. Client apps with `:write` permission can use all HTTP verbs including POST, PATCH, PUT, DESTROY on any url you whitelist using `allow_oauth!`.


### Custom Permissions

To remove write permissions comment out this line in the Opro initializer:

      config.request_permissions = [:write]

You can add custom permissions by adding to the array:

      config.request_permissions = [:write, :email, :picture, :whatever]

You can then restrict access using the custom permissions by calling `require_oauth_permissions` which takes the same arguments as `before_filter`

      require_oauth_permissions :email, :only => :index

You can also skip permissions using `skip_oauth_permissions`. By default permissions will just check to see if a client has the permission, and will allow the action if it is present. If you want to implement custom permission checks you can write custom methods using the pattern `oauth_client_can_#{permission}?` for example if you were restricting the `:email` permission, you would create a method.

      def oauth_client_can_email?
        # ...
      end

The result is expected to be true or false.

## Assumptions

* You have a user model and that is what your authenticating
* You're using Active::Record

## About

If you have a question file an issue or, find me on the Twitters [@schneems](http://twitter.com/schneems). Another good library for turning your app into an OAuth provider is [Doorkeeper](https://github.com/applicake/doorkeeper), if this project doesn't meet your needs let me know why and use them :)

This project rocks and uses MIT-LICENSE.