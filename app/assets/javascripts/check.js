//删除答疑问题
function delete_question(question_id,e){
    if (confirm("确定要删除这个提问吗？")){
        var data={
            question_id:question_id
        };
        var url="/check/delete_question";
        var callback="tishi_alert('删除成功');setTimeout(function(){window.location.reload();},1000)"
        $(e).attr('onclick','');
        send_request("post",url,data,callback,"json")
    }
}

//显示问题回答
function show_question(question_id){
    var data={
        question_id:question_id
    };
    var url="/check/show_question";
    send_request("post",url,data,"","script");
}

function send_request(type,url,data,callback,data_type){
    $.ajax({
        type: type,
        url: url,
        dataType: data_type,
        data : data,
        success : function(data) {
            eval(callback);
        }
    });
}

function delete_answer(answer_id,question_id,e){
    if (confirm("确定要删除这个回答吗？")){
        var data={
            answer_id:answer_id,
            question_id:question_id
        };
        var url="/check/delete_answer";
        var callback="tishi_alert('删除成功');"
        $(e).attr('onclick','');
        send_request("post",url,data,callback,"script");
    }
   
}

function set_answer(answer_id,question_id,e){
    if (confirm("确定要将此回答设置为最佳答案吗？")){
        var data={
            answer_id:answer_id,
            question_id:question_id
        };
        var url="/check/set_answer";
        var callback="window.location.reload();"
        $(e).attr('onclick','');
        send_request("post",url,data,callback,"json")
    }
}



/*skill审核 */
function delete_skill(skill_id,e){
    if (confirm("确定要删除本技巧吗？")){
        var data={
            skill_id:skill_id
        };
        var url="/check/delete_skill";
        var callback="tishi_alert('删除成功');setTimeout(function(){window.location.href='/check/skill_index?category='+data.category;},1000)"
        $(e).attr('onclick','');
        send_request("post",url,data,callback,"json")
    }
}


function set_skill(skill_id,e){
    if (confirm("确定要将此技巧审核通过吗？")){
        var data={
            skill_id:skill_id
        };
        var url="/check/set_skill";
        var callback="window.location.href='/check/skill_index?category='+data.category;"
        $(e).attr('onclick','');
        send_request("post",url,data,callback,"json")
    }
}
var editor;
function edit_skill(){
    $('#show_con').css('display','none');
    $('#edit_con').css('display','');
    editor = KindEditor.create("#area_con", {
        resizeType : 1,
        height : 500,
        allowPreviewEmoticons : false,
        allowImageUpload : true,
        items : [
        'fontname', 'fontsize', '|', 'forecolor', 'hilitecolor', 'bold', 'italic', 'underline',
        'removeformat', '|','mark' ]
    });
}

function save_skill(skill_id,e){
    var title=$("#skill_title").val();
    var con = editor.html();
    var data={
        skill_id:skill_id,
        title:title,
        con:con
    };
    var url="/check/save_skill";
    var callback="window.location.href='/check/skill_index?category='+data.category;"
    $(e).attr('onclick','');
    send_request("post",url,data,callback,"json")
}