var all_tasks=""
$(function(){
    $(".add_renwu .t_btn").click(function(){
        var radio_value=$(":checked").val();
        var select_value=$("select option:selected").val();
        var amount=$("#amount").val();
        if(radio_value==undefined){
            tishi_alert("请选择周期");
            return false;
        }
        if(parseInt(select_value)==-1){
            tishi_alert("请选择任务类型");
            return false;
        }
        if(isNaN(parseInt(amount))||parseInt(amount)==0){
            tishi_alert("请输入数量");
            return false;
        }
        var str=""
        str= radio_value+","+select_value+","+amount
        if(all_tasks==""){
            all_tasks=str;
        }else{
            all_tasks= all_tasks+";"+str
        }
        $.ajax({
            async:true,
            success:function(request){
                $("#amount").val("");
                $(":checked").removeAttr("checked");
                $("select")[0].selectedIndex=0;
                $('.add_renwu').css('display','none');
            },
            data:{
                info :all_tasks
            },
            dataType:'script',
            url:"/study_plans/create_task",
            type:'post'
        });
        return false;
    })
})


function delete_task(task){
    var tasks=new Array();
    tasks=all_tasks.split(";")
    var postion=tasks.indexOf(task);
    if (tasks.length==1){
        all_tasks=all_tasks.replace(task,"");
    }else{
        if(postion==tasks.length-1){
            all_tasks=all_tasks.replace(";"+task,"");
        }else{
            all_tasks=all_tasks.replace(task+";","");
        }
    }
    $.ajax({
        async:true,
        data:{
            info :all_tasks
        },
        dataType:'script',
        url:"/study_plans/create_task",
        type:'post'
    });
    return false;
}

$(function(){
    $(".bianji_ny .t_btn").click(function(){
        var date=$("#date").val();
        if (isNaN(parseInt(date))||parseInt(date)==0){
            tishi_alert("请输入天数");
            return false;
        }
        if (all_tasks.length==0){
            alert(1);
            if (!confirm("暂时不添加新任务?")){
                return false;
            }
        }
        $("#task_form").submit();

    //        window.location.href="/study_plans/create_plan?info='"+all_tasks+"'&date="+date+"&"+location.toString().split("?")[1]
    })
})

function delete_real_task(id){
    var delete_ids=$("#delete_task_ids").val();
    var ids="";
    if (confirm("确认删除此任务？"))
    {
        if (delete_ids==""||delete_ids.length==0){
            ids=id;
        }else{
            ids=delete_ids+","+id;
        }
        $.ajax({
            async:true,
            success:function(request){
                $("#delete_task_ids").val(ids);
            },
            data:{
                delete_ids :ids,
                category : $("#category").val()
            },
            dataType:'script',
            url:"/study_plans/delete_task",
            type:'post'
        });
        return false;
    }
}

