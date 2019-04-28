![Wrenegade](Wrenegade.png)


# Wrenegade
Wrenegade is a toolkit for developing backends for embedded [Wren](http://wren.io) based projects. 

It's API is provided in [Haxe](https://haxe.org), a powerful programming language, which eventually compiles to C/C++. 


## Getting Started
Install Haxe (v 4.0.0-rc-2) => [Download](https://haxe.org/download/version/4.0.0-rc.2)

Install Haxe project dependencies: (run the respective commands in your terminal)
1. Yaml parser => `haxelib install yaml`
2. HXCPP (Haxe C++ compiler) => `haxelib install hxcpp`

3. hxnew (for generating new Haxe project) => `haxelib install hxnew`


### __Using Wrenegade in your Haxe/C++ project__
__Create a new Haxe project if you haven't__:

`haxelib run hxnew -name MyProject -target cpp`

This will generate a new Haxe/C++ project in `MyProject` directory

__Clone Wrenegade repository into your project root__: 

`git clone https://github.com/darmie/wrenegade.git`

Edit the `build.hxml` file in your project root to reference wrenegade:

Add these lines at the top of the file: _(replace `{project_root}` with the relative path to your project)_

```yaml
-cp {project_root}/wrenegade/wren
-cp {project_root}/src ## path to your project source, let's assume it's ./src

-lib yaml

-cpp bin/cpp ## Tell haxe where to put the generated C++ files and binary

-main MyProject  ## Name of the haxe class that has a static main function
```


__Configure your project__: 

Create a config file called `.wrenconfig` in your project root
```yaml
bindpath: "bindings" #relative to your project dir
wrenlib: "::dir::/wrenegade/lib/wren" #absolute path to your wren lib
wrensrc: "::dir::" #absolute path to your haxe project that will use Wrenegade tool
```

__Create your first Wren foreign class__:

_note that for Wrenegade to gerate bindings, your haxe class must extend wren.WrenClass_

`{project_root}/src/myclass/MyClass.hx`

```haxe
package myclass;
import wren.VM;

class MyClass extends wren.WrenClass {
    @:keep public var prop:String = "Yada!";
    private static var instance:MyClass;
    public static function getInstance():MyClass{
        if(instance == null){
            instance = new MyClass();
        }
        return instance;
    }
    public function new(){}

    public function add(x:Int, y:Int) {
        trace(x+y);
    }


    public function callDyn(v:Dynamic) {
        if(Std.is(v, MyClass)){
            v.add(5, 8);
        }else {
            trace(v);
        }
    }
}
```

For instance properties and fields to be recognized by Wrenegade, you must declare a static call to your class called `getInstance()`

Wrenegade will automatically generate binding functions for your class in the bindings directory you provided in `.wrenconfig`

_generated c/c++ binding functions_

`{project_root}/bindings/c/functions.cpp`
```cpp
static void myclass_myclass_prop_set(WrenVM *vm){
	
	::Dynamic* value = (::Dynamic*)wrenGetSlotForeign(vm, 1);
	*value = ::wren::Helper_obj::getFromSlot(vm, 1);
	 ::myclass::MyClass_obj::getInstance()->prop = *value;
}

static void myclass_myclass_prop_get(WrenVM *vm){
	
	auto val = ::myclass::MyClass_obj::getInstance()->prop;
	::ValueType type = ::Type_obj::_hx_typeof(val);
	::wren::Helper_obj::saveToSlot(vm, 0, val, type);
}

static void myclass_myclass_add(WrenVM *vm){
	
	auto arg0 = ::wren::Helper_obj::getFromSlot(vm, 1);
	auto arg1 = ::wren::Helper_obj::getFromSlot(vm, 2);
	::myclass::MyClass_obj::getInstance()->add(arg0, arg1);
}

static void myclass_myclass_calldyn(WrenVM *vm){
	
	auto arg0 = ::wren::Helper_obj::getFromSlot(vm, 1);
	::myclass::MyClass_obj::getInstance()->callDyn(arg0);
}
static void myclass_myclass_new(WrenVM *vm){
	myclass::MyClass* constructor = (myclass::MyClass*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(myclass::MyClass));
	auto data = ::myclass::MyClass_obj::__new();
	std::memcpy(constructor, &data, sizeof(myclass::MyClass));
}


WrenForeignMethodFn bindMethod(const char* module, const char* signature) {
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.prop=(_)") == 0) return myclass_myclass_prop_set;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.prop") == 0) return myclass_myclass_prop_get;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.add(_,_)") == 0) return myclass_myclass_add;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.callDyn(_)") == 0) return myclass_myclass_calldyn;	}
	return NULL;
}

void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods) {
	if (strcmp(module, "myclass") == 0){
		if (strcmp(className, "MyClass") == 0) { 
			methods->allocate = myclass_myclass_new; 
 			return; 
		}
	}
}
```

__Embedding Wren scripts__:

Create an equivalent of your class in Wren language:

`{project_root}/scripts/myclass.wren`

```dart
foreign class MyClass {
    construct new(){}
    foreign add(x, y)
    foreign callDyn(v)
    foreign prop=(value) // Setter for the `prop` property
    foreign prop // Getter for the `prop` property
}
```

Create a main entry point to your Wren program:

`{project_root}/scripts/main.wren`

```dart
import "myclass" for MyClass

var mclass = MyClass.new()
mclass.add(5, 40)
mclass.callDyn("test_string")
mclass.callDyn(1080)
mclass.callDyn(mclass)

// Make sure the handle lives through a GC.
System.gc()

System.print(mclass.prop)
mclass.prop = "hello world"

// Make sure the handle lives through a GC.
System.gc()

System.print(mclass.prop)
```

Run your Wren script from Haxe:

`{project_root}/src/MyProject.hx`

```haxe
import myclass.MyClass;
import wren.VM;

class MyProject {
	public static function main() {
		
		var vm = new VM();
		try {
			var err = vm.interpretFile("main", "../scripts/main.wren");
			if (err != null) {
				throw err;
			}
			vm.stop();
		} catch (e:Dynamic) {
			throw e;
		}
	}
}

```


__Build your project__:

`haxe build.hxml`

This will generate and compile C++ files for your project in `{project_root}/bin/cpp`

Test your project binary by running `{project_root}/bin/cpp/MyProject` in terminal



# Why Wrenegade?
You are probably thinking of embedding a scripting interface in your projects (games, game engines or interactive applications), and you want a light weight, fast object oriented scripting language, Wren is the best choice.

The purpose of Wrenegade is to make it easier to expose Haxe APIs to your embedded Wren scripts without much work. You can provide access to native functions by simply creating an Haxe class, that's how easy it is.


# State of the Wren
This project was created with love, and it is one of the many side projects I work on in my spare time. I can not call Wrenegade a alpha, beta or production ready tool, you may at one point encounter issues. Please feel free to fix the issue if you can, and then open a pull request, your contributions are welcome.



# LICENSE

MIT License

Copyright (c) 2019 Damilare Akinlaja

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.