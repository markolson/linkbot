class Video < Linkbot::Plugin
  include HTTParty
  
  Linkbot::Plugin.register('video', self, {
    :message => {:regex => /^!video (.+)/i, :handler => :on_message, :help => :help}
  })

  def self.on_message(message, matches)
    default_videos = {
      "bear" => "FiARsQSlzDc",
      "das" => "SIt2CdbBo_w",
      "erlang" => "uKfKtXYLG78",
      "pizza" => "wusGIl3v044",
      "ra" => "Tb-gI_pFog0",
      "fail" => "1ytCEuuW2_A"
      "womp womp" => "yJxCdh1Ps48"
    }
    
    url = ""
    key = matches[0].strip
    if key.downcase == 'stop'
      url = "#{Linkbot::Config["plugins"]["video"]["base_uri"]}/youtube/stop"
    elsif default_videos.has_key?(key)
      url = "#{Linkbot::Config["plugins"]["video"]["base_uri"]}/youtube/#{default_videos[key]}"
    else
      url = "#{Linkbot::Config["plugins"]["video"]["base_uri"]}/youtube/#{key}"
    end
    
    get(url)
    ''
  end
  
  def self.help
    "!video (youtube video | stop) - play a video, or stop a video. Or call a built-in video. Or something."
  end
end
