require 'spec_helper'

describe Linkbot::Plugin do
  let(:mock_plugins_path) { File.expand_path(File.join(File.dirname(__FILE__), "mocks", "plugins")) }
  let (:message) { Message.new("text", 1, "user", nil, :message, {room: "this_room"}) }

  describe "#collect" do
    it "loads plugins found in a given path" do
      Linkbot::Plugin.collect([mock_plugins_path])
      expect(Linkbot::Plugin.plugins.map(&:class)).to include(MockPlugin)
    end
  end

  describe "plugin message handling smoke test" do
    subject do
      Linkbot::Plugin.collect([mock_plugins_path])
      Linkbot::Plugin.plugins
                     .select { |p| p.class == MockPlugin }
                     .first
    end

    it "has the expected mock plugin" do
      expect(subject.class).to eq MockPlugin
      expect(subject.handlers).to eq({:message => {:regex => //, :handler => :on_message}})
    end

    it "handles a message" do
      plugin = subject
      response = Linkbot::Message.handle(message)

      expect(plugin.messages.length).to eq 1
      expect(plugin.messages[0].body).to eq "text"
      expect(response).to eq ['text']
    end
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

  describe '#unescape_octal' do
    it 'octal escapes get hex encoded and url escaped' do
      incoming = 'https://example.com/E\\75MC2'
      expected = 'https://example.com/E%3dMC2'
      expect(subject.unescape_octal(incoming)).to eq(expected)
    end

    it 'multiple octal escapes should be hex encoded' do
      incoming = 'https://example.com/\\50test\\75test\\51'
      expected = 'https://example.com/%28test%3dtest%29'
      expect(subject.unescape_octal(incoming)).to eq(expected)
    end

    it 'leaves a vanilla string untouched' do
      incoming = 'https://example.com/something_else'
      expected = 'https://example.com/something_else'
      expect(subject.unescape_octal(incoming)).to eq(expected)
    end
  end
end
