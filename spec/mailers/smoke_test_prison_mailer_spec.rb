require "spec_helper"

describe SmokeTestPrisonMailer do
  it "is configured to send e-mails to a fake SMTP server" do
    SmokeTestPrisonMailer.smtp_settings.should == {address: nil, port: nil}
  end

  it "is configured with a template path pointing to the superclass' template path" do
    SmokeTestPrisonMailer.booking_request_email(sample_visit, 'irrelevant')
  end
end
