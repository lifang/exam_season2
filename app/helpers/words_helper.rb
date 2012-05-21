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
      puts '--BEGIN DOWLOAD SOUND --'
      time=Time.now
      open(sound_uri) do |fin|
        file_name = sound_uri.split('.').reverse[0]
        all_dir = "#{Rails.root}/public/word_datas/#{Time.now.strftime("%Y%m%d")}/"
        FileUtils.makedirs all_dir    #建目录
        unless File.exist?("#{all_dir}#{word}.#{file_name}")
          File.open("#{all_dir}#{word}.#{file_name}", "wb+") do |fout|
            while buf = fin.read(1024) do
              fout.write buf
              STDOUT.flush
            end
          end
          puts "take time #{Time.now-time} s"
        end
      end
      sound_over=true
    end
    return [sound_over,file_name]
  end


  #获取例句
  def dict_words(word,sens)
    model_url ="http://dict.youdao.com/search?q=lj:"
    model_agent = Mechanize.new
    word=word.gsub("one's","").gsub("…"," ").gsub("sb's","").split(" ").join("+")
    model_page = model_agent.get(model_url + "#{word}")
    model_doc= Hpricot(model_page.body)
    results_content=model_doc.search('div[@class=results-content]')
    if results_content.search('div[@class=error-wrapper]').blank?
      sentences=model_doc.search('div[@class=trans-container  tab-content]').search('ul[@class=ol]').search('li')
      sens=get_limit(sentences,sens)
    end
    puts "#{sens.length} sentences save end --success"
    return sens
  end

  #截取不大于三条例句
  def get_limit(sentences,sens)
    has_sentences=false
    descriptions=[]
    has_index=0
    sentences.each do |sententce| #示例例句
      all_content=sententce.search('p')
      description=all_content[0].inner_html.gsub(/<[^{><}]*>/, "").strip.to_s
      cn_des =all_content[1].inner_html.gsub(/<[^{><}]*>/, "").gsub("  "," ").strip
      descriptions << [description, cn_des]
      if description!= nil  and description != "" and  description.split(" ").length>5 and description.split(" ").length<25
        break if has_index >2
        has_sentences=true
        has_index += 1
        sens << description<<cn_des
      end
    end unless sentences.blank?
    unless has_sentences
      descriptions[0..2].each do |sentence|
        sens << sentence[0] << sentence[1]
      end
    end
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
      puts "--#{word} START --"
      part_main=doc_utf.search('div[@class=part_main]')
      rails_rake_error unless doc_utf.search('div[@class=question unfound_tips]').blank?
      word_sum=part_main.length
      group_pos=doc_utf.search('div[@class=group_pos]').search("p")
      eg=doc_utf.search('div[@class=prons]').search('span[@class=eg]')
      return_value=dowload_audio(eg.search('a'),word)   #下载音频文件
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
          collins_en_cn=part_main[i].search("div[@class=collins_en_cn]")
          sin_word=collins_en_cn[0].search("div[@class=en_tip]").blank? ? collins_en_cn[0] : collins_en_cn[1]
          name="#{word}#{i+1}" if part_main.length>1
          types = word_types(word_type)
          word_content=["#{name}","2","#{word_ch}","#{types}","#{word_pronounce.strip}","3"]
          vedio_url=""
          vedio_url="/word_datas/#{Time.now.strftime("%Y%m%d")}/#{word}.#{file_name}" if sound_over
          word_content <<  vedio_url
          if load_sens
            word_content=get_limit(sin_word.search("li"),word_content)
          else
            word_content=dict_words(word,word_content)
          end
          total_words << word_content
        end
        puts "--#{word} SAVE END --"
      else
        word_type=group_pos[0].search("strong").blank? ? "" : group_pos[0].search("strong").inner_html.to_s #词性
        types = word_types(word_type)
        word_ch= group_pos[0].search('span[@class=label_list]').search('label').inner_html.to_s #中文词义
        word_content=["#{word}","2","#{word_ch}","#{types}","#{word_pronounce.strip}","3"]
        vedio_url=""
        vedio_url="/word_datas/#{Time.now.strftime("%Y%m%d")}/#{word}.#{file_name}" if sound_over
        word_content <<  vedio_url
        unless load_sens
          word_content=dict_words(word,word_content)
          puts "--#{word} SAVE END BUT NO SENTENCES --"
        end
        total_words << word_content
      end
      sleep 5
      return total_words
    rescue
      puts "--#{word}-- DOWNLOAD ERROR"
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
    error.write "\r\n#{word}"
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
        word_content=dict_words(word,word_content)
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
