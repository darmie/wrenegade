#include "MySuperClass.h"

#include <wrenegade_helper.h>

#ifndef INCLUDED_type
#include <Type.h>
#endif


#include <myclass/MySuperClass.h>

namespace myclass_MySuperClass_functions {

static void myclass_mysuperclass_superprop_set(WrenVM *vm){
	
	::Dynamic* value = (::Dynamic*)wrenGetSlotForeign(vm, 1);
	*value = wrenegade::helper::getFromSlot(vm, 1);
	::myclass::MySuperClass inst = (::myclass::MySuperClass)wrenegade::helper::getFromSlot(vm, 0);
	inst->superProp = *value;
}

static void myclass_mysuperclass_superprop_get(WrenVM *vm){
	
	::myclass::MySuperClass inst = (::myclass::MySuperClass)wrenegade::helper::getFromSlot(vm, 0);
	auto val = inst->superProp;
	::ValueType type = ::Type_obj::_hx_typeof(val);
	wrenegade::helper::saveToSlot(vm, 0, val, type);
}

static void myclass_mysuperclass_graphicsbeginfill(WrenVM *vm){
	
	auto arg0 = wrenegade::helper::getFromSlot(vm, 1);
	auto arg1 = wrenegade::helper::getFromSlot(vm, 2);
	::myclass::MySuperClass inst = (::myclass::MySuperClass)wrenegade::helper::getFromSlot(vm, 0);
	inst->graphicsBeginFill(arg0, arg1);
}
static void myclass_mysuperclass_new(WrenVM *vm){
	::myclass::MySuperClass* constructor = (myclass::MySuperClass*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(::myclass::MySuperClass));
	::myclass::MySuperClass_obj obj;
	auto data = obj.__new();
	std::memcpy(constructor, &data, sizeof(::myclass::MySuperClass));
}


WrenForeignMethodFn bindMethod(const char* signature) {
	if (strcmp(signature, "MySuperClass.superProp=(_)") == 0) return myclass_mysuperclass_superprop_set;
	if (strcmp(signature, "MySuperClass.superProp") == 0) return myclass_mysuperclass_superprop_get;
	if (strcmp(signature, "MySuperClass.graphicsBeginFill(_,_)") == 0) return myclass_mysuperclass_graphicsbeginfill;
	return NULL;
}

void bindClass(WrenForeignClassMethods* methods) {
	methods->allocate = myclass_mysuperclass_new; 
 	return;
}
}
