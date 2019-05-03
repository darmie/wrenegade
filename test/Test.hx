


import myclass.MyClass;
import myclass.subpack.Hello;
// import myclass.MySuperClass;
import wren.VM;
// import openfl.display.Sprite;


class Test /*extends wren.WrenClass*/ {

	public static function main() {
        // runStatic();
        runInstance();
    }

	// private static function runStatic() {
	// 	var program:String = '
    //     foreign class Test {
    //         foreign static add(x, y)
    //     }
    //     Test.add(5, 20)';
	// 	var vm = new VM();
	// 	try {
	// 		var err = vm.interpret("main", program);
	// 		if (err != null) {
	// 			throw err;
	// 		}
	// 		vm.stop();
	// 	} catch (e:Dynamic) {
	// 		throw e;
	// 	}
	// }


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

	// static public function add(x:Dynamic, y:Dynamic) {
	// 	trace(x + y);
	// }
}
