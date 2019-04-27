package wren;

import cpp.ConstCharStar;
import cpp.RawPointer;
import haxe.Constraints.Function;
import cpp.Callable;
import wren.Helper;

/**
 * The Wren Virtual Machine
 */
class VM {
	public static var instance:wren.WrenVM;
	private var vm:wren.WrenVM;

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

	public function interpret(module:String, source:String):WrenErr { // error string
		return Helper.interpretResultToErr(Wren.interpret(this.vm, module, source));
	}

	public function interpretFile(module:String, filePath:String):WrenErr {
		var file = sys.io.File.getContent(filePath);
		return this.interpret(module, file);
	}

	public function variable(name:String):wren.Value {
		var module = "main";
		var name = name;

		Wren.ensureSlots(this.vm, 1);
		Wren.getVariable(this.vm, module, name, 0);

		var value = new Value(vm);
		value.value = Wren.getSlotHandle(this.vm, 0);

		if (value.value == null) {
			return null;
		}

		return value;
	}


}
