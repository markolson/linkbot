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
    :message => {:regex => /\A(?:n+o+[^\w]*(?:\s*))+\z/i, :handler => :on_message}
  })

  private

  def self.lots_of_nos
    [ 'http://i.imgur.com/Rd8xu.gif', # Arrested Development No. No. No. No no no.
      'http://i.imgur.com/XWAvo.gif', # The Office No! God! No! Please! Noooooooo!
      'http://i.imgur.com/816uC.gif', # Tracy Jordan No no no no no no HELL no
      'http://media.tumblr.com/tumblr_lvpj1lEg5N1qegw8v.gif', # fuzzy cap oh noooooo no
      'http://media.tumblr.com/tumblr_m42alaqSHG1rom4w3.gif', # Emma Stone nononononono, no!
      'http://media.tumblr.com/tumblr_m4ybpoVu2L1qhk160.gif', # B&W band no no no
      'http://media.tumblr.com/tumblr_m9t9sot19G1r1qmov.gif', # No no, did I mention? No.
      'http://cdn-w.sneakhype.com/wp-content/uploads/2013/03/super-duper-cool-pics-6.gif', # kitchen dancy nos
    ].sample
  end

  def self.emphatic_no
    [ 'http://i.imgur.com/g9qfN.gif', # hockey stick to the head
      'http://i.imgur.com/IzUaG.gif', # kick to the pant, NO!
      'http://i.imgur.com/NpAbl.gif', # The Office, silent hand-waving no
      'http://media.tumblr.com/tumblr_lxrls6dPET1qjzzyw.gif', # Buzz Noo-ooo-ooo-ooo!
      'http://media.tumblr.com/tumblr_lvpj5oH0sq1qegw8v.gif', # Aubrey Plaza No!
      'http://media.tumblr.com/tumblr_lvpizkYu881qegw8v.gif', # I love Lucy, NO!!
      'http://media.tumblr.com/tumblr_m42akbnDuy1rom4w3.gif', # Elf, NO!
      'http://25.media.tumblr.com/tumblr_m5c7h8cBMt1qii6tmo1_250.gif', # Lion King Noooooooo!
      'http://media.tumblr.com/155946280664f1c782c3806a439851b1/tumblr_inline_mf92lqbSUz1qisgmg.gif', # stitch
      'http://24.media.tumblr.com/tumblr_m4h3dgo59o1rwcc6bo1_250.gif', # Wolverine Nooooooo!
   ].sample
  end

  def self.simple_no
    [ 'http://i.imgur.com/BVzQk.gif', # disappointed Colbert
      'http://i.imgur.com/M0EKn.gif', # meditative no
      'http://i.imgur.com/4RnrF.gif', # Seinfeld finger wag
      'http://i.imgur.com/upqjk.gif', # Let me think about it, no.
      'http://24.media.tumblr.com/tumblr_lt29rodb0m1r3v6f2o1_500.gif', # Richard Madden thinks you're silly.
      'http://24.media.tumblr.com/tumblr_ls9dp4N9fX1r3v6f2o1_500.gif', # Sheldon shakes his head
      'http://media.tumblr.com/tumblr_lvpiwcs2um1qegw8v.gif', # typetypetype No.
      'http://media.tumblr.com/tumblr_lvpiwrnIhE1qegw8v.gif', #
      'http://media.tumblr.com/tumblr_lvpj4sUqUk1qegw8v.gif', # Psych Uh, no.
      'http://media.tumblr.com/tumblr_lvpj38aVmF1qegw8v.gif', # Sherlock Ummmm...no.
      'http://media.tumblr.com/tumblr_m48cdk5BNm1qert37.gif', # Adele don't care.
      'http://25.media.tumblr.com/tumblr_m36y50fVOC1r4kc4so2_250.gif', # Moriarty #no.
      'http://25.media.tumblr.com/tumblr_mb0dydfUJA1rq1vxuo1_500.gif', # Parks & Rec grumpy no.
      'http://media.tumblr.com/tumblr_ma0sa4FAAb1r1i0lk.gif', # shake my head
      'http://media.tumblr.com/tumblr_mchmayrwpD1rsj88k.gif', # Sheldon says no.
      'http://media.tumblr.com/tumblr_m32gxvuToI1ro2d43.gif', # Oprah is unimpressed
      'http://media.tumblr.com/tumblr_mamomlzSQI1qbt1zf.gif', # Dr. Watson thinks about it ... no.
      'http://media.tumblr.com/tumblr_lzc9otJ6KB1qgqauu.gif', # Dumbledore does not want more.
      'http://i.imgur.com/TX4ZJ.gif', # The Office head shaking
      'http://i.imgur.com/e0J9dxJ.gif', # Sloth says how about no
      'http://i1190.photobucket.com/albums/z458/AutomneLeafs/GIFs/No/no.gif', # Sherlock Oddly enough, no.
      'http://i1190.photobucket.com/albums/z458/AutomneLeafs/GIFs/No/256zbsp.gif', # Sherlock TXT Wrong wrong wrong.
      'http://i1190.photobucket.com/albums/z458/AutomneLeafs/GIFs/No/287i2pk.gif', # 9th Doctor, No.
      'http://i1190.photobucket.com/albums/z458/AutomneLeafs/GIFs/No/tumblr_lroqtuHuVk1qfp4oc.gif', # UP No.
    ].sample
  end

end

