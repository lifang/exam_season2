# encoding: utf-8
class SimulationsController < ApplicationController
  respond_to :html, :xml, :json
  require 'spreadsheet'
  #模考列表
  
  def index
    category_id = params[:category].to_i
    sql = "select e.id, e.title, e.is_free,e.price,e.start_at_time,e.start_end_time from examinations e
        where e.category_id = #{category_id} and e.types = #{Examination::TYPES[:SIMULATION]}"
    if !params[:category_type].nil? and params[:category_type] == Examination::IS_FREE[:NO].to_s
      sql += " and e.is_free = #{Examination::IS_FREE[:NO]} and e.price is null"
    elsif !params[:category_type].nil? and params[:category_type] == Examination::IS_FREE[:YES].to_s
      sql += " and (e.is_free = #{Examination::IS_FREE[:YES]} or e.is_free is null) and e.price is null"
    elsif !params[:category_type].nil? and params[:category_type] =="2"
      sql += " and price>0 and e.is_free = #{Examination::IS_FREE[:NO]}"
    end
    @simulations = Examination.paginate_by_sql(sql,
      :per_page => 5, :page => params[:page])
    @exam_papers = {}
    examination_ids = []
    @simulations.collect { |s|  examination_ids << s.id }
    papers = Paper.find_by_sql(["select epr.examination_id, p.title p_title from examination_paper_relations epr
        left join papers p on epr.paper_id = p.id where epr.examination_id in (?)", examination_ids])
    exam_raters = ExamRater.find_by_sql(["select er.examination_id, er.email from exam_raters er
       where er.examination_id in (?)", examination_ids])
    @exam_raters={}
    exam_raters.collect { |exam_rater| 
      if @exam_raters[exam_rater.examination_id].nil?
        @exam_raters[exam_rater.examination_id]=[exam_rater.email]
      else
        @exam_raters[exam_rater.examination_id]<<exam_rater.email
      end
    }
    papers.each do |paper|
      if @exam_papers[paper.examination_id].nil?
        @exam_papers[paper.examination_id] = [paper.p_title]
      else
        @exam_papers[paper.examination_id] << paper.p_title
      end
    end unless papers.blank?
    puts @exam_papers
  end



  def add_rater
    @examination=params[:examination_id]
    if ExamRater.where("email='#{params[:email]}' and examination_id=#{@examination}").blank?
      exam_rater=ExamRater.create(:email=>params[:email],:examination_id=>@examination,:author_code => proof_code(6))
      UserMailer.rater_affirm(exam_rater,Examination.find(@examination)).deliver
    end
    @exam_rater=ExamRater.find_by_sql("select er.examination_id, er.email from exam_raters er where er.examination_id = #{@examination}")
    @exam_rater << @examination
    respond_with (@exam_rater) do |format|
      format.js
    end
  end

  def delete_rater
    @examination=params[:examination_id]
    ExamRater.where("email='#{params[:email]}' and examination_id=#{@examination}")[0].delete
    @exam_rater=ExamRater.find_by_sql("select er.examination_id, er.email from exam_raters er where er.examination_id = #{@examination}")
    @exam_rater << @examination
    respond_with (@exam_rater) do |format|
      format.js
    end
  end

  def create
    unless params[:title].empty? or params[:paper_id].empty?
      papers = Paper.find(params[:paper_id].split(","))
      options={
        :title => params[:title].strip, :creater_id => cookies[:user_id].to_i,
        :is_published => true, :category_id => params[:category_id],
        :types => Examination::TYPES[:SIMULATION],:start_end_time=>params[:end_date],
        :start_at_time=>params[:from_date]
      }
      if params[:fee].to_i==Examination::IS_FREE[:YES]
        is_free=Examination::IS_FREE[:YES]
      else
        is_free=Examination::IS_FREE[:NO]
        options.merge!(:price=>params[:total_price].to_i) if params[:fee].to_i==2
      end
      options.merge!(:is_free=>is_free)
      simulation_exam = Examination.create!(options)
      simulation_exam.update_paper("create", papers.to_a)
      redirect_to "/simulations?category=#{params[:category_id]}"
    else
      flash[:error] = "请填写试卷标题以及选择对应的试卷。"
      redirect_to request.referer
    end
  end


  def edit
    @single_exam=Examination.find(params[:id])
    @papers = @single_exam.papers
    @paper_ids = []
    @papers.collect { |p| @paper_ids << p.id  }
  end


  def update_rater
    unless params[:title].empty? or params[:paper_id].empty?
      papers = Paper.find(params[:paper_id].split(","))
      options={
        :title => params[:title].strip, :creater_id => cookies[:user_id].to_i,
        :is_published => true, :category_id => params[:category_id],
        :types => Examination::TYPES[:SIMULATION],:start_end_time=>params[:end_date],
        :start_at_time=>params[:from_date]
      }
      if params[:fee].to_i==Examination::IS_FREE[:YES]
        is_free=Examination::IS_FREE[:YES]
      else
        is_free=Examination::IS_FREE[:NO]
        options.merge!(:price=>params[:total_price].to_i) if params[:fee].to_i==2
      end
      options.merge!(:is_free=>is_free)
      simulation_exam=Examination.find(params[:id])
      simulation_exam.update_attributes!(options)
      simulation_exam.update_paper("update", papers.to_a)
      redirect_to "/simulations?category=#{params[:category_id]}"
    else
      flash[:error] = "请填写试卷标题以及选择对应的试卷。"
      redirect_to request.referer
    end

  end


  def count_detail
    exam_user_total =ExamUser.get_paper(params[:id].to_i)
    unmarked=0
    marking=0
    exam_user_total.each do |e|
      marking +=1 if e.relation_id and e.is_marked!=1
      unmarked +=1 unless e.relation_id
    end unless  exam_user_total.blank?
    unmarked_num=unmarked+marking
    exam_user_one=Statistic.exam_user_count(params[:id].to_i)
    examination=Examination.find(params[:id])
    url=Constant::PUBLIC_PATH + Constant::SIMULATION_DIR
    unless File.directory?(url)               #判断dir目录是否存在，不存在则创建 下3行
      Dir.mkdir(url)
    end
    file_name="/#{Time.now.to_date.to_s}.xls"
    file_url=url+file_name
    unless File.exist?(file_url)
      Spreadsheet.client_encoding = "UTF-8"
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      sheet.row(0).concat "#{examination.title} 的统计数据"
      sheet.row(1).font("12").concat("考生人数统计")
      sheet.row(2).concate["前一天","#{exam_user_one[0]}"]
      sheet.row(3).concate["前三天","#{exam_user_one[1]}"]
      sheet.row(4).concate["所有","#{exam_user_one[2]}"]
      sheet.row(6).concate["为批阅的试卷","#{unmarked_num},其中#{marking}份正批阅"]
      exam_users =ExamUser.find_by_sql("select name,email from exam_user eu inner join users u on u.id=eu.user_id where eu.examination_id=#{params[:id]}")
      users.each_with_index do |user, index|
        sheet.row(index+1).concat ["#{user.name}", "#{user.email}"]
      end
      sheet.row(users.size+1).concat ["总计", "#{users.size}"]
      book.write file_url
    end
    render :inline => "<script>window.location.href='/data/#{file_name}';</script>"
  end
end
