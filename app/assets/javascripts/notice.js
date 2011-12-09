function new_notice_form() {
    if ($("#started_at").val() == "") {
        tishi_alert("请输入消息有效期的开始日期。");
        return false;
    }
    if ($("#ended_at").val() == "") {
        tishi_alert("请输入消息有效期的截止日期。");
        return false;
    }
    if ($("#started_at").val() >= $("#ended_at").val()) {
        tishi_alert("消息有效期的截止日期应该要大于开始日期。");
        return false;
    }
    if (checkspace($("#description").val()) || $("#description").val().length > 200) {
        tishi_alert("请输入消息内容，且内容的长度不能超过250个字符。");
        return false;
    }
    return true;
}

function show_notice(notice_id, item) {
    generate_flash_div(".see_message");
    var notice = $("#tr_" + notice_id + " td");
    var pop_window = $(".see_message span");
    for (var i=0; i<pop_window.length; i++) {
        pop_window[i].innerHTML = notice[i].innerHTML;
    }
    $(".see_mess_xx").html($(item).html());
}