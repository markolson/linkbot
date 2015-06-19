require 'rubygems'
require 'pp'
require 'httparty'
require 'open-uri'
require 'image_size'
require 'uri'
require 'cgi'
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

    def self.wallpaper?(url)
      wallpaper_resolutions = {
        "800x600" => true,
        "1024x600" => true,
        "1024x768" => true,
        "1152x864" => true,
        "1280x720" => true,
        "1280x768" => true,
        "1280x800" => true,
        "1280x960" => true,
        "1280x1024" => true,
        "1360x768" => true,
        "1366x768" => true,
        "1440x900" => true,
        "1600x900" => true,
        "1600x1200" => true,
        "1680x1050" => true,
        "1920x1080" => true,
        "1920x1200" => true,
        "2560x1440" => true
      }

      supported_extensions = {
        "jpg" => true,
        "jpeg" => true,
        "png" => true,
        "gif" => true
      }

      if supported_extensions.has_key?(url.split(".").last)
        dimensions = ''
        open(url) do |fh|
          d = ImageSize.new(fh.read).get_size
          dimensions = "#{d[0]}x#{d[1]}"
        end

        if wallpaper_resolutions.has_key?(dimensions)
          return true
        end
      end

      false
    end

    def self.ago_in_words(time1, time2)
      diff = time1.to_i - time2.to_i
      ago = ''
      if diff == 1
        ago = "#{diff} second ago"
      elsif diff < 60
        ago = "#{diff} seconds ago"
      elsif diff < 120
        ago = "a minute ago"
      elsif diff < 3600
        ago = "#{(diff / 60).to_i} minutes ago"
      elsif diff < 7200
        ago = "an hour ago"
      elsif diff < 86400
        ago = "#{(diff / 3600).to_i} hours ago"
      elsif diff < 172800
        ago = "yesterday"
      elsif diff < 604800
        ago = "#{(diff / 86400).to_i} days ago"
      elsif diff < 1209600
        ago = "last week"
      else
        ago = "#{(diff / 604800).to_i} weeks ago"
      end
      ago
    end
  end
end
