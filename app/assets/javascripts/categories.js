
//验证邮箱 来源于："/categories" 添加管理员
function validate_add_manage(category_id){
    var emailReg = new RegExp(/^\w+([-+.])*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/);
    var email = $("#add_manage_email_textfield_"+category_id).val().replace(/ /g , "");
    var this_email = $("#add_manage_email_textfield_"+category_id).val(email).val();
    if (this_email.length ==0 || !emailReg.test(this_email)){
        tishi_alert("请输入有效邮箱!");
        $("#add_manage_email_textfield_"+category_id).focus().select();
        return false;
    }
    return true;
}

//验证新建和编辑科目  来源于："/categories/new" 新建科目    "/categories/?/edit" 修改   参数str无实际功能，起提示作用
function validate_category_form(str){
    //    alert($("#category_new_name").val());
    //    alert($("#category_new_price").val());
    var name = $("#category_name").val($("#category_name").val().replace(/ /g,"")).val();
    if(name==""||name.length>50){
        tishi_alert("科目名称不能为空，且长度不能超过50个字");
        $("#category_name").focus().select();
        return false;
    }
    var price = $("#category_price").val($("#category_price").val().replace(/ /g,"")).val();
    if(parseFloat(price)<0){
        tishi_alert("付费标准必须为数字且金额不能为负");
        $("#category_price").focus().select();
        return false;
    }
    return true;
}