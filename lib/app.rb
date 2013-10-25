require 'hashie'
require 'json'

class Word < ::Hashie::Mash
  def initialize(&block)
    yield self
  end
end

class StudyBuddy < Shoes
  url '/', :index
  url '/study', :study
  url '/add_words' , :add_words

  WORDS = []

  # store currently used stacks
  APP = Hashie::Mash.new

  def index
    # For some reason, filling the window with this stack causes
    # an overflow and needs a scrollbar. .92 is the perfect fit
    APP[:main] = stack height: 0.92 do
      main_background
      title "Let's Study!", align: "center"

      flow do
        main_background
        button 'study' do
          visit '/study'
        end
        button 'add vocab' do
          visit '/add_words'
        end
      end
    end
  end

  def add_words
    APP.main.clear do
        stack margin: 10 do
          main_background curve: 20
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

          flow do
            para "Infinitve: "
            edit_lines[:inf] = edit_line
            para "Definition: "
            edit_lines[:def] = edit_line
          end

          # Setup inputs and labels for conjugations
          edit_lines.each_key do |key|
            next if key.eql?(:inf) || key.eql?(:def)
            flow do
              para "#{key.to_s}: "
              edit_lines[key] = edit_line
            end
          end

          flow do
            button "Save" do
              @word = Word.new do |word|
                edit_lines.each do |k,v|
                  word[k] = v.text
                end
              end

              WORDS << @word
              clear_edit_lines edit_lines.values
            end

            button 'New Word' do
              clear_edit_lines edit_lines.values
            end

            button "Go Back" do
              visit '/'
            end
          end
        end
    end
  end

  def study
    main_background

    index = 0
    word = WORDS[index]

    stack height: 0.8, width: 1.0 do
      @title = span "#{word.inf}", align: "center"
    end

    flow margin: 10 do
      button 'Back' do
        visit '/'
      end

      button 'Next' do
        index += 1
        word = WORDS[index]
        @title.replace word.inf
      end
    end
  end

  private

    def main_background(options={})
      background("#089C68", options)
    end

    def clear_edit_lines(lines)
      lines.each do |line|
        line.text = ''
      end
    end
end

Shoes.app title: 'Study Buddy', height: 400
