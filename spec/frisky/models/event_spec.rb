require 'spec_helper'

require 'frisky/helpers/github'
require 'frisky/models/event'

describe Frisky::Model::Event do
  before do
    @events = Frisky::Helpers::GitHub.fetch_events
  end

  before :each do
    Frisky::Model::Event.collection.remove
  end

  let (:push_event_hash) { @events.select {|e| e['type'] == 'PushEvent'}.first }
  let (:non_push_event_hash) { @events.select {|e| e['type'] != 'PushEvent'}.first }

  it "has many events" do
    @events.count.should >= 10
  end

  it "has a push event" do
    push_event_hash.should_not be_nil
  end

  it "has a non push event" do
    non_push_event_hash.should_not be_nil
  end



  context "push event" do
    let (:event) { Frisky::Model::Event.new(push_event_hash) }

    it "is a push event" do
      event.push?.should be_true
    end

    it "has commits referenced" do
      event.commits.count.should >= 1
    end
  end



  context "non push event" do
    let (:event) { Frisky::Model::Event.new(non_push_event_hash) }

    it "is not a push event" do
      event.push?.should be_false
    end
  end

  context ".exists?" do
    let (:event) { Frisky::Model::Event.new(push_event_hash) }

    it "doesn't exist before its created" do
      Frisky::Model::Event.exists?(push_event_hash).should be_false
    end

    it "exists after its created" do
      event.save!
      Frisky::Model::Event.exists?(push_event_hash).should be_true
    end
  end
end