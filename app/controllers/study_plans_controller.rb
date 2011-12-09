# encoding: utf-8
class StudyPlansController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @study=StudyPlan.find_by_category_id(params[:category].to_i)
  end
  
  def create_task
    @tasks=[]
    unless params[:info]==""||params[:info].nil?
      infos=params[:info].split(";")
      infos.each do |info|
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
    end
    unless params[:info]==""||params[:info].nil?
      infos=params[:info].split(";")
      infos.each do |info|
        single=[]
        info.split(",").each do |task|
          single << task
        end
        PlanTask.create(:study_plan_id=>study.id,:task_types=>single[0].to_i,:period_types=>single[1].to_i,:num=>single[2].to_i)
      end
    end
    redirect_to "/study_plans?category=#{params[:category]}"
  end
  
end
