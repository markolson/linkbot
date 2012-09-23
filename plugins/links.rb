# encoding: UTF-8
require 'uri'
  
class Links < Linkbot::Plugin
  
  Linkbot::Plugin.register('links', self,
    {
      :message => {:regex => Regexp.new('(?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:\'".,<>?«»“”‘’]))'), 
                  :handler => :on_message}
    }
  )
  
  Linkbot::Config["plugins"]["links"] = {} if Linkbot::Config["plugins"]["links"].nil?
  Linkbot::Config["plugins"]["links"]["whitelist"] = [] if Linkbot::Config["plugins"]["links"]["whitelist"].nil?
  Linkbot::Config["plugins"]["links"]["whitelist"] = Linkbot::Config["plugins"]["links"]["whitelist"].map do |link|
    uri = URI.parse(link)
    Regexp.new("^#{uri.host}#{uri.path}")
  end

  def self.on_message(message, matches)
    url = matches[0]
    url = URI.decode(url)
    uri = URI.parse(url)
    
    # First, make sure this is a HTTP or HTTPS scheme
    if uri.scheme.downcase == "http" || uri.scheme.downcase == "https"
      
      # Make sure this link has not been whitelisted
      Linkbot::Config["plugins"]["links"]["whitelist"].each do |whitelist_regex|
        if whitelist_regex.match("#{uri.host}#{uri.path}")
          return ''
        end
      end
      messages = []
    
      rows = Linkbot.db.execute("select username, dt from links, users where links.user_id=users.user_id and url = '#{url.gsub("'", "''")}'")
      if rows.empty?
        Linkbot::Plugin.plugins.each {|k,v|
          messages << v[:ptr].on_newlink(message, url).join("\n") if(v[:ptr].respond_to?(:on_newlink)) 
        }
        # Add the link to the dupe table
        Linkbot.db.execute("insert into links (user_id, dt, url) VALUES ('#{message.user_id}', '#{Time.now}', '#{url.gsub("'", "''")}')")
      else
        Linkbot::Plugin.plugins.each {|k,v|
          messages << v[:ptr].on_dupe(message, url, rows[0][0], rows[0][1]) if(v[:ptr].respond_to?(:on_dupe)) 
        }
      end  
      messages.join("\n")
    else
      ''
    end
  end

  if Linkbot.db.table_info('users').empty?
    Linkbot.db.execute('CREATE TABLE users (user_id STRING, username TEXT, showname TEXT)')
  end
  if Linkbot.db.table_info('links').empty?
    Linkbot.db.execute('CREATE TABLE links (user_id STRING, dt DATETIME, url TEXT)');
  end

  if Linkbot.db.table_info('trans').empty?
    Linkbot.db.execute('CREATE TABLE trans (user_id STRING, karma INTEGER, trans TEXT)');
  end

end
