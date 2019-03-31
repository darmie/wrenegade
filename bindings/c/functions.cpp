#include "../../linc/linc_wren.h"
#include "functions.h"
#include <wren/Helper.h>
#include <Test.h>
#include <MyClass.h>
namespace bindings {
namespace functions {

static void test_add(WrenVM *vm){
	auto value =  wrenGetSlotForeign(vm, 0);
	::Dynamic arg0 = (::Dynamic) ::cpp::CreateDynamicPointer(value);
	auto arg1 = ::wren::Helper_obj::getFromSlot(vm, 1);

	auto arg2 = ::wren::Helper_obj::getFromSlot(vm, 2);

	::Test_obj::add(arg0, arg1, arg2);
}
static void myclass_add(WrenVM *vm){
	auto value =  wrenGetSlotForeign(vm, 0);
	::Dynamic arg0 = (::Dynamic) ::cpp::CreateDynamicPointer(value);
	auto arg1 = ::wren::Helper_obj::getFromSlot(vm, 1);

	auto arg2 = ::wren::Helper_obj::getFromSlot(vm, 2);

	::MyClass_obj::add(arg0, arg1, arg2);
}
static void test_constructor(WrenVM *vm){
	wrenSetSlotNewForeign(vm, 0, 0, sizeof(::Dynamic));
	::Test_obj::constructor();
}
static void myclass_constructor(WrenVM *vm){
	wrenSetSlotNewForeign(vm, 0, 0, sizeof(::Dynamic));
	auto value = ::wren::Helper_obj::getFromSlot(vm, 1);
	::Dynamic arg0 = (::Dynamic) value;
	::MyClass_obj::constructor(arg0);
}


WrenForeignMethodFn bindMethod(const char* signature) {
	if (strcmp(signature, "Test.add(_,_)") == 0) return test_add;
	if (strcmp(signature, "MyClass.add(_,_)") == 0) return myclass_add;
	return NULL;
}

void bindClass(const char* className, WrenForeignClassMethods* methods) {
	if (strcmp(className, "Test") == 0) { 
		methods->allocate = test_constructor; 
 		return; 
	}
	if (strcmp(className, "MyClass") == 0) { 
		methods->allocate = myclass_constructor; 
 		return; 
	}
}
}
}