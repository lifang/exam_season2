#encoding: utf-8
class ReportErrorsController < ApplicationController
  require 'rexml/document'
  include REXML

  def index
    error_sql="select id,question_id from report_errors where status=0"
    unless params[:error_type].nil?|| params[:error_type]=""
      error_sql += " and error_type=#{params[:error_type].to_i}"
    end
    unless params[:offset].nil?
      error_sql +=" order by created_at desc  limit #{params[:offset].to_i},1"
    else
      error_sql +=" order by created_at desc  limit 0,1"
    end
    @errors=ReportError.find_by_sql(error_sql)
    other_sql="select u.email,re.error_type,re.description from report_errors re inner join users u on u.id=re.user_id where re.question_id=#{@errors[0].question_id}"
    @others=ReportError.paginate_by_sql(other_sql,:per_page =>1, :page => params[:page])
    sql="select re.id error_id,re.description r_desc,q.*,u.name u_name,p.title p_title,pe.title pe_title,pe.total_question_num num,w.*,ws.description ws_des from report_errors re inner join users u on u.id=re.user_id inner join
         questions q on q.id=re.question_id inner join problems p on p.id=q.problem_id inner join papers pe on pe.id=re.paper_id left join word_question_relations wq on wq.question_id=q.id
         left join words w on w.id=wq.word_id left join word_sentences ws on ws.word_id=w.id where re.id=#{@errors[0].id}"
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
  end
end
