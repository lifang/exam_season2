# encoding: utf-8
class Examination < ActiveRecord::Base
  has_many :examination_paper_relations,:dependent => :destroy
  has_many :papers,:through=>:examination_paper_relations, :source => :paper
  belongs_to :user,:foreign_key=>"creater_id"
  has_many :exam_users,:dependent => :destroy
  has_many :examination_tag_relations,:dependent => :destroy
  has_many :tags,:through=>:examination_tag_relations, :source => :tag

  STATUS = {:EXAMING => 0, :LOCK => 1, :GOING => 2,  :CLOSED => 3 } #考试的状态：0 考试中 1 未开始 2 进行中 3 已结束
  IS_PUBLISHED = {:NEVER => 0, :ALREADY => 1} #是否发布  0 没有 1 已经发布
  IS_FREE = {:YES => 1, :NO => 0} #是否免费 1是 0否

  TYPES = {:SIMULATION => 0, :OLD_EXAM => 1, :PRACTICE => 2, :SPECIAL => 3}
  #考试的类型： 0 模拟考试  1 真题练习  2 综合训练  3 专项练习
  TYPE_NAMES = {0 => "模拟考试", 1 => "真题练习", 2 => "综合训练", 3 => "专项练习"}

  default_scope :order => "examinations.created_at desc"

  def generate_exam_pwd(attr_hash)
    attr_hash[:exam_password1] = proof_code(6)
    attr_hash[:exam_password2] = proof_code(6)
  end

  #发布考试
  def publish!
    self.toggle!(:is_published)
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

  def proof_code(len)
    chars = (1..9).to_a
    code_array = []
    1.upto(len) {code_array << chars[rand(chars.length)]}
    return code_array.join("")
  end



end
