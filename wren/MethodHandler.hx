package wren;

typedef MethodRegistry = {
    var isStatic:Bool;
    var signature:String;
}

class MethodHandler {
    public var registry:MethodRegistry;
    public var handler:WrenVM->Void;

    public function new(isStatic:Bool, signature:String, callback:WrenVM->Void){
        handler = callback;
        this.registry = {
            isStatic: isStatic,
            signature: signature
        };
       
    }

    public function call(vm:WrenVM){
        handler(vm);
    }
}