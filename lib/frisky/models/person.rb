module Frisky
  module Model
    class Person < ProxyBase
      attr_accessor :name, :email, :bio, :location, :blog, :company,
                    :login, :followers, :gravatar_id, :avatar_url, :html_url

      fetch_key :login, :email
      fetch_autoload :name, :email, :bio, :location, :blog, :company,
                    :login, :followers, :gravatar_id, :avatar_url, :html_url

      fallback_fetch { |args| args[:login] ? Octokit.user(args[:login]) : args }

      proxy_methods :name, :email, :bio, :location, :blog, :company,
                    :followers, :gravatar_id, :avatar_url, :html_url
    end
  end
end