# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'linkbot/version'

Gem::Specification.new do |spec|
  spec.name          = "linkbot"
  spec.version       = Linkbot::VERSION
  spec.authors       = ["Kenny Hoxworth", "Mark Olson", "Bill Mill", "Kafu Chau", "Jason Denney"]
  spec.email         = ["hoxworth@gmail.com", "theothermarkolson@gmail.com", "billmill@gmail.com"]
  spec.description   = "A Ruby chatbot written for simple plugin generation and management"
  spec.summary       = "A Ruby chatbot written for simple plugin generation and management"
  spec.homepage      = "http://github.com/markolson/linkbot"
  spec.license       = "MIT"

  spec.bindir        = 'exe'
  spec.files         = ["Gemfile",
                        "Gemfile.lock",
                        "LICENSE.txt",
                        "linkbot.gemspec",
                        "README.md",
                        "Rakefile"]
  spec.files         += Dir["connectors/*"] +
                        Dir["exe/*"] +
                        Dir["lib/**/*"] +
                        Dir["plugins/*"]
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "connectors"]

  spec.add_runtime_dependency "activesupport", ">= 5.1"
  spec.add_runtime_dependency "bundler", ">= 1.7"
  spec.add_runtime_dependency "certifi", "~> 14.5.14"
  spec.add_runtime_dependency 'chronic', ">= 0.10.2"
  spec.add_runtime_dependency 'em-http-request', ">= 1.1.5"
  spec.add_runtime_dependency "em-irc", ">= 0.0.2"
  spec.add_runtime_dependency 'eventmachine', "~> 1.0"
  spec.add_runtime_dependency 'faraday', "~> 0.9"
  spec.add_runtime_dependency 'faye-websocket', "~> 0.10.1"
  spec.add_runtime_dependency 'hipchat', ">= 1.5.4"
  spec.add_runtime_dependency 'hpricot', ">= 0.8.6"
  spec.add_runtime_dependency 'htmlentities', ">= 4.3"
  spec.add_runtime_dependency 'httparty', "~> 0.13"
  spec.add_runtime_dependency 'image_size', ">= 1.5.0"
  spec.add_runtime_dependency 'octokit', "~> 2.0"
  spec.add_runtime_dependency 'phonie', ">= 3.3.1"
  spec.add_runtime_dependency 'rack', ">= 1.6.5"
  spec.add_runtime_dependency 'sanitize', ">= 2.1", "< 6.0"
  spec.add_runtime_dependency 'sinatra', "~> 1.4"
  spec.add_runtime_dependency "slack-ruby-client", "~> 0.3.1"
  spec.add_runtime_dependency 'sqlite3', "~> 1.3"
  spec.add_runtime_dependency "stock_quote", ">= 1.2.6"
  spec.add_runtime_dependency 'thin', '>= 1.5.0'
  spec.add_runtime_dependency 'twilio-ruby', ">= 4.13.0"
  spec.add_runtime_dependency 'twitter-stream', ">= 0.1.12"
  spec.add_runtime_dependency 'twss', ">= 0.0.5"
  spec.add_runtime_dependency 'tzinfo', ">= 1.2.2"
  spec.add_runtime_dependency 'unidecode', ">= 1.0.0"
  spec.add_runtime_dependency 'xmpp4r', "~> 0.5qq"

  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rb-readline", ">= 0.5.3"
  spec.add_development_dependency "rspec", '>= 3.0'
  spec.add_development_dependency "byebug", '>= 3.2'
  spec.add_development_dependency "pry", ">= 0.10.1"
end
