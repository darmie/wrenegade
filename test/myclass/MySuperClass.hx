package myclass;

import wren.WrenClass;

class MySuperClass  extends WrenClass {
    public var superProp:String = "super world";

    // private var baseSprite:openfl.display.Sprite;
    // private var graphics:openfl.display.Graphics;

   
    public function new(){
    //    baseSprite = new openfl.display.Sprite();
    //    graphics = baseSprite.graphics;
    }

    public function graphicsBeginFill(color:Int, alpha:Float):Dynamic {
        // graphics.beginFill(color, alpha);
        return null;
    }
}

