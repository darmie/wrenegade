#include "functions.h"
#include <wren/Helper.h>
#include <Test.h>
#include <Test.h>
#include <myclass/MyClass.h>
#include <myclass/MyClass.h>
namespace bindings {
namespace functions {

static void test_init(WrenVM *vm){
	
	::Test_obj::init();
}
static void test_add(WrenVM *vm){
	
	auto arg0 = ::wren::Helper_obj::getFromSlot(vm, 1);
	auto arg1 = ::wren::Helper_obj::getFromSlot(vm, 2);
	::Test_obj::add(arg0, arg1);
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
	if (strcmp(module, "main") == 0){		if (strcmp(signature, "static Test.init(_)") == 0) return test_init;	}
	if (strcmp(module, "main") == 0){		if (strcmp(signature, "static Test.add(_,_)") == 0) return test_add;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.add(_,_)") == 0) return myclass_myclass_add;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.callDyn(_)") == 0) return myclass_myclass_calldyn;	}
	return NULL;
}

void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods) {
	if (strcmp(className, "MyClass") == 0) { 
		methods->allocate = myclass_myclass_new; 
 		return; 
	}
}
}
}