# encoding: utf-8
require 'net/https'
require 'uri'
require 'mechanize'
require 'hpricot'
require 'open-uri'
require 'rubygems'
require 'spreadsheet'

namespace :get do
  desc "get sentence"
  task(:dj_iciba => :environment) do
    include WordsHelper
    match_file = File.open("#{Rails.root}/public/words_data/sentences.txt","rb")
    words = match_file.readlines.join(";").gsub("\r\n", "").gsub(",", ";").gsub(".", ";").to_s.split(";")
    match_file.close

    excel_sum=100  #execl记录数

    #记录未抓取到的文件
    rescue_url="#{Rails.root}/public/words_data/rescue.txt"
    rescue_file = File.new(rescue_url,"w+")
    
    #处理带'/'的词组
    new_words = []
    words.each do |word|
      if word.include?("/")
        r_index = []
        r_arr = []
        line_arr = word.split(" ")
        line_arr.each_with_index do |l,index|
          if l.include?("/")
            r_index << index
            r_arr = r_arr==[] ? l.split("/") : r_arr.product(l.split("/")).collect{|a|a.flatten}
          end
        end
        r_arr.each do |a|
          a = [a] if a.class==String
          a.each_with_index do |w,index|
            line_arr[r_index[index]] = w
          end
          new_words << line_arr.join(" ")
        end
      else
        new_words << word
      end
    end
    sheet,book = ""
    words = new_words
    success_index = 0
    words.each_with_index do |word,index|
      word=word.downcase if word.length>1
      begin
        next if word.strip==""
        puts "\n\n------------START- -------------------------- #{word}\n\n"

        exist = false
        #获取词组意思(如果词组存在)
        url = "http://www.iciba.com/"
        agent = Mechanize.new
        page = agent.get(url + "#{word}")
        source = Hpricot(page.body)
        if source.search('div[@class=unfound_tips]').length==0
          exist = true
          meaning = source.search('div[@class=group_pos]').search('span[@class=label_list]').search('label').inner_html.gsub(/<[^{><}]*>/, "").gsub("  "," ").strip
          meaning="***#{meaning}" if !meaning.nil? and meaning.length>=10
          puts "--OK-- GOT TRANSLATION"
          # 下载音频
          audio_uri = source.search('div[@class=dictbar]').search('span[@class=eg]').search('a').attr('onclick')
          enunciate_url = ""
          if audio_uri
            audio_uri = audio_uri.split("'")[1]
            open(audio_uri) do |fin|
              file_type = audio_uri.split('.').reverse[0]
              all_dir = "#{Rails.root}/public/word_datas/#{Time.now.strftime("%Y%m%d")}/"
              FileUtils.makedirs all_dir    #建目录
              File.open("#{all_dir}#{word.gsub("  "," ").gsub("'","")}.#{file_type}", "wb+") do |fout|
                while buf = fin.read(1024) do
                  fout.write buf
                  STDOUT.flush
                end
              end
              enunciate_url = "/word_datas/#{Time.now.strftime("%Y%m%d")}/#{word.gsub("  "," ").gsub("'","")}.#{file_type}"
              puts "--OK-- AUDIO DOWNLOADED"
            end
          end
          sleep 5
        else
          puts "(NOT FOUND)"
          puts "--------------------------------------------------------"
        end
        dj_content=["#{word.strip}","2","#{meaning}","","","3", "#{enunciate_url}"]
       
        if exist
          dj_content=WordsHelper.dict_words(word,dj_content)  #获取例句（如果词组存在）
        end unless source.nil?
        puts "\n------------ END - SUCCESS------------------- #{word}\n\n"
        sleep 5
        excel_index = success_index%excel_sum
        if excel_index == 0
          Spreadsheet.client_encoding = "UTF-8"
          book = Spreadsheet::Workbook.new
          sheet = book.create_worksheet
          sheet.row(0).concat %w{单词 分类 中文翻译 词性 发音 等级 音频 例句1 翻译1 例句2 翻译2 例句3 翻译3}
        end
        sheet.row(excel_index+1).concat dj_content
        success_index += 1
      rescue
        puts "\n------------ END - RESCUE ------------------- #{word}\n"
        puts "--------------------------------------------------------"
        rescue_file.write("#{word}\n")
      end
      if excel_index == excel_sum-1 || index == words.length-1
        execl_url="#{Rails.root}/public/words_data/xmls/#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
        book.write execl_url
      end
    end
    rescue_file.close
  end
end