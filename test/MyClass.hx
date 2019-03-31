
class MyClass extends wren.WrenClass {
    override static public function constructor(x:Dynamic):Dynamic{
        return {
            x: x
        };
    }

    static public function add(c:Dynamic, x:Int, y:Int):Int {
        return x+y;
    }
}