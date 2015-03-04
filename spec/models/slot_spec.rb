require 'spec_helper'

describe Slot do
  subject do
    Slot.new(date: '2014-05-22', times: '1200-1600')
  end

  it "generates timestamps for the view" do
    subject.timestamps.should == [
     Time.parse("2014-05-22T12:00:00"),
     Time.parse("2014-05-22T16:00:00")
    ]
  end
end
