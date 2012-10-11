//删除答疑问题
function delete_question(question_id,e){
    var data={
        question_id:question_id
    };
    var url="/check/delete_question";
    var callback="tishi_alert('删除成功');setTimeout(function(){window.location.reload();},1000)"
    $(e).attr('onclick','');
    send_request("post",url,data,callback,"json")
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
    var data={
        answer_id:answer_id,
        question_id:question_id
    };
    var url="/check/delete_answer";
    $(e).attr('onclick','');
    send_request("post",url,data,"","script");
}

function set_answer(answer_id,question_id,e){
    var data={
        answer_id:answer_id,
        question_id:question_id
    };
    var url="/check/set_answer";
    var callback="window.location.reload();"
    $(e).attr('onclick','');
    send_request("post",url,data,callback,"json")
}

