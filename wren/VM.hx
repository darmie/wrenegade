package wren;

import cpp.ConstCharStar;
import cpp.RawPointer;
import haxe.Constraints.Function;
import haxe.rtti.Rtti;
import cpp.Callable;

/**
 * The Wren Virtual Machine
 */
class VM {
	private var vm:WrenVM;

	private static var classes:Array<String> = [];

	/**
	 * creates a new Wren virtual machine.
	 */
	public function new() {
		// var config:wren.Wren.WrenConfiguration = {
		// 	bindForeignClassFn: cpp.Callable.fromStaticFunction(VM.bindClass),
		// 	bindForeignMethodFn: cpp.Callable.fromStaticFunction(VM.bindMethod)
		// };
		this.vm = Wren.newVM();
	}

	public function stop() {
		Wren.freeVM(this.vm);
	}

	@:keep public function registerMethod(className:String, signature:String, isStatic:Bool, func:WrenVM->Void) {
		// var sig = ConstCharStar.fromString(signature);
		// var _className = ConstCharStar.fromString(className);

		VM.setMethod(className, signature, isStatic, func);
	}

	@:keep public function registerClass(className:String) {
		// var _className = ConstCharStar.fromString(className);
		VM.setClass(className);
	}

	public function GC() {
		Wren.collectGarbage(this.vm);
	}

	public function interpret(module:String, source:String):String { // error string
		return Helper.interpretResultToErr(Wren.interpret(this.vm, module, source));
	}

	public function interpretFile(module:String, filePath:String):String {
		var file = sys.io.File.getContent(filePath);
		return this.interpret("main", file);
	}

	public function variable(name:String):Value {
		var module = "main";
		var name = name;

		Wren.ensureSlots(this.vm, 1);
		Wren.getVariable(this.vm, module, name, 0);

		var value = new Value(vm);
		value.value = Wren.getSlotHandle(this.vm, 0);

		if (value.value == null) {
			return null;
		}

		// for (method in value.methods){
		//     Wren.releaseHandle(this.vm, method);
		// }

		// Wren.releaseHandle(this.vm, value.value);

		return value;
	}

	@:keep public static function setClass(_cls:String){
		VM.classes.push(_cls);
	}

	@:keep public static function setMethod(className:String, signature:String, isStatic:Bool, func:WrenVM->Void){
		var _cls = getClass(className);
		var m = new MethodHandler(isStatic, signature, func);
		Reflect.field(_cls, "setMethod")(m);
	}

	@:keep public static function getClass(className:String):Dynamic{
		for(i in 0...VM.classes.length){
			var cls = Type.resolveClass(VM.classes[i]);
			if(Reflect.hasField(cls, "name") && Reflect.field(cls, "name") == className){
				return cls;
			}
		}

		return null;
	}

	@:keep public static function bindMethod(vm:WrenVM, module:ConstCharStar, className:ConstCharStar, isStatic:Bool, signature:ConstCharStar):WrenForeignMethodFn {
		// trace('${className}.${signature}');
		if (module != "main") {
			return null;
		}
		var fullName = new StringBuf();
		if (isStatic) {
			fullName.add("static ");
		}
		fullName.add(className);
		fullName.add(".");
		fullName.add(signature);

		var _class = VM.getClass(className);

		var method:MethodHandler = Reflect.field(_class, "getMethod")(signature, isStatic);
		
		return method.call;
	}

	@:keep public static function bindClass(vm:WrenVM, module:ConstCharStar, className:ConstCharStar):WrenForeignClassMethods {
		if (module != "main") {
			throw "tried to bind foreign class from non-main module";
		}

		// var wrenMethods:WrenForeignClassMethods = untyped __cpp__("WrenForeignClassMethods{}");
		var cls = getClass(className);
		var wrenMethods = Reflect.field(cls, "bindclass");
		// var func = allocator.bind(_, allo);
		// wrenMethods.allocate = untyped __cpp__("(WrenForeignMethodFn)  GodClass_obj.constructor");
		// wrenMethods.finalize = null;

		// trace(Reflect.fields(Type.getClass(wrenMethods)));
		return wrenMethods;
	}

	@:keep public static function allocator(vm:WrenVM, f:Dynamic){

	}
}
