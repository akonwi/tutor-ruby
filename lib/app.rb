# need full path because of the way startup of shoes works right now
require '~/projects/tutor/lib/tutor/word'
require '~/projects/tutor/lib/tutor/cleans'
require 'hashie'

module Tutor
  # Collection of elements. Primarily elements that don't get
  # removed when they are supposed to
  APP = Hashie::Mash.new

  class StudyBuddy < Shoes
    include Cleans

    url '/', :index
    url '/study', :study
    url '/add_words' , :add_words

    WORDS = []
    WORDS << Word.new do |word|
      word.inf = 'manger'
      word.def = 'to eat'
      word.je = 'mange'
      word.tu = 'manges'
    end

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
              # TODO: verify edit_lines aren't empty
              @word = Word.new do |word|
                edit_lines.each do |k,v|
                  word[k] = v.text
                end
              end

              puts "Created #{@word.inf}"

              WORDS << @word
              clear_edit_lines edit_lines.values
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
      @word = WORDS[@words_index]

      # order of conjugations, excluding the infinitive and including the definition
      @conjugations = [:def, :je, :tu, :il, :nous, :vous, :ils]

      # index of the conjugations
      @conjugations_index = 0

      stack width: 1.0 do
        @title = banner "#{@word.inf}", align: "center"
      end

      # actual form section
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
          # TODO: Validate input for presence and correctness
          @conjugations_index += 1
          next_conjugation @conjugations[@conjugations_index], @label, @input
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
  end
end

Shoes.app title: 'Study Buddy', height: 450
