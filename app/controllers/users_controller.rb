# encoding: utf-8
class UsersController < ApplicationController
  before_filter :access?
  
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

  #科目一览表的单个可以信息
  def category_logs
    @user_id = params[:id].to_i
    @category_id = params[:category_id].to_i
    @action_logs = User.action_log_by_category(@category_id, @user_id, params[:page])
    @simulations = User.get_simulation_by_category(@category_id, @user_id, params[:page])
    @study_plan = UserPlanRelation.find(:first, 
      :select => ["sp.study_date, user_plan_relations.created_at, user_plan_relations.ended_at"],
      :joins => "inner join study_plans sp on sp.id = user_plan_relations.study_plan_id",
      :conditions => ["user_plan_relations.user_id = ? and sp.category_id = ?", @user_id, @category_id])
    if @study_plan
      @today_plan = ActionLog.find(:first, :conditions => ["types = ? and user_id = ? ",
          ActionLog::TYPES[:STUDY_PLAY], @user_id], :order => "updated_at desc")
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  #动作详情
  def user_action_logs
    @user_id = params[:id].to_i
    @category_id = params[:category_id].to_i
    @action_logs = User.action_log_by_category(@category_id, @user_id, params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  #考试成绩
  def user_simulations
    @user_id = params[:id].to_i
    @category_id = params[:category_id].to_i
    @simulations = User.get_simulation_by_category(@category_id, @user_id, params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  #升级为vpi
  def goto_vip
    order = Order.find(:first, 
      :conditions => ["status = #{Order::STATUS[:NOMAL]} and user_id = ? and category_id = ?",
        params[:id].to_i, params[:vip_c_id].to_i])
    if order.nil? || order.types==Order::TYPES[:COMPETE] || order.types==Order::TYPES[:TRIAL_SEVEN]
      Order.create(:user_id => params[:id].to_i, :types => params[:order_type].to_i,
        :status => Order::STATUS[:NOMAL], :start_time => Time.now.to_datetime, :total_price => 0,
        :end_time => params[:end_time],
        :category_id => params[:vip_c_id].to_i, :remark => params[:reason])
      order.update_attributes(:status=>Order::STATUS[:INVALIDATION]) unless order.nil?
    end
    flash[:notice] = "升级成功。"
    redirect_to request.referer
  end

end
