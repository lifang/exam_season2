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

