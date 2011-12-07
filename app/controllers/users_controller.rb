# encoding: utf-8
class UsersController < ApplicationController
  
  def index
    session[:search_text] = nil
    session[:pays] = nil
    session[:rels] = nil
    session[:select] = nil
    @users = User.search_action_log(params[:time_sort], nil, params[:page], nil)
  end

  def search
    session[:search_text] = nil
    session[:search_text] = params[:search_text]
    redirect_to search_list_users_path
  end

  def search_list
    @users = User.search_action_log(params[:time_sort], session[:search_text], params[:page], true)
    render "index"
  end

  def show
    @user = User.find(params[:id].to_i)
    @login_log = ActionLog.find(:first,
      :conditions => ["user_id = ? and types = ?", params[:id].to_i, ActionLog::TYPES[:LOGIN]],
      :order => "updated_at desc")
    @user_action_logs = UserActionLog.find_by_user_id(params[:id].to_i)
    @pay_logs = @user.pay_logs(params[:pays])
    @category_relations = @user.category_relations(params[:rels])
  end

  def category_logs
    @user_id = params[:id].to_i
    @category_id = params[:category_id].to_i
    @action_logs = User.action_log_by_category(@category_id, @user_id, params[:page])
    @simulations = User.get_simulation_by_category(@category_id, @user_id, params[:page])
    @study_plan = StudyPlanUser.find_by_user_id(@user_id)
    if @study_plan
      ActionLog.find_by_sql(["select * from action_logs al 
        where al.types = ? and TO_DAYS(NOW())=TO_DAYS(created_at) and al.user_id = ?", ActionLog::TYPES[:STUDY_PLAY]])
      respond_to do |format|
        format.html
        format.js
      end
    end
  end






















end
