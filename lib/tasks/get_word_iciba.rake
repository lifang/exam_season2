# encoding: utf-8

namespace :get do
  desc "get word from iciba"
  task(:word_iciba => :environment) do
    include WordsHelper
    file_url="#{Rails.root}/public/words_data/all.txt"
    if File.exist? file_url
      match_file = File.open(file_url,"rb")
      words = match_file.readlines.join(";").gsub("\r\n", "").gsub(",", ";").gsub(".", ";").gsub(")", "").gsub("(", "").to_s.split(";")
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
      word_row=0
      excel_sum=100
      sheet,book=[]
      words.each_with_index do |word,index|
        word=word.force_encoding('UTF-8').gsub(/[0-9]*$/, "").gsub("’","'")
        if word != nil and word.strip != ""
          word=word.downcase if word.length>1
          word=word.strip
          num_word="(\"#{word}\""
          (1..9).each{|num| num_word << ",\"#{word}#{num}\"" }
          num_word += ")"
          already_word = Word.first(:conditions=>"name in #{num_word}")
          if already_word.nil?
            content=WordsHelper.word_detail(word,url)
            unless content.nil?
              content.each do |c|
                excel_index=word_row%excel_sum
                if excel_index==0
                  Spreadsheet.client_encoding = "UTF-8"
                  book = Spreadsheet::Workbook.new
                  sheet = book.create_worksheet
                  sheet.row(0).concat %w{单词 分类 中文翻译 词性 发音 等级 音频 例句1 翻译1 例句2 翻译2 例句3 翻译3}
                end
                sheet.row(excel_index+1).concat c
                if excel_index==excel_sum-1 || words.length==index+1
                  execl_url="#{Rails.root}/public/words_data/xmls/#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
                  book.write execl_url
                end
                word_row += 1
              end
            else
              if word_row%excel_sum==0
                Spreadsheet.client_encoding = "UTF-8"
                book = Spreadsheet::Workbook.new
                sheet = book.create_worksheet
                sheet.row(0).concat %w{单词 分类 中文翻译 词性 发音 等级 音频 例句1 翻译1 例句2 翻译2 例句3 翻译3}
              end
              if  words.length==index+1
                execl_url="#{Rails.root}/public/words_data/xmls/#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
                book.write execl_url
              end
            end
          end
        end
      end
    end
  end
 
end