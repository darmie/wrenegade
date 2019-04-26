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
	public static var instance:WrenVM;
	private var vm:WrenVM;

	private static var classes:Array<String> = [];

	/**
	 * creates a new Wren virtual machine.
	 */
	public function new() {

		this.vm = Wren.newVM();
		VM.instance = this.vm;
	}

	public function stop() {
		Wren.freeVM(this.vm);
	}

	public function GC() {
		Wren.collectGarbage(this.vm);
	}

	public function interpret(module:String, source:String):String { // error string
		return Helper.interpretResultToErr(Wren.interpret(this.vm, module, source));
	}

	public function interpretFile(module:String, filePath:String):String {
		var file = sys.io.File.getContent(filePath);
		return this.interpret(module, file);
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


}
