require 'rubygems'
require 'pp'
require 'httparty'
require 'certifi'
require 'image_size'
require 'uri'
require 'cgi'
require_relative 'db'

module Linkbot
  class Plugin
    @@plugins = []

    def self.plugins; @@plugins; end;

    def log(message)
      Linkbot::MessageLogs.log(message)
    end
    def message_history(message)
      Linkbot::MessageLogs.logs_for(message)
    end

    def self.collect(paths)
      paths.each do |path|
        Dir[File.join(path, "*.rb")].each do |file|
          begin
            load file
          rescue Exception => e
            Linkbot.log.error "Plugin collection: unable to load plugin #{file}"
            Linkbot.log.error "#{e.inspect}"
            Linkbot.log.error e.backtrace.join("\n")
          end
        end
      end
      @@plugins = []
      ObjectSpace.each_object(Class).select { |klass| klass < self }.each do |plugin|
        @@plugins << plugin.new
      end
    end

    def register(options = {})
      handlers = {}
      message_handler = options[:handler] || :on_message
      message_matcher = options[:regex] || raise('Message matching plugin needs a regex. //to match all messages.')
      handlers[:message] = {:regex => message_matcher, :handler => message_handler}

      if options.fetch(:periodic, false)
        periodic_handler = options[:periodic][:handler] || :periodic
        handlers[:periodic] = { :handler => periodic_handler }
      end

      @handlers = handlers
    end

    def name
      self.class.name
    end

    def handlers
      @handlers
    end

    def help(message = nil)
      @help = message.chomp if !message.nil?
      @help
    end

    def matches?(message)
      !!match(message)
    end

    def matches(message)
      match(message).to_a.drop(1)
    end

    def match(message)
      handlers[message.type][:regex].match(message.body)
    end

    def matches_everything?(message_type)
      handlers[message_type][:regex].nil?
    end

    def has_permission?(message)
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

    def has_handler_for?(message)
      !self.handlers.nil? &&
      self.handlers.has_key?(message.type) &&
      self.respond_to?("on_#{message.type}")
    end

    # unescape google urls with octal (!?) escapes into url-encoded hex equivalents
    def unescape_octal(url)
      url.gsub(/\\(\d{2})/) do |escape|
        # given an octal escape like '\\75':
        #
        # 1. strip the leading slash
        # 2. convert to an integer
        # 3. convert to a hex string (url escaped)
        "%#{escape[1..-1].to_i(8).to_s(16)}"
      end
    end

    def wallpaper?(url)
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
        img = HTTParty.get(url, {ssl_ca_file: Certifi.where}).body
        d = ImageSize.new(img).size
        dimensions = "#{d[0]}x#{d[1]}"

        if wallpaper_resolutions.has_key?(dimensions)
          return true
        end
      end

      false
    end

    def ago_in_words(time1, time2)
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
