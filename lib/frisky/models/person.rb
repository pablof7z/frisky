module Frisky
  module Model
    class Person < ProxyBase
      attr_accessor :name, :email, :bio, :location, :blog, :company, :login, :followers

      fetch_key :login, :email
      fetch_autoload :name, :email, :bio, :location, :blog, :company, :login, :followers

      fallback_fetch { |args| Frisky.log.debug "[FALLBACK PERSON] #{args[:login]}"; Octokit.user(args[:login]) }

      proxy_methods :name, :email, :bio, :location, :blog, :company, :followers
    end
  end
end