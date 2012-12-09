module Frisky
  module Helpers
    # The Lock module provides locking helper methods. Takes care of race-conditions scenarios.
    module Lock
      class << self
        # Check if a key is locked -- read-only
        def locked?(key)
          Frisky.redis.exists key
        end

        # Attempt to lock, return true if the locked work
        def lock?(key, expiration=60)
          a = Frisky.redis.setnx(key, true)
          Frisky.redis.expire(key, expiration) if a and expiration
          a
        end

        # Lock the key, if the key is busy, block on this call until its released
        def block(key, expiration=60, check_interval=0.2)
          $statsd.time("process.lock.#{key}") do
            while Frisky.redis.setnx(key, true) == false
              sleep check_interval
            end
          end
          Frisky.redis.expire(key, expiration) if expiration > 0
        end

        # Refresh the expiration of the key
        def keepalive(key)
          key.each {|k,v| Frisky.redis.expire(k, v)}
        end

        # Remove a number of locks immediately
        def unlock(*keys)
          keys.each {|k| Frisky.redis.del(k)}
        end
      end
    end
  end
end
