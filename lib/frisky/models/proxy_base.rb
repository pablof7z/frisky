module Frisky
  module Model
    # Add extensions that need to be loaded to this array
    EXTENSIONS ||= []

    class ProxyBase
      include ClassProxy

      class << self
        # Attempts to fetch an object, skipping the fallback,
        # if it comes back empty, an object is created using the
        # data available in the raw model, which could possible be
        # incomplete but perhaps no more data is required and doesn't
        # make sense to make a new query to the fallback.
        def soft_fetch(raw)
          raw = Hashie::Mash.new(raw) if raw.class == Hash

          fetch_obj = {}
          @fetch_keys.each do |key, value|
            if value.is_a? Symbol
              fetch_obj[key] = raw.send(value) if raw.respond_to? value
            elsif value.is_a? Proc
              begin
                fetch_obj[key] = raw.instance_eval(&value)
              rescue NameError => e
                raise IncompatibleDataStructure, e.message
              end
            end
          end

          model = self.fetch(fetch_obj, {skip_fallback: true})
          model ||= self.load_from_raw(raw)
          model.save if model.new?
          model
        end

        def load_from_raw(raw)
          model = self.new

          @fetch_autoload.each do |key|
            model.send("#{key}=", raw.send(key)) if raw.respond_to? key
          end

          model
        end

        # Key that is going to be used to
        def fetch_key(*keys)
          @fetch_keys ||= {}

          keys.each do |key|
            if key.is_a? Hash
              key.each do |k, v|
                @fetch_keys[k] = v
              end
            elsif key.is_a? Symbol
              @fetch_keys[key] = key
            else
              raise NameError
            end
          end

          self
        end

        # Pass the keys that will be autoimported by load
        def fetch_autoload(*keys)
          @fetch_autoload ||= []
          @fetch_autoload |= keys
        end
      end
    end
  end
end