class Titles < Linkbot::Plugin
    def self.on_store(args)
      mymsg = nil
      
      if args.length > 1
        target_user = args.shift
        rows = Linkbot.db.execute("select username,showname from users where username='#{target_user}'")
        if rows.length == 0
          raise StoreError.new("Unknown user")
        else
          old_username = (rows[0][1].nil? || rows[0][1] == '') ? rows[0][0] : rows[0][1]
          new_username = args.join(" ")
          Linkbot.db.execute("update users set showname='#{new_username}' where username='#{target_user}'")
          mymsg = "'#{old_username}' is now known as '#{new_username}'"
        end
      end
      
      mymsg
    end
    
    def self.cost
      50
    end
    
    def self.advertisement
      "name (username) (new name): Change how a user's name appears in any linkbot command."
    end
    
    Linkbot::Plugin.register('titles', self,
      {
        :"linkbot-store" => {:regex => /^name$/, :handler => :on_store},
      }
    )
end
