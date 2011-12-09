function modify_status(id,status){
    var error_type=$("#error_type").val();
    var page=$("#page").val();
    var category=$("#category").val();
    var all_error=$("#all_error").val();
    if (parseInt(all_error)==parseInt(page))
        $.ajax({
            async:true,
            success:function(request){
           
            },
            data:{
                status :status,
                errortype :error_type,
                page :page,
                category :category,
                error :all_error,
                id :id
            },
            dataType:'script',
            url:"/report_errors/modify_status",
            type:'post'
        });
    return false;
}


