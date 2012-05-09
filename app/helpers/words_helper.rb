# encoding: utf-8
module WordsHelper

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

  #为单词匹配词性
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

  #下载音频文件
  def dowload_audio(word_soundmark,word)
    sound_over=false
    unless word_soundmark.blank?
      soundmark=word_soundmark.attr('onclick')
      sound_uri =soundmark.split("'")[1]
      file_name = "mp3"
      puts 'begin download sound'
      time=Time.now
      open(sound_uri) do |fin|
        file_name = sound_uri.split('.').reverse[0]
        all_dir = "#{Rails.root}/public/word_datas/#{Time.now.strftime("%Y%m%d")}/"
        FileUtils.makedirs all_dir    #建目录
        File.open("#{all_dir}#{word}.#{file_name}", "wb+") do |fout|
          while buf = fin.read(1024) do
            fout.write buf
            STDOUT.flush
          end
        end
        puts "take time #{Time.now-time} s"
      end
      sound_over=true
    end
    return [sound_over,file_name]
  end


  #获取例句
  def sen_detail(word)
    model_url = "http://dj.iciba.com/"
    model_agent = Mechanize.new
    word=word.gsub("one's","").gsub("…"," ").gsub("sb's","")
    model_page = model_agent.get(model_url + "#{word}")
    model_doc= Hpricot(model_page.body)
    sens=[]
    if model_doc.search('div[@class=mainL]').search('div[@class=mContentNothing]').blank?
      sentences=model_doc.search('div[@class=mContentW]').search('div[@class=mContentLi]')
      has_sentences=false
      descriptions=[]
      has_index=0
      sentences.each do |sententce| #示例例句
        description=sententce.search('div[@class=mEn]').search("b").inner_html.gsub(/<[^{><}]*>/, "").strip.to_s
        cn_des = sententce.search('div[@class=mCn]').inner_html.gsub(/<span[^>]*?>.*?<\/span>/,"").gsub(/<[^{><}]*>/, "").gsub("  "," ").strip
        descriptions << [description, cn_des]
        if description!= nil  and description != "" and  description.split(" ").length>5
          break if has_index >2
          has_sentences=true
          has_index += 1
          sens << [description,cn_des]
        end
      end unless sentences.blank?
      unless has_sentences
        descriptions[0..2].each do |sentence|
          sens << sentence
        end
      end
    end
    puts "#{sens.length} sentences save end --success"
    return sens
  end

  #截取单词及相关内容
  def word_detail(word,url)
    begin
      agent = Mechanize.new
      page = agent.get(url + "#{word}")
      #    contents =Iconv.conv("UTF-8//IGNORE", "GB2312",page.body )
      #    contents =Iconv.conv("GB2312//IGNORE", "UTF-8", contents)
      #            puts "page aready"
      doc_utf = Hpricot(page.body)
      puts "--#{word}-- start"
      part_main=doc_utf.search('div[@class=part_main]')
      rails_rake_error unless doc_utf.search('div[@class=question unfound_tips]').blank?
      word_sum=part_main.length
      group_pos=doc_utf.search('div[@class=group_pos]').search("p")
      eg=doc_utf.search('div[@class=prons]').search('span[@class=eg]')
      #音频文件
      word_soundmark=eg.search('a')
      return_value=dowload_audio(word_soundmark,word)
      sound_over=return_value[0]
      file_name=return_value[1]
      word_pronounce=eg.search("strong")[1].nil? ? "" : eg.search("strong")[1].inner_html.to_s   #音标
      load_sens=true
      load_sens=false unless word.strip.match(" ").nil? and word.strip.match("-").nil?
      total_words=[]
      unless word_sum==0
        (0..word_sum-1).each do |i|
          name=word
          word_type=group_pos[i].search("strong").blank? ? "" : group_pos[i].search("strong").inner_html.to_s #词性
          ch=group_pos[i].search('span[@class=label_list]').search('label')
          word_ch=ch.blank? ? "" : ch.inner_html.to_s #中文词义
          sin_word=part_main[i].search("div[@class=collins_en_cn]")[0]
          name="#{word}#{i+1}" if part_main.length>1
          types = word_types(word_type)
          word_content=["#{name}","2","#{word_ch}","#{types}","#{word_pronounce.strip}","3"]
          vedio_url=""
          vedio_url="/word_datas/#{Time.now.strftime("%Y%m%d")}/#{word}.#{file_name}" if sound_over
          word_content <<  vedio_url
          if load_sens
            has_sentences=false
            descriptions=[]
            has_index=0
            sin_word.search("li").each do |sententce| #示例例句
              description=sententce.search("p")[0].inner_html.gsub(/<[^{><}]*>/, "").strip.to_s
              cn_des=sententce.search("p")[1].inner_html.gsub(/<[^{><}]*>/, "").strip.to_s
              descriptions << [description, cn_des]
              if description!= nil  and description != "" and  description.split(" ").length>5
                break if has_index >2
                has_sentences=true
                has_index += 1
                word_content << description << cn_des
              end
            end unless sin_word.search("li").blank?
            unless has_sentences
              descriptions[0..2].each do |sentence|
                sentence.collect{|a| word_content << a}
              end
            end
          else
            sentences=sen_detail(word)
            sentences.each do |sent|
              sent.collect{|a| word_content << a}
            end unless sentences.blank?
          end
          total_words << word_content
        end
        puts "--#{word}-- save end"
      else
        word_type=group_pos[0].search("strong").blank? ? "" : group_pos[0].search("strong").inner_html.to_s #词性
        types = word_types(word_type)
        word_ch= group_pos[0].search('span[@class=label_list]').search('label').inner_html.to_s #中文词义
        word_content=["#{word}","2","#{word_ch}","#{types}","#{word_pronounce.strip}","3"]
        vedio_url=""
        vedio_url="/word_datas/#{Time.now.strftime("%Y%m%d")}/#{word}.#{file_name}" if sound_over
        unless load_sens
          sentences=sen_detail(word)
          sentences.each do |sent|
            sent.collect{|a| word_content << a}
          end unless sentences.blank?
        else
          puts "--#{word}-- save end but no sentences"
        end
        total_words << word_content
      end
      sleep 10
      return total_words
    rescue
      puts "--#{word}-- download error"
      begin
        write_error("error_word",word)
      rescue
      end
    end
  end

  #将错误的词或词组写入文件
  def write_error(file_name,word)
    file_path="#{Rails.root}/public/words_data/#{file_name}.txt"
    if File.exists? file_path
      error = File.open( file_path,"a+")
    else
      error= File.new(file_path, "w+")
    end
    error.write "#{word}\r\n"
    error.close
  end

  #下载包含词义的词组
  def phrase_detail(word,meaning,init_word)
    begin
      puts "--begin -- from--  #{word}\n"
      exist = false
      #获取词组意思(如果词组存在)
      url = "http://www.iciba.com/"
      agent = Mechanize.new
      page = agent.get(url + "#{word}")
      source = Hpricot(page.body)
      if source.search('div[@class=unfound_tips]').length==0
        exist = true
        # 下载音频
        audio_uri = source.search('div[@class=dictbar]').search('span[@class=eg]').search('a')
        return_value=dowload_audio(audio_uri,word)
      else
        puts "--#{word}-- download error"
        write_error("error_phrase",word)
      end
      #存取数据库
      word_content=["#{init_word}","2","#{meaning}","","","3"]
      vedio_url=""
      vedio_url="/word_datas/#{Time.now.strftime("%Y%m%d")}/#{word}.#{return_value[1]}" if return_value[0]
      word_content <<  vedio_url
      #获取例句（如果词组存在）
      if exist
        sentences=sen_detail(word)
        sentences.each do |sent|
          sent.collect{|a| word_content << a}
        end unless sentences.blank?
      end unless source.nil?
      sleep 5
      return word_content
    rescue
      puts "--#{word}-- download error"
      begin
        write_error("error_phrase",word)
      rescue
      end
    end
  end


  def word_restore(init_word)
    init=init_word.split("(")
    q_w=init.delete_at(0)
    init.each_with_index do |w,index|
      inits=w.split(" ")
      if w.include? ")"
        init[index]="(#{w}"
      else
        inits[0] = "(#{inits[0]})"
        init[index]=inits.join(" ")
      end
    end
    init.insert(0,q_w)
    init_word=init.join(" ")
    init=init_word.split(")")
    pos=init.length-1
    q_w=init.delete_at(pos)
    init.each_with_index do |w,index|
      inits=w.split(" ")
      if w.include? "("
        init[index]="#{w})"
      else
        inits[inits.length-1] = "(#{inits[inits.length-1]})"
        init[index]=inits.join(" ")
      end
    end
    init.insert(pos,q_w)
    init_word=init.join(" ")
    return init_word
  end

end
