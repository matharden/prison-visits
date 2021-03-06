require 'rails_helper'
require 'zmarshal'

RSpec.describe ZMarshal do
  it "knows how to dump and restore objects" do
    object = Array.new(100, 15)
    expect(ZMarshal.load(ZMarshal.dump(object))).to eq object
  end
end
