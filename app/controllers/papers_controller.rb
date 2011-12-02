class PapersController < ApplicationController

  require 'rexml/document'
  include REXML

  before_filter :access?
  
  #[get][collection] 试卷列表
  def index
    category=params["category"]
    checked=params["checked"].to_i unless params["checked"].nil?
    @papers=Paper.search_mothod(category,checked,5, params[:page])
  end

  #[get][collection] 新建试卷页面
  def new
    
  end

  #[post][collection] 新建试卷
  def create
    @paper=Paper.create(:creater_id=>cookies[:user_id],
      :title=>params[:title].strip,
      :category_id => params[:category])
    category = Category.find(params[:category])
    @paper.create_paper_url(@paper.xml_content({"category_name" => category.name}), "#{Time.now.strftime("%Y%m%d")}", "xml") unless category.nil?
    redirect_to "/papers/#{@paper.id}/edit?category=#{params[:category]}"
  end

  #[get][member] 编辑试卷具体内容（新建试卷第二步）
  def edit
    paper = Paper.find(params[:id].to_i)
#    begin
      file = File.open("#{Constant::PAPER_XML_PATH}#{paper.paper_url}")
      @xml=Document.new(file).root
      file.close
#    rescue
#      flash[:error] = "当前试卷不能正常打开，请检查试卷是否正常。"
#      redirect_to request.referer
#    end
  end

  
end
