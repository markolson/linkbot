require 'spec_helper'

describe Linkbot::Plugin do
  before(:each) do
    Linkbot::Plugin.collect([PLUGIN_PATH])
  end

  it "has the correct plugin" do
    expect(Linkbot::Plugin.plugins.keys.length).to eq 1
    expect(Linkbot::Plugin.plugins['mock'][:ptr]).to eq MockPlugin
    expect(Linkbot::Plugin.plugins['mock'][:handlers]).to eq({:message => {:regex => //, :handler => :on_message, :help => :help}})
  end

  it "handles a message" do
    plugin = Linkbot::Plugin.plugins['mock'][:ptr]
    response = Linkbot::Message.handle(Message.new("text", 1, "user", nil, :message, {}))

    expect(plugin.messages.length).to eq 1
    expect(plugin.messages[0].body).to eq "text"
    expect(response).to eq ['text']
  end
end
