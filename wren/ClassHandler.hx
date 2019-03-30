package wren;


@:keep
@:keepSub
class ClassHandler {
    @:keep public static var name:String;
    @:keep public static var methods:Array<MethodHandler>;
    @:keep public static var count:Int = 0;
    @:keep public static var callback:WrenVM->Void;

    @:keep public static function constructor(vm:WrenVM):Void {
        callback(vm);
    }

    @:keep public static function setMethod(method:MethodHandler)
    {
        methods.push(method);
        count++;
    }

    @:keep public static function getMethod(signature:String, isStatic:Bool):MethodHandler {
        for(i in 0...methods.length){
            var method = methods[i];

            if(method.registry.signature == signature && method.registry.isStatic == isStatic){
                return method;
            }

        }
        return null;
    }
}