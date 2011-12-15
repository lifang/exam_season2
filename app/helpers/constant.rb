# encoding: utf-8
module Constant
  #邮箱地址
  EMAILS = {
    :e126 => ['http://www.126.com','网易126'],
    :eqq => ['http://mail.qq.com','QQ'],
    :e163 => ['http://mail.163.com','网易163'],
    :esina => ['http://mail.sina.com.cn','新浪'],
    :esohu => ['http://mail.sohu.com','搜狐'],
    :etom => ['http://mail.tom.com','TOM'],
    :esogou => ['http://mail.sogou.com','搜狗'],
    :e139 => ['http://mail.10086.cn','139手机'],
    :egmail => ['http://gmail.google.com','Gmail'],
    :ehotmail => ['http://www.hotmail.com','Hotmail'],
    :e189 => ['http://www.189.cn','189'],
    :eyahoo => ['http://mail.cn.yahoo.com','雅虎'],
    :eyou => ['http://www.eyou.com','亿邮'],
    :e21cn => ['http://mail.21cn.com','21CN'],
    :e188 => ['http://www.188.com','188财富邮'],
    :eyeah => ['http://www.yeah.net','网易Yeah.net'],
    :efoxmail => ['http://www.foxmail.com','foxmail'],
    :ewo => ['http://mail.wo.com.cn','联通手机'],
    :e263 => ['http://www.263.net','263']
  }
  SERVER_PATH = "http://localhost:3000"
  PUBLIC_PATH = "#{Rails.root}/public"
  PAPER_XML_PATH = "#{Rails.root}/public"
  #运营数据目录
  DIR_ROOT="/data"

  #模考统计
  SIMULATION_DIR="/simulas"
  #运营数据操作类型
  ACTION_TYPES={:action1=>1,:action2=>2,:action3=>3,:action4=>4}
  
  #考试类型
  EXAM_TYPES={:forth_level=>1,:sixth_level=>2}

  #考试价格
  EXAM_PRICE={:vip=>36,:competes=>10}

  #系统管理员的id
  ADMIN_ID = 1



end
