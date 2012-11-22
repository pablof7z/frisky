module Frisky
  module Lock
    class << self
      def locked?(key)
        Frisky.redis.exists key
      end

      def lock?(key, expiration=60)
        a = Frisky.redis.setnx(key, true)
        Frisky.redis.expire(key, expiration) if a
        a
      end

      def block(key, expiration=60)
        $statsd.time("process.lock.#{key}") do
          while Frisky.redis.setnx(key, true) == false
            sleep 0.2
            puts "waiting on #{key}"
          end
        end
        Frisky.redis.expire(key, expiration) if expiration > 0
      end

      def keepalive(key)
        key.each {|k,v| Frisky.redis.expire(k, v)}
      end

      def unlock(key)
        key = [key] if key.class != Array
        key.each {|k| Frisky.redis.del(k)}
      end
    end
  end
end