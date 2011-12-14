#encoding: utf-8
class ReportErrorsController < ApplicationController
  respond_to :html, :xml, :json
  require 'rexml/document'
  include REXML

  def index
    error_sql="select id,question_id from report_errors where status=0"
    unless params["error_type"].nil?|| params["error_type"]==""
      session[:error_type]=params["error_type"]
    else
      session[:error_type]=nil
    end
    num_sql="status=0"
    unless session[:error_type].nil?
      error_sql += " and error_type=#{session[:error_type].to_i}"
      num_sql += " and error_type=#{session[:error_type].to_i}"
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
    error=@errors[1]
    @next=params[:page].to_i==@num-1 ? @num-1:params[:page].to_i+1
    if @errors.size==1
      error= @errors[0]
    end
    if @num==1
      @last=0
      @next=0
    end
    if @last.to_i<0
      @last=0
    end
    begin
      @others=ReportError.count(:id,:conditions=>"question_id=#{error.question_id}")
      sql="select re.id error_id,re.question_id,re.description r_desc,p.id p_id,q.*,pe.paper_url,u.name u_name,p.title p_title,pe.title pe_title,pe.id pe_id,pe.total_question_num num from report_errors re inner join users u on u.id=re.user_id inner join
         questions q on q.id=re.question_id inner join problems p on p.id=q.problem_id inner join papers pe on pe.id=re.paper_id  where re.id=#{error.id}"     
      @single_error=ReportError.find_by_sql(sql)
      url=Constant::PAPER_XML_PATH+@single_error[0].paper_url
      doc= open_file(url)
      problem=doc.elements["/paper/blocks//problems/problem[@id='#{@single_error[0].p_id}']"]
      blocks=doc.get_elements("/paper/blocks//block")
      @block_postion=blocks.index(problem.parent.parent)+1
      problems=doc.get_elements("/paper/blocks//problems//problem")
      @problem_postion=problems.index(problem)+1
      @question=Question.find(error.question_id)
    rescue
      @errors=[]
    end
  end


  def modify_status
    error_report=ReportError.find(params[:id].to_i)
    error_report.update_attributes(:status=>params[:status].to_i)
    Order.create(:user_id=>error_report.user_id,:status=>Order::TYPES[:OTHER],:pay_type=>Order::STATUS[:NOMAL]) if Order.find_by_user_id(error_report.user_id).nil? if params[:status].to_i==1
    page=params[:page]
    my_params = Hash.new
    request.parameters.each {|key,value|my_params[key.to_s]=value}
    my_params.delete("action")
    my_params.delete("controller")
    my_params.delete("id")
    my_params.delete("status")
    my_params.delete("authenticity_token")
    my_params.delete("utf8")
    unless page.nil? || page=="" ||page.to_i<1
      url=my_params.sort.map{|k,v|"#{k}=#{v}"}.join("&")
    else
      my_params.delete("page")
      url=my_params.sort.map{|k,v|"#{k}=#{v}"}.join("&")
    end
    redirect_to "/report_errors?#{url}"
  end

  def other_users
    session[:question_id]=params[:question_id].to_i
    other_sql="select u.email,re.error_type,re.description from report_errors re inner join users u on u.id=re.user_id where re.question_id=#{session[:question_id]}"
    @others=ReportError.paginate_by_sql(other_sql,:per_page =>2, :page => params[:page])
    respond_with (@others) do |format|
      format.js
    end
  end
end
