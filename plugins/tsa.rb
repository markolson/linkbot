class Tsa < Linkbot::Plugin
  Linkbot::Plugin.register('tsa', self,
    {
      :message => {:regex => Regexp.new('tsa', 'g'), :handler => :on_message}
    }
  )
  
  def self.on_message(message, matches)
     messages = [
        "I'm going to touch your balls with the back of my hand",
        "We have an opt-out!",
        "TSA: the McDonalds workers of the government",
        "Security Theater Professionals",
        "Sir, you've been added to the \"domestic extremists\" list",
        "Not all parts of the government are accountable to the public, especially the TSA",
        "Your junk is safe in our hands",
        "It's not a grope, it's a freedom pat",
        "We handle more packages than UPS",
      ]
      messages[rand(messages.length)]
  end
end
