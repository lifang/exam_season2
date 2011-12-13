function new_word_form() {
    if (checkspace($("#name").val()) || $("#name").val().length > 250) {
        tishi_alert("请输入单词条目，且内容的长度不能超过250个字符。");
        return false;
    }
    if (checkspace($("#phonetic").val()) || $("#phonetic").val().length > 250) {
        tishi_alert("请输入单词音标，且内容的长度不能超过250个字符。");
        return false;
    }
    if (checkspace($("#enunciate_url").val())) {
        tishi_alert("请选择单词发音的音频文件。");
        return false;
    }
    if (checkspace($("#en_mean").val()) || $("#en_mean").val().length > 250) {
        tishi_alert("请输入单词释义，且内容的长度不能超过250个字符。");
        return false;
    }
    if (checkspace($("#ch_mean").val()) || $("#ch_mean").val().length > 250) {
        tishi_alert("请输入单词翻译，且内容的长度不能超过250个字符。");
        return false;
    }
    if (checkspace($("#sentence").val()) || $("#sentence").val().length > 250) {
        tishi_alert("请输入单词例句，且内容的长度不能超过250个字符。");
        return false;
    }
    return true;
}

//列出相似的词
function list_similar() {
    if (checkspace($("#search_text").val())) {
        tishi_alert("请输入查询的条件。");
        return false;
    }
    $.ajax({
        async:true,
        complete:function(request){
            $("#similar_list").css("display", "");
            $("#similar_list").html(request.responseText);
        },
        data:{
            search_text :$("#search_text").val()
        },
        dataType:'script',
        url:"/words/list_similar",
        type:'post'
    });
    return false;
}

//选择选中的单词
function choose_word(id, name) {
    var word_ids = $("#re_word").val();
    if (word_ids.split(",").indexOf("" + id) == -1) {
        var new_ids = word_ids != "" ? (word_ids + "," + id) : id;
        $("#re_word").attr("value", new_ids);
        var word = create_element("span", null, "similar_" + id, "gl_add_span", null, "innerHTML");
        word.innerHTML = name + "<a href='javascript:void(0);' onclick='javascript:remove_similar(" + id + ");'>[删除]</a>";
        $("#chose_list").append(word);
    }
}

//删除选择的单词
function remove_similar(id) {
    var word_ids = $("#re_word").val();
    $("#similar_" + id).remove();
    $("#re_word").attr("value", word_ids.replace(","+id, "").replace(id+",", "").replace(id, ""));
}