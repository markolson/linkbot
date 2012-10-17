class Fact < Linkbot::Plugin
  def self.help
    "!fact <fact number> - get a random fact from mental floss or by fact number"
  end
  
  def self.on_message(message, match)
    factnumber = match[0]

    if factnumber.nil?
      factnumber = rand(2001)
    elsif factnumber.to_i > 2000
      factnumber = rand(2001)
    else
      factnumber = factnumber.to_i
    end

    mentalfloss = "http://mentalfloss.com/amazingfactgenerator/load-fact.php?id=#{factnumber}"
    doc = ActiveSupport::JSON.decode(open(mentalfloss).read)

    outputStr = doc["post_content"]
        
    if outputStr.empty?
      "The fact is no facts came back..."
    else
      outputStr
    end
  end

  Linkbot::Plugin.register('fact', self, {
    :message => {:regex => Regexp.new('!fact(?: (\d+))?'), :handler => :on_message, :help => :help}
  })
end
