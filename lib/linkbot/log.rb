require 'logger'

module Linkbot
  @@logger = ::Logger.new(STDOUT)

  def self.log
    @@logger
  end
end
