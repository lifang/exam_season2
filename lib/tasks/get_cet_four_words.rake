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

namespace :cet6_word do
  desc "notice rater"
  task(:get_word => :environment) do
    match_file = File.open("#{Rails.root}/public/words_data/all.txt","rb")
    words = match_file.readlines.join(";").gsub("\r\n", "").to_s.split(";")
    match_file.close
    url = "http://oald8.oxfordlearnersdictionaries.com/dictionary/"
    url_ch = "http://hk.dictionary.yahoo.com/dictionary?p="
    words.each do |word|
      if word != nil and word.strip != ""
        already_word = Word.find_by_name(word)
        if already_word.nil?
          begin
            puts "#{word} start"
            agent = Mechanize.new
            page = agent.get(url + "#{word}")
            #    contents =Iconv.conv("UTF-8//IGNORE", "GB2312",page.body )
            #    contents =Iconv.conv("GB2312//IGNORE", "UTF-8", contents)
            puts "page aready"
            doc_utf = Hpricot(page.body)
            #词性
            pos = doc_utf.search('div[@class=webtop-g]').search('span[@class=pos]').inner_html unless
            doc_utf.search('span[@class=pos]').nil?

            #获取释义和例句
            infos = doc_utf.search('span[@class=n-g]')
            descriptions = {}   #释义为key，例句为value
            ds = []
            if infos.inner_html.to_s.strip == ""
              d = doc_utf.search("span[@class=d]").inner_html.gsub(/<[^{><}]*>/, "")  #释义
              d = doc_utf.search("span[@class=ud]").inner_html.gsub(/<[^{><}]*>/, "") if d.to_s.strip == ""
              ds << d
              doc_utf.search("span[@class=x]").each do |sentence|
                if descriptions[d].nil? or descriptions[d].length < sentence.inner_html.gsub(/<[^{><}]*>/, "").length
                  descriptions[d] = sentence.inner_html.gsub(/<[^{><}]*>/, "")
                end
              end unless doc_utf.search("span[@class=x]").inner_html.to_s.strip == ""
            else
              puts infos.length
              infos.each do |block|
                unless block.search('/img').length == 0
                  d = block.search("span[@class=d]").inner_html.gsub(/<[^{><}]*>/, "")
                  d = block.search("span[@class=ud]").inner_html.gsub(/<[^{><}]*>/, "") if d.to_s.strip == ""
                  ds << d
                  block.search("span[@class=x]").each do |sentence|
                    if descriptions[d].nil? or descriptions[d].length < sentence.inner_html.gsub(/<[^{><}]*>/, "").length
                      descriptions[d] = sentence.inner_html.gsub(/<[^{><}]*>/, "")
                    end
                  end unless block.search("span[@class=x]").inner_html.to_s.strip == ""
                end
              end
              if ds.blank?
                d = infos[0].search("span[@class=d]").inner_html.gsub(/<[^{><}]*>/, "")
                d = infos[0].search("span[@class=ud]").inner_html.gsub(/<[^{><}]*>/, "") if d.to_s.strip == ""
                ds << d
                infos[0].search("span[@class=x]").each do |sentence|
                  if descriptions[d].nil? or descriptions[d].length < sentence.inner_html.gsub(/<[^{><}]*>/, "").length
                    descriptions[d] = sentence.inner_html.gsub(/<[^{><}]*>/, "")
                  end
                end unless infos[0].search("span[@class=x]").inner_html.to_s.strip == ""
              end
            end
            #获取音标和音频
            info = doc_utf.search('div[@class=ei-g]').search('span[@class=i]')
            unless info.search('/img').attr('onclick').nil?
              img = info.search('/img').attr('onclick').split("'")[1]
              uri = "http://oald8.oxfordlearnersdictionaries.com" +img
              puts uri
              file_name = ""
              open(uri) do |fin|
                file_name = uri.split('.').reverse[0]
                all_dir = "#{Rails.root}/public/word_datas/#{Time.now.strftime("%Y%m%d")}/"
                FileUtils.makedirs all_dir    #建目录
                puts 'begin download pic'
                File.open("#{all_dir}#{word}.#{file_name}", "wb+") do |fout|
                  while buf = fin.read(1024) do
                    fout.write buf
                    STDOUT.flush
                  end
                end
                puts 'download pic over'
              end
              yinbiao = info.inner_html.force_encoding('UTF-8').gsub(/<[^{><}]*>/, "")
              puts yinbiao
            end

            #中文词义
            agent = Mechanize.new
            ch_page = agent.get(url_ch + "#{word}")
            doc_utf = Hpricot(ch_page.body)
            ch_infos = doc_utf.search('div[@id=summary-card]').search('div[@class=summary]').search('div[@class=description]')
            ch_ds = []
            ch_infos.each do |block|
              d = block.inner_html.gsub(/<[^{><}]*>/, "").gsub(", ", ";").gsub(",", ";")
              ch_ds << d
            end
            ch=ch_ds[0].nil? ? "暂无中文释义" : ch_ds[0].split(".").length>1 ? ch_ds[0].split(".")[1] :ch_ds[0].split(".")[0]
            word_info = "#{word},;,#{pos},;,#{ds[0]},;,#{ch},;,#{yinbiao},;,/word_datas/#{Time.now.strftime("%Y%m%d")}/#{word}.#{file_name},;,#{descriptions[ds[0]]}"
            puts word_info
            puts "download end, save db start"
            pho = 0
            Word::TYPES.each do |k, v|
              if pos.include?(v.gsub(".", ""))
                pho = k
                break
              end
            end
            pram={:category_id => 3, :name => word, :types => pho,
              :phonetic => yinbiao.strip, :enunciate_url => "/word_datas/#{Time.now.strftime("%Y%m%d")}/#{word}.#{file_name}",
              :en_mean => ds[0],
              :ch_mean => ch, :level => Word::WORD_LEVEL[:THIRD]}
            new_word = Word.create(pram)
            WordSentence.create(:word_id => new_word.id, :description => descriptions[ds[0]].strip) unless
            (descriptions[ds[0]].nil? or descriptions[ds[0]].strip.empty?)
            puts "save end"
            sleep 10
          rescue
            puts "#{word} download error"
          end
        end
      end
    end
  end
end