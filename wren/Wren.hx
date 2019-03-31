package wren;

import haxe.Constraints.Function;
import cpp.ConstCharStar;
import cpp.UInt8;
import wren.WrenVM;
import wren.WrenHandle;

@:keep
@:include('linc_wren.h')
#if !display
@:build(linc.Linc.touch())
@:build(linc.Linc.xml('wren'))
#end
extern class Wren {
	@:native('linc::wren::newVM')
	static function newVM(?config:WrenConfiguration):WrenVM;
	
	@:native('wrenFreeVM')
	static function freeVM(vm:WrenVM):Void;
	@:native('wrenCollectGarbage')
	static function collectGarbage(vm:WrenVM):Void;
	@:native('wrenInterpret')
	static function interpret(vm:WrenVM, module:String, source:String):WrenInterpretResult;
	@:native('wrenMakeCallHandle')
	static function makeCallHandle(vm:WrenVM, signature:String):WrenHandle;
	@:native('wrenCall')
	static function call(vm:WrenVM, method:WrenHandle):WrenInterpretResult;
	@:native('wrenReleaseHandle')
	static function releaseHandle(vm:WrenVM, value:WrenHandle):Void;
	@:native('wrenGetSlotCount')
	static function getSlotCount(vm:WrenVM):Int;
	@:native('wrenEnsureSlots')
	static function ensureSlots(vm:WrenVM, numSlots:Int):Void;
	@:native('wrenGetSlotType')
	static function getSlotType(vm:WrenVM, slot:Int):WrenType;
	@:native('wrenGetSlotBool')
	static function getSlotBool(vm:WrenVM, slot:Int):Bool;
	@:native('wrenGetSlotBytes')
	static function getSlotBytes(vm:WrenVM, slot:Int, length:Int):Bool;
	@:native('wrenGetSlotDouble')
	static function getSlotDouble(vm:WrenVM, slot:Int):Float;
	@:native('wrenGetSlotForeign')
	static function getSlotForeign(vm:WrenVM, slot:Int):Dynamic;
	@:native('linc::wren::getSlotString')
	static function getSlotString(vm:WrenVM, slot:Int):String;
	@:native('wrenGetSlotHandle')
	static function getSlotHandle(vm:WrenVM, slot:Int):WrenHandle;
	@:native('wrenSetSlotBool')
	static function setSlotBool(vm:WrenVM, slot:Int, value:Bool):Void;
	@:native('wrenSetSlotBytes')
	static function setSlotBytes(vm:WrenVM, slot:Int, bytes:String, length:UInt):Void;
	@:native('wrenSetSlotDouble')
	static function setSlotDouble(vm:WrenVM, slot:Int, value:Float):Void;
	@:native('wrenSetSlotNewForeign')
	static function setSlotNewForeign(vm:WrenVM, slot:Int, classSlot:Int, size:UInt):cpp.Pointer<UInt8>;
	@:native('wrenSetSlotNewList')
	static function setSlotNewList(vm:WrenVM, slot:Int):Void;
	@:native('wrenSetSlotNull')
	static function setSlotNull(vm:WrenVM, slot:Int):Void;
	@:native('wrenSetSlotString')
	static function setSlotString(vm:WrenVM, slot:Int, text:String):Void;
	@:native('wrenSetSlotHandle')
	static function setSlotHandle(vm:WrenVM, slot:Int, value:WrenHandle):Void;
	@:native('wrenGetListCount')
	static function getListCount(vm:WrenVM, slot:Int):Int;
	@:native('wrenGetListElement')
	static function getListElement(vm:WrenVM, listSlot:Int, index:Int, elementSlot:Int):Void;
	@:native('wrenInsertInList')
	static function insertInList(vm:WrenVM, listSlot:Int, index:Int, elementSlot:Int):Void;
	@:native('wrenGetVariable')
	static function getVariable(vm:WrenVM, module:String, name:String, slot:Int):Void;
	@:native('wrenAbortFiber')
	static function abortFiber(vm:WrenVM, slot:Int):Void;
} // Wren

typedef WrenConfiguration = {
	@:optional var initialHeapSize:UInt;
	@:optional var minHeapSize:UInt;
	@:optional var heapGrowthPercent:Int;
} // WrenConfiguration

@:enum
abstract WrenInterpretResult(Int) from Int to Int {
	var WREN_RESULT_SUCCESS = 0;
	var WREN_RESULT_COMPILE_ERROR = 1;
	var WREN_RESULT_RUNTIME_ERROR = 2;
} // WrenInterpretResult

@:enum
abstract WrenErrorType(Int) from Int to Int {
	var WREN_ERROR_COMPILE = 0;
	var WREN_ERROR_RUNTIME = 1;
	var WREN_ERROR_STACK_TRACE = 2;
} // WrenErrorType

@:enum
abstract WrenType(Int) from Int to Int {
	var WREN_TYPE_BOOL = 0;
	var WREN_TYPE_NUM = 1;
	var WREN_TYPE_FOREIGN = 2;
	var WREN_TYPE_LIST = 3;
	var WREN_TYPE_NULL = 4;
	var WREN_TYPE_STRING = 5;
	var WREN_TYPE_UNKNOWN = 6;
} // WrenType
