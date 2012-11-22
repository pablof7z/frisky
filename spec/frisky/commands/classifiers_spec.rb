require "spec_helper"

require 'frisky/commands/classifiers'

Frisky::Classifier

describe Frisky::Commands::Classifiers do
  before :each do
    Frisky.reset_classifiers!
  end

  context "attempts to load a classifier with a particular name" do
    it "loads at least one classifier" do
      Frisky::Commands::Classifiers.new
      Frisky.classifiers.size.should >= 1
    end

    it "loads no classifiers when it explicitly requests a non existent classifier name" do
      lambda { Frisky::Commands::Classifiers.new(load_classifiers: ['NonexistentClassifier'], mute: true) }.should raise_error SystemExit
    end

    it "loads one classifier when it explicitly has an existent classifier name" do
      Frisky::Commands::Classifiers.new
      Frisky.classifiers.size.should == 1
    end
  end
end