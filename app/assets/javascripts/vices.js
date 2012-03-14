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

function render_city(privin){
    $.ajax({
        async:true,
        dataType:'script',
        url:"/adverts/list_city",
        data:{
            region_id : privin
        },
        type:'post'
    });
    return false;
}

function advert_update(id,re_id,ad_id){
    $("#region option:selected").attr("selected",false);
    $("#region #"+id).attr("selected",true);
    $("#text_content").html($("#advert_"+ad_id).val());
    $("#tishi_div").css("display","none");
    $("#region").trigger("onchange");
    $("#advert_id").val(ad_id);
    setTimeout(function(){
        $("#city #"+re_id).attr("selected",true);
    },1000);
}

function advert_check(){
    if($("#city option:selected").length==0){
        alert("选择合适的省市");
        return false;
    }
    if ($("#text_content").val()==""||$("#text_content").val().length==0){
        alert("请输入广告内容");
        return false;
    }
    $('#advert_form').submit();

}

function advert_create(){
    $('#tishi_div').css('display','');
    $("#text_content").html("");
    $('#advert_id').val("");
}

function city_search(privin){
    $.ajax({
        async:true,
        dataType:'script',
        url:"/adverts/search_city",
        data:{
            region_id : privin
        },
        type:'post'
    });
    return false;
}