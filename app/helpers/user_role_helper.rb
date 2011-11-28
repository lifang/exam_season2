# encoding: utf-8
module UserRoleHelper
  
  def is_student?
    cookie_role cookies[:user_id] unless cookies[:user_roles]
    user_roles = cookies[:user_roles].split(",")
    user_roles.include? Role::TYPES[:STUDENT].to_s
  end

  def is_paper_creater?
    cookie_role cookies[:user_id] unless cookies[:user_roles]
    user_roles = cookies[:user_roles].split(",")
    user_roles.include? Role::TYPES[:TEACHER].to_s
  end
  
  
  def is_vicegerent?
    cookie_role cookies[:user_id] unless cookies[:user_roles]
    user_roles = cookies[:user_roles].split(",")
    user_roles.include? Role::TYPES[:VICEGERENT].to_s
  end

  def is_admin?
    cookie_role cookies[:user_id] unless cookies[:user_roles]
    user_roles = cookies[:user_roles].split(",")
    user_roles.include? Role::TYPES[:SYSTEM].to_s
  end


  #罗列当前用户的所有权限
  def cookie_role(user_id)
    user = User.find user_id
    roles = user.roles
    user_roles = []
    model_role = {}
    for role in roles
      user_roles << role.id
      gankao_model_role = role.model_role
      if model_role["gankao".to_sym]
        model_role["gankao".to_sym] = model_role["gankao".to_sym].to_i|gankao_model_role.right_sum.to_i
      else
        model_role["gankao".to_sym] = gankao_model_role.right_sum.to_i
      end if gankao_model_role
    end if roles
    cookies[:model_role] = {:value => model_role.to_a.join(","), :path => "/", :secure  => false}
    cookies[:user_roles] = {:value => user_roles.join(","), :path => "/", :secure  => false}
  end
  
  def permission?(role)
    i = Constant::RIGHTS[role]
    role_flag = nil
    if cookies[:user_id]
      cookie_role(cookies[:user_id]) unless cookies[:model_role]
      puts cookies[:model_role]
      if cookies[:model_role]
        model_roles = cookies[:model_role].split(",")
        for j in (0..model_roles.length)
          if model_roles[j].to_s == "gankao".to_s
            role_flag = model_roles[j+1]
            break
          end
        end
      end
    end
    role_flag.to_i&i[1] == i[1]
  end

    
end
