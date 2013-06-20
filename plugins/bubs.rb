# encoding: utf-8

class Bubs < Linkbot::Plugin
    def self.on_message(message, matches)
      matches[0].tr('A-Za-z1-90', 'Ⓐ-Ⓩⓐ-ⓩ①-⑨⓪')
    end

    Linkbot::Plugin.register('bubs', self,
      {
        :message => {:regex => /!bubs (.*)/, :handler => :on_message}
      }
    )
end
