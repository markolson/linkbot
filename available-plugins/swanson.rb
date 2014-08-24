# -*- coding: utf-8 -*-

class Swanson < Linkbot::Plugin
    def self.on_message(message, matches)
      quotes = [
"http://24.media.tumblr.com/20a84e7698fd777896aadbce42e571aa/tumblr_ml46srJ1Iv1rdh9azo1_400.gif",
"http://24.media.tumblr.com/a49de3bc8b55a7ea0e935df28248060e/tumblr_ml46srJ1Iv1rdh9azo2_400.gif",
"http://i.imgur.com/dqgmsLh.gif",
"http://i.imgur.com/yNSz3os.jpg",
"http://i.imgur.com/BlNkVw9.jpg",
"http://i.imgur.com/mOw7acG.jpg",
"http://i.imgur.com/Ez41HO9.jpg",
"http://i.imgur.com/Z9XNYW8.jpg",
"http://i.imgur.com/8Q1N6rw.jpg",
"http://i.imgur.com/roudIZk.gif",
"http://i.imgur.com/VgBmug2.jpg",
"http://i.imgur.com/eLazeBA.png",
"http://i.imgur.com/TbGtoHd.jpg",
"http://i.imgur.com/mLhMsIN.jpg",
"http://i.imgur.com/3DuzOoX.jpg",
"http://i.imgur.com/dnJMAwX.jpg",
"http://i.imgur.com/ZmB4icU.jpg",
"http://i.imgur.com/a3xCTv4.jpg",
"http://i.imgur.com/QK5OLcT.gif",
"http://i.imgur.com/EYj9BWC.jpg",
"http://i.imgur.com/PKBztP8.jpg",
"http://www.pajiba.com/image/ron-dancing-animated.gif",
"http://28.media.tumblr.com/tumblr_lgl0ieJ0Z01qzkiy8o1_400.jpg",
"http://i.imgur.com/8DH5j.jpg",
"I have been developing the Swanson Pyramid of Greatness for years. It's a perfectly calibrated recipe for maximum personal achievement. Categories include: Capitalism, God's way of determining who is smart, and who is poor. Crying, acceptable at funerals and the Grand Canyon. Rage. Poise. Property rights. Fish, for sport only, not for meat. Fish meat is practically a vegetable.",
"The less I know about other people's affairs, the happier I am. I'm not interested in caring about people. I once worked with a guy for three years and never learned his name. Best friend I ever had. We still never talk sometimes.",
"Now, I know I'm not going to find somebody that's both aggressively mean and apathetic. April really is the whole package.",
"You had me at meat tornado.",
"I'm surrounded by a lot of women in this department. And that includes the men.",
"When I walked in this morning I saw that the flag was at half mast, I though, 'All right, another bureaucrat ate it!' And then I saw it was Lil' Sebastian. Half mast is too high. Show some damn respect.",
"I am submitting this menu from a Pawnee institution, J.J.'s Diner. Home of the world's best breakfast dish: The Four Horsemeals of the Eggporkalypse.",
"You may have thought you heard me say I wanted a lot of bacon and eggs, but what I said was: Give me all the bacon and eggs you have.",
"(On fishing) It's like yoga, except I still get to kill something.",
"Encapsulate the spirit of melancholy. Easy. Boom, a sad desk. Boom, sad wall. It's art. Anything is anything.",
"I am off to have a mid-morning pre-lunch with my lady friend, but I will be back in time for lunch.",
"The key to burning an ex-wife effigy is to dip it in paraffin wax and then toss the flaming bottle of isopropyl alcohol from a safe distance. Do not stand too close when you light an ex-wife effigy.",
"It's never too early to learn that the government is a greedy piglet that suckles on a taxpayer's teet until they have sore, chapped nipples. I'm gonna need a different metaphor to give this nine year old.",
"Leslie, you need to understand that we are headed to the most special place on earth. When I'm done eating a Mulligan's meal, for weeks afterwards there are flecks of meat in my mustache and I refuse to clean it because every now and then a piece of meat will fall into my mouth.",
"(His museum speech) Shut up. And look at me. Welcome to Visions of Nature. This room has several paintings in it. Some are big and some are small. People did them and they are here now. I believe after this is over they will be hung in government buildings. Why the government is involved in an art show is beyond me. I also think it's pointless for a human to paint scenes of nature when they can go outside and stand in it.",
"The whole thing is a scam. Birthdays were invented by Hallmark to sell cards.",
"I won't publicly endorse a product unless I use it exclusively. My only official recommendations are U.S. Army issued mustache trimmers, Morton's salt, and the C.R. Lawrence Fein two inch axe-style scraper oscillating knife blade."             
	]
      quotes[rand(quotes.length)]
    end

    def self.help
      "!swanson - The one and only, Ron Swanson"
    end

    
    Linkbot::Plugin.register('swanson', self,
      {
        :message => {:regex => /!swanson/, :handler => :on_message, :help => :help},
        :"direct-message" => {:regex => /!swanson/, :handler => :on_message, :help => :help}
      }
    )
end
