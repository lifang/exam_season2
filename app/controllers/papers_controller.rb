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
  def edit_block_baseinfo
    block_xpath = params["block_xpath"]
    block_name = params["block_name"]
    paper = Paper.find(params[:id].to_i)
    url="#{Constant::PAPER_XML_PATH}#{paper.paper_url}"
    file = File.open(url)
    doc = Document.new(file).root
    if block_xpath != ""
      edit_element(doc,block_xpath,{"base_info/title"=>block_name},{"time"=>params["time"],"start_time"=>params["start_time"]})
    else
      create_block(doc,url,block_name,params["start_time"],params["time"])
    end
    doc_write_file(doc,url)
    redirect_to request.referer
  end


  # 编辑XML节点 （用处：form_block_baseinfo ）
  def edit_element(doc,xpath,texts={},attributes={})
    element = doc.elements[xpath]
    texts.each do |key,value|
      element.elements["#{key}"].text = value unless element.elements["#{key}"].nil?
    end
    attributes.each do |key,value|
      if element.attributes[key].nil?
        element.add_attribute(key,value)
      else
        element.attributes[key] = value
      end
    end
  end


  # 新建XML节点 （用处：form_block_baseinfo ）
  def create_block(doc,url,block_name,start_time,time)
    blocks = doc.root.elements["blocks"]
    block = blocks.add_element("block")
    block.add_attribute("total_score","0")
    block.add_attribute("total_num","0")
    block.add_attribute("time", "#{time}")
    block.add_attribute("start_time", "#{start_time}")
    base_info=block.add_element("base_info")
    title = base_info.add_element("title")
    title.add_text(block_name)
    problems = block.add_element("problems")
  end

  
  #将document对象生成xml文件 （用处：create_element ，edit_element ）
  def doc_write_file(doc,url)
    file = File.new(url, File::CREAT|File::TRUNC|File::RDWR, 0644)
    file.write(doc)
    file.close
  end

  
  #[post][member] 添加题目
  def create_problem
    puts "------------------------------------------------------"
    puts params[:create_problem][:block_index]
    @problem = Problem.create(params[:problem])
    

    redirect_to request.referer
  end

  
end
