function search_user_form() {
    if ($("#search_text").val() == "昵称或E-mail") {
        tishi_alert("请输入查询条件。");
        return false;
    }
    if (checkspace($("#search_text").val())) {
        tishi_alert("请输入查询条件。");
        return false;
    }
}