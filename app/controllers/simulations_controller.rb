# encoding: utf-8
class SimulationsController < ApplicationController
  #模考列表
  
  def index
    category_id = params[:category].to_i
    sql = "select e.id, e.title, e.is_free,e.price from examinations e
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
        @exam_papers[paper.examination_id] << paper
      end
    end unless papers.blank?
  end

  def create
    
  end

  def edit
    
  end
  
end
