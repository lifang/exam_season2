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
      url = "http://www.iciba.com/"
      word_row=0
      excel_sum=100
      sheet,book=[]
      words.each_with_index do |single_word,index|
        word=single_word.force_encoding('UTF-8').gsub(/[0-9]*$/, "").gsub("’","'")
        if word != nil and word.strip != ""
          word=word.downcase if word.length>1
          word=WordsHelper.get_one(word)  unless  word.match("/").nil?
          content=WordsHelper.word_detail(word.gsub("(","").gsub(")",""),url,single_word)
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