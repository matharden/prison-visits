require "spec_helper"

describe SmokeTestVisitorMailer do
  it "is configured to send e-mails to a fake SMTP server" do
    SmokeTestVisitorMailer.smtp_settings.should == {address: nil, port: nil}
  end

  it "is configured with a template path pointing to the superclass' template path" do
    SmokeTestVisitorMailer.instant_confirmation_email(sample_visit)
  end
end
