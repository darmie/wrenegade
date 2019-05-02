package myclass;

class MyClass extends MySuperClass {
    @:keep public var prop:String = "Yada!";
    public function new(){
        super();
    }

    public function add(x:Int, y:Int) {
        trace(x+y);
    }

    // override public function mult(x:Int, y:Int) {
    //     super.mult(x, y);
    // }


    public function callDyn(v:Dynamic) {
        if(Std.is(v, MyClass)){
            v.add(5, 8);
        }else {
            trace(v);
        }
    }
}