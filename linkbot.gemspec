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
  spec.homepage      = "http://github.com/markolson/linkbot"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "connectors", "plugins"]

  spec.add_runtime_dependency 'sanitize'
  spec.add_runtime_dependency 'htmlentities'
  spec.add_runtime_dependency 'json'
  spec.add_runtime_dependency 'sqlite3'
  spec.add_runtime_dependency 'hpricot'
  spec.add_runtime_dependency 'twss'
  spec.add_runtime_dependency 'httparty'
  spec.add_runtime_dependency 'em-http-request'
  spec.add_runtime_dependency 'twitter-stream'
  spec.add_runtime_dependency 'eventmachine'
  spec.add_runtime_dependency 'rack'
  spec.add_runtime_dependency 'thin', '~>1.5.0'
  spec.add_runtime_dependency 'sinatra'
  spec.add_runtime_dependency 'xmpp4r'
  spec.add_runtime_dependency 'image_size'
  spec.add_runtime_dependency 'octokit'
  spec.add_runtime_dependency 'tzinfo'
  spec.add_runtime_dependency 'twilio-ruby'
  spec.add_runtime_dependency 'phonie'
  spec.add_runtime_dependency 'aws-sdk'
  spec.add_runtime_dependency 'hipchat'
  spec.add_runtime_dependency 'chronic'
  spec.add_runtime_dependency 'unidecode'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
