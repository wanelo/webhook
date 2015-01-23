require 'yaml'

module Webhook
  class Settings
    class << self
      def load!
        @publishers ||= YAML.load(File.read('config/publishers.yml'))
      end

      def publishers
        @publishers || {}
      end
    end
  end
end
