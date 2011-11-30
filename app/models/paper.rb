# encoding: utf-8
class Paper < ActiveRecord::Base

  belongs_to :category
  
  default_scope :order => "papers.created_at desc"

  # 未审核、已审核、所有 
  CHECKED={:NO=>0,:YES=>1,:ALL=>2}

  # 试卷筛选 + 分页
  def Paper.search_mothod(category_id,checked, per_page, page)
    sql = "select * from papers where category_id = #{category_id}"
    sql += " and paper_url is null" if checked==CHECKED[:NO]
    sql += " and paper_url is not null" if checked==CHECKED[:YES]
    sql += " order by created_at desc"
    puts "#{sql}"
    return Paper.paginate_by_sql(sql, :per_page =>per_page, :page => page)
  end
  
end
