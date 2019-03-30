package test;

class Test extends wren.WrenClass {
    public static function main(){

    }

    override static public function constructor():Dynamic{
        return {};
    }

    static public function add(c:Dynamic, x:Int, y:Int):Int {
        return x+y;
    }
}