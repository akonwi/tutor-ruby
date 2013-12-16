module Tutor
  class AddWordsPage < Shoes
    include Common
    include Cleans

    url '/add', :add_menu
    url '/add/(\w+)', :add_word

    def add_menu
      clean

      App.main.clear do
        stack Options do
          main_background
          banner 'New Word', align: 'center', margin_bottom: 5
          title 'Type of word', align: 'center'

          box = nil
          stack margin_left: 200 do
            box = list_box items: ['Verb', 'Adjective', 'Noun', 'Stuff']
            box.choose 'Verb'
            App.list_box = box
          end

          flow margin_left: 200 do
            App.buttons!.next = button 'Next' do
              visit "/add/#{box.text}"
            end
            App.buttons.back = button 'Back' do
              visit '/'
            end
          end
        end
      end
    end

    def add_word(type)
      clean

      App.main.clear do
        stack Options do
          main_background
          banner type, align: 'center'

          edit_lines = {}

          case type
          when 'Verb'
            verb_conjugations = [ :inf, :def, :je, :tu, :il, :nous, :vous, :ils ]

            flow margin_left: 200 do
              verb_conjugations.each do |conj|
                if conj.eql? :inf
                  para "Infinitive"
                  edit_lines[:inf] = edit_line
                elsif conj.eql? :def
                  para "Definition"
                  edit_lines[:def] = edit_line
                else
                  para "#{conj.to_s}: "
                  edit_lines[conj] = edit_line
                end
              end

              App.edit_lines = edit_lines.values
            end

            flow margin_left: 200 do
              App.buttons!.save = button 'Save' do
                handle_save edit_lines, type
              end

              App.buttons.back = button 'Back' do
                visit '/add'
              end
            end

            # When 'enter' key is pressed, save
            keypress do |key|
              if key.eql? "\n"
                handle_save edit_lines, type
              end
            end
          ## TODO: when 'Adjective', etc.
          end
        end
      end
    end

    private

      # callback for when clicking save for a new word
      # @params edit_lines the inputs with text in them
      # @params type kind of word, 'Verb', 'Adjective', etc.
      def handle_save(edit_lines, type)
        if validate_inputs edit_lines
          @word = Word.new do |word|
            word.type = type.downcase.to_sym
            edit_lines.each do |k,v|
              word[k] = v.text
            end
          end

          puts "Created #{@word.inf}"

          Words << @word
          File.open Words_File, 'w' do |file|
            file.truncate 0
            file.write Words.to_yaml
            file.close
          end

          clear_edit_lines edit_lines.values
        else
          puts 'not valid'
        end
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
