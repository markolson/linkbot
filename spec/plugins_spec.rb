require 'spec_helper'

HELP = "abcdefghijklmnopqrstuvwxyz"

describe Linkbot::Plugin do
  before(:each) do
    Linkbot::Plugin.collect([PLUGIN_PATH])
  end

  it "has one plugin" do
    expect(Linkbot::Plugin.plugins.keys.length).to eq 1
  end

end
