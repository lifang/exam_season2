# encoding: utf-8

namespace :cet_word do
  desc "notice rater"
  task(:ciba_word => :environment) do
    include WordsHelper
    match_file = File.open("#{Rails.root}/public/all.txt","rb")
    words = match_file.readlines.join(";").gsub("\r\n", "").gsub(",", ";").gsub(".", ";").to_s.split(";")
    match_file.close
    delete_words=[]
    words.each do |word|
      unless  word.match("/").nil?
        new_word=word.split("/")
        delete_words << word
        words << new_word[0]
        words << "#{new_word[0].split(" ")[0]} #{new_word[1]}"
      end
    end
    words=words-delete_words
    url = "http://www.iciba.com/"
    words.each do |word|
      word=word.gsub(/[0-9]*$/, "")
      if word != nil and word.strip != ""
        word=word.downcase if word.length>1
        word=word.strip
        num_word="(\"#{word}\""
        (1..9).each{|num| num_word << ",\"#{word}#{num}\"" }
        num_word += ")"
        already_word = Word.first(:conditions=>"name in #{num_word}")
        if already_word.nil?
          WordsHelper.word_detail(word,url)
        end
      end
    end
  end

 
end