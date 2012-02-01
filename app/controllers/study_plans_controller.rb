# encoding: utf-8
class StudyPlansController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :is_category_in?

  def index
    @study=StudyPlan.find_by_category_id(params[:category].to_i)
    @plans=@study.plan_tasks unless @study.blank?
  end
  
  def create_task
    @tasks=[]
    unless params[:info]==""||params[:info].nil?
      params[:info].split(";").each do |info|
        single=[]
        info.split(",").each do |task|
          single << task
        end
        @tasks << single
      end
    end
    respond_with (@tasks) do |format|
      format.js
    end
  end


  def create_plan
    study=StudyPlan.find_by_category_id(params[:category].to_i)
    if study.blank?
      study=StudyPlan.create(:study_date=>params[:date],:category_id=>params[:category])
    else
      study.update_attributes(:study_date=>params[:date])
    end
    unless params[:info]==""||params[:info].nil?
      infos=params[:info].split(",")
      (0..infos.size/3-1).each do |index|
        PlanTask.create(:study_plan_id=>study.id,:task_types=>infos[index*3+1].to_i,:period_types=>infos[index*3+0].to_i,:num=>infos[index*3+2].to_i)
      end
    end
    delete_ids=params[:delete_task_ids].split(",")
    delete_ids.each do |id|
      PlanTask.delete(id)
    end unless delete_ids.blank?
    redirect_to "/study_plans?category=#{params[:category]}"
  end


  def delete_task
    ids=[]
    params[:delete_ids].split(",").each do |id|
      ids << id
    end
    @plans=[]
    tasks=PlanTask.find(ids)
    @study=StudyPlan.find_by_category_id(params[:category].to_i)
    @plans=@study.plan_tasks-tasks unless @study.blank?
    respond_with (@plans) do |format|
      format.js
    end
  end
end
