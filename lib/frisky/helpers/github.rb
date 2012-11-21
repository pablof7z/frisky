require 'open-uri'
require 'json'

module Frisky
  module Helpers
    module GitHub
      class << self
        @@client_id     = nil
        @@client_secret = nil
        @@per_page      = 100

        def client_id; @@client_id; end
        def client_id=(value); @@client_id = value; end

        def client_secret; @@client_secret; end
        def client_secret=(value); @@client_secret = value; end

        def per_page; @@per_page; end
        def per_page=(value); @@per_page = value; end

        def fetch_events; fetch_url("https://api.github.com/events"); end

        def create_url(url, opts={})
          # Append client_id and client_secret when we have them
          unless (@@client_id != nil and @@client_secret != nil) or url.include?('client_id')
            url << ((not url.include?('?')) ? '?' : '&')
            url << "client_id=#{@@client_id}&client_secret=#{@@client_secret}"
          end

          opts.each do |key, value|
            url << ((not url.include?('?')) ? '?' : '&')
            url << "#{key}=#{value}"
          end

          unless url.include?('per_page')
            url << ((not url.include?('?')) ? '?' : '&')
            url << "per_page=#{@@per_page}"
          end

          url
        end

        def fetch_url(url, opts={})
          attempts ||= 0

          url = create_url(url.dup, opts)

          Frisky.log.debug url

          JSON.parse(open(url).read)
        rescue OpenURI::HTTPError => e
          status = e.io.status[0].to_i

          raise if status != 403

          print "[403 ERROR] "

          attempts += 1

          if attempts <= 12
            puts "Retrying in 5 minutes"
            sleep(300)
            retry
          else
            puts "Giving up"
            raise
          end
        end
      end
    end
  end
end