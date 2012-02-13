#encoding: utf-8
class InviteCode < ActiveRecord::Base
  belongs_to :bus
  belongs_to :vicegerent

  def self.search(code, page)
    sql = "select i.code code, v.name v_name, i.created_at, u.name u_name, i.use_time
      from invite_codes i left join vicegerents v on v.id = i.vicegerent_id left join users u on u.id = i.user_id"
    sql += " where i.code like '#{code}%' " unless code.nil?
    sql += " order by created_at desc"
    return InviteCode.paginate_by_sql(sql, :per_page => 10, :page => page)
  end
end
