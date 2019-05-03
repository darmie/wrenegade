#include "MyClass.h"

#include <linc_helper.h>

#ifndef INCLUDED_type
#include <Type.h>
#endif


#include <myclass/MyClass.h>
static WrenHandle* myclass_MyClass_handle;

namespace myclass_MyClass_functions {

static void myclass_myclass_superprop_set(WrenVM *vm){
	
	::Dynamic* value = (::Dynamic*)wrenGetSlotForeign(vm, 1);
	*value = linc::helper::getFromSlot(vm, 1);
	::myclass::MyClass inst = (::myclass::MyClass)linc::helper::getFromSlot(vm, 0);
	inst->superProp = *value;
}

static void myclass_myclass_superprop_get(WrenVM *vm){
	
	::myclass::MyClass inst = (::myclass::MyClass)linc::helper::getFromSlot(vm, 0);
	auto val = inst->superProp;
	::ValueType type = ::Type_obj::_hx_typeof(val);
	linc::helper::saveToSlot(vm, 0, val, type);
}

static void myclass_myclass_graphicsbeginfill(WrenVM *vm){
	
	auto arg0 = linc::helper::getFromSlot(vm, 1);
	auto arg1 = linc::helper::getFromSlot(vm, 2);
	::myclass::MyClass inst = (::myclass::MyClass)linc::helper::getFromSlot(vm, 0);
	inst->graphicsBeginFill(arg0, arg1);
}

static void myclass_myclass_prop_set(WrenVM *vm){
	
	::Dynamic* value = (::Dynamic*)wrenGetSlotForeign(vm, 1);
	*value = linc::helper::getFromSlot(vm, 1);
	::myclass::MyClass inst = (::myclass::MyClass)linc::helper::getFromSlot(vm, 0);
	inst->prop = *value;
}

static void myclass_myclass_prop_get(WrenVM *vm){
	
	::myclass::MyClass inst = (::myclass::MyClass)linc::helper::getFromSlot(vm, 0);
	auto val = inst->prop;
	::ValueType type = ::Type_obj::_hx_typeof(val);
	linc::helper::saveToSlot(vm, 0, val, type);
}

static void myclass_myclass_add(WrenVM *vm){
	
	auto arg0 = linc::helper::getFromSlot(vm, 1);
	auto arg1 = linc::helper::getFromSlot(vm, 2);
	::myclass::MyClass inst = (::myclass::MyClass)linc::helper::getFromSlot(vm, 0);
	inst->add(arg0, arg1);
}

static void myclass_myclass_calldyn(WrenVM *vm){
	
	auto arg0 = linc::helper::getFromSlot(vm, 1);
	::myclass::MyClass inst = (::myclass::MyClass)linc::helper::getFromSlot(vm, 0);
	inst->callDyn(arg0);
}
static void myclass_myclass_new(WrenVM *vm){
	::myclass::MyClass* constructor = (myclass::MyClass*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(::myclass::MyClass));
	::myclass::MyClass_obj obj;
	auto data = obj.__new();
	std::memcpy(constructor, &data, sizeof(::myclass::MyClass));
}


WrenForeignMethodFn bindMethod(const char* module, const char* signature) {
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.superProp=(_)") == 0) return myclass_myclass_superprop_set;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.superProp") == 0) return myclass_myclass_superprop_get;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.graphicsBeginFill(_,_)") == 0) return myclass_myclass_graphicsbeginfill;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.prop=(_)") == 0) return myclass_myclass_prop_set;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.prop") == 0) return myclass_myclass_prop_get;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.add(_,_)") == 0) return myclass_myclass_add;	}
	if (strcmp(module, "myclass") == 0){		if (strcmp(signature, "MyClass.callDyn(_)") == 0) return myclass_myclass_calldyn;	}
	return NULL;
}

void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods) {
	if (strcmp(module, "myclass") == 0){
		if (strcmp(className, "MyClass") == 0) { 
			methods->allocate = myclass_myclass_new; 
 			return; 
		}
	}
}
}
