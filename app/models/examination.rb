# encoding: utf-8
class Examination < ActiveRecord::Base
  has_many :examination_paper_relations,:dependent => :destroy
  has_many :papers,:through=>:examination_paper_relations, :source => :paper
  belongs_to :user,:foreign_key=>"creater_id"
  has_many :exam_users,:dependent => :destroy

  STATUS = {:EXAMING => 0, :LOCK => 1, :GOING => 2,  :CLOSED => 3 } #考试的状态：0 考试中 1 未开始 2 进行中 3 已结束
  IS_PUBLISHED = {:NEVER => 0, :ALREADY => 1} #是否发布  0 没有 1 已经发布
  IS_FREE = {:YES => 1, :NO => 0} #是否免费 1是 0否

  TYPES = {:SIMULATION => 0, :OLD_EXAM => 1, :PRACTICE => 2} #考试的类型： 0 模拟考试  1 真题练习  2 综合训练
  TYPE_NAMES = {0 => "模拟考试", 1 => "真题练习", 2 => "综合训练"}

  default_scope :order => "examinations.created_at desc"

  #创建考试
  def update_examination(attr_hash)
    attr_hash[:is_published] = IS_PUBLISHED[:NEVER] 
    unless attr_hash[:generate_exam_pwd].nil?
      generate_exam_pwd(attr_hash) if attr_hash[:generate_exam_pwd]
      attr_hash.delete(:generate_exam_pwd)
    end
    self.update_attributes(attr_hash)
    self.publish!
    #return examination
  end

  def generate_exam_pwd(attr_hash)
    attr_hash[:exam_password1] = proof_code(6)
    attr_hash[:exam_password2] = proof_code(6)
  end

  #发布考试
  def publish!
    self.toggle!(:is_published)
  end

  #考试组织人员添加考生添加考试记录账号
  def new_exam_user(user)
    exam_user = ExamUser.create(:user_id => user.id,:examination_id => self.id,:password => User::DEFAULT_PASSWORD,
      :is_user_affiremed => ExamUser::IS_USER_AFFIREMED[:NO])
    exam_user.set_paper(self)
    UserMailer.user_affirmed(exam_user,self).deliver if self.user_affirm == true
  end

  #修改试卷,此方法用来修改考试试卷，update_flag 是传过来增加或删除的标记，papers是试卷数组
  def update_paper(update_flag, papers)
    if update_flag == "create"
      papers.each do |i|
        self.papers << i
        i.set_paper_used!
      end
    else
      self.papers = []
      papers.each do |i|
        self.papers << i
        i.set_paper_used!
      end
    end
  end

  def Examination.search_method(user_id, start_at, end_at, title, pre_page, page)
    sql = "select * from examinations e where creater_id = #{user_id} and is_published = 1 "
    sql += "and e.created_at >= '#{start_at}' " unless start_at.nil?
    sql += "and e.created_at <= '#{end_at}' " unless end_at.nil?
    sql += "and e.title like '%#{title}%' " unless title.nil?
    sql += "order by e.status asc, e.created_at desc "
    puts sql
    return Examination.paginate_by_sql(sql, :per_page =>pre_page, :page => page)
  end

  def update_score_level(score_array)
    self.score_levels = []
    0.step(score_array.length-1, 2) do |i|
      ScoreLevel.create(:examination_id=>self.id,:key=>score_array[i],:value=>score_array[i+1])
    end
  end

  def proof_code(len)
    chars = (1..9).to_a
    code_array = []
    1.upto(len) {code_array << chars[rand(chars.length)]}
    return code_array.join("")
  end

  #显示单个登录考生能看到的所有的考试
  def Examination.return_examinations(user_id, examination_id = nil)
    sql = "select e.*, eu.id exam_user_id, eu.paper_id, eu.started_at, eu.ended_at, eu.is_submited from examinations e
          left join exam_users eu on e.id = eu.examination_id
          where e.is_published = 1 and e.status != #{STATUS[:CLOSED]} "
    sql += " and e.id = #{examination_id} " if !examination_id.nil? and examination_id != ""
    sql += " and eu.user_id = #{user_id} "
    Examination.find_by_sql(sql)
  end



end
