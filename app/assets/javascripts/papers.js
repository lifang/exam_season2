
//试卷筛选   注意其中  1 = Paper::CHECKED[:YES]    0 = Paper::CHECKED[:NO]    2 = Paper::CHECKED[:ALL]
function select_checked(dom,category_id){
    if(dom.options[dom.selectedIndex].value=="2"){
        window.location.href="/papers?category="+category_id;
        return false;
    }
    if(dom.options[dom.selectedIndex].value=="0"){
        window.location.href="/papers?category="+category_id+"&checked=0";
        return false;
    }
    if(dom.options[dom.selectedIndex].value=="1"){
        window.location.href="/papers?category="+category_id+"&checked=1";
        return false;
    }
}

// 设置DIV根据浏览器宽度，居中
function set_center(jq_params){
    if (jQuery(jq_params) != null) {
        var win_height = jQuery(window).height();
        var win_width = jQuery(window).width();
        var z_layer_height = jQuery(jq_params).height();
        var z_layer_width = jQuery(jq_params).width();
        if (win_height-z_layer_height > 0) {
            jQuery(jq_params).css('top',(win_height-z_layer_height)/2);
        } else {
            jQuery(jq_params).css('top',0);
        }
        jQuery(jq_params).css('left',(win_width-z_layer_width)/2);
        return false;
    }
}

//停止事件冒泡
function stop_bunble(){
    if(event.stopPropagation){
        event.stopPropagation();
    }else
    if(window.event){
        window.event.cancelBubble = true;
    };
}


//载入编辑模块div
function load_edit_block(block_xpath,block_name,block_description,block_start_time,block_time){
    $("#block_xpath").val(block_xpath);
    $("#block_name").val(block_name);
    $("#block_description").val(block_description);
    if(block_start_time!="0" && block_start_time!=""){
        $("#block_start_time_radio2").attr("checked","true").val(block_start_time);
        $("#block_start_time").removeAttr("disabled").val(block_start_time);
    }else{
        $("#block_start_time_radio1").attr("checked","true").val('0');
        $("#block_start_time").attr("disabled","disabled").val('0');
    }
    if(block_time!="0" && block_time!=""){
        $("#block_time_radio2").attr("checked","true").val(block_time);
        $("#block_time").removeAttr("disabled").val(block_time);
    }else{
        $("#block_time_radio1").attr("checked","true").val('0');
        $("#block_time").attr("disabled","disabled").val('0');
    }

    jQuery('.part_info').css('display','block');
    jQuery('.zhezhao').css('display','block');
    $("#block_name").focus();
}


//关闭新建、编辑模块DIV
function close_part_info(){
    jQuery('.part_info').css('display','none');
    jQuery('.zhezhao').css('display','none');
    return false;
}

//验证 模块表单 ，名称不能为空
function validate_post_block(){
    if(checkspace($('#block_name').val())){
        tishi_alert("请输入名称");
        return false;
    }
}


//ajax载入小题类型，拼凑完整表单(create_problem 表单)
function select_question_type(question_type,block_index){
    $('#create_problem_attrs_module_'+block_index).load('/papers/select_question_type',
    {
        "question_type" : question_type,
        "block_index" : block_index
    },
    function(){
        add_event_on_create_problem_form(question_type,block_index);
    });
}

//ajax回调函数，载入模版后，给其中的元素绑定事件 (create_problem 表单)
function add_event_on_create_problem_form(question_type,block_index){
    var text = ".text_"+question_type+"_block_"+block_index;
    var attrs = ".question_attrs_block_"+block_index;   //表单
    var answer = ".question_answer_block_"+block_index;   //表单
    if(question_type == 0 ){
        var radio = ".radio_"+question_type+"_block_"+block_index;
        generate_single_choose(text,attrs,answer,radio);
    }else if(question_type== 1 ){
        var checkbox = ".checkbox_"+question_type+"_block_"+block_index;
        generate_multi_choose(text,attrs,answer,checkbox);
    }else if(question_type== 2 ){
        var radio = ".radio_"+question_type+"_block_"+block_index;
        generate_judge(answer,radio);
    }else if(question_type==3 ||question_type==5){
        generate_fill(answer,text);
    }
}

//单选题 整理组织单选题选项和答案
function generate_single_choose(text,attrs,answer,radio){
    $(text).bind("change",function(){
        var attrs_array = [];
        $(text).each(function(){
            attrs_array.push($(this).val());
        })
        $(attrs).val(attrs_array.join(';-;'));
        $(radio).each(function(){
            if(this.checked){
                $(answer).val($(this).next(text).val());
            }
        })
    })
    $(radio).bind("click",function(){
        $(answer).val($(this).next(text).val());
    });
}

//多选题 整理组织单选题选项和答案
function generate_multi_choose(text,attrs,answer,checkbox){
    $(text).bind("change",function(){
        var attrs_array = [];
        $(text).each(function(){
            attrs_array.push($(this).val());
        })
        $(attrs).val(attrs_array.join(';-;'));
        $(answer).val(organize_multichoose_answer(checkbox,text));
    })
    $(checkbox).bind("click",function(){
        $(answer).val(organize_multichoose_answer(checkbox,text));
    });
}

//判断题 整理组织答案
function generate_judge(answer,radio){
    $(radio).bind("click",function(){
        $(answer).val($(this).val());
    })
}

//填空题、简答题 整理组织答案
function generate_fill(answer,text){
    $(text).bind("change",function(){
        $(answer).val($(this).val());
    })
}

//多选题组织答案
function organize_multichoose_answer(element,text){
    var answer_array = [];
    $(element).each(function(){
        if(this.checked){
            answer_array.push($(this).next(text).val());
        }
    })
    return answer_array.join(';|;');
}


//ajax 编辑题目说明
function ajax_edit_problem_description(paper_id,block_index,problem_index,description){
    $.ajax({
        type: "POST",
        url: "/papers/"+paper_id+"/ajax_edit_problem_description.json",
        dataType: "json",
        data : {
            "paper_id" : paper_id,
            "block_index" : block_index,
            "problem_index" : problem_index,
            "description" : description
        },
        beforeSend: function(){
            $("#show_problem_description_"+block_index+"_"+problem_index).html($("#ajax_loader").html());
        },
        success : function(data){
            $("#show_problem_description_"+block_index+"_"+problem_index).html(data.description);
        }
    });
}

//ajax 编辑题目内容
function ajax_edit_problem_title(paper_id,block_index,problem_index,title){
    $.ajax({
        type: "POST",
        url: "/papers/"+paper_id+"/ajax_edit_problem_title.json",
        dataType: "json",
        data : {
            "paper_id" : paper_id,
            "block_index" : block_index,
            "problem_index" : problem_index,
            "title" : title
        },
        beforeSend: function(){
            $("#show_problem_title_"+block_index+"_"+problem_index).html($("#ajax_loader").html());
        },
        success : function(data){
            $("#show_problem_title_"+block_index+"_"+problem_index).html(data.title);
        }
    });
}

//将null转化为""
function rescue_null(object){
    if(object==null){
        return ""
    }
    return object
}


////ajax载入小题类型，拼凑完整表单(post_question 表单)
function select_correct_type(ele_str,block_index,problem_index,question_index,correct_type,question_answer,question_attrs,question_description,question_analysis,question_score,question_tags,question_words,hidden_div){
    //如果参数为null,转化为""
    question_answer=rescue_null(question_answer);
    question_attrs=rescue_null(question_attrs);
    question_description=rescue_null(question_description);
    question_analysis=rescue_null(question_analysis);
    question_score=rescue_null(question_score);
    question_tags=rescue_null(question_tags);
    question_words=rescue_null(question_words);
    hidden_div=rescue_null(hidden_div);
    $('#post_question_attrs_module').load('/papers/select_correct_type',
    {
        "correct_type" : correct_type,
        "question_answer" : question_answer,
        "question_attrs" : question_attrs
    },
    function(){
        var location = question_index=="" ?  ele_str+block_index+"_"+problem_index : ele_str+block_index+"_"+problem_index+"_"+question_index;
        $("#post_question_div").hide();
        $(location).append($("#post_question_div"));  //载入form
        $("#post_question_div").slideDown(1200);
        var questions_xpath = "/paper/blocks/block["+block_index+"]/problems/problem["+problem_index+"]/questions" //构造 questions_xpath , 作为下一个方法的变量
        fill_post_question_form(questions_xpath,question_index,question_answer,question_attrs,question_description,question_analysis,question_score,question_tags,question_words); //初始化表单值
        add_event_on_post_question_form(correct_type);  //初始化表单事件
        if(hidden_div!=null && hidden_div!=""){
            hidden_div.hide();
        }  //隐藏显示小题的DIV
    });
}

//初始化 post_question 表单 值
function fill_post_question_form(questions_xpath,question_index,question_answer,question_attrs,question_description,question_analysis,question_score,question_tags,question_words){
    $("#post_question_questions_xpath").val(questions_xpath);
    $("#post_question_question_index").val(question_index);
    $("#post_question_question_answer").val(question_answer);
    $("#post_question_question_attrs").val(question_attrs);
    $("#post_question_question_description").val(question_description);
    $("#post_question_question_analysis").val(question_analysis);
    $("#post_question_question_score").val(question_score);
    $("#post_question_question_tags").val(question_tags);
    $("#post_question_question_words").val(question_words);
    display_tags_text('#post_question_question_tags','#post_question_tags_div');         //显示标签
    display_words_text('#post_question_question_words','#post_question_words_div');      //显示词汇
}

//初始化 post_question 表单 元素事件
function add_event_on_post_question_form(correct_type){
    var text = ".text_"+correct_type+"_question";
    var attrs = "#post_question_question_attrs";   //表单
    var answer = "#post_question_question_answer";   //表单
    if(correct_type == 0 ){
        var radio = ".radio_"+correct_type+"_question";
        generate_single_choose(text,attrs,answer,radio);
    }else if(correct_type== 1 ){
        var checkbox = ".checkbox_"+correct_type+"_question";
        generate_multi_choose(text,attrs,answer,checkbox);
    }else if(correct_type== 2 ){
        var radio = ".radio_"+correct_type+"_question";
        generate_judge(answer,radio);
    }else if(correct_type==3 ||correct_type==5){
        generate_fill(answer,text);
    }
}


function ajax_edit_paper_title(paper_id,title){
    $.ajax({
        type: "POST",
        url: "/papers/"+paper_id+"/ajax_edit_paper_title.json",
        dataType: "json",
        data : {
            "title" : title
        },
        beforeSend: function(){
        // $(".p_name:eq(1)").html($("#ajax_loader").html());
        },
        success : function(data){
            $(".p_name:eq(1)").html(data.title);
        }
    });
}

function ajax_edit_paper_time(paper_id,time){
    $.ajax({
        type: "POST",
        url: "/papers/"+paper_id+"/ajax_edit_paper_time.json",
        dataType: "json",
        data : {
            "time" : time
        },
        beforeSend: function(){
        //  $(".p_time:eq(1)").html($("#ajax_loader").html());
        },
        success : function(data){
            $(".p_time:eq(1)").html(data.time);
        }
    });
}

// 载入标签管理框
function load_add_label(tags_input,display){
    jQuery('.add_label').css('display','block');
    jQuery('.zhezhao').css('display','block');
    $('#add_label_tags_input').val(tags_input);
    $('#add_label_display').val(display);
    $("#tags_list_ajax_loader").empty();
    $("#t_se_input_tags").val("");
    $("#t_se_input_tags").focus();
    display_tags_text(tags_input,display);
    //ajax_load_tags_list('',$(tags_input).val()); //初始化可选标签列表
}

//关闭标签管理框
function close_add_label(){
    jQuery('.add_label').css('display','none');
    jQuery('.zhezhao').css('display','none');
    return false;
}

//根据查询内容，载入标签列表
function ajax_load_tags_list(match,added_tags){
    $.ajax({
        type: "POST",
        url: "/papers/ajax_load_tags_list.html",
        dataType: "html",
        data : {
            "match" : match,
            "added_tags" : added_tags
        },
        beforeSend: function(){
            $("#tags_list_ajax_loader").html($("#ajax_loader").html());
        },
        success : function(data){
            $("#tags_list_ajax_loader").html(data);
        }
    });
}

//插入标签，如果选中了不存在的标签，则新建标签
function organize_tags(tags_input,display){
    if($(".need_delete_tag").length>0){
        for(var i=0;i<$(".need_delete_tag").length;i++){
            if($(".need_delete_tag:eq("+i+")").attr("checked")!="checked"){
                delete_tag($(".need_delete_tag:eq("+i+")").val(),tags_input);
            }
        }
    } //删除标签
    if($(".select_exist_tag").length>0){
        for(var i=0;i<$(".select_exist_tag").length;i++){
            if($(".select_exist_tag:eq("+i+")").attr("checked")=="checked"){
                insert_tag($(".select_exist_tag:eq("+i+")").val(),tags_input);
            }
        }
    } //插入标签
    if($("#insert_new_tag").length>0 && $("#insert_new_tag:eq(0)").attr("checked")=="checked"){
        $.ajax({
            type: "POST",
            url: "/papers/ajax_insert_new_tag.json",
            async :false,
            dataType: "json",
            data : {
                "tag_name" : $("#insert_new_tag").val()
            },
            beforeSend: function(){
                $("#already_add_tags_div").html($("#ajax_loader").html());
            },
            success : function(data){
                insert_tag($("#insert_new_tag").val(),tags_input);
            }
        });
    } // ajax 在数据库中增加新记录，并插入标签
    display_tags_text(tags_input,display);   //更新页面
    ajax_load_tags_list($('#t_se_input_tags').val(),$(tags_input).val()); //刷新标签列表
}

//插入小题的标签
function insert_tag(tag_name,tags_input){
    var origin_tags_arr = $(tags_input).val().split(" ");
    var exist=false;
    for(var i=0;i<origin_tags_arr.length;i++){
        if(origin_tags_arr[i]==tag_name){
            exist=true;
        }
    }
    if(exist==false && tag_name!=""){
        origin_tags_arr.push(tag_name);
    }
    $(tags_input).val(origin_tags_arr.join(" "));
}

//删除小题的标签
function delete_tag(tag_name,tags_input){
    var origin_tags_arr = $(tags_input).val().split(" ");
    var result_tags_arr = new Array;
    for(var i=0;i<origin_tags_arr.length;i++){
        if(origin_tags_arr[i]!=tag_name){
            result_tags_arr.push(origin_tags_arr[i]);
        }
    }
    $(tags_input).val(result_tags_arr.join(" "));
}

//将标签显示到页面上
function display_tags_text(tags_input,display){
    var origin_tags_arr = $(tags_input).val().split(" ");
    //显示到标签管理框
    $("#already_add_tags_div").empty();
    for(var i=0;i<origin_tags_arr.length;i++){
        if(origin_tags_arr[i]!=""){
            $("#already_add_tags_div").html($("#already_add_tags_div").html()+"<li><input type='checkbox' class='need_delete_tag' value="+origin_tags_arr[i]+" checked='true' />"+origin_tags_arr[i]+"</li>");
        }
    }
    //显示到编辑表单框
    $(display).empty();
    for(var i=0;i<origin_tags_arr.length;i++){
        if(origin_tags_arr[i]!=""){
            $(display).html($(display).html()+" "+origin_tags_arr[i]);
        }
    }
    if($(display).html()==""){
        $(display).html("未添加标签");
    }
}

// 载入词汇管理框
function load_addWords(words_input,display){
    jQuery('.addWords').css('display','block');
    jQuery('.zhezhao').css('display','block');
    $('#addWords_words_input').val(words_input);
    $('#addWords_display').val(display);
    $("#words_list_ajax_loader").empty();
    $("#t_se_input_words").val("");
    $("#t_se_input_words").focus();
    $("#addWords_insert_words").val($(words_input).val());
    $("#xs_add_div").hide(); //未选中单词，详细信息隐藏
    display_words_text(words_input,display);
    //ajax_load_words_list('',$(words_input).val());
}

function close_addWords(){
    jQuery('.addWords').css('display','none');
    jQuery('.zhezhao').css('display','none');
    return false;
}

//将词汇显示到页面上
function display_words_text(words_input,display){
    var origin_words_arr = $(words_input).val().split(" ");
    //显示到词汇管理框
    $("#already_add_words_div").empty();
    for(var i=0;i<origin_words_arr.length;i++){
        if(origin_words_arr[i]!=""){
            $("#already_add_words_div").html($("#already_add_words_div").html()+"<div>"+origin_words_arr[i]+" <a href='javascript:void(0);'  onclick='javascript:delete_word(\""+origin_words_arr[i]+"\")'>[删除]</a></div>");
        }
    }
    //显示到编辑表单框
    $(display).empty();
    for(var i=0;i<origin_words_arr.length;i++){
        if(origin_words_arr[i]!=""){
            $(display).html($(display).html()+" "+origin_words_arr[i]);
        }
    }
    if($(display).html()==""){
        $(display).html("未添加词汇");
    }
}

//根据查询内容，载入单词列表
function ajax_load_words_list(match,added_words){
    //alert(""+(match=="")+" | "+(added_words=="")+" | "+category_id);
    $.ajax({
        type: "POST",
        url: "/papers/ajax_load_words_list.html",
        dataType: "html",
        data : {
            "match" : match,
            "added_words" : added_words,
            "category_id" : category_id
        },
        beforeSend: function(){
            $("#words_list_ajax_loader").html($("#ajax_loader").html());
        },
        success : function(data){
            $("#words_list_ajax_loader").html(data);
            $(".single_word_li:eq(0)").trigger("click");
        }
    });
}






