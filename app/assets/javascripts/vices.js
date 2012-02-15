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
    var check_phone = new RegExp(/^[0-9]{11,11}$/);
    if (name==""||name.length==0||phone==""||phone.length==0||!check_phone.test(phone)){
        tishi_alert("请输入代理人姓名和手机号");
        return false;
    }
    $("#vice_form").submit();
}

