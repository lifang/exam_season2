# encoding: utf-8
desc "import all the excel infos into the phone words"
task :import_data do
  require 'spreadsheet'
  dir_path="#{Rails.root}/public/words_data/xmls"
  files=[]
  Dir.foreach(dir_path) { |entry|
    if entry =~ /.xls/
      files << entry
    end
  }
  if File.exist? dir_path and files !=[]
    files.each do |file|
      book = Spreadsheet.open File.join(dir_path,file)
      sheet = book.worksheet 0
      sheet.each_with_index do |row,index|
        unless index==0
          content={:name=>row[0],:category_id=>row[1],:ch_mean=>row[2],:types=>row[3],:phonetic=>row[4],:level=>row[5],:enumciate_url=>row[6]}
          phone_word=PhoneWord.create(content)
          (0..2).each do |sen|
            WordSentence.create(:word_id=>phone_word.id,:description=>row[7+2*sen],:ch_mean=>row[8+2*sen])
          end
        end
      end
    end
  end
end