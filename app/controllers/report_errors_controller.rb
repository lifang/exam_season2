#encoding: utf-8
class ReportErrorsController < ApplicationController
  require 'rexml/document'
  include REXML

  def index
    error_sql="select id from report_errors where status=0"
    unless params[:error_type].nil?|| params[:error_type]=""
      error_sql += " and error_type=#{params[:error_type].to_i}"
    end
    unless params[:page].nil?
      error_sql +=" order by created_at desc  limit #{params[:page].to_i},1"
    else
      error_sql +=" order by created_at desc  limit 0,1"
    end
    @errors=ReportError.find_by_sql(error_sql)
    sql="select re.id error_id,re.description r_desc,q.*,u.name,p.title p_title,pe.title pe_title,pe.total_question_num num from report_errors re inner join users u on u.id=re.user_id inner join
         questions q on q.id=re.question_id inner join problems p on p.id=q.problem_id inner join papers pe on  pe.id=re.paper_id where re.id=#{@errors[0].id}"
    @num=ReportError.count(:id,:conditions=>"status=0")
    @single_error=ReportError.find_by_sql(sql)
  end


  def modify_status
    ReportError.find(params[:id].to_i).update_attributes(:status=>params[:status].to_i)
    if params[:error_type].nil? || params[:error_type]==""
      redirect_to "/report_errors?category=#{params[:category]}"
    else
      redirect_to "/report_errors?category=#{params[:category]}&error_type=#{params[:error_type]}"
    end
    Array.inject
  end
end
