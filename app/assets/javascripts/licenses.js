function search_license_form() {
    if (checkspace($("#code").val())) {
        tishi_alert("请输入授权码。");
        return false;
    }
    return true;
}


$(function(){
    code_details(1);
})

function code_details(status){
    if (status==0){
        var detail=$("#search_detail").val();
        if (detail==""||detail.length==0){
            tishi_alert("请输入代理人姓名");
            return false;
        }
    }
    $.ajax({
        async:true,
        data:{
            info :detail
        },
        dataType:'script',
        url:"/licenses/code_details",
        type:'get'
    });
    return false;
  
}