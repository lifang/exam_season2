#encoding: utf-8
class ReportErrorsController < ApplicationController
  require 'rexml/document'
  include REXML
  def index
    sql="select re.id,re.question_id,u.name,p.title,q.problem_id,p.paper_url,re.paper_id,q.correct_type from report_errors re inner join users u on u.id=re.user_id inner join
         questions q on q.id=re.question_id inner join papers p on p.id=re.paper_id where re.status =0"
    unless params[:error_type].nil?
      sql += " and error_type=#{params[:error_type].to_i}"
    end
    sql += " order by re.created_at desc"
    @errors=ReportError.find_by_sql(sql)
    @info={}
    @errors.each do |error|
      url=Constant::PAPER_XML_PATH+"#{error.paper_url}"
      doc=open_file(url)
      problems=doc.get_elements("/paper/blocks//problems/problem")
      problem=doc.elements["/paper/blocks//problem[@id=#{error.problem_id}]"]
      index=problems.index(problem)+1
      @info[error.id]=[index,problems.size,error.title,problem]
    end
  end

  def modify_status
    ReportError.find(params[:id].to_i).update_attributes(:status=>params[:status].to_i)
    my_params = Hash.new
    request.parameters.each {|key,value|my_params[key.to_s]=value}
    my_params.delete("action")
    my_params.delete("controller")
    my_params.delete("id")
    my_params.delete("status")
    paras=my_params.sort.map{|k,v|"#{k}=#{v}"}.join("&")
    puts  paras
  end
end
