
package test;

import wren.VM;


class Test extends wren.WrenClass {

	public static function main() {
        runInstance();
    }


	static public function add(x:Dynamic, y:Dynamic) {
		trace(x + y);
	}


	private static function runInstance() {
		
		var vm = new VM();
		try {
			var err = vm.interpretFile("main", "main.wren");
			if (err != null) {
				throw err;
			}
			vm.stop();
		} catch (e:Dynamic) {
			throw e;
		}
	}
}
