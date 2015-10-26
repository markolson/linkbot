require 'spec_helper'

describe Linkbot::Plugin do
  before(:each) do
    Linkbot::Plugin.collect([PLUGIN_PATH])
  end

  let (:message) { Message.new("text", 1, "user", nil, :message, {room: "this_room"}) }

  it "has the correct plugin" do
    expect(Linkbot::Plugin.plugins.length).to eq 1
    expect(Linkbot::Plugin.plugins.first.class).to eq MockPlugin
    expect(Linkbot::Plugin.plugins.first.handlers).to eq({:message => {:regex => //, :handler => :on_message}})
  end

  it "handles a message" do
    plugin = Linkbot::Plugin.plugins.first
    response = Linkbot::Message.handle(message)

    expect(plugin.messages.length).to eq 1
    expect(plugin.messages[0].body).to eq "text"
    expect(response).to eq ['text']
  end

  context "MockPlugin" do
    subject {MockPlugin.new}
    context "has permission" do

      it "when there is no room associated with a message" do
        message.options = {}

        expect(subject.has_permission?(message)).to be true
      end

      it "when no explicit permissions are set" do
        ::Linkbot::Config["permissions"] = nil

        expect(subject.has_permission?(message)).to be true
      end

      it "when permissions are set, but not for this room" do
        ::Linkbot::Config["permissions"] = {
          "not_this_room" => { "whitelist" => ["not_this_plugin"] } }

        expect(subject.has_permission?(message)).to be true
      end

      it "when this room whitelists this plugin" do
        ::Linkbot::Config["permissions"] = {
          "this_room" => { "whitelist" => ["MockPlugin"] } }

        expect(subject.has_permission?(message)).to be true
      end

      it "when this room blacklists other plugins, but not this one" do
        ::Linkbot::Config["permissions"] = {
          "this_room" => { "blacklist" => ["some", "other", "plugins"] } }

        expect(subject.has_permission?(message)).to be true
      end

      it "when this room both whitelists and blacklists this plugin" do
        ::Linkbot::Config["permissions"] = {
          "this_room" => { "whitelist" => ["MockPlugin"],
            "blacklist" => ["Linkbot::Plugin"] } }
        expect(subject.has_permission?(message)).to be true
      end
    end

    context "does not have permission" do

      it "when this room whitelists other plugins, but not this one" do
        ::Linkbot::Config["permissions"] = {
          "this_room" => { "whitelist" => ["some", "other", "plugins"] } }

        expect(subject.has_permission?(message)).to be false
      end

      it "when this room blacklists this plugin" do
        ::Linkbot::Config["permissions"] = {
          "this_room" => { "blacklist" => ["MockPlugin"] } }

        expect(subject.has_permission?(message)).to be false
      end
    end
  end
end
