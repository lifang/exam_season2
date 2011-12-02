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


//鼠标点击阅卷，弹出层
$(function(){
    var doc_height = $(document).height();
    //var doc_width = $(document).width();
    var win_height = $(window).height();
    var win_width = $(window).width();
    var s_layer_height = $('.yuejuan_div').height();
    var s_layer_width = $('.yuejuan_div').width();
	
    $(".yuejuan_btn").bind("click",function(){
        $(".yuejuan_div").css("display","block");
        $('.yuejuan_div').css('top',(win_height-s_layer_height)/2)
        $('.yuejuan_div').css('left',(win_width-s_layer_width)/2);
    })
	
    $(".yj_x").bind("click",function(){
        $(".yuejuan_div").css("display","none");
    })
})

//试卷编辑TAB
$(function() {
    $('.q_tab_ul li').bind('click',function(){
        $(this).addClass('hover').siblings().removeClass('hover');
        var index = $('.q_tab_ul li').index(this);
        $('div.q_tab_div > div').eq(index).show().siblings().hide();
    });
})
 
//试卷编辑小题，点击出现编辑内容
$(function(){
    $(".q_l_text").bind("click",function(){
        var $answer = $(this).next(".q_l_answer")
        if($answer.is(":visible")){
            $answer.hide();
        }else{
            $answer.show();
        }
    })
})

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

//用户表格
$(function(){
    $(".user_tb tbody tr:even").css("background","#f2f2f2");
    $(".user_tb tbody tr:first").css("background","#333");
	
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
    $('.tishi_tab').animate({"":""},3000).fadeOut("slow",function(){
        $(this).remove();
    });
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

function pop_window_closed(tab) {
    tab.parentNode.parentNode.style.display = "none";
}
