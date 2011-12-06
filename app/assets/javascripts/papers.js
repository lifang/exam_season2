
//试卷筛选   注意其中  1 = Paper::CHECKED[:YES]    0 = Paper::CHECKED[:NO]    2 = Paper::CHECKED[:ALL]
function select_checked(dom,category_id){
    if(dom.options[dom.selectedIndex].value=="2"){
        window.location.href="/papers?category="+category_id;
        return false;
    }
    if(dom.options[dom.selectedIndex].value=="0"){
        window.location.href="/papers?category="+category_id+"&checked=0";
        return false;
    }
    if(dom.options[dom.selectedIndex].value=="1"){
        window.location.href="/papers?category="+category_id+"&checked=1";
        return false;
    }
}

  
//编辑、新建部分，控制DIV居中
jQuery(function(){
    if (jQuery('.part_info') != null) {
        var win_height = jQuery(window).height();
        var win_width = jQuery(window).width();
        var z_layer_height = jQuery('.part_info').height();
        var z_layer_width = jQuery('.part_info').width();
        if (win_height-z_layer_height > 0) {
            jQuery('.part_info').css('top',(win_height-z_layer_height)/2);
        } else {
            jQuery('.part_info').css('top',0);
        }
        jQuery('.part_info').css('left',(win_width-z_layer_width)/2);
        return false;
    }
})


//停止事件冒泡
function stop_bunble(){
    if(event.stopPropagation){
        event.stopPropagation();
    }else
    if(window.event){
        window.event.cancelBubble = true;
    };
}


//载入编辑模块div
function load_edit_block(block_xpath,block_name,block_start_time,block_time){
    $("#block_xpath").val(block_xpath);
    $("#block_name").val(block_name);
    if(block_start_time!="0" && block_start_time!=""){
        $("#block_start_time_radio2").attr("checked","true").val(block_start_time);
        $("#block_start_time").removeAttr("disabled").val(block_start_time);
    }else{
        $("#block_start_time_radio1").attr("checked","true").val('');
        $("#block_start_time").attr("disabled","disabled").val('');
    }
    if(block_time!="0" && block_time!=""){
        $("#block_time_radio2").attr("checked","true").val(block_time);
        $("#block_time").removeAttr("disabled").val(block_time);
    }else{
        $("#block_time_radio1").attr("checked","true").val('');
        $("#block_time").attr("disabled","disabled").val('');
    }

    jQuery('.part_info').css('display','block');
    jQuery('.zhezhao').css('display','block');
    $("#block_name").focus().select();
}


//关闭新建、编辑模块DIV
function close_part_info(){
    jQuery('.part_info').css('display','none');
    jQuery('.zhezhao').css('display','none');
    return false;
}

//验证 模块表单 ，名称不能为空
function validate_form_block_baseinfo(){
    if(checkspace($('#block_name').val())){
        tishi_alert("请输入名称");
        return false;
    }
}
  