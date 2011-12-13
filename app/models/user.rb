#encoding: utf-8
class User < ActiveRecord::Base
  has_many :user_role_relations,:dependent=>:destroy
  has_many :roles,:through=>:user_role_relations,:foreign_key=>"role_id"
  has_many :category_manages,:dependent=>:destroy
  has_one :user_action_log
  has_many :user_category_relations,:dependent => :destroy
  has_many :categories,:through=>:user_category_relations, :source => :category
  has_many :user_plan_relations,:dependent => :destroy
  has_many :study_plans,:through=>:user_plan_relations, :source => :study_plan
  has_many :send_notices, :foreign_key => "send_id", :source => :notice
  has_many :recive_notices, :foreign_key => "target_id", :source => :notice

  attr_accessor :password
  validates:password, :confirmation=>true,:length=>{:within=>6..20}, :allow_nil => true

  FROM = {"sina" => "新浪微博", "renren" => "人人网", "qq" => "腾讯网"}
  TIME_SORT = {:ASC => 0, :DESC => 1}   #用户列表按创建时间正序倒序排列

  #查询用户的操作记录统计
  def self.search_action_log(time_sort, search_text, page, search_flag)
    sql = "select u.id user_id, u.username, u.email, u.created_at, u.code_type,
        al.total_num, al.last_update_time, al.week_num from users u
        left join user_action_logs al on al.user_id = u.id "
    sql += " where u.username like ? or u.email like ? " unless search_flag.nil? or search_text.strip.empty?
    if time_sort.nil?
      sql += " order by u.username "
    else
      sql += " order by u.created_at "
      sql += " desc " if time_sort.to_i == TIME_SORT[:DESC]
    end
    if search_text.nil? or search_text.strip.empty?
      users = User.paginate_by_sql(sql, :per_page => 10, :page => page)
    else
      users = User.paginate_by_sql([sql, "%#{search_text.strip}%", "%#{search_text.strip}%"],
        :per_page => 10, :page => page)
    end
    return users
  end

  #用户的支付记录
  def pay_logs(page)
    pay_sql = "(select o.created_at created_at, c.name name, o.remark remark, o.total_price total_price from orders o
           left join categories c on c.id = o.category_id
           where o.user_id = ?)
           union
           (select co.created_at created_at, ca.name name, co.remark remark, co.price total_price from competes co
           left join categories ca on ca.id = co.category_id
           where co.user_id = ? ) order by created_at desc "
    return Order.paginate_by_sql([pay_sql, self.id, self.id], :per_page => 10, :page => page)
  end

  #用户参与的科目
  def category_relations(page)
    category_sql = "select c.id c_id, c.name, ucr.types ucr_type, o.types order_type, o.remark,
          o.end_time from user_category_relations ucr
          left join orders o on ucr.user_id = o.user_id
          inner join categories c on c.id = ucr.category_id
          where ucr.user_id = ? and o.status = #{Order::STATUS[:NOMAL]} and ucr.status = #{UserCategoryRelation::STATUS[:NOMAL]} "
    return UserCategoryRelation.paginate_by_sql([category_sql, self.id],
      :per_page => 10, :page => page)
  end

  #查看用户分类下的action_log
  def self.action_log_by_category(category_id, user_id, page)
    ActionLog.paginate_by_sql(["select al.created_at, al.types, al.total_num from action_logs al
      where al.category_id = ? and user_id = ?",
        category_id, user_id],
      :per_page => 5, :page => page)
  end

  #查看用户参与的所有模拟考试
  def self.get_simulation_by_category(category_id, user_id, page)
    ExamUser.paginate_by_sql(["select eu.created_at, e.title, eu.total_score from exam_users eu
        inner join examinations e on e.id = eu.examination_id
        where eu.is_submited = ? and e.types = ? and e.category_id = ? and eu.user_id = ?",
      ExamUser::IS_SUBMITED[:YES], Examination::TYPES[:SIMULATION], category_id, user_id], :per_page => 5, :page => page)
  end

  def has_password?(submitted_password)
		encrypted_password == encrypt(submitted_password)
	end
  
  def encrypt_password
    self.encrypted_password=encrypt(password)
  end

  private
  def encrypt(string)
    self.salt = make_salt if new_record?
    secure_hash("#{salt}--#{string}")
  end

  def make_salt
    secure_hash("#{Time.new.utc}--#{password}")
  end

  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end

end

