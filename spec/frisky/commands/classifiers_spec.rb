require "spec_helper"

require 'frisky/commands/classifiers'

Frisky::Classifier

describe Frisky::Commands::Classifiers do
  before :each do
    reset_databases
  end

  let (:command) { Frisky::Commands::Classifiers.new(load_classifiers: []) }
  let (:invalid_classifier) { "spec/fixtures/classifiers/invalid_class_classifier.rb" }
  let (:valid_classifier) { "spec/fixtures/classifiers/valid_classifier.rb" }
  let (:classifier_klass) { ValidClassifier }

  describe '#load_classifier' do
    it "tries to use an existing file, but it doesn't have the right class name" do
      expect { command.load_classifier(invalid_classifier) }.to raise_error(Frisky::InvalidClassName)
    end

    it "correctly loads a valid classifier" do
      command.load_classifier(valid_classifier)
      command.classifiers.size.should == 1
    end
  end

  describe '#announce_classifiers' do
    before :each do
      command.load_classifier(valid_classifier)
      command.announce_classifiers
    end

    it "announces the loaded classifiers" do
      time = Time.now.utc.to_i
      Frisky.redis.zrangebyscore("classifiers", time-60, time).length.should == 1
    end
  end
end