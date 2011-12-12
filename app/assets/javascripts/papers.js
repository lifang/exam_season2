
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

  
//编辑、新建部分，控制DIV居中
jQuery(function(){
    if (jQuery('.part_info') != null) {
        var win_height = jQuery(window).height();
        var win_width = jQuery(window).width();
        var z_layer_height = jQuery('.part_info').height();
        var z_layer_width = jQuery('.part_info').width();
        if (win_height-z_layer_height > 0) {
            jQuery('.part_info').css('top',(win_height-z_layer_height)/2);
        } else {
            jQuery('.part_info').css('top',0);
        }
        jQuery('.part_info').css('left',(win_width-z_layer_width)/2);
        return false;
    }
})


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


//ajax载入小题类型，拼凑完整表单
function select_question_type(question_type,block_index){
    $('#attrs_module_'+block_index).load('/papers/select_question_type',
    {
        "question_type" : question_type,
        "block_index" : block_index
    },
    function(){
        ajax_callback_function(question_type,block_index);
    });
}

//ajax回调函数，载入模版后，给其中的元素绑定事件
function ajax_callback_function(question_type,block_index){
    //  alert("  "+question_type+"    "+block_index);
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
