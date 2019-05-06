package wren;


import wren.WrenClass;

class Globals extends WrenClass {

    public static function callback(module:String, className:String, fname:String) {
       return VM.instance.value.bind(module, className, fname);
    }
}