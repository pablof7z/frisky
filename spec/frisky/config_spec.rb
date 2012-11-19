require 'spec_helper'

describe Frisky::Config do
  let (:config) { Frisky::Config }

  context "when its not initialized" do
    describe ".valid?" do
      it "fails" do
        config.valid?.should be_false
      end
    end
  end

  context "when its initialized" do
    before :all do
      config.config = {mongo: MONGO_URI, redis: REDIS_HOSTNAME}
    end

    describe ".valid?" do
      it { config.valid?.should be_true }
    end
  end
end