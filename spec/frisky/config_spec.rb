require 'spec_helper'

describe "Frisky::Config" do
  let (:config) { Frisky }

  context "when its initialized" do
    describe ".valid?" do
      it { config.valid?.should be_true }
    end
  end

  context "when its not initialized" do
    before { Frisky.reset! }

    describe ".valid?" do
      it "fails" do
        config.valid?.should be_false
      end
    end
  end
end