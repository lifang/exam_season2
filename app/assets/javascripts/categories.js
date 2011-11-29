
//验证邮箱 来源于："/categories" 添加管理员
  function validate_add_manage(category_id){
    var emailReg = new RegExp(/^\w+([-+.])*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/);
    var email = $("#add_manage_email_textfield_"+category_id).val().replace(/ /g , "");
    var this_email = $("#add_manage_email_textfield_"+category_id).val(email).val();
    if (this_email.length ==0 || !emailReg.test(this_email)){
      alert("请输入有效邮箱!");
      return false;
    }
  }