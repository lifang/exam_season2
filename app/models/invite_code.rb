#encoding: utf-8
class InviteCode < ActiveRecord::Base
  belongs_to :bus
  belongs_to :vicegerent
  belongs_to :category
  
  CODE_EXCEL_PATH = "/code_excel_path"
  IS_USED = {:YES => 1, :NO => 0} #0未使用 1 已使用
  STATUS = {:NOMAL => 0, :INVALID => 1}#0 正常 1 失效


  def self.search(code, page)
    sql = "select i.id, i.code code, v.name v_name, i.created_at, u.name u_name, i.use_time, i.status, c.name c_name
      from invite_codes i inner join vicegerents v on v.id = i.vicegerent_id
      inner join categories c on c.id = i.category_id left join users u on u.id = i.user_id"
    sql += " where i.code like '#{code}%' " unless code.nil?
    sql += " order by created_at desc"
    return InviteCode.paginate_by_sql(sql, :per_page => 10, :page => page)
  end
  


end
