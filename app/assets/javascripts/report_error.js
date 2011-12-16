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




function get_others(question_id){
    $.ajax({
        async:true,
        data:{
            question_id :question_id
        },
        dataType:'script',
        url:"/report_errors/other_users",
        type:'get'
    });
    return false;   
}
