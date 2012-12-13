require 'spec_helper'
require 'fixtures/classifiers/valid_classifier.rb'

describe Frisky::Classifier do
  let (:klass) { ValidClassifier }

  describe ".included" do
    it "includes the commit callback" do
      klass.should respond_to :on_commit
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

  describe '.on_commit' do
    it "correctly sets the push event" do
      klass.events.should include('PushEvent')
    end

    it "adds a handler for the commit hook" do
      klass.hooks.keys.should include(:commit)
    end
  end

  describe "::Queue" do
    let (:valid_event) { {id: '1234', type: 'PushEvent'}.to_json }
    let (:invalid_event) { {id: '1234', type: 'InexistentEvent'}.to_json }

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

    describe '.perform' do
      it "errors on unhandled event" do
        expect { klass.perform(invalid_event) }.to raise_error Frisky::NotImplemented
      end

      it "handles valid event properly" do
        lambda { klass.perform(valid_event) }.should_not raise_error
      end

      it "raises no error on invalid json" do
        lambda { klass.perform('invalid json') }.should_not raise_error
      end
    end
  end
end