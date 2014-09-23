#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/linkbot"
require 'config'
require 'db'
require 'plugin'
require 'connector'
require 'bot'
