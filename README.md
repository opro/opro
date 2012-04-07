## Stop, Read This

This is my first time writing and Oauth Provider, so there may be buggy or insecure code. If you want to use this, do so at your own risk. I'm vetting it on some development and production applications, when it is ready for consumption and contribution, i'll remove this. If you want to be notified when that happens let me know [@schneems](http://twitter.com/schneems). For now this should be considered a toy, and enjoyed as such :)

## Opro

A Rails Engine that turns your app into an [Oauth](http://oauth.net/2/) Provider.


## What is an Oauth Provider

Oauth is used all over the web by companies that need to authenticate users or restrict access to information in a secure fashion. Twitter and Facebook are the best known Oauth Providers. You click "connect to Twitter" then you're sent over to Twitter's site where you can accept or deny. From there you're sent back from where you came, but now they have any information you granted them. Most users understand the flow pretty well, it's a fairly standard process, and is secure. Unfortunately it's not super easy to implement. Since I hate writing code twice, I decided to take an Oauth Provider and turn it into a Rails Engine so anyone could implement an Oauth Provider on their site. 

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
  $ #
```

## Use it


TODO