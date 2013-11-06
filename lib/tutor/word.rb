require 'hashie'

module Tutor
  # Extending Hashie::Mash allows for method like calling of
  # keys in a hash. Having a block makes creation easier
  class Word < ::Hashie::Mash
    def initialize(&block)
      yield self
    end
  end
end
