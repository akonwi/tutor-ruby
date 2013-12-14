module Tutor
  # Collection of common methods and values that each Shoes page will use
  module Common
    # style options and values
    Options = { height: 450 }

    def main_background(options={})
      background("#089C68", options)
    end

  end
end
