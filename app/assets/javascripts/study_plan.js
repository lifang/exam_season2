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
            if (!confirm("暂时不添加任务?")){
                return false;
            }

        }
        window.location.href="/study_plans/create_plan?info="+all_tasks+"&date="+date+"&"+location.toString().split("?")[1]
    })
})