import MyClass;
import wren.VM;

class Test extends wren.WrenClass {
	@:keep public static var initializer:Dynamic = {
		hello: "world"
	};

	public static function main() {
        runStatic();
        runInstance();
    }

	private static function runStatic() {
		var program:String = '
        foreign class Test {
            foreign static add(x, y)
        }
        Test.add(5, 20)';
		var vm = new VM();
		try {
			var err = vm.interpret("main", program);
			if (err != null) {
				throw err;
			}
		} catch (e:Dynamic) {
			throw e;
		}
	}


	private static function runInstance() {
		
		var vm = new VM();
		try {
			var err = vm.interpretFile("main", "test/myclass.wren");
			if (err != null) {
				throw err;
			}
		} catch (e:Dynamic) {
			throw e;
		}
	}

	static public function init():Dynamic {
		return initializer;
	}

	static public function add(x:Dynamic, y:Dynamic) {
		trace(x + y);
	}
}
