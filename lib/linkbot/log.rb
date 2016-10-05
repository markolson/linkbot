require 'logger'

module Linkbot
  $stdout.sync = true
  @@logger = ::Logger.new($stdout)

  def self.log
    @@logger
  end
end
