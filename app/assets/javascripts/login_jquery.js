$(function(){
    $("#login_exam").click(function(){
        var name=$("#user_name").val().length;
        var password=$("#user_password").val().lenth;
        if(name<=0||name>50||password<=0||password>20){
            alert("用户名或密码不能为空");
        }else{
            $("form").submit();
        }
    })
})   //验证登陆，符合格式要求则提交表单

function generate_flash_div(style) {
    var scolltop = document.body.scrollTop|document.documentElement.scrollTop;
    var win_height = document.documentElement.clientHeight;//jQuery(document).height();
    var win_width = jQuery(window).width();
    var z_layer_height = jQuery(style).height();
    var z_layer_width = jQuery(style).width();
    jQuery(style).css('top',(win_height-z_layer_height)/2 + scolltop);
    jQuery(style).css('left',(win_width-z_layer_width)/2);
    jQuery(style).css('display','block');
}

