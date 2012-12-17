module Frisky
  module Model
    class Repository < ProxyBase
      attr_accessor :homepage, :watchers_count, :html_url, :owner, :master_branch,
                    :forks_count, :git_url, :full_name, :name, :created_at, :url

      fetch_key :full_name
      fetch_autoload :homepage, :watchers_count, :html_url, :owner, :master_branch,
                     :forks_count, :git_url, :full_name, :name, :created_at, :url

      fallback_fetch { |args| Frisky.log.debug "[FALLBACK REPOSITORY] #{args[:full_name]}"; Octokit.repo(args[:full_name]) }
      after_fallback_fetch do |obj|
        self.owner = Person.soft_fetch(obj.owner)
      end

      proxy_methods :name, :url, :owner

      def self.soft_fetch(raw)
        # Check if raw provides a full_name, when the data is not complete,
        # it tends to come as "name"
        if not raw.respond_to?(:full_name) and raw.respond_to?(:name)
          raw.full_name = raw.name
          raw.delete :name
        end

        super(raw)
      end
    end
  end
end