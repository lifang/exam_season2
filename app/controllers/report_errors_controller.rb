#encoding: utf-8
class ReportErrorsController < ApplicationController
  before_filter :access?
  before_filter :is_category_in?
  respond_to :html, :xml, :json
  require 'rexml/document'
  include REXML

  def index
    category_id = params[:category].nil? ? 2 : params[:category]
    error_sql = "select id,question_id from report_errors where status = #{ReportError::STATUS[:UNSOVLED]}
      and category_id = #{category_id}"
    unless params["error_type"].nil?|| params["error_type"] == ""
      session[:error_type] = params["error_type"]
    else
      session[:error_type] = nil
    end
    num_sql="status = #{ReportError::STATUS[:UNSOVLED]} and category_id = #{category_id}"
    unless session[:error_type].nil?
      error_sql += " and error_type = #{session[:error_type].to_i}"
      num_sql += " and error_type = #{session[:error_type].to_i}"
    end
    unless params[:page].nil?||params[:page]==""||params[:page].to_i<0
      @last=params[:page].to_i-1
      error_sql +=" order by created_at desc  limit #{params[:page].to_i},3"
    else
      @last=0
      error_sql +=" order by created_at desc  limit 0,3"
    end
    @num=ReportError.count(:id,:conditions=>num_sql)
    @errors=ReportError.find_by_sql(error_sql)
    error=@errors[0]
    @next = params[:page].to_i == @num-1 ? @num-1:params[:page].to_i+1
    if @num==1
      @last=0
      @next=0
    end
    if @last.to_i<0
      @last=0
    end
    begin
      others=ReportError.count(:id,:conditions=>"question_id=#{error.question_id} and category_id=#{category_id}")
      sql="select re.id,re.question_id,re.description r_desc,pe.id paper_id,pe.paper_url,u.name from
       report_errors re inner join users u on u.id=re.user_id  inner join papers pe on pe.id=re.paper_id  where re.id=#{error.id} and re.category_id=#{category_id}"
      single_error=ReportError.find_by_sql(sql)
      url=Constant::PUBLIC_PATH+single_error[0].paper_url
      doc= open_file(url)
      question=doc.elements["/paper/blocks//problems//questions/question[@id='#{single_error[0].question_id}']"]
      problem=question.parent.parent
      title=doc.elements["/paper/base_info/title"]
      blocks=doc.get_elements("/paper/blocks//block")
      block_postion=blocks.index(problem.parent.parent)+1
      problems=doc.get_elements("/paper/blocks//problems//problem")
      problem_postion=problems.index(problem)+1
      block_problem=problem.parent.parent.get_elements("problems//problem")
      init_problem=block_problem.index(problem)+1
      @info=[single_error[0],question,title,problem,block_postion,problem_postion,problems.size,others,init_problem]
      @word=Word.find_by_sql("select * from words w inner join word_question_relations wq on w.id=wq.word_id where wq.question_id=#{error.question_id}")
    rescue
      @errors=[]
    end
  end


  def modify_status
    
    begin
      errors=ReportError.find_by_sql("select * from report_errors where question_id=#{params[:id].to_i}
        and status=#{ReportError::STATUS[:UNSOVLED]} order by created_at asc")
      errors.each_with_index  do |error,index|
        if params[:status].to_i== ReportError::STATUS[:OVER]
          message="亲，你报告的试卷#{params[:title]}第#{params[:question_index]}题的错误已经修改完成，欢迎你监督检查。"
          category_id=error.category_id.nil? ? 2 : error.category_id
          if index==0 and Order.first(:conditions=>"user_id=#{error.user_id} and status=#{Order::STATUS[:NOMAL]} and category_id=#{category_id}
              and types in (#{Order::TYPES[:CHARGE]},#{Order::TYPES[:OTHER]},#{Order::TYPES[:ACCREDIT]},#{Order::TYPES[:RENREN]},#{Order::TYPES[:SINA]})").nil?
            category_name = Category.find(category_id).name
            message += "为了表示谢意，我们将您升级网站#{category_name}的正式用户，您将免费使用我们网站#{category_name}的功能。"
            Order.create(:user_id=>error.user_id,:types=>Order::TYPES[:OTHER],
              :status=>Order::STATUS[:NOMAL],:category_id=>error.category_id)
          end
        else
          message="亲，你报告的试卷#{params[:title]}第#{params[:question_index]}题的错误我们反复研究，仔细查看，觉得好像没什么不对,
                      请核对问题，欢迎继续提交。当然，如果可以说明具体原因，那就更完美了。感谢你的支持。"
        end
        error.update_attributes(:status=>params[:status].to_i)
        Notice.create(:send_types => Notice::SEND_TYPE[:SINGLE], :send_id => cookies[:user_id].to_i,
          :target_id => error.user_id, :description =>message)
      end
      page=params[:page]
      my_params = Hash.new
      request.parameters.each {|key,value|my_params[key.to_s]=value}
      my_params.delete("action")
      my_params.delete("controller")
      my_params.delete("id")
      my_params.delete("status")
      my_params.delete("authenticity_token")
      my_params.delete("utf8")
      my_params.delete("title")
      my_params.delete("question_index")
      unless page.nil? || page=="" ||page.to_i<1
        url=my_params.sort.map{|k,v|"#{k}=#{v}" unless (v.nil? or v.empty?)}.join("&")
      else
        my_params.delete("page")
        url=my_params.sort.map{|k,v|"#{k}=#{v}" unless (v.nil? or v.empty?)}.join("&")
      end
      redirect_to "/report_errors?#{url}"
    rescue
      render :text=>"系统繁忙，请您稍后再试"
    end
  end

  def other_users
    session[:question_id]=params[:question_id].to_i
    other_sql="select u.name,re.error_type,re.description from report_errors re
      inner join users u on u.id=re.user_id where re.question_id=#{session[:question_id]} and re.status!=#{ReportError::STATUS[:IGNORE]}"
    @others=ReportError.paginate_by_sql(other_sql,:per_page =>2, :page => params[:page])
    respond_with (@others) do |format|
      format.js
    end
  end
end
