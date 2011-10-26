class Blowhard < Linkbot::Plugin
    def self.on_message(message, matches)
      quotes = ['I just blue myself.',
    		"I'll be your wingman. Even if it means I have to take a chubby. I will suck it up.",
    		"Well, yes, but I'm afraid I prematurely shot my wad on what was supposed to be a dry run, if you will, so now I’m afraid I have something of a mess on my hands.",
    		"I can already taste those meaty leading man parts.",
    		"I just can't seem to get one in the can...",
    		"I will pack your mouth with your sweet, pink mouth with so much ice cream, you'll be the envy of every Jerry and Jane on the block.",
    		"Well I guess you could say I am buy-curious",
    		'I see you wasted no time filling my "seat hole"',
    		'Excuse me, do these effectively hide my thunder?',
    		'Perhaps I should call the hot cops and tell them to come up with a more nautical theme. Hot sailors. Better yet... Hot sea...',
    		'Ah yes, the Bob Loblaw Law Blog. You, sir, are a mouthful.',
    		"No, no. It's pronounced a-nal-ra-pist.",
    		"Okay, who'd like a banger in the mouth? Right, I forgot, here in the States, you call it a sausage in the mouth.",
    		'Michael, you are quite the cupid. You can stick an arrow in my buttocks any time. ',
    		'Oh really? Then have sex with this girl right now. Go on. Have some sex with her.',
    		'Let the great experiment begin!',
    		"Tobias, you blowhard.",
    		"Michael, you are not quite the ladies man I had pictured. Hopefully, we will remedy that when we are in the spa spreading body chocolate on each other. ",
    		"Boy, I sure feel like a Mary without a Peter and a Paul. ",
    		"I'm looking for something that says 'Dad likes leather'. ",
    		"I need to go take down the buffet and set up the leather pony. "]
    	
      quotes[rand(quotes.length)]
    end


    def self.help
      "!blowhard - words of wisdom from Dr. Funke"
    end

    
    Linkbot::Plugin.register('blowhard', self,
      {
        :message => {:regex => /!blowhard/, :handler => :on_message, :help => :help},
        :"direct-message" => {:regex => /!blowhard/, :handler => :on_message, :help => :help}
      }
    )
end
