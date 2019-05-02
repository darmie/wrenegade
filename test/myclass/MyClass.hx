package myclass;
import wren.VM;

class MyClass extends wren.WrenClass {
    @:keep public var prop:String = "Yada!";
    public function new(){}

    public function add(x:Int, y:Int) {
        trace(x+y);
    }


    public function callDyn(v:Dynamic) {
        if(Std.is(v, MyClass)){
            v.add(5, 8);
        }else {
            trace(v);
        }
    }
}