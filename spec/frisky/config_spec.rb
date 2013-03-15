require 'spec_helper'

describe Frisky do
  context "multiple github tokens" do
    before :all do
      Frisky.config = {
        'github' => {
          'keys' => [
            "abcd:abcd",
            "efgh:efgh",
            "ijkl:ijkl"
          ]
        },
        'mongo' => 'mongodb://127.0.0.1/test'
      }
    end

    it "uses different tokens" do
      used_tokens = []
      100.times do # Montecarlo!
        client_id, client_secret = Octokit.client_id, Octokit.client_secret
        used_tokens |= [client_id]

        client_id.should == client_secret
      end

      used_tokens.length.should == 3
    end
  end
end

# Put the right credentials back in place
Frisky.config_file "#{File.dirname(__FILE__)}/../../frisky.yml"