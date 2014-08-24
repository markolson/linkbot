class StoreHelp < Linkbot::Plugin
    def self.on_store(args)
      mymsg = nil
      
      if args.length > 0
        Linkbot::Plugin.plugins.each {|k,v|
          if v[:handlers][:"linkbot-store"] && v[:handlers][:"linkbot-store"][:help] && v[:handlers][:"linkbot-store"][:regex].match(args[0])
            mymsg = v[:ptr].send(v[:handlers][:"linkbot-store"][:help])
          end 
        }
      end
      
      mymsg
    end
    
    
    Linkbot::Plugin.register('store_help', self,
      {
        :"linkbot-store" => {:regex => /^help$/, :handler => :on_store},
      }
    )
end
