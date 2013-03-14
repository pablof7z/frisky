require 'spec_helper'
require 'fixtures/classifiers/valid_classifier.rb'

describe Frisky::Classifier do
  let (:klass) { ValidClassifier }

  describe ".included" do
    it "includes the commit callback" do
      klass.should respond_to :on_push
    end

    it "has the appropriate number of callbacks registered" do
    end

    it "has the right number of events registered" do
      klass.events.length.should == 1
    end

    it { klass.key(:events).should_not be_nil }
    it { expect { klass.key(:invalid_key)}.to raise_error NameError }
  end

  it { klass.should respond_to :events }
  it { klass.should respond_to :hooks }

  describe '.on_push' do
    it "correctly sets the push event" do
      klass.events.should include('PushEvent')
    end

    it "adds a handler for the push hook" do
      klass.hooks.keys.should include(:push)
    end
  end

  describe "::Queue" do
    let (:valid_event) do
      Octokit.public_events.select {|e| e.type == event_type}.first.to_json
    end

    describe ".announce" do
      it "announces the events supported by the classifier" do
        klass.announce
        Frisky.redis.smembers(klass.key(:events)).should include('PushEvent')
      end

      it "should expire the key in some time" do
        klass.announce
        Frisky.redis.ttl(klass.key(:events)).should > 0
      end
    end

    context "with a push event" do
      let (:event_type) { "PushEvent" }

      describe '.perform' do
        it "handles valid event properly" do
          klass.should_receive(:push_handler).with(kind_of(Frisky::Model::Repository), kind_of(Frisky::Model::Event))
          lambda { klass.perform(valid_event) }.should_not raise_error
        end
      end
    end
  end
end