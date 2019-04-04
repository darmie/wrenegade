#include "functions.h"
#include <wren/Helper.h>
#include <test/Test.h>
#include <test/Test.h>
#include <test/MyClass.h>
#include <test/MyClass.h>
namespace bindings {
namespace functions {

static void test_test_init(WrenVM *vm){
	
	::test::Test_obj::init();
}
static void test_test_add(WrenVM *vm){
	
	auto arg0 = ::wren::Helper_obj::getFromSlot(vm, 1);
	auto arg1 = ::wren::Helper_obj::getFromSlot(vm, 2);
	::test::Test_obj::add(arg0, arg1);
}
static void test_myclass_add(WrenVM *vm){
	
	auto arg0 = ::wren::Helper_obj::getFromSlot(vm, 1);
	auto arg1 = ::wren::Helper_obj::getFromSlot(vm, 2);
	::test::MyClass_obj::getInstance()->add(arg0, arg1);
}
static void test_myclass_new(WrenVM *vm){
	test::MyClass* constructor = (test::MyClass*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(test::MyClass));
	auto data = ::test::MyClass_obj::__new();
	std::memcpy(constructor, &data, sizeof(test::MyClass));
}


WrenForeignMethodFn bindMethod(const char* signature) {
	if (strcmp(signature, "static Test.init(_)") == 0) return test_test_init;
	if (strcmp(signature, "static Test.add(_,_)") == 0) return test_test_add;
	if (strcmp(signature, "MyClass.add(_,_)") == 0) return test_myclass_add;
	return NULL;
}

void bindClass(const char* className, WrenForeignClassMethods* methods) {
	if (strcmp(className, "MyClass") == 0) { 
		methods->allocate = test_myclass_new; 
 		return; 
	}
}
}
}