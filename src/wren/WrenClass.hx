package wren;


@:autoBuild(wren.Wrenegade.bind())
@:keep 
@:keepSub
class WrenClass {
    public static function constructor():Dynamic{
        return WrenClass;
    }
}