require 'spec_helper'

require 'frisky/models/event'

describe Frisky::Model::Event do
  before :each do
    reset_databases
  end

  let!(:raw_events) { Octokit.public_events }

  describe ".load_from_raw" do
    let(:event) { Frisky::Model::Event.load_from_raw(raw_events.first) }

    it "has a type" do
      event.type.should_not be_nil
    end

    it "has a person" do
      event.actor.class.should == Frisky::Model::Person
    end

    it "doesn't create it in the database" do
      event
      Frisky::Model::Event.count.should == 0
    end
  end

  context "on a push event" do
    let (:event) do
      e = raw_events.select{|event| event.type == 'PushEvent' and event.payload.commits.any? }.first
      Frisky::Model::Event.load_from_raw(e)
    end

    it "has a person" do
      event.actor.class.should == Frisky::Model::Person
    end

    it "has a repository" do
      event.repository.class.should == Frisky::Model::Repository
    end

    it "has commits" do
      event.commits.any?.should be_true
    end

    it "has only valid commit objects" do
      event.commits.select {|a| a.is_a? Frisky::Model::Commit }.size.should == event.commits.size
    end

    it "has a valid creation date" do
      event.created_at.class.should == DateTime
    end
  end
end
