require 'open-uri'
require 'image_size'
require 'uri'
require 'cgi'

module Util
  
  @@resolutions = {
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
  
  @@extensions = {
    "jpg" => true,
    "jpeg" => true,
    "png" => true,
    "gif" => true
  }
  
  def self.wallpaper?(url)
    d = nil
    
    if @@extensions.has_key?(url.split(".").last)
      open(url) do |fh|
        d = ImageSize.new(fh.read).get_size
      end
    
      if @@resolutions.has_key?("#{d[0]}x#{d[1]}")
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

class IO
  alias_method :orig_puts, :puts
  def puts(*terms)
    terms[0] = "#{Time.now.strftime("[%Y-%m-%d %H:%M:%S] ")}#{terms[0]}"
    orig_puts(*terms)
  end
end