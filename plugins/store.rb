class Store < Linkbot::Plugin
    def self.on_message(user, message, matches, msg)
      mymsg = nil
      
      if matches[0] && matches[0].length > 0
        args = matches[0].split(" ")
        command = args.shift
        mymsg = case command
        when "name"
          cost = 50
          rmsg = nil
          if args.length > 1
            target_user = args.shift
            rows = Linkbot.db.execute("select username,showname from users where username='#{target_user}'")
            if rows.length == 0
              rmsg = "Unknown user"
            else
              old_username = (rows[0][1].nil? || rows[0][1] == '') ? rows[0][0] : rows[0][1]
              new_username = args.join(" ")
              if check_karma(cost, user)
                Linkbot.db.execute("update users set showname='#{new_username}' where username='#{target_user}'")
                rmsg = "'#{old_username}' is now known as '#{new_username}'"
                deduct_karma(cost, user)
              else
                rmsg = "Not enough karma to do this."
              end
            end
          end
          rmsg
        else
          nil
        end
      end
      
      if mymsg.nil?
        mymsg = [
          "Karma Store",
          "-----------",
          "Buy some stuff with karma. To buy, just use the !store command, followed by the appropriate stuff.",
          "",
          "1. [COST 50] name (username) (new name): Change how a user's name appears in any linkbot command."
        ].join("\n")
      end
      [mymsg]
    end
    
    def self.check_karma(cost, user)
      karma = Linkbot.db.execute("select karma from karma where user_id=#{user['id']}")[0][0]
      karma > cost
    end
    
    def self.deduct_karma(cost, user)
      karma = Linkbot.db.execute("select karma from karma where user_id=#{user['id']}")[0][0] - cost
      Linkbot.db.execute("update karma set karma=#{karma} where user_id=#{user['id']}")
    end
    
    def self.help
      "!store - Buy some shit"
    end
    
    Linkbot::Plugin.register('store', self,
      {
        :"direct-message" => {:regex => /!store(.*)/, :handler => :on_message, :help => :help}
      }
    )
end
