# Linkbot

[![Build Status](https://travis-ci.org/markolson/linkbot.svg)](https://travis-ci.org/markolson/linkbot)

Linkbot is a ruby chatbot designed to sit in your chat room and provide
interesting/fun/useful responses to your queries. It has an easy-to-use
plugin system and many plugins already written.

## Installation

Make sure you have ruby 2.7 or greater, rubygems, and bundler installed.

Then,

```
git clone https://github.com/markolson/linkbot.git
cd linkbot
bundle install
```

That should set you up with linkbot and all its dependencies.

Next, copy `config.example.json` into `./tmp/config.json`, and set the
appropriate variables. You must fill in the `connectors` field with appropriate
connection information, but feel free to add or delete entries from the `plugins`
section for plugins you don't want. KEEP the `plugins` section, though, even if
it is empty.

(TODO: more on this, refactor config)

Finally, run `linkbot --config ./tmp/config.json --database ./tmp/data.sqlite3`
to run linkbot.

## Connectors

Connectors are the interface for linkbot to connect with your chat service.
Currently, linkbot has jabber, campfire, slack, and irc connectors, though
you should really only use the Slack connector.

## Plugins

Plugins are the bits that make linkbot useful. Each plugin implements a command
that linkbot knows how to respond to. A basic plugin inherits from `Linkbot::Plugin`,
and registers a regex to match against in the initializer. Matches are passed
into `on_message`, which should return a string.

```
class Slap < Linkbot::Plugin
  def initialize
    register :regex => /\/slap(?: ([\w\s]+))?/
    help "/slap [username] - Flashback to the halcyon days of the 1990s when hammer pants were all the rage"
  end

  def on_message(message, matches)
    user = (matches[0] and matches[0].length > 0) ? matches[0] : "everyone"
    "#{message.user_name} slaps #{user} around a bit with a large trout"
  end
end
```
