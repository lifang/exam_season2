# encoding: utf-8
require 'net/https'
require 'uri'
require 'mechanize'
require 'hpricot'
require 'open-uri'
require 'rubygems'
require 'spreadsheet'

namespace :dj_iciba do
  desc "get sentence"
  task(:get => :environment) do
    match_file = File.open("#{Rails.root}/public/words_data/rake_dj_iciba/sentence.txt","rb")
    words = match_file.readlines.join(";").gsub("\r\n", "").gsub(",", ";").gsub(".", ";").to_s.split(";")
    match_file.close

    excel_sum=2  #execl记录数
    
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    sheet.row(0).concat %w{单词 分类 中文翻译 词性 发音 等级 音频 例句1 翻译1 例句2 翻译2 例句3 翻译3}

    #记录未抓取到的文件
    rescue_url="#{Rails.root}/public/words_data/rake_dj_iciba/rescue.txt"
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
    words = new_words
    words.each_with_index do |word,index|
      begin
        puts "\n\n------------START- -------------------------- #{word}\n\n"
        
#        already_word = Word.first(:conditions=>"name = \"#{word.strip}\"")
#        if already_word
#          puts "(ALREADY EXIST)"
#          puts "--------------------------------------------------------"
#          next
#        end

        exist = false
        #获取词组意思(如果词组存在)
        url = "http://www.iciba.com/"
        agent = Mechanize.new
        page = agent.get(url + "#{word}")
        source = Hpricot(page.body)
        if source.search('div[@class=unfound_tips]').length==0
          exist = true
          meaning = source.search('div[@class=group_pos]').search('span[@class=label_list]').search('label').inner_html.gsub(/<[^{><}]*>/, "").gsub("  "," ").strip
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
        #获取例句（如果词组存在）
        if exist
          url = "http://dj.iciba.com/"
          agent = Mechanize.new
          dj_word = word.gsub("one's","")
          page = agent.get(url + "#{dj_word}")
          source = Hpricot(page.body).search('div[@class=mContentW]').search('div[@class=mContentLi]')
          #例句
          sentence = []
          source = source[-3,3]
          source.each do |s|
            arr = []
            en = s.search('div[@class=mEn]').search('b').inner_html.gsub(/<[^{><}]*>/, "").strip
            cn = s.search('div[@class=mCn]').inner_html.gsub(/<span[^>]*?>.*?<\/span>/,"").gsub(/<[^{><}]*>/, "").gsub("  "," ").strip
            arr << en << cn
            sentence << arr
          end
        end unless source.nil?
        puts "--OK-- GOT #{sentence.length} SENTENCES \n"
        puts "\n------------ END - SUCCESS------------------- #{word}\n\n"
        sleep 5
              #    存取数据库(弃用)
      #        new_word = Word.create(:name=>word.strip,:ch_mean=>meaning,:category_id =>2,:enunciate_url => enunciate_url,:level => Word::WORD_LEVEL[:THIRD])
      #        sentence.each do |s|
      #          WordSentence.create(:word_id => new_word.id, :description =>s[0])
      #        end

      #存取EXECL
      (0..2).each do |i|
        sentence[i]=[] unless sentence[i]
      end
      excel_index = index%excel_sum
      sheet.delete_row(excel_index+1)
      sheet.row(excel_index+1).concat ["#{word.strip}","2","#{meaning}","","","3", "#{enunciate_url}","#{sentence[0][0]}", "#{sentence[0][1]}","#{sentence[1][0]}","#{sentence[1][1]}","#{sentence[2][0]}","#{sentence[2][1]}"]
      rescue
        puts "\n------------ END - RESCUE ------------------- #{word}\n"
        puts "--------------------------------------------------------"
        rescue_file.write("#{word}\n")
      end

      if excel_index == excel_sum-1
        execl_url="#{Rails.root}/public/words_data/rake_dj_iciba/#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
        book.write execl_url
      end
      
    end
    rescue_file.close
  end
end