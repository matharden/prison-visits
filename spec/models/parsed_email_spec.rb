# -*- coding: utf-8 -*-
require 'spec_helper'

describe ParsedEmail do
  context "given valid data" do
    let :data do
      {
        from: "Some Dude <some.dude@digital.justice.gov.uk>",
        to: 'test@example.com',
        text: "some text",
        charsets: {to: "UTF-8", html: "utf-8", subject: "UTF-8", from: "UTF-8", text: "utf-8"}.to_json,
        subject: "important email",
      }
    end
    
    it "parses the email" do
      ParsedEmail.parse(data).should be_valid
    end

    it "reports the source as coming in from a visitor" do
      ParsedEmail.parse(data).source.should == :visitor
    end
  end

  context "given data from hotmail.com" do
    let :data do
      {
        from: "=?ISO-8859-1?Q?Keld_J=F8rn_Simonsen?= <keld@dkuug.dk>",
        to: 'test@example.com',
        text: "æ".encode('windows-1252'),
        charsets: {to: "utf-8", subject: "windows-1252", from: "utf-8", text: "windows-1252"}.to_json,
        subject: "Wøt up?".encode('windows-1252')
      }
    end

    it "parses the email" do
      email = ParsedEmail.parse(data)
      email.should be_valid

      email.from.display_name.should == "Keld Jørn Simonsen"
      email.subject.should == "Wøt up?"
      email.text.should == "æ"
    end
  end

  context "when an e-mail from the prison comes in" do
    let :data do
      {
        from: "HMP Prison <prison@hmps.gsi.gov.uk>",
        to: 'test@example.com',
        text: "some text",
        charsets: {to: "UTF-8", html: "utf-8", subject: "UTF-8", from: "UTF-8", text: "utf-8"}.to_json,
        subject: "important email",
      }
    end

    it "reports the source as 'prison'" do
      ParsedEmail.parse(data).source.should == :prison
    end
  end
end