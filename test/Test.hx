
package test;

import wren.VM;
import wren.Globals;

class Test extends wren.WrenClass {

	public static function main() {
        runInstance();
    }


	static public function add(x:Dynamic, y:Dynamic):Dynamic {
		trace(x + y);
		return null;
	}


	private static function runInstance() {
		
		var vm = new VM();
		try {
			var err = vm.interpretFile("main", "main.wren");
			

			if (err != null) {
				throw err;
			}
			
			// vm.free();
		} catch (e:Dynamic) {
			throw e;
		}
		// var v = Globals.callback("main", "TestClass", "callback=(_)");
		// v(["hello World"]);
	}
}
