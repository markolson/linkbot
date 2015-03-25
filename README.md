# Linkbot

[![Join the chat at https://gitter.im/markolson/linkbot](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/markolson/linkbot?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Linkbot is a ruby chatbot designed to sit in your chat room and provide
interesting/fun/useful responses to your queries. It has an easy-to-use
plugin system and many plugins already written.

## Installation

Make sure you have ruby 1.9.2 or greater, rubygems, and bundler installed.

Then,

```
git clone https://github.com/markolson/linkbot.git
cd linkbot
bundle install
```

That should set you up with linkbot and all its dependencies.

Next, copy `config.json.example` into `config.json`, and set the
appropriate variables. You must fill in the `connectors` field
with appropriate connection information, but feel free to delete
sections from teh `plugins` section for plugins you don't want.

(TODO: more on this, refactor config)

Finally, run `ruby linkbot.rb` to run linkbot.

## Connectors

Connectors are the interface for linkbot to connect with your chat service.
Currently, linkbot has jabber and campfire connectors.

The service is mainly used on hipchat at the moment, so bug reports and
patches from other services would be very helpful.

## Plugins

Plugins are the bits that make linkbot useful. Each plugin implements a command
that linkbot knows how to respond to.
