package openfl;


class Sprite extends DisplayObject {
    private var __sprite:openfl.display.Sprite;

    @:isVar public var width(get, set):Int;
    @:isVar public var height(get, set):Int;

    public function new() {
        __sprite = new openfl.display.Sprite()
    }
}