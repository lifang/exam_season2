$(function(){
    $(".add_renwu .t_btn").click(function(){
        var radio_value=$("add_renwu :radio").val();
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
        if(amount==""){
            tishi_alert("请输入数量");
            return false;
        }
        $.ajax({
            async:true,
            data:{
                period :radio_value,
                task : select_value,
                amount:amount
            },
            dataType:'script',
            url:"/study_plans/create_task",
            type:'post'
        });
        return false;
    })
})


