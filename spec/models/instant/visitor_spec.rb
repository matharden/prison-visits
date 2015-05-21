require 'spec_helper'

describe Instant::Visitor do
  before :each do
    EmailValidator.any_instance.stub(:validate_dns_records)
    EmailValidator.any_instance.stub(:validate_spam_reporter)
    EmailValidator.any_instance.stub(:validate_bounced)
  end

  let :visitor do
    subject.tap do |v|
      v.first_name = 'Otto'
      v.last_name = 'Fibonacci'
      v.email = 'test@maildrop.dsd.io'
      v.date_of_birth = 30.years.ago
    end
  end

  it 'generates an initial from the last name' do
    visitor.last_initial.should == 'F'
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
      v.should be_valid
    end
  end
end
