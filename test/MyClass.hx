
package test;

class MyClass extends wren.WrenClass {
    private static var instance:MyClass;
    public static function getInstance():MyClass{
        if(instance == null){
            instance = new MyClass();
        }
        return instance;
    }
    public function new(){}

    public function add(x:Int, y:Int) {
        trace(x+y);
    }
}