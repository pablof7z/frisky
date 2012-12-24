require 'spec_helper'

require 'frisky/models/proxy_base'

describe Frisky::Model::ProxyBase do
  before :each do
    reset_databases
  end

  let (:klass) { Frisky::Model::ProxyBase }

  describe ".fetch_key" do
    let (:base) { Class.new(klass) }

    it "fails when provided an invalid key" do
      expect { klass.new.class_eval { fetch_key "test" } }.to raise_error NameError
    end

    it "sets a symbol correctly" do
      base.fetch_key :symbol1
      base.instance_variable_get(:@fetch_keys).keys.should == [:symbol1]
    end

    it "sets two symbols correctly" do
      base.fetch_key :symbol1, :symbol2
      base.instance_variable_get(:@fetch_keys).keys.should == [:symbol1, :symbol2]
    end

    it "allows adding keys with further calls" do
      base.fetch_key :symbol1
      base.fetch_key :symbol2

      base.instance_variable_get(:@fetch_keys).keys.should == [:symbol1, :symbol2]
    end

    it "sets a lambda correctly" do
      base.fetch_key symbol1: lambda { "test" }
      base.instance_variable_get(:@fetch_keys).keys.should == [:symbol1]
      base.instance_variable_get(:@fetch_keys).values.first.class.should == Proc
    end

    it "sets a symbol and a lambda correctly" do
      base.fetch_key :symbol1, symbol2: lambda { "test" }
      base.instance_variable_get(:@fetch_keys).keys.should == [:symbol1, :symbol2]
      base.instance_variable_get(:@fetch_keys).values[1].class.should == Proc
    end
  end

  describe ".soft_fetch" do
    let (:object_base) do
      t = Class.new(klass) do
        attr_accessor :full_name, :name

        def new?; true; end
        def save; true; end
      end
      t.fetch_autoload :name
      t
    end

    context "using symbols" do
      let (:base) do
        object_base.fetch_key :symbol1
      end

      let (:raw) do
        raw = double
        raw.should_receive(:respond_to?).with(:symbol1).and_return(true)
        raw.should_receive(:respond_to?).with(:name).and_return(true)
        raw.should_receive(:symbol1).and_return(:symbol1)
        raw.should_receive(:name).and_return("symbol1")
        raw
      end

      it { base.soft_fetch(raw).name.should == 'symbol1' }
    end

    context "using procs" do
      let (:base) do
        object_base.fetch_key symbol1: Proc.new { full_name || name }
      end

      let (:raw) do
        raw = double
        raw.should_receive(:respond_to?).with(:name).and_return(true)
        raw.should_receive(:full_name).and_return(nil)
        raw.should_receive(:name).at_most(:twice).and_return("symbol1")
        raw
      end

      it { base.soft_fetch(raw).name.should == 'symbol1' }
    end
  end
end
