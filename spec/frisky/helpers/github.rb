require 'open-uri'

module Frisky
  module Helpers
    module GitHub
      class << self
        @@client_id     = nil
        @@client_secret = nil

        def client_id; @@client_id; end
        def client_id=(value); @@client_id = value; end

        def client_secret; @@client_secret; end
        def client_secret=(value); @@client_secret = value; end

        def create_url(url)
          # Append client_id and client_secret when we have them
          unless (@@client_id.blank? and @@client_secret.blank?) or url.include?('client_id')
            url << ((not url.include?('?')) ? '?' : '&')
            url << "client_id=#{@@client_id}&client_secret=#{@@client_secret}"
          end

          url
        end

        def fetch_url(url)
          attempts ||= 0

          url = create_url(url)

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