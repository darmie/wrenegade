package wren;

import wren.Wren;
import wren.Helper;


@:autoBuild(wren.Wrenegade.bind())
@:keep 
@:keepSub
class WrenClass {
    public static function constructor():Dynamic{
        return WrenClass;
    }
}