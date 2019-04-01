#include "functions.h"
#include <wren/Helper.h>
#include <Test.h>
#include <MyClass.h>
namespace bindings {
namespace functions {

static void test_add(WrenVM *vm){
	
	auto arg0 = ::wren::Helper_obj::getFromSlot(vm, 1);
	auto arg1 = ::wren::Helper_obj::getFromSlot(vm, 2);
	::Test_obj::add(arg0, arg1);
}
static void myclass_add(WrenVM *vm){
	
	auto arg0 = ::wren::Helper_obj::getFromSlot(vm, 1);
	auto arg1 = ::wren::Helper_obj::getFromSlot(vm, 2);
	::MyClass_obj::getInstance()->add(arg0, arg1);
}
static void test_init(WrenVM *vm){
	cpp::Pointer<::Dynamic> handler = new cpp::Pointer<::Dynamic>();
	auto constructor = wrenSetSlotNewForeign(vm, 0, 0, sizeof(::Dynamic));
	auto data = ::Test_obj::init();
	&handler.set_ref(data);
	constructor = &handler;
}
static void myclass_new(WrenVM *vm){
	cpp::Pointer<::Dynamic> handler = new cpp::Pointer<::Dynamic>();
	auto constructor = wrenSetSlotNewForeign(vm, 0, 0, sizeof(::Dynamic));
	auto data = ::MyClass_obj::__new();
	&handler.set_ref(data);
	constructor = &handler;
}


WrenForeignMethodFn bindMethod(const char* signature) {
	if (strcmp(signature, "static Test.add(_,_)") == 0) return test_add;
	if (strcmp(signature, "MyClass.add(_,_)") == 0) return myclass_add;
	return NULL;
}

void bindClass(const char* className, WrenForeignClassMethods* methods) {
	if (strcmp(className, "Test") == 0) { 
		methods->allocate = NULL; 
 		return; 
	}
	if (strcmp(className, "MyClass") == 0) { 
		methods->allocate = myclass_new; 
 		return; 
	}
}
}
}