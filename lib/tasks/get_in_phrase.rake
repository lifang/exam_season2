# encoding: utf-8

namespace :get do
  desc "get phrase from iciba"
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
      Spreadsheet.client_encoding = "UTF-8"
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      sheet.row(0).concat %w{单词 分类 中文翻译 词性 发音 等级 音频 例句1 翻译1 例句2 翻译2 例句3 翻译3}
      words_phrase.keys.each_with_index do |word,index|
        word=word.gsub(/[0-9]*$/, "").gsub("’","'")
        if word != nil and word.strip != ""
          word=word.downcase if word.length>1
          word_restore=WordsHelper.word_restore(word).strip
          already_word = Word.first(:conditions=>"name like \"#{word_restore}\"")
          if already_word.nil?
             content=WordsHelper.phrase_detail(word.gsub(")", "").gsub("(", ""),words_phrase[word],word_restore)
            sheet.row(index+1).concat content unless content.nil?
          end
        end
      end
      execl_url="#{Rails.root}/public/words_data/xmls/#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
      book.write execl_url
    end
  end
 
end