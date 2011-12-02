//选择收费，免费和单独收费
function redirect_to(category_id) {
    var option_value = $("select option:selected").attr("value");
    if (option_value == "-1") {
        window.location.href = "simulations?category=" + category_id;
    } else {
        window.location.href = "simulations?category="+ category_id +"&category_type=" + option_value;
    }
}


$(function(){
    $(".t_btn").click(function(){
        if (parseInt($(":checked").val())==2){
            var fee=$(":text:last").val();
            if (isNaN(parseInt(fee))) {
                tishi_alert("请输入数值");
                return false;
            }
        }
        $("form").submit();
    })
   
})


//验证邮箱 来源于："/categories" 添加管理员
function valid_email(exam_id){
    alert($("#email_"+84).val());
    var emailReg = new RegExp(/^\w+([-+.])*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/);
    var this_email = $("#email_"+exam_id).val().replace(/ /g , "");
    if (this_email.length ==0 || !emailReg.test(this_email)){
        tishi_alert("请输入有效邮箱!");
        return false;
    }
    $.post( "/simulations/add_rater" ,
    {
       email : this_mail
    },function(data,textStauts){
        $("#yuejuan_div_"+exam_id);
    })
}

