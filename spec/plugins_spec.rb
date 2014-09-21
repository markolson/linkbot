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
    Linkbot::Plugin.handle_message(Message.new("text", 1, "user", nil, nil, {}))

    expect(plugin.messages.length).to eq 1
    expect(plugin.messages).to eq "text"
  end
end
