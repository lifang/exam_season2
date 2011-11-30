# encoding: utf-8
class SimilaritiesController < ApplicationController
  #真题列表
  def index
    category_id = params[:category].to_i
    @similarities = Examination.paginate_by_sql(["select e.id, e.title, e.is_free from examinations e
        where e.category_id = ? and e.types = ?", category_id, Examination::TYPES[:OLD_EXAM]],
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
  
end
