#encoding: utf-8
class SpecialsController < ApplicationController
  before_filter :access?
  before_filter :is_category_in?

  def index
    @tags = Examination.find_by_sql(["select t.id tag_id, t.name, e.id examination_id, etr.id etr_id
        from examination_tag_relations etr
        inner join examinations e on e.id = etr.examination_id
        inner join tags t on t.id = etr.tag_id where e.types = ? and e.status = ? and e.category_id = ?",
      Examination::TYPES[:SPECIAL], Examination::STATUS[:GOING], params[:category].to_i])
  end

  def destroy
    ExaminationTagRelation.delete(params[:id].to_i)
    redirect_to "/specials?category=#{params[:category]}"
  end
  
end
