module Hh
  module Worker
    def self.included(klass)
      klass.send(:include, Sidekiq::Worker) if Gem.loaded_specs.key?('sidekiq')
    end
  end
end
