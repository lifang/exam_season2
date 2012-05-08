# encoding: utf-8

namespace :word do
  desc "notice rater"
  task(:in_prase => :environment) do
    include WordsHelper
    file_url="#{Rails.root}/public/phrase_with_paraphrase.txt"
    if File.exist? file_url
      match_file = File.open(file_url,"rb")
      words = match_file.readlines.join(";").gsub("\r\n", "").gsub(",", ";").gsub(".", ";").to_s.split(";")
      match_file.close
      delete_words=[]
      words.each do |word|
        unless  word.match("/").nil?
          delete_words << word
          new_word=word.split(" ")
          new_word.each_with_index do |one_word,index|
            if one_word.include?("/")
              one_word.split("/").each do |ci|
                new_word[index]=ci
                words << new_word.join(" ")
              end
            end
          end
        end
      end
      p words
      words=words-delete_words
      p words
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
 
end