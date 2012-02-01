//试卷筛选   注意其中  1 = Paper::CHECKED[:YES]    0 = Paper::CHECKED[:NO]    2 = Paper::CHECKED[:ALL]
function select_checked(dom, category_id) {
    if (dom.options[dom.selectedIndex].value == "2") {
        window.location.href = "/papers?category=" + category_id;
        return false;
    }
    if (dom.options[dom.selectedIndex].value == "0") {
        window.location.href = "/papers?category=" + category_id + "&checked=0";
        return false;
    }
    if (dom.options[dom.selectedIndex].value == "1") {
        window.location.href = "/papers?category=" + category_id + "&checked=1";
        return false;
    }
}

//创建试卷第一步验证
function paper_info() {
    var title = $("#title").val();
    var time = $("#time").val();
    if (title == "" || title.length == 0 || title.length > 50) {
        tishi_alert("试卷名称不能为空，长度不超过50个字符")
        return false;
    } else {
        if (isNaN(parseInt(time)) || parseInt(time) <= 0) {
            tishi_alert("请输入正确的试卷长度")
            return false;
        }
    }
}

// 设置DIV根据浏览器宽度，居中
function set_center(jq_params) {
    if (jQuery(jq_params) != null) {
        var win_height = jQuery(window).height();
        var win_width = jQuery(window).width();
        var z_layer_height = jQuery(jq_params).height();
        var z_layer_width = jQuery(jq_params).width();
        if (win_height - z_layer_height > 0) {
            jQuery(jq_params).css('top', (win_height - z_layer_height) / 2);
        } else {
            jQuery(jq_params).css('top', 0);
        }
        jQuery(jq_params).css('left', (win_width - z_layer_width) / 2);
        return false;
    }
}

//小题的jquery效果 简单显示 => 详细显示
$(function() {
    $(".q_l_text").bind("click", function() {
        if (check_edit()) {
            var form_position = $("#post_question_div").parent().attr("id").replace('question_list_', '').replace('q_l_answer_', '').split('_');
            if (confirm("系统检测到您正在第 " + form_position[0] + " 部分，第 " + form_position[1] + " 大题处编辑小题。\n如果你取消编辑，所有未保存的内容将全部丢失。\n您确定要取消么？")) {
                $("#post_question_loader").append($('#post_question_div'));
            } else {
                return false;
            }
        }
        $(".q_l_text:hidden").show();
        $(".q_l_answer").hide();
        var $answer = $(this).next(".q_l_answer");
        $(this).slideUp(400, function() {
            $answer.slideDown(800)
        });
    })
})

//小题的jquery效果  详细显示 => 简单显示
$(function() {
    $(".q_l_answer[id!=post_question_div]").bind("dblclick", function() {
        $(this).slideUp(1000, function() {
            $(this).siblings(".q_l_text").slideDown(400);
        });
    })
})


//判断用户在问题编辑页面是否处于编辑状态
function check_edit() {
    return $("#post_question_loader>#post_question_div").length == 0;
}


//停止事件冒泡
function stop_bunble() {
    $(function() {  
        var e = getEvent();
        if (window.event) {
            //e.returnValue=false;
            e.cancelBubble=true;
        }else{
            //e.preventDefault();
            e.stopPropagation();
        }
    }
    );
}

//在火狐和Ie下取event事件
function getEvent(){
    if(window.event)    {
        return window.event;
    }
    func=getEvent.caller;
    while(func!=null){
        var arg0=func.arguments[0];
        if(arg0){
            if((arg0.constructor==Event || arg0.constructor ==MouseEvent
                || arg0.constructor==KeyboardEvent)
            ||(typeof(arg0)=="object" && arg0.preventDefault
                && arg0.stopPropagation)){
                return arg0;
            }
        }
        func=func.caller;
    }
    return null;
}

//载入编辑模块div
function load_edit_block(block_xpath, block_name, block_description, block_start_time, block_time) {
    block_name=unescape(block_name);
    $("#block_xpath").val(block_xpath);
    $("#block_name").val(block_name);
    $("#block_description").val(block_description);
    if (block_start_time != "0:0" && block_start_time != "") {
        var block_start_time_arr=block_start_time.split(":");
        var result_start_time=0;
        result_start_time+=parseInt(block_start_time_arr[0])*60;
        result_start_time+=parseInt(block_start_time_arr[1]);
        $("#block_start_time_radio2").attr("checked", "true").val(result_start_time);
        $("#block_start_time").removeAttr("disabled").val(result_start_time);
    } else {
        $("#block_start_time_radio1").attr("checked", "true").val('0');
        $("#block_start_time").attr("disabled", "disabled").val('0');
    }

    if (block_time != "0" && block_time != "") {
        $("#block_time_radio2").attr("checked", "true").val(block_time);
        $("#block_time").removeAttr("disabled").val(block_time);
    }
    else {
        $("#block_time_radio1").attr("checked", "true").val('0');
        $("#block_time").attr("disabled", "disabled").val('0');
    }

    jQuery('.part_info').css('display', 'block');
    jQuery('.zhezhao').css('display', 'block');
    $("#block_name").focus();
}


//关闭新建、编辑模块DIV
function close_part_info() {
    jQuery('.part_info').css('display', 'none');
    jQuery('.zhezhao').css('display', 'none');
    return false;
}

//验证 模块表单 ，名称不能为空
function validate_post_block() {
    if (checkspace($('#block_name').val())) {
        tishi_alert("请输入名称");
        return false;
    }
}

//ajax载入小题类型，拼凑完整表单(create_problem 表单)
function select_question_type(question_type, block_index) {
    $('#create_problem_attrs_module_' + block_index).load('/papers/select_question_type',
    {
        "question_type" : question_type,
        "block_index" : block_index
    },
    function() {
        add_event_on_create_problem_form(question_type, block_index);
    });
}

//ajax回调函数，载入模版后，给其中的元素绑定事件 (create_problem 表单)
function add_event_on_create_problem_form(question_type, block_index) {
    var text = ".text_" + question_type + "_block_" + block_index;
    var attrs = ".question_attrs_block_" + block_index;   //表单
    var answer = ".question_answer_block_" + block_index;   //表单
    if (question_type == 2) {
        var radio = ".radio_" + question_type + "_block_" + block_index;
        generate_judge(answer, radio);
    } else if (question_type == 3 || question_type == 5) {
        generate_fill(answer, text);
    }
}


//判断题 整理组织答案
function generate_judge(answer, radio) {
    $(radio).bind("click", function() {
        $(answer).val($(this).val());
    })
}

//填空题、简答题 整理组织答案
function generate_fill(answer, text) {
    $(text).bind("change", function() {
        $(answer).val($(this).val());
    })
}

//提交create_problem表单前组织单选题、多选题答案
function submit_create_problem_form(block_index) {
    var correct_type = parseInt($("#create_problem_correct_type_" + block_index).val());
    if (correct_type == 0) {
        create_problem_single_choose(block_index);
    }
    if (correct_type == 1) {
        create_problem_multi_choose(block_index);
    }

    //验证题面不能为空
    if(checkspace($("#problem_title_block_"+block_index).val())){
        tishi_alert("未填写题目内容");
        return false;
    }

    //验证答案不能为空
    if(checkspace($(".question_answer_block_"+block_index).val())){
        tishi_alert("未设置答案");
        return false;
    }

    //建题面中题目，匹配标记数量是否正确
    var question_type = parseInt($(".question_type_block_" + block_index).val());
    if (question_type == 1) {
        var mark = "((sign))";
        var mark_sum = $('#problem_title_block_' + block_index).val().split(mark).length-1;
        if (mark_sum == 0) {
            tishi_alert("请在题目内容中插入1个标记");
            return false;
        }else{
            if(mark_sum>1){
                tishi_alert("提示，你插入了"+mark_sum+"标记");
            }
        }
    }
}

//单选题 整理组织单选题选项和答案
function create_problem_single_choose(block_index) {
    $(".radio_0_block_" + block_index).each(function() {
        if (this.checked) {
            $(".question_answer_block_" + block_index).val($(this).next(".text_0_block_" + block_index).val());
        }
    })
    var attrs = [];
    $(".text_0_block_" + block_index).each(function() {
        if ($(this).val() != "") {
            attrs.push($(this).val());
        }
    })
    $(".question_attrs_block_" + block_index).val(attrs.join(";-;"));
}

//多选题 整理组织多选题选项和答案
function create_problem_multi_choose(block_index) {
    var answer_arr = [];
    $(".checkbox_1_block_" + block_index).each(function() {
        if (this.checked && $(this).next(".text_1_block_" + block_index).val() != "") {
            answer_arr.push($(this).next(".text_1_block_" + block_index).val());
        }
    })
    $(".question_answer_block_" + block_index).val(answer_arr.join(";|;"));
    var attrs = [];
    $(".text_1_block_" + block_index).each(function() {
        if ($(this).val() != "") {
            attrs.push($(this).val());
        }
    })
    $(".question_attrs_block_" + block_index).val(attrs.join(";-;"));
}

//ajax 编辑题目说明
function ajax_edit_problem_description(paper_id, block_index, problem_index, description) {
    $.ajax({
        type: "POST",
        url: "/papers/" + paper_id + "/ajax_edit_problem_description.json",
        dataType: "json",
        data : {
            "paper_id" : paper_id,
            "block_index" : block_index,
            "problem_index" : problem_index,
            "description" : description
        },
        beforeSend: function() {
            $("#show_problem_description_" + block_index + "_" + problem_index).html($("#ajax_loader").html());
        },
        success : function(data) {
            $("#show_problem_description_" + block_index + "_" + problem_index).html(data.description);
        }
    });
}

//ajax 编辑题目内容
function ajax_edit_problem_title(paper_id, block_index, problem_index, title) {
    $.ajax({
        type: "POST",
        url: "/papers/" + paper_id + "/ajax_edit_problem_title.json",
        dataType: "json",
        data : {
            "paper_id" : paper_id,
            "block_index" : block_index,
            "problem_index" : problem_index,
            "title" : title
        },
        beforeSend: function() {
            $("#show_problem_title_" + block_index + "_" + problem_index).html($("#ajax_loader").html());
        },
        success : function(data) {
            $("#show_problem_title_" + block_index + "_" + problem_index).html(data.title);
        }
    });
}

//将null转化为""
function rescue_null(object) {
    if (object == null) {
        return ""
    }
    return object
}

//提醒用户，当前正在编辑小题
function notice_edit() {
    if (check_edit()) {
        var form_position = $("#post_question_div").parent().attr("id").replace('question_list_', '').replace('q_l_answer_', '').split('_');
        if (!confirm("系统检测到您正在第" + form_position[0] + "部分，第" + form_position[1] + "大题处编辑小题。\n如果你取消编辑，所有未保存的内容将全部丢失。\n您确定要取消么？")) {
            return false;
        } else {
            close_post_question_form();
            return true;
        }
    }else{
        return true;
    }
}

////ajax载入小题类型，拼凑完整表单(post_question 表单)
function select_correct_type(ele_str, question_type, block_index, problem_index, question_index, correct_type, question_answer, question_attrs, question_description, question_analysis, question_score, question_tags, question_words, question_flag, hidden_div) {
    //如果参数为null,转化为""
    if (check_edit()) {
        var form_position = $("#post_question_div").parent().attr("id").replace('question_list_', '').replace('q_l_answer_', '').split('_');
        if (!confirm("系统检测到您正在第" + form_position[0] + "部分，第" + form_position[1] + "大题处编辑小题。\n如果你取消编辑，所有未保存的内容将全部丢失。\n您确定要取消么？")) {
            return false;
        }
    }
    question_answer = rescue_null(question_answer);
    question_attrs = rescue_null(question_attrs);
    question_description = rescue_null(question_description);
    question_analysis = rescue_null(question_analysis);
    question_score = rescue_null(question_score);
    question_tags = rescue_null(question_tags);
    question_words = rescue_null(question_words);
    question_flag = rescue_null(question_flag);
    hidden_div = rescue_null(hidden_div);   //编辑小题时有值，追加小题时为空
    $('#post_question_attrs_module').load('/papers/select_correct_type',
    {
        "correct_type" : correct_type,
        "question_answer" : question_answer,
        "question_attrs" : question_attrs
    },
    function() {
        var location = question_index == "" ? ele_str + block_index + "_" + problem_index : ele_str + block_index + "_" + problem_index + "_" + question_index;
        if (hidden_div != "") {
            hidden_div.hide();
            $("#post_question_div").show();
            $(location).append($("#post_question_div"));  //载入form
        } else {
            var index = $(".insert_index_block_"+block_index+"_problem_"+problem_index+":checked").val();
            if(index==null){
                var insert_index = 0;
            }else{
                var insert_index = index;
            }
            $("#post_question_insert_index").val(insert_index);
            $(".q_l_answer").hide();
            $(".q_l_text:hidden").show();
            $("#post_question_div").show();
            if (insert_index == 0) {
                $(location).append($("#post_question_div"));
            } else {
                var insert_location = "#question_list_" + block_index + "_" + problem_index + "_" + (insert_index);
                $(insert_location).append($("#post_question_div"));
            }
        } // 显示框 和 编辑框 切换显示
        var questions_xpath = "/paper/blocks/block[" + block_index + "]/problems/problem[" + problem_index + "]/questions" //构造 questions_xpath , 作为下一个方法的变量
        fill_post_question_form(questions_xpath, question_type, question_index, question_answer, question_attrs, question_description, question_analysis, question_score, question_tags, question_words, question_flag); //初始化表单值
        add_event_on_post_question_form(correct_type);  //初始化表单事件
    });
}

//关闭编辑小题框
function close_post_question_form() {
    var this_index = ($('#post_question_div').closest(".question_list_box").children(".question_list").not("ignore").index($('#post_question_div').closest(".question_list")));
    $('#post_question_div').slideUp(1000, function() {
        if (this_index > 0) {
            $(".q_l_text:hidden").slideDown(400);
        }
        $('#post_question_loader').append($('#post_question_div'));
        $('#post_question_div').show();
    })

}

//初始化 post_question 表单 值
function fill_post_question_form(questions_xpath, question_type, question_index, question_answer, question_attrs, question_description, question_analysis, question_score, question_tags, question_words, question_flag) {
    $("#post_question_questions_xpath").val(questions_xpath);
    $("#post_question_question_index").val(question_index);
    $("#post_question_question_answer").val(question_answer);
    $("#post_question_question_attrs").val(question_attrs);
    $("#post_question_question_description").val(question_description);
    $("#post_question_question_analysis").val(question_analysis);
    $("#post_question_question_score").val(question_score);
    $("#post_question_question_tags").val(question_tags);
    $("#post_question_question_words").val(question_words);
    $("#post_question_question_flag").val(question_flag);
    $("#post_question_question_type").val(question_type);
    if (question_flag == 1) {
        $("#post_question_flag_checkbox").attr("checked", true);
    } else {
        $("#post_question_flag_checkbox").attr("checked", false);
    }
    display_tags_text('#post_question_question_tags', '#post_question_tags_div');         //显示标签
    display_words_text('#post_question_question_words', '#post_question_words_div');      //显示词汇
}

//初始化 post_question 表单 元素事件
function add_event_on_post_question_form(correct_type) {
    var text = ".text_" + correct_type + "_question";
    var attrs = "#post_question_question_attrs";   //表单
    var answer = "#post_question_question_answer";   //表单
    if (correct_type == 2) {
        var radio = ".radio_" + correct_type + "_question";
        generate_judge(answer, radio);
    } else if (correct_type == 3 || correct_type == 5) {
        generate_fill(answer, text);
    }
}

//提交post_question表单前组织单选题、多选题答案
function submit_post_question_form() {

    var correct_type = parseInt($("#post_question_correct_type").val());
    if (correct_type == 0) {
        post_question_single_choose();
    }
    if (correct_type == 1) {
        post_question_multi_choose();
    }
    //小题答案不能为空
    if(checkspace($("#post_question_question_answer").val())){
        tishi_alert("未设置答案");
        return false;
    }
    //建题面中题目，匹配标记数量是否正确
    var question_type = parseInt($("#post_question_question_type").val());
    var question_index = $("#post_question_question_index").val();
    if (question_type == 1 && question_index=="") {
        var form_position = $("#post_question_div").parent().attr("id").replace('question_list_', '').replace('q_l_answer_', '').split('_');
        //form_position[0]是block_index,form_postion[1]是problem_index
        var mark = "((sign))";
        var problem_title = $("#show_problem_title_" + form_position[0] + "_" + form_position[1]).html();
        var sign_sum = problem_title.split(mark).length - 1;
        var question_sum = $("#question_list_box_" + form_position[0] + "_" + form_position[1]).find(".question_list").not(".ignore").length;
        if ($("#post_question_question_index").val() == "") {   //如果#post_question_question_index没有值，说明是新建小题，判断小题数+1
            question_sum ++;
        }
        if (sign_sum != question_sum) {
            tishi_alert("标记数（" + sign_sum + "） 不符合 题目数（" + question_sum + "）");
        }
    }
}

//单选题 整理组织单选题选项和答案
function post_question_single_choose() {
    $("#post_question_question_answer").val("");
    $(".radio_0_question").each(function() {
        if (this.checked) {
            $("#post_question_question_answer").val($(this).next(".text_0_question").val());
        }
    })
    var attrs = [];
    $(".text_0_question").each(function() {
        if ($(this).val() != "") {
            attrs.push($(this).val());
        }
    })
    $("#post_question_question_attrs").val(attrs.join(";-;"));
}

//多选题 整理组织单选题选项和答案
function post_question_multi_choose() {
    var answer_arr = [];
    $(".checkbox_1_question").each(function() {
        if (this.checked && $(this).next(".text_1_question").val() != "") {
            answer_arr.push($(this).next(".text_1_question").val());
        }
    })
    $("#post_question_question_answer").val(answer_arr.join(";|;"));
    var attrs = [];
    $(".text_1_question").each(function() {
        if ($(this).val() != "") {
            attrs.push($(this).val());
        }
    })
    $("#post_question_question_attrs").val(attrs.join(";-;"));
}

function ajax_edit_paper_title(paper_id, title) {
    $.ajax({
        type: "POST",
        url: "/papers/" + paper_id + "/ajax_edit_paper_title.json",
        dataType: "json",
        data : {
            "title" : title
        },
        success : function(data) {
            $(".p_name:eq(1)").html(data.title);
        }
    });
}

function ajax_edit_paper_time(paper_id, time) {
    $.ajax({
        type: "POST",
        url: "/papers/" + paper_id + "/ajax_edit_paper_time.json",
        dataType: "json",
        data : {
            "time" : time
        },
        success : function(data) {
            $(".p_time:eq(1)").html(data.time);
        }
    });
}

// 载入标签管理框
function load_add_label(tags_input, display) {
    jQuery('.add_label').css('display', 'block');
    jQuery('.zhezhao').css('display', 'block');
    $('#add_label_tags_input').val(tags_input);
    $('#add_label_display').val(display);
    $("#tags_list_ajax_loader").empty();
    $("#t_se_input_tags").val("");
    $("#t_se_input_tags").focus();
    display_tags_text(tags_input, display);
//ajax_load_tags_list('',$(tags_input).val()); //初始化可选标签列表
}

//关闭标签管理框
function close_add_label() {
    jQuery('.add_label').css('display', 'none');
    jQuery('.zhezhao').css('display', 'none');
    return false;
}

//根据查询内容，载入标签列表
function ajax_load_tags_list(match, added_tags) {
    $.ajax({
        type: "POST",
        url: "/papers/ajax_load_tags_list.html",
        dataType: "html",
        data : {
            "match" : match,
            "added_tags" : added_tags
        },
        beforeSend: function() {
            $("#tags_list_ajax_loader").html($("#ajax_loader").html());
        },
        success : function(data) {
            $("#tags_list_ajax_loader").html(data);
        }
    });
}

//插入标签，如果选中了不存在的标签，则新建标签
function organize_tags(tags_input, display) {
    if ($(".need_delete_tag").length > 0) {
        for (var i = 0; i < $(".need_delete_tag").length; i++) {
            if ($(".need_delete_tag:eq(" + i + ")").attr("checked") != "checked") {
                delete_tag($(".need_delete_tag:eq(" + i + ")").val(), tags_input);
            }
        }
    } //删除标签
    if ($(".select_exist_tag").length > 0) {
        for (var i = 0; i < $(".select_exist_tag").length; i++) {
            if ($(".select_exist_tag:eq(" + i + ")").attr("checked") == "checked") {
                insert_tag($(".select_exist_tag:eq(" + i + ")").val(), tags_input);
            }
        }
    } //插入标签
    if ($("#insert_new_tag").length > 0 && $("#insert_new_tag:eq(0)").attr("checked") == "checked") {
        $.ajax({
            type: "POST",
            url: "/papers/ajax_insert_new_tag.json",
            async :false,
            dataType: "json",
            data : {
                "tag_name" : $("#insert_new_tag").val()
            },
            beforeSend: function() {
                $("#already_add_tags_div").html($("#ajax_loader").html());
            },
            success : function(data) {
                insert_tag($("#insert_new_tag").val(), tags_input);
            }
        });
    } // ajax 在数据库中增加新记录，并插入标签
    display_tags_text(tags_input, display);   //更新页面
    ajax_load_tags_list($('#t_se_input_tags').val(), $(tags_input).val()); //刷新标签列表
}

//插入小题的标签
function insert_tag(tag_name, tags_input) {
    var origin_tags_arr = $(tags_input).val().split(" ");
    var exist = false;
    for (var i = 0; i < origin_tags_arr.length; i++) {
        if (origin_tags_arr[i] == tag_name) {
            exist = true;
        }
    }
    if (exist == false && tag_name != "") {
        origin_tags_arr.push(tag_name);
    }
    $(tags_input).val(origin_tags_arr.join(" "));
}

//删除小题的标签
function delete_tag(tag_name, tags_input) {
    var origin_tags_arr = $(tags_input).val().split(" ");
    var result_tags_arr = new Array;
    for (var i = 0; i < origin_tags_arr.length; i++) {
        if (origin_tags_arr[i] != tag_name) {
            result_tags_arr.push(origin_tags_arr[i]);
        }
    }
    $(tags_input).val(result_tags_arr.join(" "));
}

//将标签显示到页面上
function display_tags_text(tags_input, display) {
    var origin_tags_arr = $(tags_input).val().split(" ");
    //显示到标签管理框
    $("#already_add_tags_div").empty();
    for (var i = 0; i < origin_tags_arr.length; i++) {
        if (origin_tags_arr[i] != "") {
            $("#already_add_tags_div").html($("#already_add_tags_div").html() + "<li><input type='checkbox' class='need_delete_tag' value=" + origin_tags_arr[i] + " checked='true' />" + origin_tags_arr[i] + "</li>");
        }
    }
    //显示到编辑表单框
    $(display).empty();
    for (var i = 0; i < origin_tags_arr.length; i++) {
        if (origin_tags_arr[i] != "") {
            $(display).html($(display).html() + " " + origin_tags_arr[i]);
        }
    }
    if ($(display).html() == "") {
        $(display).html("未添加标签");
    }
}

// 载入词汇管理框
function load_addWords(words_input, display) {
    jQuery('.addWords').css('display', 'block');
    jQuery('.zhezhao').css('display', 'block');
    $('#addWords_words_input').val(words_input);
    $('#addWords_display').val(display);
    $("#words_list_ajax_loader").empty();
    $("#t_se_input_words").val("");
    $("#t_se_input_words").focus();
    $("#addWords_insert_words").val($(words_input).val());
    $("#xs_add_div").hide(); //未选中单词，详细信息隐藏
    display_words_text(words_input, display);
//ajax_load_words_list('',$(words_input).val());
}

function close_addWords() {
    jQuery('.addWords').css('display', 'none');
    jQuery('.zhezhao').css('display', 'none');
    return false;
}

//将词汇显示到页面上
function display_words_text(words_input,display){
    var origin_words_arr = $(words_input).val().split(";");
    //显示到词汇管理框
    $("#already_add_words_div").empty();
    for (var i = 0; i < origin_words_arr.length; i++) {
        if (origin_words_arr[i] != "") {
            $("#already_add_words_div").html($("#already_add_words_div").html() + "<div>" + origin_words_arr[i] + " <a href='javascript:void(0);'  onclick='javascript:delete_word(\"" + origin_words_arr[i] + "\")'>[删除]</a></div>");
        }
    }
    //显示到编辑表单框
    $(display).html($(words_input).val());
    if($(display).html()==""){
        $(display).html("未添加词汇");
    }
}

//根据查询内容，载入单词列表
function ajax_load_words_list(match, added_words) {
    $.ajax({
        type: "POST",
        url: "/papers/ajax_load_words_list.html",
        dataType: "html",
        data : {
            "match" : match,
            "added_words" : added_words,
            "category_id" : category_id
        },
        beforeSend: function() {
            $("#words_list_ajax_loader").html($("#ajax_loader").html());
        },
        success : function(data) {
            $("#words_list_ajax_loader").html(data);
            $(".single_word:eq(0)").trigger("click");
        }
    });
}

//词汇管理框，点击单一小题，右侧显示单词的详细信息
function show_single_word_detail(jqery_ele, name, en_mean, ch_mean, types, phonetic, enunciate_url, id) {
    $("#web_word").val("");
    $(".single_word_li").removeClass("hover");
    jqery_ele.addClass("hover");
    $(".single_word_element").html("");
    $("#single_word_name").html(name);
    $("#single_word_id").val(id);
    $("#single_word_en_mean").html(en_mean);
    $("#single_word_ch_mean").html(ch_mean);
    $("#single_word_types").html(types);
    $("#single_word_phonetic").html(phonetic);
    $("#single_word_enunciate_url").val(enunciate_url);
    $("#xs_add_div").show();
}

//词汇管理框，选择词汇
function select_word(word){
    var added_words=$("#addWords_insert_words").val();
    if (added_words==""||added_words.length==0){
        origin_words=[word]
    }else{
        var origin_words =added_words.split(";");
        for(var i=0;i<origin_words.length;i++){
            if(origin_words[i]==word){
                tishi_alert("你选择的单词已经在列表中");
                return false;
            }
        }
        origin_words.push(word);
    }
    if(parseInt(($("#web_word")).val())==1){
        $.ajax({
            type: "POST",
            url: "/words/create_word.html",
            dataType: "html",
            data : {
                name :$("#single_word_name").html(),
                en_mean :$("#single_word_en_mean").html(),
                ch_mean :$("#single_word_ch_mean").html(),
                types :$("#single_word_types").html(),
                phonetic :$("#single_word_phonetic").html(),
                enunciate_url :$("#single_word_enunciate_url").val(),
                sentence :$('.word_liju').html(),
                category_id : category_id
            }
        });
    }
    $("#addWords_insert_words").val(origin_words.join(";"));
    $("#already_add_words_div").html($("#already_add_words_div").html() + "<div>" + word + " <a href='javascript:void(0);' onclick='javascript:delete_word(\"" + word + "\")'>[删除]</a></div>");
}

//修改单词
function edit_word(category_id) {
    var word_id = $("#single_word_id").val();
    window.open("/words/" + word_id + "/edit?category=" + category_id, "修改单词");
}

//词汇管理框 删除词汇
function delete_word(word) {
    var origin_tags_arr = $("#addWords_insert_words").val().split(";");
    var result_tags_arr = new Array;
    for (var i = 0; i < origin_tags_arr.length; i++) {
        if (origin_tags_arr[i] != word && origin_tags_arr[i] != "") {
            result_tags_arr.push(origin_tags_arr[i]);
        }
    }
    $("#addWords_insert_words").val(result_tags_arr.join(";"));
    $("#already_add_words_div").empty();
    for (var i = 0; i < result_tags_arr.length; i++) {
        if (result_tags_arr[i] != "") {
            $("#already_add_words_div").html($("#already_add_words_div").html() + "<div>" + result_tags_arr[i] + " <a href='javascript:void(0);' onclick='javascript:delete_word(\"" + result_tags_arr[i] + "\")'>[删除]</a></div>");
        }
    }
}

//词汇管理框 插入词汇，更新form值
function insert_words(origin_words_input,target_words_input,display){
    $(target_words_input).val($(origin_words_input).val());
    display_words_text(target_words_input,display);
    close_addWords();
}


//请求网上单词
function download_word(word, category_id) {
    $.ajax({
        type: "POST",
        url: "/words/download_word.html",
        dataType: "html",
        data : {
            word : word,
            category_id : category_id
        },
        beforeSend: function() {
            $(".web_load").html($("#ajax_loader").html());
        },
        success : function(data) {
            $("#words_list_ajax_loader").html(data);
            $(".single_word:eq(0)").trigger("click");
        }

    });
}


function show_ready_word(jquery_ele, word_id) {
    $(".single_word_li").removeClass("hover");
    jquery_ele.addClass("hover");
    $("#xs_add_div").show();
    $('#xs_add_div').html($('#show_word_'+word_id).html());
    if ($("#web_word").val() == "0") {
        $("#modify_word").css("display", "");
    } else {
        $("#modify_word").css("display", "none");
    }
}


$(document).ready(function(){
    $('.info_ul').sortable({
        update: function(event, ui){
            var list = $(this).sortable('serialize');
            var item_id = ui.item.attr("id").split("li_");
            if (item_id[1] != null) {
                $.ajax({
                    type: 'post',
                    data: "paper_id="+getCookie("init_paper")+"&block_index="+getCookie("init_block")+"&old_postion="+item_id[1]+"&"+list,
                    dataType: 'script',
                    url: '/papers/sort',
                    complete:function(request){
                        var res = request.responseText.split(",");
                        tishi_alert(res[0]);
                        if (res[1] != null) {
                            setCookie("init_problem",""+res[1]);
                        }
                        window.setTimeout(function(){
                            window.location.reload();
                        }, 1000);
                    }
                })
            } else {
                tishi_alert("您拖动的大题已经不存在，请刷新页面");
                return false;
            }
        }
    });
    $(".info_ul").disableSelection();
});


//显示请求到的单词
function show_single_word(web_word){
    $('#xs_add_div').html($('#web_word_m').html());
    $(".single_word_li").removeClass("hover");
    $("#web_word").val(web_word);
    $("#xs_add_div").show();
    if($("#web_word").val() == "0"){
        $("#select_word").css("display", "none");
    } else {
        $("#select_word").css("display", "");
    }
}

//载入富文本编辑框,编辑时用，新建题目时使用load_create_kindeditor
function load_edit_kindeditor(selector,paper_id,block_index,problem_index,question_sum,question_type) {
    var editor = KindEditor.create(selector, {
        resizeType : 1,
        allowPreviewEmoticons : false,
        allowImageUpload : true,
        items : [
        'fontname', 'fontsize', '|', 'forecolor', 'hilitecolor', 'bold', 'italic', 'underline',
        'removeformat', '|', 'image','audio','mark', '|' ,'commit' ]
    });
    KindEditor.plugin('commit', function(K) {
        var name = 'commit';
        editor.clickToolbar(name, function() {
            var text = editor.html();
            if(question_type==1){
                var mark = "((sign))";
                var sign_sum = text.split(mark).length-1;
                if(question_sum !=sign_sum){
                    tishi_alert("标记数（" + sign_sum + "） 不符合 小题数（" + question_sum + "）");
                }
            }
            if($("#show_problem_title_"+block_index+"_"+problem_index).html()!=text){
                ajax_edit_problem_title(paper_id,block_index,problem_index,text);
            }
            editor.remove();
        });
    });
    editor.focus();
};

function load_create_kindeditor(index) {
    var form = "#bj_info_box_"+index;
    var selector = "#problem_title_block_"+index;
    if($(form).css('display')!="none" && $(selector).css('display')!="none"){
        var editor = KindEditor.create(selector, {
            resizeType : 1,
            allowPreviewEmoticons : false,
            allowImageUpload : true,
            afterBlur : function() {
                var text = editor.html();
                $(selector).val(text);
            },
            items : [
            'fontname', 'fontsize', '|', 'forecolor', 'hilitecolor', 'bold', 'italic', 'underline',
            'removeformat', '|', 'image','audio','mark']
        });
    }
};

//删除模块
function destroy_block(paper_id,block_index){
    if(confirm("系统即将删除第"+block_index+"部分的所有内容。\n确认要删除么？")){
        $('#zhezhao').show();
        delCookie("init_block");
        delCookie("init_problem");
        tishi_alert("正在删除，请稍等。");
        window.location.href='/papers/'+paper_id+"/destroy_element?block_index="+block_index;
    }
}

//删除大题
function destroy_problem(paper_id,block_index,problem_index){
    if(confirm("系统即将将删除第"+block_index+"部分第"+problem_index+"大题的所有内容。\n确认要删除么？")){
        $('#zhezhao').show();
        setCookie("init_problem","1");
        tishi_alert("正在删除，请稍等。");
        window.location.href='/papers/'+paper_id+"/destroy_element?block_index="+block_index+"&problem_index="+problem_index;
    }
}

//删除小题
function destroy_question(paper_id,block_index,problem_index,question_index){
    if(confirm("系统即将删除第"+block_index+"部分第"+problem_index+"大题第"+question_index+"小题的所有内容。\n确认要删除么？")){
        $('#zhezhao').show();
        tishi_alert("正在删除，请稍等。");
        window.location.href='/papers/'+paper_id+"/destroy_element?block_index="+block_index+"&problem_index="+problem_index+"&question_index="+question_index;
    }
}



//create_problem表单 追加选项
function create_problem_add_attr(ele,correct_type,block_index){
    var attrs = ele.parent().prev("ul");
    if(correct_type==0){
        attrs.append($("#append_create_problem_single_attr_"+block_index+">li").clone());
    }
    if(correct_type==1){
        attrs.append($("#append_create_problem_multi_attr_"+block_index+">li").clone());
    }
}

//post_question表单 追加选项
function post_question_add_attr(ele,correct_type){
    var attrs = ele.parent().prev("ul");
    if(correct_type==0){
        attrs.append($("#append_post_question_single_attr>li").clone());
    }
    if(correct_type==1){
        attrs.append($("#append_post_question_multi_attr>li").clone());
    }
}

//删除选项
function remove_attr(ele){
    ele.closest("li").remove();
}

//播放音频
function jplayer_play(src){
    $("#jplayer_loader").jPlayer("setMedia", {
        mp3: src
    });
    $("#jplayer_loader").jPlayer("play");
}

//点击 “在题面后插入小题”，“在题面中插入小题”
function reset_question_type(block_index,type){
    $('.question_type_block_'+block_index).val(type);
    $('.question_answer_block_'+block_index).val("");
    $('.question_attrs_block_'+block_index).val("");
    $('#create_problem_attrs_module_'+block_index).html('<font color=\'red\'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;请选择小题类型。</font>');
}
