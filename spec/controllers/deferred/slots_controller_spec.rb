require 'spec_helper'

describe Deferred::SlotsController do
  render_views

  before :each do
    Timecop.freeze(Time.local(2013, 12, 1, 12, 0))
    session[:visit] = Visit.new(visit_id: SecureRandom.hex, prisoner: Prisoner.new, visitors: [Visitor.new], slots: [])
    cookies['cookies-enabled'] = 1
    controller.stub(smoke_testing?: false)
  end

  after :each do
    Timecop.return
  end
  
  it_behaves_like "a browser without a session present"
  it_behaves_like "a session timed out"

  it "sets up the flow" do
    controller.this_path.should == deferred_edit_slots_path
    controller.next_path.should == deferred_edit_visit_path
  end

  it "permits up to 3 slots to be selected" do
    controller.max_slots.should == 3
  end

  context "correct slot information" do
    let(:slots_hash) do
      {
        visit: {
          slots: [
                  {
                    slot: '2013-01-01-1345-2000'
                  }
                 ]
        },
      }
    end

    it "permits us to select a time slot" do
      post :update, slots_hash
      response.should redirect_to(controller.next_path)
    end
  end

  context "no slots" do
    let(:slots_hash) do
      {
        visit: { slots: [{slot: ''}] }
      }
    end

    it "prompts us to retry" do
      post :update, slots_hash
      response.should redirect_to(controller.this_path)
    end
  end

  context "exactly three slots" do
    let(:slots_hash) do
      {
        visit: { slots: [{slot: '2013-01-01-1200-1300'}] * 3 }
      }
    end

    it "accepts the submission" do
      post :update, slots_hash
      response.should redirect_to(controller.next_path)
    end
  end

  context "exactly two slots" do
    let(:slots_hash) do
      {
        visit: { slots: [{slot: '2013-01-01-1200-1300'}] * 2 }
      }
    end

    it "accepts the submission" do
      post :update, slots_hash
      response.should redirect_to(controller.next_path)
    end
  end

  context "too many slots" do
    let(:slots_hash) do
      {
        visit: { slots: [{ slot: '2013-01-01-1200-1300' }] * 4 }
      }
    end

    it "prompts us to retry" do
      post :update, slots_hash
      response.should redirect_to(controller.this_path)
      session[:visit].errors[:slots].should_not be_nil
    end
  end
end
