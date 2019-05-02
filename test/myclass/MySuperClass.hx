package myclass;

class MySuperClass extends wren.WrenClass {
    public var superProp:String = "super world";
    public static function hello() {
        
    }
    public function new(){}


    public function mult(x, y){
        trace(x * y);
    }
}