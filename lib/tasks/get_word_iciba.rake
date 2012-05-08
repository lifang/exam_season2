# encoding: utf-8

namespace :get do
  desc "notice rater"
  task(:word_iciba => :environment) do
    include WordsHelper
    file_url="#{Rails.root}/public/words_data/all.txt"
    if File.exist? file_url
      match_file = File.open(file_url,"rb")
      words = match_file.readlines.join(";").gsub("\r\n", "").gsub(",", ";").gsub(".", ";").to_s.split(";")
      match_file.close
      delete_words=[]
      words.each do |word|
        unless  word.match("/").nil?
          delete_words << word
          new_word=word.split(" ")
          init_pos=[]
          init_words=[]
          new_word.each_with_index do |one_word,index|
            if one_word.include?("/")
              init_pos << index
              init_words = init_words==[] ? one_word.split("/") :init_words.product(one_word.split("/")).collect{|a|a.flatten}
            end
          end
          init_words.each do |a|
            a = [a] if a.class==String
            a.each_with_index do |ci,index|
              new_word[init_pos[index]] = ci
            end
            words << new_word.join(" ")
          end
        end
      end
      words=words-delete_words
      url = "http://www.iciba.com/"
      words.each do |word|
        word=word.force_encoding('UTF-8').gsub(/[0-9]*$/, "").gsub("’","'")
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
 
end