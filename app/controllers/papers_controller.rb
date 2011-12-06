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

  #[post][member] 编辑、新建模块基本信息，修改名称
  def form_block_baseinfo
    puts "--------------------------------------------------------"
    puts params["begin_time"]
    puts params["time_length"]
    block_xpath = params["block_xpath"]
    block_name = params["block_name"]
    paper = Paper.find(params[:id].to_i)
    url="#{Constant::PAPER_XML_PATH}#{paper.paper_url}"
    file = File.open(url)
    doc = Document.new(file).root
    if block_xpath != ""
      edit_element(doc,url,block_xpath,block_name)
      doc_write_file(doc,url)
    else
      create_block(doc,url,block_name)
    end
    redirect_to request.referer
  end


  # 编辑XML节点 （用处：form_block_baseinfo ）
  def edit_element(doc,url,xpath,text)
    doc.elements[xpath].text = text
  end


  # 新建XML节点 （用处：form_block_baseinfo ）
  def create_block(doc,url,block_name)
    blocks = doc.root.elements["blocks"]
    block = blocks.add_element("block")
    block.add_attribute("total_score","0")
    block.add_attribute("total_num","0")
    #      block.add_attribute("time", "#{self.time}")
    #      block.add_attribute("start_time", "#{self.start_time}")
    base_info=block.add_element("base_info")
    title = base_info.add_element("title")
    title.add_text(block_name)
    #      description = base_info.add_element("description")
    #      description.add_text("#{self.description}")
    problems = block.add_element("problems")
    doc_write_file(doc,url)
  end

  #将document对象生成xml文件 （用处：create_element ，edit_element ）
  def doc_write_file(doc,url)
    file = File.new(url, File::CREAT|File::TRUNC|File::RDWR, 0644)
    file.write(doc)
    file.close
  end
end
