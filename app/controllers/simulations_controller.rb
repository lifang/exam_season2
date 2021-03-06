# encoding: utf-8
class SimulationsController < ApplicationController
  before_filter :access?
  before_filter :is_category_in?
  respond_to :html, :xml, :json
  require 'spreadsheet'

  #模考列表
  def index
    category_id = params[:category].to_i
    sql = "select e.id, e.title, e.is_free,e.price,e.start_at_time,e.is_published,e.start_end_time from examinations e
        where e.category_id = #{category_id} and e.types = #{Examination::TYPES[:SIMULATION]}"
    if !params[:category_type].nil? and params[:category_type] == Examination::IS_FREE[:NO].to_s
      sql += " and e.is_free = #{Examination::IS_FREE[:NO]} and e.price is null"
    elsif !params[:category_type].nil? and params[:category_type] == Examination::IS_FREE[:YES].to_s
      sql += " and (e.is_free = #{Examination::IS_FREE[:YES]} or e.is_free is null) and e.price is null"
    elsif !params[:category_type].nil? and params[:category_type] =="2"
      sql += " and price>0 and e.is_free = #{Examination::IS_FREE[:NO]}"
    end
    sql += "  order by created_at desc"
    @simulations = Examination.paginate_by_sql(sql,:per_page => 5, :page => params[:page])
    @exam_papers = {}
    examination_ids = []
    @simulations.collect { |s|  examination_ids << s.id }
    papers = Paper.find_by_sql(["select epr.examination_id, p.title p_title from examination_paper_relations epr
        left join papers p on epr.paper_id = p.id where epr.examination_id in (?)", examination_ids])
    exam_raters = ExamRater.find_by_sql(["select er.examination_id, er.email from exam_raters er
       where er.examination_id in (?)", examination_ids])
    @exam_raters={}
    exam_raters.each do |exam_rater|
      if @exam_raters[exam_rater.examination_id].nil?
        @exam_raters[exam_rater.examination_id]=[exam_rater.email]
      else
        @exam_raters[exam_rater.examination_id]<<exam_rater.email
      end
    end unless exam_raters.blank?
    papers.each do |paper|
      if @exam_papers[paper.examination_id].nil?
        @exam_papers[paper.examination_id] = [paper.p_title]
      else
        @exam_papers[paper.examination_id] << paper.p_title
      end
    end unless papers.blank?
  end



  def add_rater
    @examination=params[:examination_id]
    if ExamRater.find(:first,:conditions=>"email='#{params[:email]}' and examination_id=#{@examination}").nil?
      exam_rater=ExamRater.create(:email=>params[:email],:examination_id=>@examination,:author_code => proof_code(6))
      UserMailer.rater_affirm(exam_rater,Examination.find(@examination)).deliver
    end
    @exam_rater=ExamRater.find_by_sql("select er.examination_id, er.email from exam_raters er
      where er.examination_id = #{@examination}")
    @exam_rater << @examination
    respond_with (@exam_rater) do |format|
      format.js
    end
  end

  def delete_rater
    @examination=params[:examination_id]
    ExamRater.where("email='#{params[:email]}' and examination_id=#{@examination}")[0].delete
    @exam_rater=ExamRater.find_by_sql("select er.examination_id, er.email from exam_raters er
      where er.examination_id = #{@examination}")
    @exam_rater << @examination
    respond_with (@exam_rater) do |format|
      format.js
    end
  end

  def create
    unless params[:title].empty? or params[:paper_id].empty?
      papers = Paper.find(params[:paper_id].split(","))
      status = Examination::STATUS[:EXAMING]
      status = Examination::STATUS[:LOCK] if params[:from_date].to_date>Time.now.to_date
      status = Examination::STATUS[:CLOSED] if params[:end_date].to_date<Time.now.to_date
      options={
        :title => params[:title].strip, :creater_id => cookies[:user_id].to_i,
        :is_published => Examination::IS_PUBLISHED[:ALREADY], :category_id => params[:category_id],
        :types => Examination::TYPES[:SIMULATION],:start_end_time=>params[:end_date],:status=>status,
        :start_at_time=>params[:from_date]
      }
      is_free=Examination::IS_FREE[:YES]
      unless params[:fee].to_i==Examination::IS_FREE[:YES]
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
      status = Examination::STATUS[:EXAMING]
      status = Examination::STATUS[:LOCK] if params[:from_date].to_date>Time.now.to_date
      status = Examination::STATUS[:CLOSED] if params[:end_date].to_date<Time.now.to_date
      options={
        :title => params[:title].strip, :creater_id => cookies[:user_id].to_i, :category_id => params[:category_id],
        :types => Examination::TYPES[:SIMULATION],:start_end_time=>params[:end_date],
        :start_at_time=>params[:from_date],:status=>status
      }
      is_free = Examination::IS_FREE[:YES]
      price = nil
      unless params[:fee].to_i == Examination::IS_FREE[:YES]
        is_free = Examination::IS_FREE[:NO]
        price = params[:total_price].to_i if params[:fee].to_i == 2
      end
      options.merge!(:is_free=>is_free, :price => price)
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
    examination = Examination.find(params[:id].to_i)
    
    exam_user_total = ExamUser.get_paper(params[:id].to_i)
    unmarked = 0
    marking = 0
    marked = 0
    total_score = 0
    exam_user_total.each do |e|
      marking += 1 if e.relation_id and e.is_marked != RaterUserRelation::MARK[:YES]
      unmarked += 1  unless e.relation_id
      if e.is_marked == RaterUserRelation::MARK[:YES] and !e.total_score.nil?
        marked += 1
        total_score += e.total_score
      end
    end unless exam_user_total.blank?
    averge_score = (marked == 0) ? "未统计" : (total_score*1.0/marked)
    unmarked_num = unmarked + marking
    exam_user_one = Statistic.exam_user_count(params[:id].to_i)
    
    url = Constant::PUBLIC_PATH + Constant::SIMULATION_DIR
    Dir.mkdir(url) unless File.directory?(url)  #判断dir目录是否存在，不存在则创建 下3行
    file_name="/#{Time.now.strftime("%Y%m%d%H%M").to_s}_#{params[:id]}.xls"
    file_url = url + file_name
    
    unless File.exist?(file_url)
      Spreadsheet.client_encoding = "UTF-8"
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      sheet.row(0).concat ["","","#{examination.title.to_s}"]
      show_unmarked = (marking == 0) ? "#{unmarked_num}" : "#{unmarked_num},其中#{marking}份正批阅"
      sheet.row(1).concat ["前一天考生人数", "前三天考生人数", "所有考生", "未批阅", "平均分"]
      sheet.row(2).concat ["#{exam_user_one[0]}","#{exam_user_one[1]}","#{exam_user_one[2]}",show_unmarked, averge_score]
      sheet.row(4).concat ["","分数报告"]
      exam_users = ExamUser.score_users(params[:id].to_i)
      unless exam_users.blank?
        sheet.row(5).concat ["用户名","邮箱","分数"]
        exam_users.each_with_index do |user, index|
          if user.relation_id
            score_text = (user.is_marked == RaterUserRelation::MARK[:YES] and !user.total_score.nil?) ?
              user.total_score : "批阅中"
          else
            score_text = (user.order_id) ? "未批阅" : "非VIP用户"
          end
          score_text = "未交卷" unless user.is_submited
          sheet.row(index+6).concat ["#{user.name}", "#{user.email}","#{score_text}"]
        end
      else
        sheet.row(6).concat ["暂无考生"]
      end
      book.write file_url
    end
    render :inline => "<script>window.location.href='#{Constant::SIMULATION_DIR}#{file_name}';</script>"
    
  end


  def stop_exam
    exam=Examination.find(params[:exam_id])
    exam.update_attributes(:is_published=>params[:types].to_i)
  end

  def delete
    simulation = Examination.find(params[:id])
    if simulation
      exam_users = ExamUser.count_by_sql(["select count(eu.id) from examinations e
          inner join exam_users eu on eu.examination_id = e.id where e.id = ?", simulation.id])
      if exam_users > 0
        flash[:notice] = "当前真题已经有用户使用。"
      else
        similarity.destroy
        flash[:notice] = "当前真题删除成功。"
      end
    end
    redirect_to request.referer
  end
  
end
