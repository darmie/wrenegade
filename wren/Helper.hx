package wren;

import cpp.abi.Abi;
import haxe.Constraints.Function;
import wren.WrenVM;
import wren.Wren.WrenType;
import wren.Wren.WrenInterpretResult;

import wren.Wren;

import haxe.rtti.Rtti;

import haxe.rtti.CType.CTypeTools;


class Helper {


	

	public static function getParams(vm:WrenVM, numargs:Int):Array<Dynamic>{
		var params = [];
		var offset:Int = 0;
        var numargs = 1;
		for (i in 0...numargs) {
			var slot = i + offset;
			trace(slot);

			// If the receiver value is inaccessible from C, it likely just means that
			// it's a native class with a foreign method. Rather than panic, we simply
			// advance to the first parameter and continue from there.
			if (i == 0 && Helper.getSlotType(vm, slot) == wren.Wren.WrenType.WREN_TYPE_UNKNOWN) {
				offset++;
				slot++;
			}
			var v = Helper.getFromSlot(vm, slot);
			trace(v);
			params.push(v);
		}

		return params;
	}


	public static function newForeign(vm:WrenVM, x:Dynamic){
		trace(x);
		var data = Wren.setSlotNewForeign(vm, 0, 0, 8);

		trace(data);

		var fs = Reflect.fields(Type.getClass(data));

		for(i in 0...fs.length){
			var name = fs[i];
			var f = Reflect.field(Type.getClass(data), name);
			Reflect.setField(Type.getClass(x), name, f);
		}
	}

	// handle static functions
	public static function handleFunction(vm:WrenVM, _classPath:String, funcName:String) {
		var inspect = Rtti.getRtti(Type.resolveClass(_classPath)).statics;
		var params:Array<Dynamic> = [];
		for (func in inspect) {
			if (func.name == funcName) {
				switch (func.type) {
					case haxe.rtti.CType.CFunction(args, b):
						{
							var offset:Int = 0;
							for (i in 0...args.length) {
								
								var slot = i + offset;
								trace(slot);

								// If the receiver value is inaccessible from C, it likely just means that
								// it's a native class with a foreign method. Rather than panic, we simply
								// advance to the first parameter and continue from there.
								if (i == 0 && Wren.getSlotType(vm, slot) == WrenType.WREN_TYPE_UNKNOWN) {
									offset++;
									slot++;
								}
								var v = getFromSlot(vm, slot);
								trace(v);
								params.push(v);
							}

							var func = Reflect.field(Type.getClass(_classPath), funcName);
							var res = Reflect.callMethod(Type.getClass(_classPath), func, params);
							trace(res);
							saveToSlot(vm, 0, res, Type.typeof(res));
						}
					case _:
				}
			}
		}
	}

	public static function writeErr(vm:WrenVM, errorType:WrenErrorType,  module:cpp.ConstCharStar, line:Int, message:cpp.ConstCharStar) {
		switch errorType {
			case WrenErrorType.WREN_ERROR_COMPILE:
				trace('compilation error: ${module.toString()}:${line}: ${message.toString()}\n');
			case WrenErrorType.WREN_ERROR_RUNTIME:
				trace('runtime error: ${message.toString()}');
			case WrenErrorType.WREN_ERROR_STACK_TRACE:
				trace('\t${module.toString()}:${line}: ${message.toString()}\n');
			default:
				throw "impossible error type";
		}
	}

	public static function interpretResultToErr(result:WrenInterpretResult):Dynamic {
		return switch (result) {
			case WrenInterpretResult.WREN_RESULT_SUCCESS: null;
			case WrenInterpretResult.WREN_RESULT_COMPILE_ERROR: "compilation error";
			case WrenInterpretResult.WREN_RESULT_RUNTIME_ERROR: "runtime error";
			default: throw "unreachable";
		}
	}

	public static function getSlotType(vm:WrenVM, slot:Int):WrenType{
		return Wren.getSlotType(vm, slot);
	}

	// public static function setSlotNewForeign(vm:WrenVM, slot:Int, classSlot:Int, size:UInt):Dynamic {
	// 	return Wren.setSlotNewForeign(vm, 0, 0, 8);
	// }

	public static function saveToSlot(vm:WrenVM, slot:Int, value:Dynamic, type:Type.ValueType):Void {
		switch (type) {
			case TInt:
				{
					Wren.setSlotDouble(vm, slot, value);
				}
			case  TFloat:
				{
					Wren.setSlotDouble(vm, slot, value);
				}
			case TBool:
				{
					Wren.setSlotBool(vm, slot, value);
				}
			case TClass(c):
				{
					Wren.setSlotString(vm, slot, value);
				}
			case TNull:
				{
					Wren.setSlotNull(vm, slot);
				}
			case TUnknown:{
					Wren.setSlotNull(vm, slot);
			}
			default:
				{
					throw 'don\'t know how to save this to a slot: ${type}';
				}
		}
	}

	public static function getFromSlot(vm:WrenVM, slot:Int):Dynamic {
		function getValue(vm, slot):Dynamic {
			return switch (Wren.getSlotType(vm, slot)) {
				case WrenType.WREN_TYPE_BOOL: {
						return Wren.getSlotBool(vm, slot);
					}
				case WrenType.WREN_TYPE_NUM: {
						return Wren.getSlotDouble(vm, slot);
					}
				case WrenType.WREN_TYPE_FOREIGN: {
						return Wren.getSlotForeign(vm, slot);
					}
				case WrenType.WREN_TYPE_LIST: {
						var count:Int = Wren.getListCount(vm, slot);
						var bucket:Array<Dynamic> = [];
						for (i in 0...count) {
							Wren.getListElement(vm, slot, i, 0);
							var elem = getValue(vm, 0);
							bucket.push(elem);
						}
						return bucket;
					}
				case WrenType.WREN_TYPE_NULL: {
						return null;
					}
				case WrenType.WREN_TYPE_STRING: {
						return Wren.getSlotString(vm, slot);
					}
				case WrenType.WREN_TYPE_UNKNOWN: {
						throw 'received an inaccessible-from-C parameter in slot ${slot}';
					}
				default: {
						throw "unreachable";
					}
			}
		}

		return getValue(vm, slot);
	}
}
