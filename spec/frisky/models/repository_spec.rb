require 'spec_helper'

require 'frisky/models/repository'

describe Frisky::Model::Repository do
  before :each do
    reset_databases
  end

  let (:klass) { Frisky::Model::Repository }
  let (:full_name) { "heelhook/frisky" }
  let (:minimal_raw) { stub(full_name: full_name) }

  describe ".soft_fetch" do
    let (:repo) { klass.soft_fetch(minimal_raw) }

    it "creates a partially-filled model when it doesn't exist" do
      repo.full_name.should == full_name
    end

    it "doesn't load using the fallback when not requested" do
      repo.no_proxy_name.should be_nil
    end

    it "fallbacks when required" do
      repo.name.should_not be_nil
    end

    context "using a name key instead of full_name" do
      let (:repo) do
        data = Class.new do
          attr_accessor :full_name, :name
          def delete(k); end;
          def respond_to?(k); (super(k) and self.send(k) != nil) == true; end
        end.new
        data.name = full_name
        klass.soft_fetch(data)
      end

      it "finds the repository" do
        repo.url.should_not be_nil
      end
    end
  end

  describe ".load_from_raw" do
    it "creates a model" do
      model = klass.load_from_raw(minimal_raw)
      model.full_name.should_not be_nil
    end
  end
end
