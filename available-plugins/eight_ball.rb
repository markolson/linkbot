class EightBall < Linkbot::Plugin
  
  PHRASE = '8ball'
  PROMPT = 'Ask a question! "8ball, will I win the game?"'
  RESPONSE_HEADER = 'Magic 8-ball says...'
    
  Linkbot::Plugin.register(PHRASE, self, {
    :message => {:regex => /^#{PHRASE}/, :handler => :on_message}
  })

  def self.on_message(message, matches)
    user = message.user_name
    question = self.strip_phrase_from message.body
    
    return PROMPT if message.body == PHRASE || question.empty?
    
    response
  end
  
  def self.response
    YES_NO_RESPONSES[rand(YES_NO_RESPONSES.size)]
  end
  
  def self.strip_phrase_from message
    message.scan(/^#{PHRASE},? (.*)/)
  end
  
  def self.says
    RESPONSE_HEADER
  end
  
  YES_NO_RESPONSES = [
    "Yes, it is certain.",
    "Yes, decidedly so.",
    "Without a doubt, yes.",
    "Yes - definitely...",
    "As I see it, yes...",
    "Most likely.",
    "Outlook is good.",
    "Signs point to yes...",
    "Yes.",
    "Better not tell you now...",
    "Concentrate and ask again.",
    "Don't count on it.",
    "My reply is no.",
    "My sources say no.",
    "Very doubtful."
    ]
end
