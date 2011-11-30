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

//提示框弹出层
function show_flash_div() {
    (function(){
        generate_flash_div(".tishi_tab");
        setTimeout(function(){
            jQuery('.tishi_tab').fadeTo("slow",0);
        }, 2500);
        setTimeout(function(){
            jQuery('.tishi_tab').css('display','none');
        }, 3000);
    })(jQuery)
}


function create_element(element, name, id, class_name, type, ele_flag) {
    var ele = document.createElement("" + element);
    if (name != null)
        ele.name = name;
    if (id != null)
        ele.id = id;
    if (class_name != null)
        ele.className = class_name;
    if (type != null)
        ele.type = type;
    if (ele_flag == "innerHTML") {
        ele.innerHTML = "";
    } else {
        ele.value = "";
    }
    return ele;
}


function tishi_alert(str){
    var div=create_element("div",null,"flash_notice","tishi_tab",null,null);
    var p=create_element("p","","","","innerHTML");
    p.innerHTML=str;
    div.appendChild(p);
    var body=jQuery("body")
    body.append(div);
    show_flash_div();
}
