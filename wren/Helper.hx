package wren;


import haxe.Constraints.Function;
import wren.WrenVM;
import wren.Wren.WrenType;
import wren.Wren.WrenInterpretResult;

import wren.Wren;
import Type;


typedef WrenErr = String;


class Helper {

	public static function writeErr(vm:WrenVM, errorType:WrenErrorType,  module:cpp.ConstCharStar, line:Int, message:cpp.ConstCharStar) {
		switch errorType {
			case WrenErrorType.WREN_ERROR_COMPILE:
				Sys.println('compilation error: ${module.toString()}:${line}: ${message.toString()}');
			case WrenErrorType.WREN_ERROR_RUNTIME:
				Sys.println('runtime error: ${message.toString()}');
			case WrenErrorType.WREN_ERROR_STACK_TRACE:
				Sys.println('\t${module.toString()}:${line}: ${message.toString()}');
			default:
				throw "impossible error type";
		}
	}

	public static function interpretResultToErr(result:WrenInterpretResult):WrenErr {
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
					switch(c){
						case String: Wren.setSlotString(vm, slot, value);
						case _:
					}
					
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
						untyped __cpp__('::Dynamic* val = (::Dynamic*)wrenGetSlotForeign(vm1,slot1)');
						return untyped __cpp__('*val');
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
