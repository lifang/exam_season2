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


  
  PUBLIC_PATH = "#{Rails.root}/public"


  COLLECTION_PATH = "/collections"
  #txt文件路径
  #统计信息路径
  LOG_PATH = "/count_log"
  #下载LOG
  LOG_PASSWORD = "gankao2011"
  RIGHTS = {
    :english_fourth_level => ["英语四级",1],
    :english_sixth_level => ["英语六级",2]
  }
  PROOF_CHECK="jameswang@comdosoft.com"
  #综合训练音频文件播放次数
  CANPLAYTIME={
    :practice_2=>3,
    :practice_3=>1,
    :practice_4=>3,
    :practice_5=>3,
    :practice_6=>3,
  }

  #运营数据目录
  DIR_ROOT="/data"
  #大赛考试
  EXAMINATION_ID = 21
 
end
