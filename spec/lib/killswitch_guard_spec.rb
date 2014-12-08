require 'spec_helper'

describe KillswitchGuard, type: :controller do
  controller do
    include KillswitchGuard

    def index
      render text: 'OK'
    end
  end

  context "killswitch enabled" do
    it "resets the session and redirects to step one" do
      controller.stub(killswitch_active?: true)
      controller.should_receive(:reset_session)
      get :index
      response.should redirect_to edit_prisoner_details_path
    end
  end

  context "killswitch disabled" do
    it "doesn't do anything" do
      controller.stub(killswitch_active?: false)
      controller.should_receive(:reset_session).never
      get :index
      response.should be_success
    end
  end
end