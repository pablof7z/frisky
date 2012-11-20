require 'spec_helper'
require 'frisky/helpers/github.rb'

describe Frisky::Helpers::GitHub do
  context '.fetch_url' do
    it "fetches urls" do
      Frisky::Helpers::GitHub.fetch_url("https://api.github.com/events").is_a?(Array).should be_true
    end

    it "needs authentication to fetch a /user url" do
      lambda { Frisky::Helpers::GitHub.fetch_url("https://api.github.com/user") }.should raise_error OpenURI::HTTPError
    end
  end

  context ".create_url" do
    it "creates a url without client_id when there are no settings" do
      Frisky::Helpers::GitHub.create_url('https://api.github.com/events').include?("client_id").should be_false
    end

    it "creates a url using client_id when it has settings" do
      unless ENV['GITHUB_CLIENT_ID'].blank? or ENV['GITHUB_CLIENT_SECRET'].blank?
        Frisky::Helpers::GitHub.client_id     = ENV['GITHUB_CLIENT_ID']
        Frisky::Helpers::GitHub.client_secret = ENV['GITHUB_CLIENT_SECRET']

        Frisky::Helpers::GitHub.create_url('https://api.github.com/events').include?("client_id").should be_true
      end
    end

    it "doesn't override client_id when its manually set" do
      Frisky::Helpers::GitHub.client_id     = "wrong"
      Frisky::Helpers::GitHub.client_secret = "wrong"

      Frisky::Helpers::GitHub.create_url('https://api.github.com/events?client_id=right').include?("client_id=right").should be_true
    end

    it "includes a per_page parameter of 100" do
      Frisky::Helpers::GitHub.create_url('https://api.github.com/events').include?("per_page=100").should be_true
    end

    context "with a custom per_page size" do
      let(:per_page) { 200 }

      it "includes a per_page parameter of 200" do
        Frisky::Helpers::GitHub.per_page = per_page
        Frisky::Helpers::GitHub.create_url('https://api.github.com/events').include?("per_page=#{per_page}").should be_true
      end
    end
  end
end