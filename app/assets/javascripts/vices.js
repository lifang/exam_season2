function vice_form(){
    var code=$("#code").val();
    if(code==""||code.length==0||code=="代理人姓名"){
        tishi_alert("请输入代理人姓名");
        return false;
    }
}

function vice_create(){
    var name=$('#vice_name').val();
    var phone=$('#vice_phone').val();
    if (name==""||name.length==0){
        tishi_alert("请输入代理人姓名");
        return false;
    }
    if (phone==""||phone.length==0){
        tishi_alert("请输入手机号码");
        return false;
    }
    $("#vice_form").submit();
}

