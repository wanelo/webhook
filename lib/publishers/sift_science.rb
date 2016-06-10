require 'lapine'

module Webhook
  module Publisher
    class SiftScience < Struct.new(:data)
      include Lapine::Publisher

      def to_hash
        data
      end
    end
  end
end
