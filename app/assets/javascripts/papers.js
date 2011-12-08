
//试卷筛选   注意其中  1 = Paper::CHECKED[:YES]    0 = Paper::CHECKED[:NO]    2 = Paper::CHECKED[:ALL]
  function select_checked(dom,category_id){
    if(dom.options[dom.selectedIndex].value=="2"){
      window.location.href="/papers?category="+category_id;
      return false;
    }
    if(dom.options[dom.selectedIndex].value=="0"){
      window.location.href="/papers?category="+category_id+"&checked=0";
      return false;
    }
    if(dom.options[dom.selectedIndex].value=="1"){
      window.location.href="/papers?category="+category_id+"&checked=1";
      return false;
    }
    return true;
  }
