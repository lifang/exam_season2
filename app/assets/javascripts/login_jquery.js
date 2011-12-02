$(function(){
    $("#login_exam").click(function(){
        var name=$("#user_name").val().length;
        var password=$("#user_password").val().length;
        if(name<=0||name>50||password<=0||password>20){
            tishi_alert("用户名或密码不能为空");
        }else{
            $("form").submit();
        }
    })
})   //验证登陆，符合格式要求则提交表单


//选择收费，免费和单独收费
function redirect_to(category_id) {
    var option_value = $("select option:selected").attr("value");
    if (option_value == "-1") {
        window.location.href = "simulations?category=" + category_id;
    } else {
        window.location.href = "simulations?category="+ category_id +"&category_type=" + option_value;
    }
}

//无法固定div的位置
//$(function(){
//    var win_height = $(window).height();
//    var win_width = $(window).width();
//    $(".yuejuan_btn").bind("click",function(){
//        var s_layer_height = $('.yuejuan_div').height();
//        var s_layer_width = $('.yuejuan_div').width();
//        $(".yuejuan_div").css("display","none");
//        $('.yuejuan_div')[$(".yuejuan_btn").index(this)].style.display="block";
////        $('.yuejuan_div')[$(".yuejuan_btn").index(this)].css('top',(win_height-s_layer_height)/2);
//        $('.yuejuan_div')[$(".yuejuan_btn").index(this)].style.marginLeft=(win_width-s_layer_width)/2-100;
//    })
//    $(".yj_x").bind("click",function(){
//        $('.yuejuan_div')[$(".yj_x").index(this)].style.display="none";
//    })
//})
