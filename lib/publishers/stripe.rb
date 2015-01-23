require 'lapine'

module Webhook
  module Publisher
    class Stripe < Struct.new(:data)
      include Lapine::Publisher

      def to_hash
        data
      end
    end
  end
end
