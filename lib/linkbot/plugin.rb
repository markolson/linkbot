require 'rubygems'
require 'pp'
require 'httparty'
require_relative 'db'

module Linkbot
  class Plugin
    @@plugins = {}

    def self.plugins; @@plugins; end;

    def self.log(message)
      Linkbot::MessageLogs.log(message)
    end
    def self.message_history(message)
      Linkbot::MessageLogs.logs_for(message)
    end

    def self.collect(paths)
      paths.each do |path|
        Dir[File.join(path, "*.rb")].each do |file|
          begin
            load file
          rescue Exception => e
            puts "unable to load plugin #{file}"
            puts e
          end
        end
      end
    end

    def self.register_plugin(name, s, handlers)
      @@plugins[name] = {:ptr => s, :handlers => handlers}
    end

    def self.register(options = {})
      name = options[:name] || self.name

      handlers = {}
      message_handler = options[:handler] || :on_message
      handlers[:message] = {:regex => options[:regex], :handler => message_handler}

      if options.has_key? :periodic
        periodic_handler = options[:periodic][:handler] || :periodic
        handlers[:periodic] = { :handler => periodic_handler }
      end

      register_plugin(name, self, handlers)
    end

    def self.help(message = nil)
      @help = message if !message.nil?
      @help
    end

    def self.has_permission?(message)
      room = message[:options][:room]
      # If no room is set, there's nothing to {white,black}list on.
      return true unless room

      permissions = ::Linkbot::Config["permissions"]
      # If no permissions are set in the configuration, there's no {white,black}listing.
      return true unless permissions

      # If no permissions exist for this room, no {white,black}lists exist for the room.
      room_permissions = permissions[room]
      return true unless room_permissions

      # whitelisting takes precedence over blacklisting
      return room_permissions["whitelist"].include?(self.name) if room_permissions["whitelist"]
      return !room_permissions["blacklist"].include?(self.name) if room_permissions["blacklist"]

      # if the plugin is not set in the {white,black}list, return true.
      return true
    end

    def self.has_handler_for?(message)
      self.respond_to?("on_#{message.type}")

    end
  end
end
