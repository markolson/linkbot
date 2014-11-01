module Linkbot
  class MessageLogs < Array
    @@logs = {}

    def self.named(log_name, size=1)
      @@logs[log_name] ||= Linkbot::MessageLogs.new(size)
    end

    def self.log(message)
      named(:global).log(message)
      named("_room_#{message[:options][:room]}").log(message) if message[:options][:room]
      named("_user_#{message[:options][:user]}").log(message) if message[:options][:user]
    end

    def self.previous_message(message)
      @@logs["_room_#{message[:options][:room]}"].first
    end

    def self.logs_for(message)
      if message[:options][:room]
        @@logs["_room_#{message[:options][:room]}"]
      elsif message[:options][:user]
        @@logs["_user_#{message[:options][:user]}"]
      else
        @@logs[:global]
      end
    end

    attr_reader :max_size
    def initialize(max_size=1)
      @max_size = max_size
    end

    def <<(message)
      if self.size < @max_size || @max_size.nil?
        super
      else
        self.shift
        self.push(message)
      end
    end

    alias :log :<<
  end
end
