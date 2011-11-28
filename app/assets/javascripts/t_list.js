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