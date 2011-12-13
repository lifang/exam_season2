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


//试卷编辑TAB
$(function() {
    $('.q_tab_ul li').bind('click',function(){
        $(this).addClass('hover').siblings().removeClass('hover');
        var index = $('.q_tab_ul li').index(this);
        $('div.q_tab_div > div').eq(index).show().siblings().hide();
    });
})
 
//试卷编辑小题，点击出现详细内容，关闭编辑表单
$(function(){
    $(".q_l_text").bind("click",function(){
        var $answer = $(this).next(".q_l_answer");
        if(check_edit()){
            if(confirm("你当前处于编辑状态，如果你取消编辑，所有未保存的内容将全部丢失，你要取消编辑么？")){
                $("#post_question_loader").append($('#post_question_div'));
            }else{
                return false;
            }
        }
        if($answer.is(":visible")){
            $answer.hide();
        }
        else{
            $answer.show();
        }
    })
})

//判断用户在问题编辑页面是否处于编辑状态
function check_edit(){
    return $("#post_question_loader>#post_question_div").length == 0;
}

//用户列表search
$(function(){
    $('.user_search input').focus(function(){
        var thisVal = $(this).val();
        if(thisVal == this.defaultValue){
            $(this).val('');
        }
    })
    $('.user_search input').blur(function(){
        var thisVal = $(this).val();
        if(thisVal == ''){
            $(this).val(this.defaultValue);
        }
    })
})

/*试卷信息，添加小题，左右滑动--*/
$(function(){
    var page = 1;
    var i = 14;
    $('div.next').click(function(){
        //alert(0)
        var $parent = $(this).parents('div.info_Box');
        var $pic_show = $parent.find('.info_ul')
        var $smallImg = $parent.find('.info_show');
        var small_width = $smallImg.width();
        var len = $pic_show.find('li').length;
        var page_count = Math.ceil(len/i);

        if(!$pic_show.is(':animated')){

            if(page == page_count){
                $pic_show.animate({
                    left:'0px'
                },'slow');
                page = 1;
            }else{
                $pic_show.animate({
                    left:'-='+small_width
                },'slow');
                page++;
            }
        }
    })

    $('div.prev').click(function(){
        //alert(0)
        var $parent = $(this).parents('div.info_Box');
        var $pic_show = $parent.find('.info_ul')
        var $smallImg = $parent.find('.info_show');
        var small_width = $smallImg.width();
        var len = $pic_show.find('li').length;
        var page_count = Math.ceil(len/i);

        if(!$pic_show.is(':animated')){

            if(page == 1){
                $pic_show.animate({
                    left:'-='+small_width*(page_count-1)
                },'slow');
                page = page_count;
            }else{
                $pic_show.animate({
                    left:'+='+small_width
                },'slow');
                page--;
            }
        }
    })

})

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
    $('.tishi_tab').stop(null,true);
    generate_flash_div(".tishi_tab");
    $('.tishi_tab').fadeOut("slow",function(){
        $(this).remove();
    });
}

//创建元素
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
    }
    else {
        ele.value = "";
    }
    return ele;
}

//弹出错误提示框
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

//关闭弹出框
function pop_window_closed(tab) {
    tab.parentNode.parentNode.style.display = "none";
}

//用户表格
$(function(){
    $(".user_tb tbody tr:even").css("background","#f2f2f2");
    $(".tr_bg").css("background","#333");

})

/*用户消费记录切换-----*/
$(function() {
    $('.user_tab_ul li').bind('click',function(){
        $(this).addClass('hover').siblings().removeClass('hover');
        var index = $('.user_tab_ul li').index(this);
        $('div.user_tab_box > div').eq(index).show().siblings().hide();
    });
})

function change_tab(item) {
    $(item).addClass('hover').siblings().removeClass('hover');
    var index = $('.user_tab_ul li').index(item);
    $('div.user_tab_box > div').eq(index).show().siblings().hide();
}

