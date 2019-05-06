package myclass.subpack;



import wren.WrenClass;

@:keep
@:keepSub
class Hello extends WrenClass {
    public function new(){}

    public function shout(callback):Dynamic {
        var v = callback(["here"]);
        return v;
    }
}