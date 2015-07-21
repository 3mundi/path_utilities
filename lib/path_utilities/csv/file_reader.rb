module PathUtilities
  module CSV
    class FileReader
      attr_reader :file_path
      attr_accessor :text, :output

      def initialize(file_path)
        @file_path = file_path
      end

      def execute
        read
        self.output = file_to_ary
      end

      private

      def read
        self.text = File.read(file_path, encoding: 'iso-8859-1:utf-8')
      end

      def file_to_ary
        lines = []
        text.each_line do |line|
          lines << line.split(';')
        end
        lines
      end
    end
  end
end
