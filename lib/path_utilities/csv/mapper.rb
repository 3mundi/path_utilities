module PathUtilities
  module CSV
    class Mapper
      attr_accessor :ary, :hashes

      def initialize(ary)
        self.ary = ary
      end

      def execute
        self.hashes ||= to_hash
      end

      alias_method :output, :hashes

      private

      def keys
        raise NotImplementedError
      end

      def to_hash
        ary.each_with_object([]) do |elem, const|
          hash = {}
          keys.each_with_index do |key, i|
            hash[key] = elem[i]
          end
          const << hash
        end
      end
    end
  end
end
