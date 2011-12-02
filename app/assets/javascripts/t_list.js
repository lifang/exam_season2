// JavaScript Document
//鼠标经过显示列表
$(function(){
    $(".t_list").bind("mouseover",function(){
        $(this).addClass("tl_hover").siblings().removeClass("tl_hover");
        $(this).find(".text_btn").show();
    })
    $(".t_list").bind("mouseout",function(){
        $(this).removeClass("tl_hover");
        $(this).find(".text_btn").hide();
    })
})


////鼠标点击阅卷，弹出层
function show_rater(id){
    var win_height = $(window).height();
    var win_width = $(window).width();
    var s_layer_height = $('#yuejuan_div_'+id).height();
    var s_layer_width = $('#yuejuan_div_'+id).width();
    $("#yuejuan_btn_"+id).bind("click",function(){
        $(".yuejuan_div").css("display","none");
        $('#yuejuan_div_'+id).css("display","block");
        $('#yuejuan_div_'+id).css('top',(win_height-s_layer_height)/2);
        $('#yuejuan_div_'+id).css('left',(win_width-s_layer_width)/2);
    })
    $("#yj_x_"+id).bind("click",function(){
        $('#yuejuan_div_'+id).css("display","none");
    })
}

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
    var div = create_element("div",null,"flash_notice","tishi_tab",null,null);
    var p = create_element("p","","","","innerHTML");
    p.innerHTML = str;
    div.appendChild(p);
    var body = jQuery("body");
    body.append(div);
    show_flash_div();

}

//判断是否空或者全部是空格
function checkspace(checkstr){
    var str = '';
    for(var i = 0; i < checkstr.length; i++) {
        str = str + ' ';
    }
    if (str == checkstr){
        return true;
    } else{
        return false;
    }
}
