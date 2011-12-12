#encoding: utf-8
class WordsController < ApplicationController

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
    @words = Word.find(:all, :conditions => ["name like ?", "%#{params[:search_text].strip}%"], :limit => 10)
    render :partial => "/words/similar_list"
  end

  def show
    @word = Word.find(params[:id].to_i)
  end
  
end
