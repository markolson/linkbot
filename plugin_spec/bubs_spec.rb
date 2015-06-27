require 'spec_helper'
require_relative '../plugins/bubs'
describe Bubs do
  let(:subject) { Bubs.new }
  it "responds with ⓑⓤⓑⓑⓛⓔ ⓣⓔⓧⓣ" do
    output = subject.on_message "!bubs Bubbalicious", ["Bubbalicious"]
    expect(output).to eq("Ⓑⓤⓑⓑⓐⓛⓘⓒⓘⓞⓤⓢ")
  end
end
