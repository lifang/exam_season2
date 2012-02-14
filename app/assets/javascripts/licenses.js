function search_license_form() {
    if (checkspace($("#code").val())) {
        tishi_alert("请输入授权码。");
        return false;
    }
    return true;
}

function show_gen_code() {    
    show_div("#add_codeTab");
}

function search_vicegerent() {
    $('#v_list_div').css('display', 'none');
    $('#vicegerent').attr("value", "");
    $('#v_list_div').html("");
    $.ajax({
        type: "POST",
        url: "/licenses/search_vicegerent",
        dataType: "script",
        data : {
            "vicegerent" : $("#vicegerent").val()
        }
    });    
}

function gen_license_form() {
    if (isNaN($("#num").val()) || $("#num").val() <= 0) {
        tishi_alert("生成数量请输入大于0的数字。");
        return false;
    }
    if (checkspace($("#ended_at").val())) {
        tishi_alert("请输入授权码有效期。");
        return false;
    }
    if (checkspace($("#v_id").val())) {
        tishi_alert("请指定代理人。");
        return false;
    }
    $("#add_codeTab").css("display", "none");
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