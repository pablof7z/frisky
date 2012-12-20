module Frisky
  module Model
    class FileCommit < ProxyBase
      attr_accessor :changes, :path, :deletions, :status, :patch, :additions,
                    :sha, :type, :repository, :commit

      fetch_key repository: Proc.new { repository.id }, commit: Proc.new { commit.id }, path: :path
      fetch_autoload :changes, :path, :deletions, :status, :patch, :additions,
                     :sha, :type

      fallback_fetch do |args|
        Frisky.log.debug "[FALLBACK FILE COMMIT] #{args.inspect}"
        Octokit.contents(repository.full_name, path: args[:path], ref: commit.sha)
      end

      proxy_method :type

      def self.load_from_raw(raw)
        model = super(raw)

        model.repository   = raw.repository if raw.repository.is_a? Repository
        model.repository ||= Repository.soft_fetch(full_name: raw.repository.full_name)

        model.commit       = raw.commit if raw.commit.is_a? Commit
        model.commit     ||= Commit.soft_fetch(repository: model.repository,
                                           sha: raw.commit.sha)

        model.path         = raw.filename || raw.path

        # id/sha, commit.message, repository
        model
      end
    end
  end
end