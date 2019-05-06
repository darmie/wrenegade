package wren;

import cpp.ConstCharStar;
import cpp.RawPointer;
import haxe.Constraints.Function;
import cpp.Callable;
import wren.Helper;
import wren.Globals;

/**
 * The Wren Virtual Machine
 */
class VM {
	public static var instance:VM;

	public var vm:wren.WrenVM;

	private static var classes:Array<String> = [];

	/**
	 * creates a new Wren virtual machine.
	 */
	public function new() {
		this.vm = Wren.newVM();

		VM.instance = this;
	}

	public function free() {
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

	public function value(module:String, name:String, signature:String, params:Array<Dynamic>) {
		trace(params);

		Wren.ensureSlots(this.vm, 2);
		Wren.getVariable(this.vm, module, name, 0);

		var value = new Value(this.vm);

		var rvalue = Wren.getSlotHandle(this.vm, 1);

		var f:wren.WrenHandle = Wren.makeCallHandle(this.vm, signature);

		Wren.ensureSlots(this.vm, (params.length + 2));
		Wren.setSlotHandle(this.vm, 0, rvalue);

		for (i in 0...params.length) {
			Helper.saveToSlot(this.vm, i + 1, params[i], Type.typeof(params[i]));
		}

		var errMsg = wren.Wren.call(this.vm, f);
		var err = Helper.interpretResultToErr(errMsg);

		if (err != null) {
			throw err;
		}

		return value.call.bind(f);
	}
}
