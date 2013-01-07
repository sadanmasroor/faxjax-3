// stops IE6 repeat loading of CSS background images
// http://ajaxian.com/archives/no-more-ie6-background-flicker
if(document.all){
    try{
        document.execCommand("BackgroundImageCache", false, true);
    }catch(e){}
}
