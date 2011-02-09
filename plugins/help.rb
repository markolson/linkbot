class Helper < Linkbot::Plugin
  def self.regex
    /!help/
  end
  
  Linkbot::Plugin.register('help', self.regex, self);
  
  def self.on_message(user, message, matches)
    messages = [] 
    Linkbot::Plugin.plugins.each {|k,v|
      if(v[:ptr].respond_to?(:help))
        messages << v[:ptr].help
      end
    }
    messages
  end
end