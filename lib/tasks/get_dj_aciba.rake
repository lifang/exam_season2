# encoding: utf-8
require 'net/https'
require 'uri'
require 'mechanize'
require 'hpricot'
require 'open-uri'
require 'rubygems'

namespace :dj_iciba do
  desc "get sentence"
  task(:get => :environment) do
    words = ["worth one's salt","work at","work on","without fail"]
	str = ""
    file = File.new("c:/dj_aciba.txt", File::CREAT|File::TRUNC|File::RDWR, 0644)
    words.each do |word|
      begin
        puts " start catch  ---- #{word}"
        exist = false
        #获取词组意思(如果词组存在)
        url = "http://www.iciba.com/"
        agent = Mechanize.new
        page = agent.get(url + "#{word}")
        source = Hpricot(page.body)
        if source.search('div[@class=unfound_tips]').length==0
          exist = true
          meaning = source.search('div[@class=group_pos]').search('span[@class=label_list]').search('label').inner_html.gsub(/<[^{><}]*>/, "").gsub("  "," ").strip
          puts " get meaning : #{meaning}         -----#{word}"
          # 下载音频
          audio_uri = source.search('div[@class=dictbar]').search('span[@class=eg]').search('a').attr('onclick')
          enunciate_url = ""
          if audio_uri
            audio_uri = audio_uri.split("'")[1]
            open(audio_uri) do |fin|
              file_type = audio_uri.split('.').reverse[0]
              all_dir = "#{Rails.root}/public/word_datas/#{Time.now.strftime("%Y%m%d")}/"
              FileUtils.makedirs all_dir    #建目录
              puts "start download audio   ----#{word}"
              File.open("#{all_dir}#{word}.#{file_type}", "wb+") do |fout|
                while buf = fin.read(1024) do
                  fout.write buf
                  STDOUT.flush
                end
              end
              enunciate_url = "/word_datas/#{Time.now.strftime("%Y%m%d")}/#{word}.#{file_type}"
              puts "download audio over  ----#{word}"
            end
          end
          sleep 5
        else
          puts " error ,  not exist   ----#{word}"
        end
        #获取例句（如果词组存在）
        if exist
          url = "http://dj.iciba.com/"
          agent = Mechanize.new
          page = agent.get(url + "#{word}")
          source = Hpricot(page.body).search('div[@class=mContentW]').search('div[@class=mContentLi]')
          #例句
          sentence = []
          source.each do |s|
            arr = []
            en = s.search('div[@class=mEn]').search('b').inner_html.gsub(/<[^{><}]*>/, "").strip
            cn = s.search('div[@class=mCn]').inner_html.gsub(/<span[^>]*?>.*?<\/span>/,"").gsub(/<[^{><}]*>/, "").gsub("  "," ").strip
            arr << en << cn
            sentence << arr
          end
        end unless source.nil?
        puts "catch #{sentence.length} sentences   ----#{word}"
        sleep 5
        puts "------------------------------------------------------------------------"
        file.write(word)
        file.write("\n-------------------------------------------------------------\n")
        file.write(meaning)
        file.write("\n-------------------------------------------------------------\n")
        sentence.each do |s|
             file.write(s.to_s)
             file.write("\n-------------------------------------------------------------\n")
         end
         file.write("\n\n\n\n\n\n")
		
        
        #存取数据库
        #        pram={:category_id => 2, :name => word, :types => pho,
        #              :phonetic => yinbiao.strip, :enunciate_url => "/word_datas/#{Time.now.strftime("%Y%m%d")}/#{word}.#{file_name}",
        #              :en_mean => ds[0],
        #              :ch_mean => ch, :level => Word::WORD_LEVEL[:THIRD]}
        
        #Word.create(:name=>word,:ch_mean=>meaning,:category_id =>2,:enunciate_url => enunciate_url,:level => 2)
		
      
      rescue
        puts "rescue  --- #{word}"
      end
      
    end
    file.close
  end
end