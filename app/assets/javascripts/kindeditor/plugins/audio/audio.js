KindEditor.plugin('audio', function(K) {
    var editor = this, name = 'audio';
    editor.clickToolbar(name, function() {
        var p = prompt("请输入音频url:");
        if(p){
            editor.insertHtml("(mp3)"+p+"(mp3)");
        }
    });
});