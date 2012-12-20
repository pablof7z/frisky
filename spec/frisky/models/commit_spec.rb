require 'spec_helper'

require 'frisky/models/commit'

describe Frisky::Model::Commit do
  before :each do
    reset_databases
  end

  let (:klass) { Frisky::Model::Commit }
  let (:repo_full_name) { "heelhook/frisky" }
  let (:repository) do
    repo = double
    repo.should_receive(:full_name).at_most(3).times.and_return(repo_full_name)
    repo
  end
  let (:minimal_raw) do
      t = double
      t.should_receive(:respond_to?).with(:id).at_most(3).times.and_return(true)
      t.should_receive(:respond_to?).at_most(10).times.and_return(false)
      t.should_receive(:repository).at_most(3).times.and_return(repository)
      t.should_receive(:author).at_least(0).times.and_return(Hashie::Mash.new(login: 'heelhook'))
      t.should_receive(:commit).at_least(0).times.and_return(nil)
      t.should_receive(:committer).and_return(nil)
      t.should_receive(:id).at_most(3).and_return('ad505b383910a933ac911b3b42500f4f7a2c5711')
      t
    end

  describe ".soft_fetch" do
    let (:commit) { klass.soft_fetch(minimal_raw) }

    it "creates a partially-filled model when it doesn't exist" do
      commit.repository.full_name.should == repo_full_name
    end

    it "fallbacks when required" do
      commit.author.class.should == Frisky::Model::Person
    end
  end

  describe ".load_from_raw" do
    let (:extended_raw) { minimal_raw }
    let (:commit) { klass.load_from_raw(extended_raw) }

    it "has a repository" do
      commit.repository.class.should == Frisky::Model::Repository
    end

    context "lazy loads with a fallback" do
      it "loads a message" do
        commit.message.should_not be_nil
      end

      it "has date" do
        commit.date.should_not be_nil
      end

      it "has stats" do
        commit.stats.total.should_not be_nil
      end

      it "has parents" do
        commit.parents.any?.should be_true
      end

      it "loads the parent message" do
        commit.parents.first.message.should_not be_nil
      end
    end

    context "with raw including the message" do
      let (:extended_raw) do
        t = double
        t.should_receive(:respond_to?).with(:id).at_most(3).times.and_return(true)
        t.should_receive(:respond_to?).with(:message).and_return(true)
        t.should_receive(:respond_to?).at_most(10).times.and_return(false)
        t.should_receive(:author).at_least(0).times.and_return(Hashie::Mash.new(login: 'heelhook'))
        t.should_receive(:commit).at_least(0).times.and_return(nil)
        t.should_receive(:committer).and_return(nil)
        t.should_receive(:message).at_most(2).times.and_return("got a message")
        t.should_receive(:repository).at_most(3).times.and_return(repository)
        t.should_receive(:id).at_most(3).and_return('ad505b383910a933ac911b3b42500f4f7a2c5711')
        t
      end

      it "loads a message" do
        commit.no_proxy_message.should_not be_nil
      end
    end

    context "with raw including the repository object" do
      # no full name so it would have failed if loading with soft_fetch
      let (:repository) do
        r = Frisky::Model::Repository.new
        r.should_receive(:full_name).exactly(0).times
        r
      end
      let (:extended_raw) { minimal_raw }
      let (:commit) { klass.load_from_raw(extended_raw) }

      it "has a repo without using soft_fetch" do
        commit.repository.should_not be_nil
      end
    end

    context "loading a specific real commit" do
      let (:repository) { Frisky::Model::Repository.new(full_name: 'heelhook/frisky') }
      let (:commit) { Frisky::Model::Commit.soft_fetch(repository: repository, sha: '9621e8f6f31d733f68834a814d2ce2a74c19edc8') }

      it "has files" do
        commit.files.size.should > 0
      end

      it "has parents" do
        commit.parents.size.should > 0
      end
    end

    context "loading a specific real commit that has no login for author or committer" do
      let (:repository) { Frisky::Model::Repository.new(full_name: 'pengwynn/octokit') }
      let (:commit) { Frisky::Model::Commit.soft_fetch(repository: repository, sha: '83c3c5bc39f863b3568ae0c6cb408d90274e2ca5') }

      it "loads the commit parent" do
        commit.parents.count.should == 1
      end

      it "gets the commit author data" do
        commit.author.name.should == 'Andrew Brader'
      end

      it "gets the commit committer information" do
        commit.committer.name.should == 'Andrew Brader'
      end
    end
  end
end
