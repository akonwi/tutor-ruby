module Tutor
  # Methods to handle cleaning up of stubborn elements
  # and resetting of elements
  module Cleans

    # Reset the values of the given inputs
    def clear_edit_lines(inputs)
      inputs.each do |input|
        input.text = ''
      end
    end

    # For general cleanup, this method does it all so
    # each page doesn't need to list each method call
    def clean
      APP.each do |key, obj|
        # Only Hashie::Mash responds to fetch. Don't call remove on that
        # or on the Shoes slots
        unless obj.respond_to? :fetch
          unless obj.is_a? Shoes::Slot
            obj.send :remove if obj.respond_to? :remove
          end
        end
      end
      remove_edit_lines
      remove_buttons
    end

    # this is really only used after leaving a page with a form because
    # the edit_line elements don't get removed on the clear() call
    def remove_edit_lines
      if lines = APP.edit_lines
        unless lines.empty?
          puts "Removing edit_lines"
          lines.map &:remove
        end
      end
    end

    # clear all the buttons on the page
    # pass in a :but key with the label of the button to keep
    #
    # remove_buttons but: :back
    def remove_buttons(options = {})
      puts "Removing buttons"
      if buttons = APP.buttons
        if options.has_key? :but
          but = options[:but].to_s
          buttons.each do |key, el|
            puts "key is a: #{key.class}"
            unless key.eql? :but
              puts "removing #{key} button"
              el.remove
            end
          end
        else
          buttons.each_value.map &:remove
        end
      end
    end

  end
end
