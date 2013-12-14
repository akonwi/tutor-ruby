module Tutor
  class StudyPage < Shoes
    include Common
    include Cleans

    # conjugations and definition keys
    Stuff_to_ask = [:def, :je, :tu, :il, :nous, :vous, :ils]
    @@words_index = 0

    url '/study', :study_menu
    url '/study/(\d+)', :study_word

    def study_menu
      remove_edit_lines
      remove_buttons

      APP.main.clear do
        stack Options do
          main_background

          @@words = Words.shuffle
          @word = @@words.first

          if @word
            banner "sup"
          else
            banner "no"
          end
        end
      end
    end
  end
end
