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
    begin
      file = File.open("#{Constant::PAPER_XML_PATH}#{paper.paper_url}")
      @xml=Document.new(file).root
      file.close
    rescue
      flash[:error] = "当前试卷不能正常打开，请检查试卷是否正常。"
      redirect_to request.referer
    end
  end

  #[post][member] 模块表单
  def post_block
    block_xpath , block_name ,block_description , block_time , block_start_time = params["block_xpath"]  , params["block_name"] , params["block_description"] , params["time"] , params["start_time"]
    paper = Paper.find(params[:id].to_i)
    url="#{Constant::PAPER_XML_PATH}#{paper.paper_url}"
    doc = get_doc(url)
    if block_xpath != ""
      block=doc.elements[block_xpath]
      manage_element(block,{"base_info/title"=>block_name,"base_info/description"=>block_description},{"time"=>block_time,"start_time"=>block_start_time})
    else
      block = doc.elements["blocks"].add_element("block")
      manage_element(block,{"base_info/title"=>block_name,"base_info/description"=>block_description,"problems"=>""},{"total_score"=>"0","total_num"=>"0","time"=>block_time,"start_time"=>block_start_time})
    end

    write_xml(doc,url)
    redirect_to request.referer
  end


  #[post][member] 新建表单
  def create_problem
    @post = params[:create_problem]
    #    puts "category_id = "+@post[:category]
    #    puts "problems_xpath = "+@post[:problems_xpath]
    #    puts "problem_description = "+@post[:problem_description]
    #    puts "problem_title = "+@post[:problem_title]
    #    puts "question_type = "+@post[:question_type]
    #    puts "correct_type = "+@post[:correct_type]
    #    puts "question_answer = " +@post[:question_answer]
    #    puts "question_attrs = "+@post[:question_attrs]
    #    puts "question_description = " +@post[:question_description]
    #    puts "question_analysis = " +@post[:question_analysis]
    #    puts "question_score = " +@post[:question_score]
    #    puts "init_block = " +@post[:init_block]
    #    puts "init_problem = " +@post[:init_problem]
    #存储数据库
    @problem = Problem.create(:category_id=>@post[:category],:description=>@post[:problem_description],:title=>@post[:problem_title],:question_type=>@post[:question_type])
    @question =Question.create(:problem_id=>@problem.id,:description=>@post[:question_description],:answer=>@post[:question_answer],:question_attrs=>@post[:question_attrs],:correct_type=>@post[:correct_type],:analysis=>@post[:question_analysis])

    #存储xml文件
    paper = Paper.find(params[:id].to_i)
    url="#{Constant::PAPER_XML_PATH}#{paper.paper_url}"
    doc = get_doc(url)
    problem_element = doc.elements[@post[:problems_xpath]].add_element("problem")
    manage_element(problem_element,{:description=>@post[:problem_description],:title=>@post[:problem_title],:category=>@post[:category],:questions=>""},{:id=>@problem.id,:question_type=>@post[:question_type]})
    question_element = problem_element.elements["questions"].add_element("question")
    manage_element(question_element,{:description=>@post[:question_description],:answer=>@post[:question_answer],:questionattrs=>@post[:question_attrs],:tags=>"",:analysis=>@post[:question_analysis]},{:id=>@question.id,:score=>@post[:question_score],:correct_type=>@post[:correct_type]})
    write_xml(doc,url)
    redirect_to "/papers/#{params[:id]}/edit?category=#{@post[:category]}"
  end

  # ajax 选择题目类型，载入 _create_problem_attrs_module 部分  备注：此方法在新建题目create_problem时用，追加、编辑小题post_question时用的select_correct_type
  def select_question_type
    question_type ,block_index =params["question_type"].to_i , params["block_index"].to_i
    @object={:question_type=>question_type,:block_index=>block_index}
    render :partial=>"create_problem_attrs_module",:object=>@object
  end

  # [post][member][ajax] 编辑题目说明
  def ajax_edit_problem_description
    paper = Paper.find(params[:id].to_i)
    url="#{Constant::PAPER_XML_PATH}#{paper.paper_url}"
    doc = get_doc(url)
    problem_element = doc.elements["/paper/blocks/block[#{params[:block_index]}]/problems/problem[#{params[:problem_index]}]"]
    Problem.find(problem_element.attributes["id"]).update_attribute("description",params[:description])
    manage_element(problem_element,{:description=>params[:description]},{})
    write_xml(doc,url)
    respond_to do |format|
      format.json {
        data={:description=>params[:description]}
        render:json=>data
      }
    end

  end
  # [post][member][ajax] 编辑题目标题
  def ajax_edit_problem_title
    paper = Paper.find(params[:id].to_i)
    url="#{Constant::PAPER_XML_PATH}#{paper.paper_url}"
    doc = get_doc(url)
    problem_element = doc.elements["/paper/blocks/block[#{params[:block_index]}]/problems/problem[#{params[:problem_index]}]"]
    Problem.find(problem_element.attributes["id"]).update_attribute("title",params[:title])
    manage_element(problem_element,{:title=>params[:title]},{})
    write_xml(doc,url)
    respond_to do |format|
      format.json {
        data={:title=>params[:title]}
        render:json=>data
      }
    end
  end

  def post_question
    @post = params[:post_question]
    puts "-------------------------------------------------------"
    puts "questions_xpath = " + @post[:questions_xpath]
    puts "question_index = " + @post[:question_index]
    puts "question_attrs = " + @post[:question_attrs]
    puts "question_answer = " + @post[:question_answer]
    puts "correct_type = "+@post[:correct_type]
    puts "question_description = " + @post[:question_description]
    puts "question_analysis = " + @post[:question_analysis]
    puts "question_score = " + @post[:question_score]
    paper = Paper.find(params[:id].to_i)
    url="#{Constant::PAPER_XML_PATH}#{paper.paper_url}"
    doc = get_doc(url)
    if @post[:question_index]==""   # 当 question_index 为空，就是新建小题，不为空，就是编辑小题
      problem_id = doc.elements[@post[:questions_xpath]].parent.attributes["id"].to_i
      @question = Question.create(:problem_id=>problem_id,:description=>@post[:question_description],:answer=>@post[:question_answer],:correct_type=>@post[:correct_type],:analysis=>@post[:question_analysis],:question_attrs=>@post[:question_attrs])
      question_element = doc.elements[@post[:questions_xpath]].add_element("question")
      manage_element(question_element,{:description=>@post[:question_description],:answer=>@post[:question_answer],:questionattrs=>@post[:question_attrs],:tags=>"",:analysis=>@post[:question_analysis]},{:correct_type=>@post[:correct_type],:id=>@question.id,:score=>@post[:question_score]})
      write_xml(doc,url)
    else
      question_xpath = @post[:questions_xpath]+"/question[#{@post[:question_index]}]"
      @question=Question.find(doc.elements[question_xpath].attributes["id"])
      @question.update_attributes(:description=>@post[:question_description],:answer=>@post[:question_answer],:question_attrs=>@post[:question_attrs],:analysis=>@post[:question_analysis])
      question_element = doc.elements[question_xpath]
      manage_element(question_element,{:description=>@post[:question_description],:answer=>@post[:question_answer],:questionattrs=>@post[:question_attrs],:tags=>"",:analysis=>@post[:question_analysis]},{:score=>@post[:question_score]})
      write_xml(doc,url)
    end
    redirect_to request.referer
  end

  #ajax 选择题目类型，载入 _post_question_attrs_module 部分
  def select_correct_type
    correct_type , question_answer , question_attrs=params["correct_type"].to_i , params["question_answer"] , params["question_attrs"]
    @object={:correct_type=>correct_type,:answer=>question_answer,:question_attrs=>question_attrs}
    render :partial=>"post_question_attrs_module",:object=>@object
  end

  
  # --------- START -------XML文件操作--------require 'rexml/document'----------include REXML----------

  #将XML文件生成document对象
  def get_doc(url)
    file = File.open(url)
    doc = Document.new(file).root
    return doc
  end
  
  #处理XML节点
  #参数解释： element为doc.elements[xpath]产生的对象，content为子内容，attributes为属性
  def manage_element(element,content={},attributes={})
    content.each do |key,value|
      arr , ele = "#{key}".split("/") , element
      arr.each do |a|
        ele = ele.elements[a].nil? ? ele.add_element(a) : ele.elements[a]
      end
      ele.text.nil? ? ele.add_text("#{value}") : ele.text="#{value}"
    end
    attributes.each do |key,value|
      element.attributes["#{key}"].nil? ? element.add_attribute("#{key}","#{value}") :  element.attributes["#{key}"] = "#{value}"
    end
    return element
  end

  #将document对象生成xml文件
  def write_xml(doc,url)
    file = File.new(url, File::CREAT|File::TRUNC|File::RDWR, 0644)
    file.write(doc)
    file.close
  end

  # --------- END ------XML文件操作--------require 'rexml/document'----------include REXML----------
  
end
