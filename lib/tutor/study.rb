module Tutor
  class StudyPage < Shoes
    include Common
    include Cleans

    url '/study', :study_menu
    url '/study/(\w+)', :get_words
    url '/study/(\d+)', :study_word

    def study_menu
      clean

      APP.main.clear do
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
            APP.buttons!.next = button 'Next' do
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

      visit "/study/#{0}"
    end

    def study_word(index)
      clean

      # conjugations and definition keys
      stuff_to_ask = [:def, :je, :tu, :il, :nous, :vous, :ils]

      word = @@words[index]

      APP.main.clear do |key|
        stack Options do
          banner word.inf, align: 'center'
          ## TODO: Show inputs for the answer
          # If it's a verb, need to show stuff one at a time
          # else just show the definition input
        end
      end
    end
  end
end
