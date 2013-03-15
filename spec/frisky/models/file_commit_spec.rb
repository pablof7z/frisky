require 'spec_helper'

require 'frisky/models/commit'
require 'frisky/models/repository'
require 'frisky/models/file_commit'

describe Frisky::Model::FileCommit do
  before :each do
    reset_databases
  end

  let (:klass) { Frisky::Model::FileCommit }

  let (:repository_full_name) { "heelhook/frisky" }
  let (:repository) { Frisky::Model::Repository.soft_fetch(full_name: repository_full_name) }

  let (:commit_sha) { '9621e8f6f31d733f68834a814d2ce2a74c19edc8' }
  let (:commit) { Frisky::Model::Commit.soft_fetch(repository: repository, sha: commit_sha) }

  describe ".soft_fetch" do
    context "with a commit object" do
      let (:file1) { klass.soft_fetch repository: repository, commit: commit, path: commit.files[0].path }

      it "starts with a commit with files" do
        commit.files.size.should > 0
      end

      it "creates a partially-filled model with the available data" do
        file1.path.should_not be_nil
        file1.no_proxy_type.should be_nil
      end

      it "fallbacks when required" do
        # file1.type.should_not be_nil
      end
    end
  end

  describe ".load_from_raw" do

  end
end
