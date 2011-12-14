function modify_status(status){
    $("#status").val(status);
    $("#error_form").submit();
}

//选择错误类型
function redirect(category_id) {
    var option_value = $("select option:selected").val();
    if (option_value == "-1") {
        window.location.href = "/report_errors?category=" + category_id;
    } else {
        window.location.href = "/report_errors?category="+ category_id +"&error_type=" + option_value;
    }
}


function show_div(id){
    var scolltop = document.body.scrollTop|document.documentElement.scrollTop;
    var win_height = document.documentElement.clientHeight;//jQuery(document).height();
    var win_width = jQuery(window).width();
    var z_layer_height = jQuery("#"+id).height();
    var z_layer_width = jQuery("#"+id).width();
    jQuery("#"+id).css('top',(win_height-z_layer_height)/2 + scolltop);
    jQuery("#"+id).css('left',(win_width-z_layer_width)/2);
    jQuery("#"+id).css('display','block');
}

function get_others(question_id){
    $.ajax({
        async:true,
        success:function(request){
        //            $("#spinner_add_"+exam_id).css("display","none");
        },
        data:{
            question_id :question_id
        },
        dataType:'script',
        url:"/report_errors/other_users",
        type:'get'
    });
    return false;   
}
