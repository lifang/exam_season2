//选择收费，免费和单独收费
function redirect_to(category_id) {
    var option_value = $("select option:selected").attr("value");
    if (option_value == "-1") {
        window.location.href = "simulations?category=" + category_id;
    } else {
        window.location.href = "simulations?category="+ category_id +"&category_type=" + option_value;
    }
}

//新建模考试题
$(function(){
    $(".bianji_ny .t_btn").click(function(){
        if (checkspace($("#title").attr("value"))) {
            tishi_alert("模考名称不能为空。");
            return false;
        }
        if ($("#title").attr("value").length > 50) {
            tishi_alert("模考的名称长度不能超过50个字。");
            return false;
        }
        if(checkspace($("#from_date").val())||checkspace($("#end_date").val())){
            tishi_alert("请设置模考日期");
            return false;
        }
        if($("#from_date").val()>$("#end_date").val()){
            tishi_alert("请正确设置模考开始和截止日期");
            return false;
        }
        if (checkspace($("#paper_id").attr("value"))) {
            tishi_alert("请选择作为本场考试的试卷。");
        }
        if($(".bj_sfei :checked").val()== undefined){
            tishi_alert("请选择收费方式");
            return false;
        }
        if (parseInt($(".bj_sfei :checked").val())==2){
            var fee=$(".bj_sfei :text:last").val();
            if (isNaN(parseInt(fee))) {
                tishi_alert("请输入收费金额");
                return false;
            }
        }
        $("form").submit();
    })
})



//验证邮箱并提交添加请求阅卷老师
function valid_email(exam_id){
    var emailReg = new RegExp(/^\w+([-+.])*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/);
    var this_email = $("#email_"+exam_id).val().replace(/ /g , "");
    if (this_email.length ==0 || !emailReg.test(this_email)){
        tishi_alert("请输入有效邮箱!");
        return false;
    }
    $("#spinner_add_"+exam_id).css("display","");
    $("#button_"+exam_id).css("display","none");
    $.ajax({
        async:true,
        success:function(request){
            $("#spinner_add_"+exam_id).css("display","none");
        },
        data:{
            examination_id :exam_id,
            email : $("#email_"+exam_id).val().replace(/ /g , "")
        },
        dataType:'script',
        url:"/simulations/add_rater",
        type:'post'
    });
    return false;
}

//删除阅卷老师
function delete_rater(exam_id,email){
    if(confirm("确定删除该阅卷老师？")){
        $.ajax({
            async:true,
            data:{
                examination_id :exam_id,
                email : email
            },
            dataType:'script',
            url:"/simulations/delete_rater",
            type:'post'
        });
        return false;
    }
}


function over_exam(id,e){
    var action=e.text();
    var status;
    var types;
    if (action=="暂停"){
        status="恢复"
        types=0;
    }else{
        status="暂停";
        types=1;
    }
    if(confirm("确定"+ action+"该场考试吗？")){
        e.text(status);
        $.ajax({
            async:true,
            data:{
                exam_id :id,
                types :types
            },
            dataType:'script',
            url:"/simulations/stop_exam",
            type:'post'
        });
        return false;
    }
}