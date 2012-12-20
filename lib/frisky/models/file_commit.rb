module Frisky
  module Model
    class FileCommit < ProxyBase
      attr_accessor :changes, :path, :deletions, :status, :patch, :additions,
                    :sha, :type, :repository, :commit

      fetch_key :repository, :commit, :path
      fetch_autoload :changes, :path, :deletions, :status, :patch, :additions,
                     :sha, :type

      fallback_fetch do |args|
        Frisky.log.debug "[FALLBACK FILE COMMIT] #{args.inspect}"
        Octokit.contents(args[:repository].full_name, path: args[:path], ref: args[:commit].sha)
      end

      proxy_method :type

      def self.load_from_raw(raw)
        model = super(raw)

        model.repository   = raw.repository if raw.repository.is_a? Repository
        model.commit       = raw.commit if raw.commit.is_a? Commit
        model.path         = raw.path

        # id/sha, commit.message, repository
        model
      end
    end
  end
end