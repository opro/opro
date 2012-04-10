## Stop, Read This

This is my first time writing and Oauth Provider, so there may be buggy or insecure code. If you want to use this, do so at your own risk. I'm vetting it on some development and production applications, when it is ready for consumption and contribution, i'll remove this. If you want to be notified when that happens let me know [@schneems](http://twitter.com/schneems). For now this should be considered a toy, and enjoyed as such :)

## Opro

A Rails Engine that turns your app into an [Oauth](http://oauth.net/2/) Provider.


## What is an Oauth Provider

Oauth is used all over the web by apps that need to authenticate users or restrict access to information in a secure fashion. Twitter and Facebook are the best known Oauth Providers. Users click "connect to Twitter" in an iPhone app, then they're sent over to Twitter's site where they can accept or deny access. From there they're sent back to the iPhone app where they can do anything through the API that they would be allowed to do in the website.

Most users understand the flow pretty well, it's a fairly standard process, and is secure. While there are plenty of Oauth client libraries unfortunately it's not super easy to implement from a provider standpoint. Since I hate writing code twice, I decided to take an Oauth Provider and turn it into a Rails Engine so anyone could implement an Oauth Provider on their site.

## Why would I use this?

Lets say you've built a Rails app, awesome. Now you want to build a mobile app on say, the iPhone; cool. You start throwing around `#to_json` like nobody's business, but then you realize you need to authenticate users somehow. "Basic Auth!!", you exclaim, but then you realize that's not the most secure solution. You also realize that some users already signed up with Facebook & Twitter so they don't have a username/password combo. What ever shall you do?

Wouldn't it be great if we could have a token exchange where the user goes to a mobile web view and grants permission, and then we return back an auth token just like the big boys (Facebook, Twitter, *cough* Foursquare *cough*). With Opro, we can add this functionality pretty easily. We'll use your existing authentication strategy and provide some end integration points for your clients to use out of the box.

## Sounds Hard

It's not, just follow the directions below. I'll add a screencast and example app when I get time. Any questions, open an issue or ping me on Twitter.

## Install

Gemfile

```ruby
  gem 'opro'
```

```shell
  $ bundle install
```

```shell
  $ opro:install
```

This will put a file in `initializers/opro.rb` and generate some migrations.

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

Now we're ready to migrate the database

```shell
  $ rake db:migrate
````



That should be all you need to do to get setup, congrats you're now able to authenticate users using OAuth!!


## Use it

Opro comes with built in documentation, so if you start your server you can view them at `/docs/oauth`. If you're reading this on Github you can jump right to the [Quick Start](/app/views/docs/markdown/quick_start.md) guide. This guide will walk you through creating your first Oauth client application, giving access to that app as a logged in user, getting an access token for that user, and using that token to access the server as an authenticated user!


## Assumptions

* You have a user model and that is what your authenticating
* You're using Active::Record

If you submit a _good_ pull request for other adapters, or for generalizing the resource we're authenticating, you'll make me pretty happy.


## About

If you have a question file an issue or, find me on the Twitters [@schneems](http://twitter.com/schneems).

This project rocks and uses MIT-LICENSE.