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
    url = "http://oald8.oxfordlearnersdictionaries.com/dictionary/"
    agent = Mechanize.new
    page = agent.get(url + "#{word}")
    contents =Iconv.conv("UTF-8//IGNORE", "GB2312",page.body )
    contents =Iconv.conv("GB2312//IGNORE", "UTF-8", contents)
    puts "page aready"
    doc_utf = Hpricot(contents)
    puts "start"
    pos = doc_utf.search('div[@class=webtop-g]').search('span[@class=pos]').inner_html unless
      doc_utf.search('span[@class=pos]').nil?     #词性
    puts pos
    
    infos = doc_utf.search('span[@class=n-g]')      #获取释义和例句
    descriptions = {}   #释义为key，例句为value
    ds = []
    if infos.inner_html.to_s.strip == ""
      d = doc_utf.search("span[@class=d]").inner_html.gsub(/<[^{><}]*>/, "")  #释义
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
        ds << d
        infos[0].search("span[@class=x]").each do |sentence|
          if descriptions[d].nil? or descriptions[d].length < sentence.inner_html.gsub(/<[^{><}]*>/, "").length
            descriptions[d] = sentence.inner_html.gsub(/<[^{><}]*>/, "")
          end
        end unless infos[0].search("span[@class=x]").inner_html.to_s.strip == ""
      end
    end

    


    puts "create"
    ds.each do |d|
      puts "#{word},#{pos},#{d},#{descriptions[d]}"
    end unless ds.blank?

  end

end
