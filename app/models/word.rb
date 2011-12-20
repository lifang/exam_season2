#encoding: utf-8
class Word < ActiveRecord::Base
  require 'net/https'
  require 'uri'
  require 'mechanize'
  require 'hpricot'
  require 'open-uri'
  require 'rubygems'
  require 'fileutils'
  require 'rexml/document'
  include REXML
  
  belongs_to :category
  has_many :word_sentences
  has_many :word_question_relations,:dependent=>:destroy
  has_many :questions,:through=>:word_question_relations, :source => :question
  has_many :word_discriminate_relations,:dependent => :destroy
  has_many :discriminates,:through=>:word_discriminate_relations, :source => :discriminate  

  TYPES = {0 => "n.", 1 => "v.", 2 => "pron.", 3 => "adj.", 4 => "adv.",
    5 => "num.", 6 => "art.", 7 => "prep.", 8 => "conj.", 9 => "interj.", 10 => "u = ", 11 => "c = ", 12 => "pl = "}
  #英语单词词性 名词 动词 代词 形容词 副词 数词 冠词 介词 连词 感叹词 不可数名词 可数名词 复数
  LEVEL = {1 => "一", 2 => "二", 3 => "三", 4 => "四", 5 => "五", 6 => "六",
    7 => "七", 8 => "八", 9 => "九", 10 => "十"}  #单词的等级
  
  def self.get_words(category_id, search_text, page)
    sql = "select w.id, w.name from words w where w.category_id = ? "
    sql += " and name like ? " unless search_text.nil? or search_text.strip.empty?
    sql += " order by name "
    unless search_text.nil? or search_text.strip.empty?
      words = Word.paginate_by_sql([sql, category_id, "%#{search_text.strip}%"], :per_page => 10, :page => page)
    else
      words = Word.paginate_by_sql([sql, category_id], :per_page => 10, :page => page)
    end
    return words
  end

  #上传音频文件
  def self.upload_enunciate(url, file_path)
    dir = "#{Rails.root}/public"
    filename = file_path.original_filename
    unless File.directory?(dir + url)
      Dir.mkdir(dir + url)
    end
    filename = url + filename
    File.open("#{File.expand_path(Rails.root)}/public#{filename}", "wb") do |f|
      f.write(file_path.read)
    end
    return filename
  end

  #从网络上下载单词
  def self.get_word_from_web(word)
    begin
      url = "http://oald8.oxfordlearnersdictionaries.com/dictionary/"
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
      url_ch = "http://hk.dictionary.yahoo.com/dictionary?p="
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
    rescue
      word_info=",;,,;,,;,,;,,;,,;,"
    end
    return word_info
  end

end
