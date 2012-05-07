# encoding: utf-8
require 'net/https'
require 'uri'
require 'mechanize'
require 'hpricot'
require 'open-uri'
require 'rubygems'
require 'fileutils'
require 'rexml/document'
include REXML
require 'spreadsheet'

namespace :cet_word do
  desc "notice rater"
  task(:ciba_word => :environment) do
    match_file = File.open("#{Rails.root}/public/all.txt","rb")
    words = match_file.readlines.join(";").gsub("\r\n", "").gsub(",", ";").gsub(".", ";").to_s.split(";")
    match_file.close
    url = "http://www.iciba.com/"
    words.each do |word|
      if word != nil and word.strip != "" and word.strip.split(" ").length==1
        word=word.gsub(/[0-9]*$/, "").downcase
        already_word = Word.first(:conditions=>"name like '#{word}' or name like '#{word}_'")
        if already_word.nil?
          begin
            agent = Mechanize.new
            page = agent.get(url + "#{word}")
            #    contents =Iconv.conv("UTF-8//IGNORE", "GB2312",page.body )
            #    contents =Iconv.conv("GB2312//IGNORE", "UTF-8", contents)
            #            puts "page aready"
            doc_utf = Hpricot(page.body)
            puts "#{word} start"
            part_main=doc_utf.search('div[@class=part_main]')
            raise unless doc_utf.search('div[@class=question unfound_tips]').blank?
            word_sum=part_main.length
            group_pos=doc_utf.search('div[@class=group_pos]').search("p")
            eg=doc_utf.search('div[@class=prons]').search('span[@class=eg]')
            #音频文件
            word_soundmark=eg.search('a')
            return_value=dowload_audio(word_soundmark,word)
            sound_over=return_value[0]
            file_name=return_value[1]
            word_pronounce=eg.search("strong")[1].nil? ? "" : eg.search("strong")[1].inner_html.to_s   #音标
            unless word_sum==0
              (0..word_sum-1).each do |i|
                name=word
                puts name
                word_type=group_pos[i].search("strong").blank? ? "" : group_pos[i].search("strong").inner_html.to_s #词性
                ch=group_pos[i].search('span[@class=label_list]').search('label')
                word_ch=ch.blank? ? "" : ch.inner_html.to_s #中文词义
                sin_word=part_main[i].search("div[@class=collins_en_cn]")[0]
                caption=sin_word.search("div[@class=caption]")
                caption.search("span").remove
                caption.search("div").remove
                word_en=caption.blank? ? "" : caption.inner_html.gsub(/<[^{><}]*>/, "").strip.to_s #英语词义
                #                puts "download end, save db start"
                name="#{word}#{i+1}" if part_main.length>1
                types = word_types(word_type)
                pram={:category_id => 3, :name =>name, :types =>types,:phonetic =>word_pronounce.strip,
                  :en_mean =>word_en,:ch_mean =>word_ch, :level => Word::WORD_LEVEL[:THIRD]}
                pram.merge!(:enunciate_url => "/word_datas/#{Time.now.strftime("%Y%m%d")}/#{word}.#{file_name}") if sound_over
                new_word = Word.create(pram)
                sin_word.search("li").each do |sententce| #示例例句
                  WordSentence.create(:word_id => new_word.id, :description =>sententce.search("p")[0].inner_html.gsub(/<[^{><}]*>/, "").strip.to_s)
                end unless sin_word.search("li").blank?
                puts "#{name} save end"
                sleep 10
              end
            else
              word_type=group_pos[0].search("strong").blank? ? "" : group_pos[0].search("strong").inner_html.to_s #词性
              types = word_types(word_type)
              word_ch= group_pos[0].search('span[@class=label_list]').search('label').inner_html.to_s #中文词义
              word_en=""
              pram={:category_id => 3, :name =>word, :types =>types,:phonetic =>word_pronounce.strip,
                :en_mean =>word_en,:ch_mean =>word_ch, :level => Word::WORD_LEVEL[:THIRD]
              }
              pram.merge!(:enunciate_url => "/word_datas/#{Time.now.strftime("%Y%m%d")}/#{word}.#{file_name}") if sound_over
              new_word = Word.create(pram)
              puts "#{word} save end but no sentences"
            end
          rescue
            puts "#{word} download error"
          end
        end
      else

      end
    end
  end

  def word_types(word_type)
    types=0
    Word::TYPES.each do |k, v|
      if word_type.include?(v.gsub(".", ""))
        types = k
        break
      end
    end
    return types
  end

  def dowload_audio(word_soundmark,word)
    sound_over=false
    unless word_soundmark.blank?
      soundmark=word_soundmark.attr('onclick')
      sound_uri =soundmark.split("'")[1]
      file_name = "mp3"
      open(sound_uri) do |fin|
        file_name = sound_uri.split('.').reverse[0]
        all_dir = "#{Rails.root}/public/word_datas/#{Time.now.strftime("%Y%m%d")}/"
        FileUtils.makedirs all_dir    #建目录
        #                puts 'begin download sound'
        File.open("#{all_dir}#{word}.#{file_name}", "wb+") do |fout|
          while buf = fin.read(1024) do
            fout.write buf
            STDOUT.flush
          end
        end
        #                  puts 'download sound over'
      end
      sound_over=true
    end
    return [sound_over,file_name]
  end
end