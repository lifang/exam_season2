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
    if (name==""||name.length==0||phone.length<11){
        tishi_alert("请输入代理人姓名");
        return false;
    }
    if (phone==""||phone.length==0){
        tishi_alert("请输入11位手机号码");
        return false;
    }
    $("#vice_form").submit();
}


function vice_update(id){
    $("#update_name").val($("#tr"+id+" td")[0].innerHTML);
    $("#update_phone").val($("#tr"+id+" td")[1].innerHTML);
    $("#update_connect").val($("#tr"+id+" td")[2].innerHTML);
    $("#update_address").val($("#tr"+id+" td")[3].innerHTML);
    $("#update_id").val(id);
}

function update_form(){
    var name=$('#update_name').val();
    var phone=$('#update_phone').val();
    if (name==""||name.length==0){
        tishi_alert("请输入代理人姓名");
        return false;
    }
    if (phone==""||phone.length==0||phone.length<11){
        tishi_alert("请输入11位手机号码");
        return false;
    }
    $("#update_vice").submit();
}