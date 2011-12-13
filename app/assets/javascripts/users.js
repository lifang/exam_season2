function search_user_form() {
    if ($("#search_text").val() == "昵称或E-mail") {
        tishi_alert("请输入查询条件。");
        return false;
    }
    return true;
}

function show_notice_div(user_id) {
    generate_flash_div(".send_message_tab");
    $(".send_message_tab").css("display","block");
    $("#user_id").attr("value", user_id);
    $(".send_message_tab textarea").html("");
}

function user_notice_form() {
    if (checkspace($("#description").val()) || $("#description").val().length > 250) {
        tishi_alert("请输入消息内容，且内容的长度不能超过250个字符。");
        return false;
    }
    return true;
}