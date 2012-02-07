//document.write('<script type="text/javascript" src="js/jquery/jquery-1.4.2.min.js"></script>');//文件引入
var ImagesLazyLoad = $$.wrapper(function(options) {
    this._initialize( options );
    //如果没有元素就退出
    if ( this.isFinish() ) return;
    //初始化模式设置
    this._initMode();
    //进行第一次触发
    this.resize(true);
}, LazyLoad);

$$.extend( ImagesLazyLoad.prototype, {
    //初始化程序
    _initialize: function(options) {
        LazyLoad.prototype._initialize.call(this, [], options);
        //设置子类属性
        var opt = this.options;
        this.onLoad = opt.onLoad;
        var attribute = this._attribute = opt.attribute;
        //设置加载图片集合
        var getSrc = opt.getSrc,
        filter = $$F.bind( this._filter, this,
            opt["class"],
            getSrc ? function(img){
                return getSrc(img);
            }
            : function(img){
                return img.getAttribute( attribute ) || img.src;
            },
            opt.holder
            );
        this._elems = $$A.filter(
            opt.images || this._container.getElementsByTagName("img"), filter
            );
        //判断属性是否已经加载的方法
        this._hasAttribute = $$B.ie6 || $$B.ie7
        ? function(img){
            return attribute in img;
        }
        : function(img){
            return img.hasAttribute( attribute );
        };
    },
    //设置默认属性
    _setOptions: function(options) {
        return LazyLoad.prototype._setOptions.call(this, $$.extend({//默认值
            images:        undefined,//图片集合
            attribute:    "_lazysrc",//保存原图地址的自定义属性
            holder:        "",//占位图
            "class":    "",//筛选样式
            getSrc:        undefined,//获取原图地址程序
            onLoad:        function(){}//加载时执行
        }, $$.extend( options, {
            onLoadData:    this._onLoadData
        })));
    },
    //筛选整理图片对象
    _filter: function(cls, getSrc, holder, img) {
        if ( cls && img.className !== cls ) return false;//排除样式不对应的
        //获取原图地址
        var src = getSrc(img);
        if ( !src ) return false;//排除src不存在的
        if ( src == img.src ) {
            //排除已经加载或不能停止加载的
            if ( img.complete || $$B.chrome || $$B.safari ) return false;
            img.removeAttribute("src");//移除src
        }
        if ( holder ) {
            img.src = holder;
        }
        //用自定义属性记录原图地址
        img.setAttribute( this._attribute, src );
        return true;
    },
    //显示图片
    _onLoadData: function(img) {
        var attribute = this._attribute;
        if ( this._hasAttribute( img ) ) {
            img.src = img.getAttribute( attribute );
            img.removeAttribute( attribute );
            this.onLoad( img );
        }
    }
});