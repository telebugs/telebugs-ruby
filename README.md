# Telebugs for Ruby

Simple error monitoring for developers. Monitor production errors in real-time
and get them reported to Telegram with Telebugs.

- [FAQ](https://telebugs.com/faq)
- [Telebugs News](https://t.me/TelebugsNews)
- [Telebugs Community](https://t.me/TelebugsCommunity)

## Introduction

Any Ruby application or script can be integrated with
[Telebugs](https://telebugs.com) using the `telebugs` gem. The gem is designed
to be simple and easy to use. It provides a simple API to send errors to
Telebugs, which will then be reported to your Telegram project. This guide will
help you get started with Telebugs for Ruby.

For full details, please refer to the [Telebugs documentation](https://telebugs.com/new/docs/integrations/ruby).

## Installation

Install the gem and add to the application's Gemfile by executing:

```sh
bundle add telebugs
```

If bundler is not being used to manage dependencies, install the gem by executing:

```sh
gem install telebugs
```

## Usage

This is the minimal example that you can use to test Telebugs for Ruby with your
project:

```rb
require "telebugs"

Telebugs.configure do |c|
  c.api_key = "YOUR_API_KEY"
end

begin
  1 / 0
rescue ZeroDivisionError => e
  Telebugs.notify(error: e)
end

sleep 2

puts "An error was sent to Telebugs asynchronously.",
  "It will appear in your dashboard shortly.",
  "A notification was also sent to your Telegram chat."
```

Replace `YOUR_API_KEY` with your actual API key. You can ask
[@TelebugsBot](http://t.me/TelebugsBot) for your API key or find it in
your project's dashboard.

## Telebugs for Ruby integrations

Telebugs for Ruby is a standalone gem that can be used with any Ruby application
or script. It can be integrated with any Ruby framework or library.

We provide official integrations for the following Ruby platforms:

- [Ruby on Rails](https://github.com/telebugs/telebugs-rails)

## Ruby support policy

Telebugs for Ruby supports the following Ruby versions:

- Ruby 3.0+

If you need support older rubies or other Ruby implementations, please contact
us at [help@telebugs.com](mailto:help@telebugs.com).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/telebugs/telebugs-ruby.
