class Store < Linkbot::Plugin
    def self.on_message(message, matches)
      mymsg = nil
      
      if matches[0] && matches[0].length > 0
        args = matches[0].split(" ")
        command = args.shift
        
        Linkbot::Plugin.plugins.each {|k,v|
          if v[:handlers][:"linkbot-store"] && v[:handlers][:"linkbot-store"][:regex] && v[:handlers][:"linkbot-store"][:regex].match(command)
            cost = v[:ptr].respond_to?(:cost) ? v[:ptr].send(:cost).to_i : 0
            if check_karma(user, cost)
              begin
                mymsg = v[:ptr].send(v[:handlers][:"linkbot-store"][:handler], user, args).join("\n")
                deduct_karma(user, cost)
              rescue StoreError
                mymsg = $!.message
              end
            else
              mymsg = "Not enough karma"
            end
          end 
        }
      end
      
      
      if mymsg.nil?
        # Build out the menu
        mymsg = [
          "Karma Store",
          "-----------",
          "Buy some stuff with karma. To buy, just use the !store command, followed by the appropriate stuff.",
          ""
        ]
        
        num = 1
        Linkbot::Plugin.plugins.each {|k,v|
          if v[:handlers][:"linkbot-store"] && v[:ptr].respond_to?(:cost) && v[:ptr].respond_to?(:advertisement)
            mymsg << "#{num}. [COST #{v[:ptr].send(:cost)}] #{v[:ptr].send(:advertisement)}"
            num += 1
          end 
        }
        
        mymsg = mymsg.join("\n")
      end
      mymsg
    end
    
    def self.check_karma(user, cost)
      karma = Linkbot.db.execute("select karma from karma where user_id=#{user['id']}")[0][0]
      karma > cost
    end
    
    def self.deduct_karma(user, cost)
      karma = Linkbot.db.execute("select karma from karma where user_id=#{user['id']}")[0][0] - cost
      Linkbot.db.execute("update karma set karma=#{karma} where user_id=#{user['id']}")
    end
    
    def self.help
      "!store - Buy some shit"
    end
    
    Linkbot::Plugin.register('store', self,
      {
        :"direct-message" => {:regex => /!store(.*)/, :handler => :on_message, :help => :help},
      }
    )
end

class StoreError < StandardError
end
