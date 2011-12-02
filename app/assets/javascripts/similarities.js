//根据免费、收费筛选
function search_similarity(category_id) {
    var type_value = $("#category_type").attr("value");
    if (type_value == "-1") {
        window.location.href = "similarities?category=" + category_id;
    } else {
        window.location.href = "similarities?category="+ category_id +"&category_type=" + type_value;
    }
}

//新建考试验证
function new_similarity_form() {
    if (checkspace($("#title").attr("value"))) {
        tishi_alert("真题名称不能为空。");
        return false;
    }
    if ($("#title").attr("value").length > 50) {
        tishi_alert("真题的名称长度不能超过50个字。");
        return false;
    }
    if (checkspace($("#paper_id").attr("value"))) {
        tishi_alert("请选择作为当前真题的试卷。");
        return false;
    }
    return true;
}

//添加试卷
function add_paper() {
    
}