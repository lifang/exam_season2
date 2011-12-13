function modify_status(id,status){
    var error_type=$("#error_type").val();
    var all_error=$("#all_error").val();
    error_type="";
    $("#error_type").val(error_type);
    $("#status").val(status);
    $("#error").submit();
}

//选择收费，免费和单独收费
function redirect_to(category_id) {
    alert(category_id);
    var option_value = $("select option:selected").attr("value");
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


