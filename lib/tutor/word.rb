require 'hashie'

module Tutor
  # Extending Hashie::Mash allows for method like calling of
  # keys in a hash. Having a block makes creation easier
  class Word < ::Hashie::Mash

    def initialize(obj=null, &block)
      if block
        yield self
      elsif obj
        from_hash obj
      end
    end

  end
end
