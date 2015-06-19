# encoding: UTF-8
class LookOfDisapproval < Linkbot::Plugin

  def self.on_message(message, matches)
    'ಠ_ಠ'
  end

  register :regex => /^.*wtf.*$/
