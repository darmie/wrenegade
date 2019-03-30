import MyClass;


class Test extends wren.WrenClass {
    public static var initializer:Dynamic = {};
    public static function main(){

    }

    override static public function constructor():Dynamic{
        return initializer;
    }

    static public function add(c:Dynamic, x:Int, y:Int):Int {
        return x+y;
    }
}




