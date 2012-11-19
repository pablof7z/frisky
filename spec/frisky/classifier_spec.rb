require 'spec_helper'

describe Frisky::Classifier do
  class TestClassifier
    include Frisky::Classifier

    commit :commit_callback

    def commit_callback(obj)
    end
  end



  describe ".included" do
    let (:klass) { TestClassifier }

    it "includes the commit callback" do
      klass.should respond_to :commit
    end

    it "includes the finalize callback" do
      klass.should respond_to :finalize
    end
  end




  describe '#new' do
    let (:test_classifier) { TestClassifier.new }

    it "has an id" do
      test_classifier.id.should == TestClassifier.name
    end
  end
end