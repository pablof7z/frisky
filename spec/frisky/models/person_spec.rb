require 'spec_helper'

require 'frisky/models/person'

describe Frisky::Model::Person do
  before :each do
    reset_databases
  end

  let (:klass) { Frisky::Model::Person }
  let (:login) { "heelhook" }
  let (:minimal_raw) { stub(login: login) }

  describe ".soft_fetch" do
    let (:user) { klass.soft_fetch(minimal_raw) }

    it "creates a partially-filled model when it doesn't exist" do
      user.login.should == login
    end

    it "doesn't load using the fallback when not requested" do
      user.no_proxy_name.should be_nil
    end

    it "fallbacks when required" do
      user.name.should_not be_nil
    end
  end

  describe ".load_from_raw" do
    it "creates a model" do
      model = klass.load_from_raw(minimal_raw)
      model.login.should_not be_nil
    end
  end
end
