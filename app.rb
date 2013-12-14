Current_Dir = File.dirname(__FILE__)

# need full path because of the way startup of shoes works right now
require File.join(Current_Dir, '/lib/tutor/cleans')
require File.join(Current_Dir, '/lib/tutor/common')
require File.join(Current_Dir, '/lib/tutor/word')
require File.join(Current_Dir, '/lib/tutor/study')
require File.join(Current_Dir, '/lib/tutor/add_words')
require 'hashie'
require 'yaml'

module Tutor
  # Collection of elements. Primarily elements that don't get
  # removed when they are supposed to
  APP = Hashie::Mash.new
  Words_File = File.join(Current_Dir, '/stuff/words.yaml')

  unless File.exists? Words_File
    File.new(Words_File, 'w').close
  end

  Words = YAML.load_file(Words_File) || []
  Common::Words = Words

  class StudyBuddy < Shoes
    include Common
    include Cleans

    url '/', :index

    def index
      remove_edit_lines
      remove_buttons

      APP[:main] = stack Options do
        main_background
        title "Let's Study!", align: "center"

        flow do
          main_background

          APP.buttons!.study = button 'Study' do
            visit '/study'
          end
          button 'Add Vocab' do
            visit '/add'
          end
        end
      end
    end

    def study_page
      remove_edit_lines
      remove_buttons

      main_background

      @words_index = 0
      @words = Words.shuffle
      @word = @words[@words_index]

      # order of conjugations, excluding the infinitive and including the definition
      @conjugations = [:def, :je, :tu, :il, :nous, :vous, :ils]

      # index of the conjugations
      @conjugations_index = 0

      APP.header = stack width: 1.0 do
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
          go_next
        end

        # when 'enter' key is pressed
        keypress do |key|
          go_next if key.eql? "\n"
        end
      end
    end

    private

      # replace the label and edit_line during studying when 'next' is clicked
      def next_conjugation(text, label, edit_line)
        label.text = text
        edit_line.text = ''
      end

      # callback for next button when studying
      def go_next
        if @input.text == @word[@conjugations[@conjugations_index]]
          @conjugations_index += 1

          # if there is another conjugation to do, do it
          # otherwise go to the next word in the list
          if next_conj = @conjugations[@conjugations_index]
            next_conjugation next_conj, @label, @input
          else
            @words_index += 1
            if @word = @words[@words_index]
              APP.header.clear do
                @title = banner @word.inf, align: 'center'
              end
            else
              alert 'Those are all the words'
            end

            @conjugations_index = 0
            next_conjugation @conjugations.first, @label, @input
          end
        else
          alert "Sorry, that's wrong."
        end
      end
  end
end

options = {title: 'Study Buddy'}
options.merge! Tutor::Common::Options
Shoes.app options
