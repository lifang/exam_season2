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
    var scolltop = document.body.scrollTop|document.documentElement.scrollTop;
    var win_height = document.documentElement.clientHeight;//jQuery(document).height();
    var win_width = $(window).width();
    var z_layer_height = $(".add_exPaper").height();
    var z_layer_width = $(".add_exPaper").width();
    $(".add_exPaper").css('top',((win_height-z_layer_height)/2 + scolltop));
    $(".add_exPaper").css('left',(win_width-z_layer_width)/2);
    $(".add_exPaper").css('display','block');
}
//检查试卷是否被选中
function check_p_sel() {
    var eles = $("input:checked");
    if (eles.length == 0) {
        tishi_alert("请选中作为当前真题的试卷。");
        return false;
    }
    var paper_ids = "";
    for (var i=0; i<eles.length; i++) {
        paper_ids += eles[i].value;
        if (i < (eles.length - 1)) {
            paper_ids += ",";
        }
    }
    alert($("#paper_ids").attr("value"));
    $("#paper_ids").value(paper_ids);
    alert($("#paper_ids").attr("value"));
    
}

//, :html => {:onsubmit => "return search()"}
//function search() {
//    $.ajax({
//        async:true,
//        complete:function(request){
//            $
//            ('#paper_list').html(request.responseText);
//        },
//        data:$.param($
//            (this).serializeArray()),
//        dataType:'script',
//        url:"/similarities/get_papers?category=<%= params[:category] %>"
//    });
//    return false;
//}

//$.ajax({async:true, complete:function(request){$
//            ('#paper_list').html(request.responseText);}, data:$.param($
//          (this).serializeArray()), dataType:'script', url:item.toString()});
//return false;