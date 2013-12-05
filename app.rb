Current_Dir = File.dirname(__FILE__)

# need full path because of the way startup of shoes works right now
require File.join(Current_Dir, '/lib/tutor/word')
require File.join(Current_Dir, '/lib/tutor/cleans')
require 'hashie'
require 'yaml'

module Tutor
  # Collection of elements. Primarily elements that don't get
  # removed when they are supposed to
  APP = Hashie::Mash.new

  class StudyBuddy < Shoes
    include Cleans

    url '/', :index
    url '/study', :study
    url '/add_words' , :add_words

    Words_File = File.join(Current_Dir, '/stuff/words.yaml')

    WORDS = YAML.load_file Words_File

    def index
      remove_edit_lines
      remove_buttons

      # For some reason, filling the window with this stack causes
      # an overflow and needs a scrollbar. .92 is the perfect fit
      APP[:main] = stack height: 0.92 do
        main_background
        title "Let's Study!", align: "center"

        flow do
          main_background

          APP.buttons!.study = button 'study' do
            visit '/study'
          end
          button 'add vocab' do
            visit '/add_words'
          end
        end
      end
    end

    def add_words
      remove_buttons
      remove_edit_lines

      APP.main.clear do
        stack do
          main_background
          banner 'New Word', align: 'center', margin_bottom: 5

          # Collection of edit_lines for enumerability
          edit_lines = {inf: nil,
                        def: nil,
                        je: nil,
                        tu: nil,
                        il: nil,
                        nous: nil,
                        vous: nil,
                        ils: nil}

          # trying to center the form with the margin_left
          flow margin_left: 200 do
            para "Infinitve: "
            edit_lines[:inf] = edit_line
            para "Definition: "
            edit_lines[:def] = edit_line
          end

          # Setup inputs and labels for conjugations
          edit_lines.each_key do |key|
            next if key.eql?(:inf) || key.eql?(:def)
            flow margin_left: 200 do
              para "#{key.to_s}: "
              edit_lines[key] = edit_line
            end
          end

          # storing the edit_lines from the form for removal later
          APP.edit_lines = edit_lines.values

          flow margin_left: 200 do

            # store these buttons in a buttons mash inside of APP global
            APP.buttons!.save = button "Save" do
              if validate_inputs edit_lines
                @word = Word.new do |word|
                  edit_lines.each do |k,v|
                    word[k] = v.text
                  end
                end

                puts "Created #{@word.inf}"

                WORDS << @word
                file = File.open Words_File, 'w'
                file.truncate 0
                file.write WORDS.to_yaml
                file.close

                clear_edit_lines edit_lines.values
              else
                puts 'not valid'
              end
            end

            APP.buttons.new = button 'New Word' do
              clear_edit_lines edit_lines.values
            end

            APP.buttons.back = button "Go Back" do
              visit '/'
            end
          end
        end
      end
    end

    def study
      remove_edit_lines
      remove_buttons

      main_background

      @words_index = 0
      @words = WORDS.shuffle
      @word = @words[@words_index]

      # order of conjugations, excluding the infinitive and including the definition
      @conjugations = [:def, :je, :tu, :il, :nous, :vous, :ils]

      # index of the conjugations
      @conjugations_index = 0

      stack width: 1.0 do
        @title = banner "#{@word.inf}", align: "center"
      end

      # form section
      #
      # label
      # edit_line
      flow margin_left: 200 do
        label = @conjugations[@conjugations_index]
        if label == :def
          @label = para 'Definition'
        else
          @label = para @conjugations[@conjugations_index]
        end

        @input = edit_line
        if lines = APP.edit_lines
          lines << @input
        else
          APP.edit_lines = [@input]
        end
      end

      flow margin: 10 do
        button 'Back' do
          visit '/'
        end

        APP.buttons!.next = button 'Next' do
          if @input.text == @word[@conjugations[@conjugations_index]]
            @conjugations_index += 1

            # if there is another conjugation to do, do it
            # otherwise go to the next word in the list
            if next_conj = @conjugations[@conjugations_index]
              next_conjugation next_conj, @label, @input
            else
              @words_index += 1
              @word = @words[@words_index]

              @conjugations_index = 0
              next_conjugation @conjugations.first, @label, @input
            end
          else
            alert "Sorry, that's wrong."
          end
        end
      end
    end

    private

      def main_background(options={})
        background("#089C68", options)
      end

      # replace the label and edit_line during studying when 'next' is clicked
      def next_conjugation(text, label, edit_line)
        label.text = text
        edit_line.text = ''
      end

      # make sure inputs from a form aren't empty
      def validate_inputs(edit_lines)
        valid = true
        edit_lines.each do |key, val|
          if val.text.empty?
            puts "#{key} is not valid"
            valid = false
            break
          end
        end
        valid
      end
  end
end

Shoes.app title: 'Study Buddy', height: 450
