# encoding: utf-8
class CategoriesController < ApplicationController
  before_filter :access?

  #[get][collection]科目列表页面
  def index
    if is_admin?
      @categories=Category.paginate(:per_page=>4,:page=>params[:page])
    else
      if is_paper_creater?
        @categories=Category.paginate_by_sql("select c.* from categories c inner join category_manages cm on cm.category_id=c.id where cm.user_id=#{cookies[:user_id]} order by c.id asc",:per_page=>4,:page=>params[:page])
      end
    end
    unless @categories.blank?
      category_ids = []
      @categories.collect { |c| category_ids << c.id }
      category_manages = CategoryManage.find_by_sql(["select cm.category_id, u.email, cm.id cm_id
        from category_manages cm inner join users u on cm.user_id = u.id
        where cm.category_id in (?)#", category_ids])
      @category_manages={}
      category_manages.each do |cm|
        @category_manages[cm.category_id]=[] if @category_manages[cm.category_id].nil?
        @category_manages[cm.category_id]<<[cm.email,cm.cm_id]
      end
    end

  end

  
  #[get][member]科目的编辑页面
  def edit
    @category=Category.find(params[:id])
  end


  #[post][member]编辑科目基本信息，名称和价格
  def edit_post
    @category=Category.find(params[:id])
    @category.update_attributes(:name=>params["name"],:price=>params["price"])
    redirect_to "/categories"
  end


  #[get][member]新建页面
  def new
    
  end

  #[post][collection]新建科目
  def new_post
    price = params["price"].nil? ? 0 : params["price"].to_i
    @category=Category.new(:name=>params["name"],:price=>price)
    puts params["name"]+"  "+params["price"]
    flash[:notice]="新建科目出错" unless @category.save
    redirect_to "/categories"
  end

  
  #[post][member]添加管理员。填写邮箱地址，生成默认密码，并发送邮件通知，默认设置teacher权限，。
  def add_manage
    password=proof_code(6)
    category_name=params["category_name"]
    @user=User.find_by_email(params["email"])
    if @user.nil?
      @user = User.new(:email=>params["email"],:password=>password,:password_confirmation =>password)
      @user.encrypt_password
      if @user.save
        flash[:notice]="管理员添加成功！"
        set_role(@user.id,Role::TYPES[:TEACHER])  #设置用户的身份为“老师”
        insert_into_categorymanage_table(@user,params[:id],password,category_name)  #建立用户和科目的关联
      else
        flash[:notice]="管理员添加失败！(保存数据库失败)"
      end
    else
      if CategoryManage.find_by_user_id_and_category_id(@user.id,params[:id]).nil?
        flash[:notice]="管理员添加成功！"
        set_role(@user.id,Role::TYPES[:TEACHER]) #设置用户的身份为“老师”
        insert_into_categorymanage_table(@user,params[:id],"",category_name) #建立用户和科目的关联
      else
        flash[:notice]="该用户已经是管理员，请勿重复添加!"
      end
    end
    redirect_to request.referer
  end


  # 设置用户和科目的关联 category_manage表 （用处：add_manage）
  def insert_into_categorymanage_table(user,category_id,password,category_name)
    UserMailer.notice_manage(user,category_name,password).deliver
    @category = CategoryManage.create(:user_id=>user.id,:category_id=>category_id.to_i)
  end

  # 设置用户的身份 （用处：add_manage）
  def set_role(user_id,role)
    UserRoleRelation.create(:user_id=>user_id,:role_id=>role) if UserRoleRelation.find_by_sql("select id from user_role_relations where user_id=#{user_id} and role_id=#{role}").blank?
  end
  
  #[get][member]删除科目管理员。
  def delete_manage
    CategoryManage.delete(params[:id])
    redirect_to request.referer
  end
  
end
