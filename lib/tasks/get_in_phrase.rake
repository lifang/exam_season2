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
        if word != nil and word.strip != ""
          all_words=word.force_encoding('UTF-8').split(/[\u4E00-\u9FA5\uF900-\uFA2D]+/)
          words_phrase[all_words[0]]=word.gsub(all_words[0],"")
        end
      end
      sheet,book=[]
      excel_sum=100
      phrase_row=0
      words_phrase.keys.each_with_index do |word_ph,index|
        word=word_ph.gsub(/[0-9]*$/, "").gsub("’","'").strip
        if word != nil and word != ""
          word=word.downcase if word.length>1
          word=WordsHelper.get_one(word)  unless  word.match("/").nil?
          content=WordsHelper.phrase_detail(word.gsub("(","").gsub(")",""),words_phrase[word_ph],word_ph)
          excel_index = phrase_row%excel_sum
          if excel_index==0
            Spreadsheet.client_encoding = "UTF-8"
            book = Spreadsheet::Workbook.new
            sheet = book.create_worksheet
            sheet.row(0).concat %w{单词 分类 中文翻译 词性 发音 等级 音频 例句1 翻译1 例句2 翻译2 例句3 翻译3}
          end
          unless content.nil?
            sheet.row(excel_index+1).concat content
            phrase_row +=1
          end
          if excel_index == excel_sum-1 || words_phrase.keys.length==index+1
            execl_url="#{Rails.root}/public/words_data/xmls/#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
            book.write execl_url
          end
        end
      end
    end
  end
 
end