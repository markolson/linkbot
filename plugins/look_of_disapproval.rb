# encoding: UTF-8
class LookOfDisapproval < Linkbot::Plugin

  def self.on_message(message, matches)
    'ಠ_ಠ'
  end

  Linkbot::Plugin.register('lod', self, {
    :message => {:regex => /^.*wtf.*$/, :handler => :on_message}
  })
end
