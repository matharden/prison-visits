require 'spec_helper'

describe GeckoboardController do
  context "IP & key restrictions" do
    it "are enabled" do
      controller.should_receive(:reject_untrusted_ips_and_without_key!)
      get :leaderboard
    end
  end
end