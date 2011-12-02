# encoding: utf-8
class SimilaritiesController < ApplicationController
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
        @exam_papers[paper.examination_id] << paper
      end
    end unless papers.blank?
  end

  def create
    
  end

  def edit
    
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
    sql = "select * from papers where category_id = #{session[:category]} and paper_url is not null"
    sql += " and created_at >= '#{session[:mintime]}'" unless session[:mintime].nil? or session[:mintime] == ""
    sql += " and created_at <= '#{session[:maxtime]}'" unless session[:maxtime].nil? or session[:maxtime] == ""
    sql += " and title like '%#{session[:exam_title]}%'" unless (session[:exam_title].nil? or session[:exam_title].strip == "")
    sql += " order by created_at desc"
    @papers = Paper.paginate_by_sql(sql, :per_page =>1, :page => params[:page])
    respond_with (@papers) do |format|
      format.js
    end
  end

  #设置试卷
  def set_paper
    
  end
  
end
