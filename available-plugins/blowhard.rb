class Blowhard < Linkbot::Plugin
  include HTTParty
  
    def self.on_message(message, matches)
      quotes = {
        'I just blue myself.' => 'BznwsT6r_tM',
    		"I'll be your wingman. Even if it means I have to take a chubby. I will suck it up." => 'VmugfdhSzJs',
    		"Well, yes, but I'm afraid I prematurely shot my wad on what was supposed to be a dry run, if you will, so now I'm afraid I have something of a mess on my hands." => "xRHxuB1SXvc",
    		"I can already taste those meaty leading man parts." => "fiEQARKXWYo",
    		"I just can't seem to get one in the can..." => nil,
    		"I will pack your mouth with your sweet, pink mouth with so much ice cream, you'll be the envy of every Jerry and Jane on the block." => nil,
    		"Well I guess you could say I am buy-curious" => nil,
    		'I see you wasted no time filling my "seat hole"' => nil,
    		'Excuse me, do these effectively hide my thunder?' => nil,
    		'Perhaps I should call the hot cops and tell them to come up with a more nautical theme. Hot sailors. Better yet... Hot sea...' => "JRecXt-Nu-0",
    		'Ah yes, the Bob Loblaw Law Blog. You, sir, are a mouthful.' => "XMb_dGucb8E",
    		"No, no. It's pronounced a-nal-ra-pist." => nil,
    		"Okay, who'd like a banger in the mouth? Right, I forgot, here in the States, you call it a sausage in the mouth." => 'FtW7eaSvd6A',
    		'Michael, you are quite the cupid. You can stick an arrow in my buttocks any time. ' => nil,
    		'Oh really? Then have sex with this girl right now. Go on. Have some sex with her.' => "NRNJ5udiiRk",
    		'Let the great experiment begin!' => nil,
    		"Tobias, you blowhard." => 'cEsdLNG3u6I',
    		"Michael, you are not quite the ladies man I had pictured. Hopefully, we will remedy that when we are in the spa spreading body chocolate on each other. " => nil,
    		"Boy, I sure feel like a Mary without a Peter and a Paul. " => nil,
    		"I'm looking for something that says 'Dad likes leather'. " => "pZr8bbKxYrE",
    		"I need to go take down the buffet and set up the leather pony. " => nil,
    		"Okay Lindsay, are you forgetting that I was a professional twice over? An analyst, and a therapist. The world's first analrapist! " => "UrIpPqcln6Y"
    	}
    	
    	qtext = quotes.keys[rand(quotes.length)]
    	
    	if Linkbot::Config["plugins"]["blowhard"]["webhook"] && !quotes[qtext].nil?
        get("#{Linkbot::Config["plugins"]["blowhard"]["webhook"]}/#{quotes[qtext]}")
      end
    	
      qtext
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
