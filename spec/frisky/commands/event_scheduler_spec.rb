require 'spec_helper'

require 'frisky/commands/event_scheduler'

describe Frisky::Commands::EventScheduler do
  before do
    Frisky::Model::Event.collection.remove
  end

  context "perform without looping" do
    before do
      Frisky::Commands::EventScheduler.run("frisky-event-scheduler", url: "https://api.github.com/events", :loop => false)
    end

    it "creates about 30 events" do
      Frisky::Model::Event.count.should >= 20
    end
  end
end