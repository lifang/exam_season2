function search_similarity(category_id) {
    var type_value = $("#category_type").attr("value");
    if (type_value == "-1") {
        window.location.href = "similarities?category=" + category_id;
    } else {
        window.location.href = "similarities?category="+ category_id +"&category_type=" + type_value;
    }
}