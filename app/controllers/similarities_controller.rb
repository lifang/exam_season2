# encoding: utf-8
class SimilaritiesController < ApplicationController
  before_filter :access?
  before_filter :is_category_in?
  respond_to :html, :xml, :json
  #真题列表
  def index
    category_id = params[:category].to_i
    sql = "select e.id, e.title, e.is_free from examinations e
        where e.category_id = #{category_id} and e.types = #{Examination::TYPES[:OLD_EXAM]}"
    if !params[:category_type].nil? and params[:category_type] == Examination::IS_FREE[:YES].to_s
      sql += " and e.is_free = #{Examination::IS_FREE[:YES]}"
    elsif !params[:category_type].nil? and params[:category_type] == Examination::IS_FREE[:NO].to_s
      sql += " and (e.is_free = #{Examination::IS_FREE[:NO]} or e.is_free is null)"
    end
    @similarities = Examination.paginate_by_sql(sql,
      :per_page => 5, :page => params[:page])
    @exam_papers = {}
    examination_ids = []
    @similarities.collect { |s|  examination_ids << s.id }
    papers = Paper.find_by_sql(["select epr.examination_id, p.title p_title from examination_paper_relations epr
        left join papers p on epr.paper_id = p.id where epr.examination_id in (?)", examination_ids])
    papers.each do |paper|
      if @exam_papers[paper.examination_id].nil?
        @exam_papers[paper.examination_id] = [paper.p_title]
      else
        @exam_papers[paper.examination_id] << paper.p_title
      end
    end unless papers.blank?
  end

  def create
    unless params[:title].empty? or params[:paper_id].empty?
      papers = Paper.find(params[:paper_id].split(","))
      is_free = (params[:is_free].to_i ==  Examination::IS_FREE[:YES]) ?
        Examination::IS_FREE[:YES] : Examination::IS_FREE[:NO]
      similarity = Examination.create!(:title => params[:title].strip, :creater_id => cookies[:user_id].to_i,
        :is_published => true,:status=>Examination::STATUS[:GOING], :category_id => params[:category_id],
        :is_free => is_free, :types => Examination::TYPES[:OLD_EXAM])
      similarity.update_paper("create", papers.to_a)
      redirect_to "/similarities?category=#{params[:category_id]}"
    else
      flash[:error] = "请你填写试卷标题以及选择真题对应的试卷。"
      redirect_to request.referer
    end
  end

  def edit
    @similarity = Examination.find(params[:id].to_i)
    @papers = @similarity.papers
    @paper_ids = []
    @papers.collect { |p| @paper_ids << p.id  }
  end

  def update
    unless params[:title].empty? or params[:paper_id].empty?
      papers = Paper.find(params[:paper_id].split(","))
      similarity = Examination.find(params[:id].to_i)
      is_free = (params[:is_free].to_i ==  Examination::IS_FREE[:YES]) ?
        Examination::IS_FREE[:YES] : Examination::IS_FREE[:NO]
      similarity.update_attributes(:title => params[:title].strip, :is_free => is_free)
      similarity.update_paper("update", papers.to_a)
      redirect_to "/similarities?category=#{params[:category_id]}"
    else
      flash[:error] = "请你填写试卷标题以及选择真题对应的试卷。"
      redirect_to request.referer
    end
    
  end

  #挑选试卷
  def get_papers
    session[:mintime] = nil
    session[:maxtime] = nil
    session[:exam_title] = nil
    session[:category] = params[:category]
    session[:mintime] = params[:mintime]
    session[:maxtime] = params[:maxtime]
    session[:exam_title] = params[:exam_title]
    redirect_to paper_list_similarities_path
  end

  def paper_list
    sql = "select * from papers where category_id = #{session[:category]}
       and types != #{Examination::TYPES[:SPECIAL]} and paper_url is not null and status = #{Paper::CHECKED[:YES]} "
    sql += " and created_at >= '#{session[:mintime]}'" unless session[:mintime].nil? or session[:mintime] == ""
    sql += " and created_at <= '#{session[:maxtime]}'" unless session[:maxtime].nil? or session[:maxtime] == ""
    sql += " and title like '%#{session[:exam_title]}%'" unless (session[:exam_title].nil? or session[:exam_title].strip == "")
    sql += " order by created_at desc"
    @papers = Paper.paginate_by_sql(sql, :per_page =>3, :page => params[:page])
    respond_with (@papers) do |format|
      format.js
    end
  end

  #设置试卷
  def set_paper
    @paper_ids = params[:paper_ids]
    unless @paper_ids.empty?
      @papers = Paper.find(@paper_ids.split(","))
      respond_with (@papers) do |format|
        format.js
      end
    end
  end

  def delete
    similarity = Examination.find(params[:id])
    if similarity
      exam_users = ExamUser.count_by_sql(["select count(eu.id) from examinations e
          inner join exam_users eu on eu.examination_id = e.id where e.id = ?", similarity.id])
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
