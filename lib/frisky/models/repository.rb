module Frisky
  module Model
    class Repository < ProxyBase
      attr_accessor :homepage, :watchers_count, :html_url, :owner, :master_branch,
                    :forks_count, :git_url, :full_name, :name, :created_at, :url,
                    :forked, :description, :contributors

      fetch_key :full_name
      fetch_autoload :homepage, :watchers_count, :html_url, :owner, :master_branch,
                     :forks_count, :git_url, :full_name, :name, :created_at, :url,
                     :description

      fallback_fetch do |args|
        raise "missing repository name" unless args[:full_name]
        Octokit.repo(args[:full_name])
      end

      after_fallback_fetch do |obj|
        self.owner = Person.soft_fetch(obj.owner)
        self.forked = obj['fork']
      end

      proxy_methods :name, :url, :owner
      proxy_methods html_url: Proc.new { "https://github.com/#{full_name}" }
      proxy_methods contributors: Proc.new {
        cvalue = {}
        Octokit.contributors(self.full_name).each {|c| cvalue[Person.soft_fetch(c).id] = c.contributions }
        cvalue
      }

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