#encoding: utf-8
class WordsController < ApplicationController
  before_filter :access?
  before_filter :is_category_in?
  
  def index
    @words = Word.get_words(params[:category].to_i, nil, params[:page])
  end

  def search
    session[:word_text] = nil
    session[:word_text] = params[:word_text]
    redirect_to "/words/search_list?category=#{params[:category]}"
  end

  def search_list
    @words = Word.get_words(params[:category].to_i, session[:word_text], params[:page])
    render "index"
  end

  def create
    Word.transaction do
      filename = Word.upload_enunciate("/word_datas/#{Time.now.strftime("%Y%m%d")}/", params[:enunciate_url])
      word = Word.create(:category_id => params[:category_id].to_i, :name => params[:name], :types => params[:types].to_i,
        :phonetic => params[:phonetic].strip, :enunciate_url => filename, :en_mean => params[:en_mean],
        :ch_mean => params[:ch_mean])
       
      sens = params[:sentence].gsub("；", ";").split(";")
      sens.each do |sen|
        WordSentence.create(:word_id => word.id, :description => sen.strip) unless sen.nil? or sen.strip.empty?
      end unless sens.blank?
      unless params[:description].nil? or params[:description].strip.empty?
        dis = Discriminate.create(:description => params[:description].strip)
        WordDiscriminateRelation.create(:word_id => word.id, :discriminate_id => dis.id)
        unless params[:re_word].nil? or params[:re_word].strip.empty?
          re_w_id = params[:re_word].strip.strip.split(",")
          re_w_id.each do |w|
            WordDiscriminateRelation.create(:word_id => w, :discriminate_id => dis.id)
          end unless re_w_id.blank?
        end
      end
    end
    flash[:notice] = "添加成功"
    redirect_to "/words?category=#{params[:category_id]}"
  end

  def list_similar
    if params[:word_id].nil? or params[:word_id].empty?
      @words = Word.find(:all, :conditions => ["name like ?", "%#{params[:search_text].strip}%"], :limit => 10)
    else
      @words = Word.find(:all,
        :conditions => ["name like ? and id != ?", "%#{params[:search_text].strip}%", params[:word_id].to_i], :limit => 10)
    end
    render :partial => "/words/similar_list"
  end

  def show
    @word = Word.find(params[:id].to_i)
  end

  def edit
    @word = Word.find(params[:id].to_i)
  end

  def update
    Word.transaction do
      word = Word.find(params[:id].to_i)
      filename = word.enunciate_url
      unless params[:enunciate_url].nil? or params[:enunciate_url] == ""
        filename = Word.upload_enunciate("/word_datas/#{word.enunciate_url.split("/")[2]}/", params[:enunciate_url])
      end
      word.update_attributes(:name => params[:name], :types => params[:types].to_i, :enunciate_url => filename,
        :phonetic => params[:phonetic].strip, :en_mean => params[:en_mean], :ch_mean => params[:ch_mean])

      word.word_sentences.delete_all
      sens = params[:sentence].gsub("；", ";").split(";")
      sens.each do |sen|
        WordSentence.create(:word_id => word.id, :description => sen.strip) unless sen.nil? or sen.strip.empty?
      end unless sens.blank?

      unless params[:description].nil? or params[:description].strip.empty?
        word.word_discriminate_relations.delete_all
        if word.discriminates.blank?
          dis = Discriminate.create(:description => params[:description].strip)
          WordDiscriminateRelation.create(:word_id => word.id, :discriminate_id => dis.id)
        else
          dis = word.discriminates[0].update_attributes(:description => params[:description].strip)
        end
        
        unless params[:re_word].nil? or params[:re_word].strip.empty?
          re_w_id = params[:re_word].strip.strip.split(",")
          re_w_id.each do |w|
            WordDiscriminateRelation.create(:word_id => w, :discriminate_id => dis.id)
          end unless re_w_id.blank?
        end
      end
    end
    flash[:notice] = "编辑成功"
    redirect_to "/words?category=#{params[:category_id]}"
  end
  
end
