module Tutor
  class StudyPage < Shoes
    include Common
    include Cleans

    url '/study', :study_menu
    url '/study/(\w+)', :get_words
    url '/study/(\d+)', :study_word

    def study_menu
      clean

      App.main.clear do
        stack Options do
          main_background

          banner 'Study', align: 'center', margin_bottom: 5
          title 'Choose a category', align: 'center'

          box = nil
          stack margin_left: 200 do
            box = list_box items: ['Verb', 'Adjective', 'Noun', 'Stuff']
            box.choose 'Verb'
          end

          flow margin_left: 200 do
            App.buttons!.next = button 'Next' do
              visit "/study/#{box.text}"
            end
          end
        end
      end
    end

    # @param type string of kind of words to get
    #
    # save collection of words to study and start studying
    # acts as middleware
    def get_words(type)
      @@words = Words.select do |word|
        word.type.to_s.eql? type.downcase
      end

      @@words.shuffle!

      study_word(0)
    end

    def study_word(index)
      clean

      # conjugations and definition keys
      @stuff_to_ask = [:def, :je, :tu, :il, :nous, :vous, :ils]

      @word = @@words[index]
      @@words_index = index

      App.main.clear do |key|
        stack Options do
          main_background
          if @word
            banner @word.inf, align: 'center'
            if @word.type.eql? :verb
              quiz_on_verb(0)
            else
              quiz
            end
          else
            puts 'no word'
            banner "There's nothing to study", align: 'center'
            App.buttons!.back = button 'Back' do
              visit '/'
            end
          end
        end
      end
    end

    private

      # @param index position in stuff_to_ask array. indicates which
      #              step user is in
      # this method will display the label and input for the verb being studied
      def quiz_on_verb(index)
        flow margin_left: 200 do
          label = @stuff_to_ask[index]
          if label == :def
            @label = para 'Definition'
          else
            @label = para label
          end

          @input = edit_line
          if lines = App.edit_lines
            lines << @input
          else
            App.edit_lines = [@input]
          end
        end

        flow margin: 30 do
          App.buttons!.back = button 'Back' do
            visit '/'
          end

          App.buttons.next = button 'Next' do
            go_next index
          end

          # when 'enter' key is pressed
          keypress do |key|
            go_next(index) if key.eql? "\n"
          end
        end
      end

      def quiz
        flow margin_left: 200 do
          @label = para 'Definition'
          @input = edit_line
          if lines = App.edit_lines
            lines << @input
          else
            App.edit_lines = [@input]
          end
        end

        flow margin_left: 30 do
          App.buttons!.back = button 'Back' do
            visit '/'
          end

          App.buttons.next = button 'Next' do
            go_next
          end

          keypress do |key|
            go_next if key.eql? "\n"
          end
        end
      end

      # @param index current index of conjugation form in stuff_to_ask
      #
      # this is just a block for when the next button is clicked or
      # enter key is pressed to do what I can to keep code DRY
      def go_next(index=nil)
        if index
          if validate(index)
            # TODO: make this an instance variable
            index += 1
            next_conjugation(index)
          else
            puts 'Sorry, that is incorrect'
          end
        elsif validate(index)
          puts 'it is correct'
          study_word(@@words_index + 1)
        end
      end

      # @params index of the current word being studied in the array of words
      #
      # This method will change the label for the next verb form
      # or
      # it will prompt going to the next word if all forms have been exhausted
      def next_conjugation(index)
        if next_conj = @stuff_to_ask[index]
          @label.text = next_conj
          @input.text = ''
        else
          study_word(@@words_index + 1)
        end
      end

      # @params index position inside the array of conjugations,
      #               indicates which verb form is being asked
      # @returns boolean is the entered text correct
      def validate(index)
        if index
          puts "answer is: " + @word[@stuff_to_ask[index]]
          @input.text.eql? @word[@stuff_to_ask[index]]
        else
          @input.text.eql? @word.def
        end
      end
  end
end
