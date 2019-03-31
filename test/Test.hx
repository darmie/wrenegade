import MyClass;
import wren.VM;

class Test extends wren.WrenClass {
	public static var initializer:Dynamic = {};

	public static function main() {
		var program:String = 'foreign class Test {
            construct new() {}
            foreign add(x, y)
        }
        var test = Test.new()
        test.add(5, 20)';
		var vm = new VM();
		try {
			var err = vm.interpret("main", program);
			if (err != null) {
				throw err;
			}

			// var val = vm.variable("Bird").call("fly(_)",["Chicago"]);
			// trace(val);
		} catch (e:Dynamic) {
			throw e;
		}
	}

	override static public function constructor():Dynamic {
		return initializer;
	}

	static public function add(c:Dynamic, x:Dynamic, y:Dynamic) {
		trace(x + y);
	}
}
