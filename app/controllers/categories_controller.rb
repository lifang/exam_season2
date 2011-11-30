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


  #[get][member]科目的新建页面
  def new
    
  end

  
  def new_post
    price = params["price"].nil? ? 0 : params["price"].to_i
    @category=Category.new(:name=>params["name"],:price=>price)
    puts params["name"]+"  "+params["price"]
    flash[:notice]="新建科目出错" unless @category.save
    redirect_to "/categories"
  end

  
  #[post][member]添加管理员。填写邮箱地址，生成默认密码，并发送邮件通知。
  def add_manage
    password=proof_code(6)
    category_name=params["category_name"]
    @user=User.find_by_email(params["email"])
    if @user.nil?
      @user = User.new(:email=>params["email"],:password=>password,:password_confirmation =>password)
      @user.encrypt_password
      if @user.save
        flash[:notice]="管理员添加成功！"
        insert_into_categorymanage_table(@user,params[:id],password,category_name)
      else
        flash[:notice]="管理员添加失败！(保存数据库失败)"
      end
    else
      if CategoryManage.find_by_user_id_and_category_id(@user.id,params[:id]).nil?
        flash[:notice]="管理员添加成功！"
        insert_into_categorymanage_table(@user,params[:id],"",category_name)
      else
        flash[:notice]="该用户已经是管理员，请勿重复添加!"
      end
    end
    redirect_to request.referer
  end


  # 插入记录 category_manage表 （来源：add_manage）
  def insert_into_categorymanage_table(user,category_id,password,category_name)
    UserMailer.notice_manage(user,category_name,password).deliver
    @category = CategoryManage.new(:user_id=>@user.id,:category_id=>category_id.to_i)
    puts "数据库保存错误，来源于 insert_into_categorymanage_table (categories_controller.rb)"  unless @category.save
  end

  
  #[get][member]删除管理员。直接点击邮箱后的红叉[X]
  def delete_manage
    CategoryManage.delete(params[:id])
    redirect_to request.referer
  end
  
end
