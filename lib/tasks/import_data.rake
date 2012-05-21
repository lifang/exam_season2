# encoding: utf-8
desc "import all the excel infos into the phone words"
task(:import_data=>:environment) do
  require 'spreadsheet'
  include WordsHelper
  dir_path="#{Rails.root}/public/words_data/xmls"
  files=[]
  file_url="#{Rails.root}/public/words_data/imported_lists.txt"
  match_file = File.open(file_url,"rb")
  words = match_file.readlines.join(" ")
  match_file.close
  Dir.foreach(dir_path) { |entry|
    if entry =~ /.xls/ and !words.include? entry
      files << entry
    end
  }
  unless files.blank?
    files.each do |file|
      book = Spreadsheet.open File.join(dir_path,file)
      sheet = book.worksheet 0
      sheet.each_with_index do |row,index|
        ever=PhoneWord.first(:conditions=>"name like \"#{row[0]}\"")
        if index!=0  and !row[0].nil?
          content={:name=>row[0],:category_id=>row[1],:ch_mean=>row[2],:types=>row[3],:phonetic=>row[4],:level=>row[5],:enunciate_url=>row[6]}
          if  ever.nil?
            phone_word=PhoneWord.create(content)
            (0..2).each do |sen|
              WordSentence.create(:word_id=>phone_word.id,:description=>row[7+2*sen],:ch_mean=>row[8+2*sen]) unless row[7+2*sen].nil? and row[7+2*sen]==""
            end
            p "--#{row[0]} CREATED OVER  --"
          else
            ever.update_attributes(content)
            WordSentence.find_all_by_word_id(ever.id).each {|sen| sen.destroy}
            (0..2).each do |sen|
              WordSentence.create(:word_id=>ever.id,:description=>row[7+2*sen],:ch_mean=>row[8+2*sen]) unless row[7+2*sen].nil? and row[7+2*sen]==""
            end
            p "--#{row[0]} UPDATED OVER  --"
          end
        end
      end
      WordsHelper.write_error("imported_lists",file)
    end
  else
    p "--NOTHING CAN BE OPERATE --"
  end
end