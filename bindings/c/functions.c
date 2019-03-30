#include "inc.h"

static void test_add(WrenVM *vm);{
	::Dynamic* arg0 = (::Dynamic*) wrenGetSlotForeign(vm, 0);
	auto arg1 = linc::wren::getFromSlot(vm, 1);
	auto arg2 = linc::wren::getFromSlot(vm, 2);
	::Test::add(arg0, arg1, arg2);
}
static void myclass_add(WrenVM *vm);{
	::Dynamic* arg0 = (::Dynamic*) wrenGetSlotForeign(vm, 0);
	auto arg1 = linc::wren::getFromSlot(vm, 1);
	auto arg2 = linc::wren::getFromSlot(vm, 2);
	::MyClass::add(arg0, arg1, arg2);
}
static void test_constructor(WrenVM *vm);{
	wrenSetSlotNewForeign(vm, 0, 0, sizeof(::Dynamic));
	::Test::constructor();
}
static void myclass_constructor(WrenVM *vm);{
	wrenSetSlotNewForeign(vm, 0, 0, sizeof(::Dynamic));
	auto arg0 = linc::wren::getFromSlot(vm, 1);
	::MyClass::constructor(arg0);
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