class No < Linkbot::Plugin

  def self.on_message(message, matches)
    case
    when message.body.scan(/n+o+/i).count > 1
      self.lots_of_nos
    when message.body.match(/n+o+!/i)
      self.emphatic_no
    when message.body.match(/noo+/i)
      self.emphatic_no
    else
      self.simple_no
    end
  end

  Linkbot::Plugin.register('no', self, {
    :message => {:regex => /\A(?:n+o+[^\w]*(?:\s+)?)+\Z/i, :handler => :on_message}
  })

  private

  def self.lots_of_nos
    %w( http://i.imgur.com/Rd8xu.gif
        http://i.imgur.com/XWAvo.gif
        http://i.imgur.com/816uC.gif
        http://media.tumblr.com/tumblr_lvpj1lEg5N1qegw8v.gif
        http://media.tumblr.com/tumblr_m42alaqSHG1rom4w3.gif
        http://media.tumblr.com/tumblr_m4ybpoVu2L1qhk160.gif
        http://media.tumblr.com/tumblr_m9t9sot19G1r1qmov.gif
      ).sample
  end

  def self.emphatic_no
    %w( http://i.imgur.com/g9qfN.gif
        http://i.imgur.com/IzUaG.gif
        http://i.imgur.com/NpAbl.gif
        http://media.tumblr.com/tumblr_lxrls6dPET1qjzzyw.gif
        http://media.tumblr.com/tumblr_lvpj5oH0sq1qegw8v.gif
        http://media.tumblr.com/tumblr_lvpizkYu881qegw8v.gif
        http://media.tumblr.com/tumblr_m42akbnDuy1rom4w3.gif
        http://25.media.tumblr.com/tumblr_m5c7h8cBMt1qii6tmo1_250.gif
        http://media.tumblr.com/155946280664f1c782c3806a439851b1/tumblr_inline_mf92lqbSUz1qisgmg.gif
      ).sample
  end

  def self.simple_no
    %w( http://i.imgur.com/BVzQk.gif
        http://i.imgur.com/M0EKn.gif
        http://i.imgur.com/4RnrF.gif
        http://i.imgur.com/upqjk.gif
        http://24.media.tumblr.com/tumblr_lt29rodb0m1r3v6f2o1_500.gif
        http://24.media.tumblr.com/tumblr_ls9dp4N9fX1r3v6f2o1_500.gif
        http://media.tumblr.com/tumblr_lvpiwcs2um1qegw8v.gif
        http://media.tumblr.com/tumblr_lvpiwrnIhE1qegw8v.gif
        http://media.tumblr.com/tumblr_lvpj4sUqUk1qegw8v.gif
        http://media.tumblr.com/tumblr_lvpj38aVmF1qegw8v.gif
        http://media.tumblr.com/tumblr_m48cdk5BNm1qert37.gif
        http://24.media.tumblr.com/tumblr_m4h3dgo59o1rwcc6bo1_250.gif
        http://25.media.tumblr.com/tumblr_m36y50fVOC1r4kc4so2_250.gif
        http://25.media.tumblr.com/tumblr_mb0dydfUJA1rq1vxuo1_500.gif
        http://media.tumblr.com/tumblr_ma0sa4FAAb1r1i0lk.gif
        http://media.tumblr.com/tumblr_mchmayrwpD1rsj88k.gif
        http://media.tumblr.com/tumblr_m32gxvuToI1ro2d43.gif
        http://media.tumblr.com/tumblr_mamomlzSQI1qbt1zf.gif
        http://media.tumblr.com/tumblr_lzc9otJ6KB1qgqauu.gif
        http://i.imgur.com/TX4ZJ.gif
        http://media.tumblr.com/tumblr_lm8m7jqb7s1qza6y2.gif
      ).sample
  end

end

