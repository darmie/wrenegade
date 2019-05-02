#include "functions.h"
#include <wren/Helper.h>
#include <Test.h>
static WrenHandle* Test_handle;
#include <myclass/MySuperClass.h>
static WrenHandle* myclass_MySuperClass_handle;
#include <myclass/MyClass.h>
static WrenHandle* myclass_MyClass_handle;
namespace bindings {
namespace functions {


static void test_add(WrenVM *vm){
	
	auto arg0 = ::wren::Helper_obj::getFromSlot(vm, 1);
	auto arg1 = ::wren::Helper_obj::getFromSlot(vm, 2);
	::Test_obj::add(arg0, arg1);
}

static void myclass_mysuperclass_superprop_set(WrenVM *vm){
	
	::Dynamic* value = (::Dynamic*)wrenGetSlotForeign(vm, 1);
	*value = ::wren::Helper_obj::getFromSlot(vm, 1);
	myclass::MyClass inst = (myclass::MyClass)::wren::Helper_obj::getFromSlot(vm, 0);
	inst->superProp = *value;
}

static void myclass_mysuperclass_superprop_get(WrenVM *vm){
	
	myclass::MyClass inst = (myclass::MyClass)::wren::Helper_obj::getFromSlot(vm, 0);
	auto val = inst->superProp;
	::ValueType type = ::Type_obj::_hx_typeof(val);
	::wren::Helper_obj::saveToSlot(vm, 0, val, type);
}

static void myclass_mysuperclass_hello(WrenVM *vm){
	
}

static void myclass_mysuperclass_mult(WrenVM *vm){
	
	auto arg0 = ::wren::Helper_obj::getFromSlot(vm, 1);
	auto arg1 = ::wren::Helper_obj::getFromSlot(vm, 2);
	myclass::MyClass inst = (myclass::MyClass)::wren::Helper_obj::getFromSlot(vm, 0);
	inst->mult(arg0, arg1);
}

static void myclass_myclass_superprop_set(WrenVM *vm){
	
	::Dynamic* value = (::Dynamic*)wrenGetSlotForeign(vm, 1);
	*value = ::wren::Helper_obj::getFromSlot(vm, 1);
	myclass::MyClass inst = (myclass::MyClass)::wren::Helper_obj::getFromSlot(vm, 0);
	inst->superProp = *value;
}

static void myclass_myclass_superprop_get(WrenVM *vm){
	
	myclass::MyClass inst = (myclass::MyClass)::wren::Helper_obj::getFromSlot(vm, 0);
	auto val = inst->superProp;
	::ValueType type = ::Type_obj::_hx_typeof(val);
	::wren::Helper_obj::saveToSlot(vm, 0, val, type);
}

static void myclass_myclass_mult(WrenVM *vm){
	
	auto arg0 = ::wren::Helper_obj::getFromSlot(vm, 1);
	auto arg1 = ::wren::Helper_obj::getFromSlot(vm, 2);
	myclass::MyClass inst = (myclass::MyClass)::wren::Helper_obj::getFromSlot(vm, 0);
	inst->mult(arg0, arg1);
}

static void myclass_myclass_prop_set(WrenVM *vm){
	
	::Dynamic* value = (::Dynamic*)wrenGetSlotForeign(vm, 1);
	*value = ::wren::Helper_obj::getFromSlot(vm, 1);
	myclass::MyClass inst = (myclass::MyClass)::wren::Helper_obj::getFromSlot(vm, 0);
	inst->prop = *value;
}

static void myclass_myclass_prop_get(WrenVM *vm){
	
	myclass::MyClass inst = (myclass::MyClass)::wren::Helper_obj::getFromSlot(vm, 0);
	auto val = inst->prop;
	::ValueType type = ::Type_obj::_hx_typeof(val);
	::wren::Helper_obj::saveToSlot(vm, 0, val, type);
}

static void myclass_myclass_add(WrenVM *vm){
	
	auto arg0 = ::wren::Helper_obj::getFromSlot(vm, 1);
	auto arg1 = ::wren::Helper_obj::getFromSlot(vm, 2);
	myclass::MyClass inst = (myclass::MyClass)::wren::Helper_obj::getFromSlot(vm, 0);
	inst->add(arg0, arg1);
}

static void myclass_myclass_calldyn(WrenVM *vm){
	
	auto arg0 = ::wren::Helper_obj::getFromSlot(vm, 1);
	myclass::MyClass inst = (myclass::MyClass)::wren::Helper_obj::getFromSlot(vm, 0);
	inst->callDyn(arg0);
}
static void myclass_mysuperclass_new(WrenVM *vm){
	myclass::MySuperClass* constructor = (myclass::MySuperClass*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(myclass::MySuperClass));
	auto data = ::myclass::MySuperClass_obj::__new();
	std::memcpy(constructor, &data, sizeof(myclass::MySuperClass));
}
static void myclass_myclass_new(WrenVM *vm){
	myclass::MyClass* constructor = (myclass::MyClass*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(myclass::MyClass));
	auto data = ::myclass::MyClass_obj::__new();
	std::memcpy(constructor, &data, sizeof(myclass::MyClass));
}


WrenForeignMethodFn bindMethod(const char* module, const char* signature) {
	if (strcmp(module, "main") == 0){		if (strcmp(signature, "static Test.add(_,_)") == 0) return test_add;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MySuperClass.superProp=(_)") == 0) return myclass_mysuperclass_superprop_set;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MySuperClass.superProp") == 0) return myclass_mysuperclass_superprop_get;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "static MySuperClass.hello(_)") == 0) return myclass_mysuperclass_hello;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MySuperClass.mult(_,_)") == 0) return myclass_mysuperclass_mult;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.superProp=(_)") == 0) return myclass_myclass_superprop_set;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.superProp") == 0) return myclass_myclass_superprop_get;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.mult(_,_)") == 0) return myclass_myclass_mult;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.prop=(_)") == 0) return myclass_myclass_prop_set;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.prop") == 0) return myclass_myclass_prop_get;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.add(_,_)") == 0) return myclass_myclass_add;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.callDyn(_)") == 0) return myclass_myclass_calldyn;	}
	return NULL;
}

void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods) {
	if (strcmp(module, "myclass") == 0){
		if (strcmp(className, "MySuperClass") == 0) { 
			methods->allocate = myclass_mysuperclass_new; 
 			return; 
		}
	}
	if (strcmp(module, "myclass") == 0){
		if (strcmp(className, "MyClass") == 0) { 
			methods->allocate = myclass_myclass_new; 
 			return; 
		}
	}
}
}
}