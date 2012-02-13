function search_license_form() {
    if (checkspace($("#code").val())) {
        tishi_alert("请输入授权码。");
        return false;
    }
    return true;
}