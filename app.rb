Current_Dir = File.dirname(__FILE__)

# need full path because of the way startup of shoes works right now
require File.join(Current_Dir, '/lib/tutor/cleans')
require File.join(Current_Dir, '/lib/tutor/common')
require File.join(Current_Dir, '/lib/tutor/word')
require File.join(Current_Dir, '/lib/tutor/study')
require File.join(Current_Dir, '/lib/tutor/add_words')
require 'hashie'
require 'yaml'

# comment
module Tutor
  # Collection of elements. Primarily elements that don't get
  # removed when they are supposed to
  App = Hashie::Mash.new
  Words_File = File.join(Current_Dir, '/stuff/words.yaml')

  unless File.exists? Words_File
    File.new(Words_File, 'w').close
  end

  Words = YAML.load_file(Words_File) || []

  class StudyBuddy < Shoes
    include Common
    include Cleans

    url '/', :index

    def index
      clean

      App[:main] = stack Options do
        main_background
        title "Let's Study!", align: "center"

        flow do
          main_background

          App.buttons!.study = button 'Study' do
            visit '/study'
          end
          button 'Add Vocab' do
            visit '/add'
          end
        end
      end
    end

  end
end

options = {title: 'Study Buddy'}
options.merge! Tutor::Common::Options
Shoes.app options
