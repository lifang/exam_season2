class CategoriesController < ApplicationController
  
  #[get][collection]科目列表页面
  def index
    categories=Category.find_by_sql("select c.id,cm.id category_manage_id,c.name,c.price,u.email from categories c left join category_manages cm on cm.category_id=c.id left join users u on u.id=cm.user_id where c.id>1")  #1为root,取id>1
    @web_params={}
    categories.each do |c|
      @web_params[c.id].nil? ? @web_params[c.id]={:id=>c.id,:name=>c.name,:price=>c.price,:manages=>[[c.email,c.category_manage_id]]} :@web_params[c.id][:manages]<<[c.email,c.category_manage_id]
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




  #[post][member]添加管理员。填写邮箱地址，生成默认密码，并发送邮件通知。
  def add_manage
    puts "-------------------------------------------------------"
    password=proof_code(6)
    @user=User.find_by_email(params["email"])
    if @user.nil?
      @user = User.new(:email=>params["email"],:password=>password,:password_confirmation =>password)
      @user.encrypt_password
      if @user.save 
        flash[:notice]="管理员添加成功！"
        insert_into_categorymanage_table(@user.id,params[:id])
      else
        flash[:notice]="管理员添加失败！(保存数据库失败)"
        redirect_to request.referer
        return false
      end
    else
      if CategoryManage.find_by_user_id_and_category_id(@user.id,params[:id]).nil?
        insert_into_categorymanage_table(@user.id,params[:id])
      else
        flash[:notice]="该用户已经是管理员，请勿重复添加!"
        redirect_to request.referer
        return false
      end
    end
    redirect_to request.referer
  end

  # 插入记录 category_manage表 （来源：add_manage）
  def insert_into_categorymanage_table(user_id,category_id)
    @category = CategoryManage.new(:user_id=>user_id.to_i,:category_id=>category_id.to_i)
    puts "数据库保存错误，来源于 insert_into_categorymanage_table (categories_controller.rb)"  unless @category.save
  end

  #[get][member]删除管理员。直接点击邮箱后的红叉[X]
  def delete_manage
    CategoryManage.delete(params[:id])
    redirect_to request.referer
  end
end
