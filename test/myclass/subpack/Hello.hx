package myclass.subpack;



import wren.WrenClass;

@:keep
@:keepSub
class Hello extends WrenClass {
    public function new(){}

    public function shout(s) {
        trace(s);
    }
}