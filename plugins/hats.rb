class Hats < Linkbot::Plugin
    def self.on_store(args)
      mymsg = nil
      
      if args.length > 0
        hatname = args.join(" ").downcase
        hat = nil
        hats.each {|k,v| hat = v if k.downcase == hatname}
        if hat.nil?
          raise StoreError.new("That hat does not exist")
        else
          # First check to see if the user already has a hat. If so, replace it and up the counter.
          rows = Linkbot.db.execute("select count from hats where user_id=#{user['id']}")
          if rows.length == 1
            count = rows[0][0].to_i + 10
            Linkbot.db.execute("update hats set count=#{count},url='#{hat}' where user_id=#{user['id']}")
          else
            Linkbot.db.execute("insert into hats (user_id,url,count) VALUES (#{user['id']},'#{hat}',10)")
          end
          mymsg = "Hat purchased!"
        end
      end
      
      [mymsg]
    end
    
    def self.on_message(message, matches, msg)
      mymsg = nil
      x = rand(10)
      if x == 0
        rows = Linkbot.db.execute("select h.url,h.count,u.showname from hats h, users u where u.user_id=#{user['id']} and h.user_id=#{user['id']}")
        if rows.length == 1
          url,count,showname = rows[0]
          mymsg = "#{showname}'s hat: #{url}"
          count = count - 1
          if count == 0 
            Linkbot.db.execute("delete from hats where user_id=#{user['id']}")
          else
            Linkbot.db.execute("update hats set count=#{count} where user_id=#{user['id']}")
          end
        end
      end
      [mymsg]
    end
    
    def self.cost
      5
    end
    
    def self.advertisement
      "hat (hat name): Buy a hat for a little while! Type '!store help hat' for a listing of hats."
    end
    
    def self.help
      h = [
        "Available Hats:",
        "---------------"
      ]
      
      num = 1
      hats.each do |k,v|
        h << "#{num}. #{k}"
        num += 1
      end
      
      h.join("\n")
    end
    
    def self.hats
      {
        "Cowboy Hat" => "http://dl.dropbox.com/u/10931735/hats/cowboyhat.jpg",
        "Hard Hat" => "http://dl.dropbox.com/u/10931735/hats/hardhat.jpg",
        "Tophat" => "http://dl.dropbox.com/u/10931735/hats/tophat.jpg",
        "Mario Hat" => "http://dl.dropbox.com/u/10931735/hats/mario.jpg",
        "Cat in the Hat" => "http://dl.dropbox.com/u/10931735/hats/catinthehat.jpg"
      }
    end
    
    if Linkbot.db.table_info('hats').empty?
      Linkbot.db.execute('CREATE TABLE hats (user_id INTEGER, url TEXT, count INTEGER)')
    end
    
    Linkbot::Plugin.register('hats', self,
      {
        :"linkbot-store" => {:regex => /^hat$/, :handler => :on_store, :help => :help},
        :message => {:handler => :on_message}
      }
    )
end
