package wren;


@:autoBuild(wren.Wrenegade.bind())
@:keep 
@:keepSub
class WrenClass {
    public static function constructor():Dynamic{
        return {};
    }


    public static function add(c:Dynamic, x:Int, y:Int):Int{
        return x+y;
    }
}