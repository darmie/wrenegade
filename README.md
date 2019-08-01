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
-cp {project_root}/wrenegade/
-cp {project_root}/src ## path to your project source, let's assume it's ./src

-dce std  # Dead code elimination. Reduce overrall package size to only stuff we need. https://haxe.org/manual/cr-dce.html
-lib yaml

# list of standard haxe packages that wrenegade needs. Important!
Type
Std

# list of Haxe classes we need to generate bindings for
myclass.MyClass
myclass.subpack.Hello

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

class MyClass extends MySuperClass {
    @:keep public var prop:String = "Yada!";
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
Wrenegade will automatically generate binding functions for your class in the bindings directory you provided in `.wrenconfig`

_generated wren externs_

`{project_root}/bindings/wren/myclass.wren`

```dart 

foreign class MyClass {
	construct new(){}
	foreign prop=(arg1)
	foreign prop
	foreign add(arg1,arg2)
	foreign callDyn(arg1)
	foreign superProp=(arg1)
	foreign superProp
	foreign graphicsBeginFill(arg1,arg2)
}


foreign class MySuperClass {
	construct new(){}
	foreign superProp=(arg1)
	foreign superProp
	foreign graphicsBeginFill(arg1,arg2)
}

```

_generated c/c++ binding functions_

`{project_root}/bindings/c/myclass/MyClass/functions.cpp`
```cpp
namespace myclass_MyClass_functions {

static void myclass_myclass_prop_set(WrenVM *vm){
	
	::Dynamic* value = (::Dynamic*)wrenGetSlotForeign(vm, 1);
	*value = wrenegade::helper::getFromSlot(vm, 1);
	::myclass::MyClass inst = (::myclass::MyClass)wrenegade::helper::getFromSlot(vm, 0);
	inst->prop = *value;
}

static void myclass_myclass_prop_get(WrenVM *vm){
	
	::myclass::MyClass inst = (::myclass::MyClass)wrenegade::helper::getFromSlot(vm, 0);
	auto val = inst->prop;
	::ValueType type = ::Type_obj::_hx_typeof(val);
	wrenegade::helper::saveToSlot(vm, 0, val, type);
}

static void myclass_myclass_add(WrenVM *vm){
	
	auto arg0 = wrenegade::helper::getFromSlot(vm, 1);
	auto arg1 = wrenegade::helper::getFromSlot(vm, 2);
	::myclass::MyClass inst = (::myclass::MyClass)wrenegade::helper::getFromSlot(vm, 0);
	inst->add(arg0, arg1);
}

static void myclass_myclass_calldyn(WrenVM *vm){
	
	auto arg0 = wrenegade::helper::getFromSlot(vm, 1);
	::myclass::MyClass inst = (::myclass::MyClass)wrenegade::helper::getFromSlot(vm, 0);
	inst->callDyn(arg0);
}

static void myclass_myclass_superprop_set(WrenVM *vm){
	
	::Dynamic* value = (::Dynamic*)wrenGetSlotForeign(vm, 1);
	*value = wrenegade::helper::getFromSlot(vm, 1);
	::myclass::MyClass inst = (::myclass::MyClass)wrenegade::helper::getFromSlot(vm, 0);
	inst->superProp = *value;
}

static void myclass_myclass_superprop_get(WrenVM *vm){
	
	::myclass::MyClass inst = (::myclass::MyClass)wrenegade::helper::getFromSlot(vm, 0);
	auto val = inst->superProp;
	::ValueType type = ::Type_obj::_hx_typeof(val);
	wrenegade::helper::saveToSlot(vm, 0, val, type);
}

static void myclass_myclass_graphicsbeginfill(WrenVM *vm){
	
	auto arg0 = wrenegade::helper::getFromSlot(vm, 1);
	auto arg1 = wrenegade::helper::getFromSlot(vm, 2);
	::myclass::MyClass inst = (::myclass::MyClass)wrenegade::helper::getFromSlot(vm, 0);
	inst->graphicsBeginFill(arg0, arg1);
}
static void myclass_myclass_new(WrenVM *vm){
	::myclass::MyClass* constructor = (myclass::MyClass*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(::myclass::MyClass));
	::myclass::MyClass_obj obj;
	auto data = obj.__new();
	std::memcpy(constructor, &data, sizeof(::myclass::MyClass));
}


WrenForeignMethodFn bindMethod(const char* signature) {
	if (strcmp(signature, "MyClass.prop=(_)") == 0) return myclass_myclass_prop_set;
	if (strcmp(signature, "MyClass.prop") == 0) return myclass_myclass_prop_get;
	if (strcmp(signature, "MyClass.add(_,_)") == 0) return myclass_myclass_add;
	if (strcmp(signature, "MyClass.callDyn(_)") == 0) return myclass_myclass_calldyn;
	if (strcmp(signature, "MyClass.superProp=(_)") == 0) return myclass_myclass_superprop_set;
	if (strcmp(signature, "MyClass.superProp") == 0) return myclass_myclass_superprop_get;
	if (strcmp(signature, "MyClass.graphicsBeginFill(_,_)") == 0) return myclass_myclass_graphicsbeginfill;
	return NULL;
}

void bindClass(WrenForeignClassMethods* methods) {
	methods->allocate = myclass_myclass_new; 
 	return;
}
}
```

__Embedding Wren scripts__:

Wrenegade generated wren foreign classes will be generated at `{project_root}/bindings/wren/`, but it will be available at `foreign/` at runtime;

Create a main entry point to your Wren program:

`{project_root}/scripts/main.wren`

```js
import "foreign/myclass" for MyClass  // This will import 'myclass' module from '{project_root}/bindings/wren/myclass'

var mclass = MyClass.new()
mclass.add(5, 40)

mclass.callDyn("test_string")
mclass.callDyn(1080)
mclass.callDyn(mclass)

mclass.graphicsBeginFill(0x00FFFF,  1)

System.print(mclass.prop)
mclass.prop = "hello world"

System.print(mclass.prop)

System.print(mclass.superProp)

mclass.superProp = "super yada!"

System.print(mclass.superProp)
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
