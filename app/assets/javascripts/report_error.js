function modify_status(id,status){
    var error_type=$("#error_type_"+id).val();
    var all_error=$("#all_error").val();
    if(parseInt(all_error)==getCookie("page")+1){
        error_type="";
        $("#error_type_"+id).val(error_type);
    }
    $("#status_"+id).val(status);
    $("#error_"+id).submit();
}

//选择收费，免费和单独收费
function redirect_to(category_id) {alert(category_id);
    var option_value = $("select option:selected").attr("value");
    if (option_value == "-1") {
        window.location.href = "/report_errors?category=" + category_id;
    } else {
        window.location.href = "/report_errors?category="+ category_id +"&error_type=" + option_value;
    }
}
