# encoding: utf-8

namespace :word do
  desc "notice rater"
  task(:in_phrase => :environment) do
    include WordsHelper
    file_url="#{Rails.root}/public/words_data/phrases.txt"
    if File.exist? file_url
      match_file = File.open(file_url,"rb")
      words = match_file.readlines.join(";").gsub("\r\n", "").gsub(".", ";").to_s.split(";")
      match_file.close
      words_phrase={}
      words.each do |word|
        all_words=word.force_encoding('UTF-8').split(/[\u4E00-\u9FA5\uF900-\uFA2D]+/)  if word != nil and word.strip != ""
        unless all_words.nil?
          sin_word=all_words[0]
          words_phrase[sin_word]=word.gsub(sin_word,"")
          unless  sin_word.match("/").nil?
            words_phrase.delete("#{sin_word}")
            new_word=sin_word.split(" ")
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
              words_phrase[new_word.join(" ")]=word.gsub(sin_word,"")
            end
          end
        end   
      end
      words_phrase.keys.each do |word|
        word=word.gsub(/[0-9]*$/, "").gsub("’","'")
        if word != nil and word.strip != ""
          word=word.downcase if word.length>1
          already_word = Word.first(:conditions=>"name like \"#{word.strip}\"")
          if already_word.nil?
            WordsHelper.phrase_detail(word,words_phrase[word])
          end
        end
      end
    end
  end
 
end