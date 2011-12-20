KindEditor.plugin('mark', function(K) {
        var editor = this, name = 'mark';
        editor.clickToolbar(name, function() {
                editor.insertHtml('((sign))');
        });
});