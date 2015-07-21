module PathUtilities
  module CSV
    class Translator
      attr_reader :hashes
      attr_accessor :output
      def initialize(hashes)
        @hashes = hashes.dup
        @output = []
      end

      def execute
        hashes.each do |hash|
          output << build_hash(hash)
        end
      end

      def date_format
        fail NotImplementedError
      end

      def key_mapping
        fail NotImplementedError
      end

      private

      def build_hash(hash)
        processed = key_exchange(hash)
      end

      def key_exchange(hash)
        key_mapping.each_with_object({}) do |(k, v), new_hash|
          new_hash[k] = if v.is_a? Array
                          join_arrays(v, hash)
                        elsif v.is_a? Hash
                          v[:proc].call(hash[v[:key]]) rescue nil
                        else
                          hash[v]
                        end
        end
      end

      def join_arrays(keys, hash)
        keys.each_with_object([]) do |k, object|
          object << hash[k] unless hash[k].blank?
        end.join(', ')
      end
    end
  end
end
