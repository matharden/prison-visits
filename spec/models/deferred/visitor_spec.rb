require 'spec_helper'

describe Deferred::Visitor do
  before :each do
    EmailValidator.any_instance.stub(:validate)
  end

  let :visitor do
    subject.tap do |v|
      v.first_name = 'Otto'
      v.last_name = 'Fibonacci'
      v.email = 'test@maildrop.dsd.io'
      v.date_of_birth = 30.years.ago
      v.phone = '09998887777'
    end
  end

  it_behaves_like 'a visitor'

  it "validates the first visitor as a lead visitor" do
    subject.tap do |v|
      v.index = 0

      v.first_name = 'Jimmy'
      v.should_not be_valid

      v.last_name = 'Harris'
      v.should_not be_valid

      v.date_of_birth = Date.parse "1986-04-20"
      v.should_not be_valid

      v.email = 'jimmy@maildrop.dsd.io'
      v.should_not be_valid
      
      v.phone = '01344 123456'
      v.should be_valid
    end
  end

  it "requires no e-mail for each successive visitor" do
    subject.tap do |v|
      v.index = 1
      v.first_name = 'Jimmy'
      v.last_name = 'Harris'
      v.date_of_birth = Date.parse "1984-04-20"
      v.should be_valid
    end
  end
end
