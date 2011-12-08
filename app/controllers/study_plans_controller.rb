# encoding: utf-8
class StudyPlansController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @study=StudyPlan.find_by_category_id(params[:category_id].to_i)
    session[:plan_ids]<< @study.plan_tasks unless @study.nil?
    @plans=PlanTask.find(session[:plan_ids]) unless session[:plan_ids].nil?
  end
  
  def create_task
    @plan=PlanTask.create(:task_types=>params[:task],:period_types=>params[:period],:num=>params[:amount])
    if session[:plan_ids].nil?
      session[:plan_ids]=[@plan.id]
    else
      session[:plan_ids]<<@plan.id
    end
    @paper=PlanTask.find(session[:plan_ids])
    respond_with (@paper) do |format|
      format.js
    end
  end
  
end
