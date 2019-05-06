#include "MyClass.h"

#include <wrenegade_helper.h>

#ifndef INCLUDED_type
#include <Type.h>
#endif


#include <myclass/MyClass.h>

namespace myclass_MyClass_functions {

static void prop_set(WrenVM *vm){
	

	wrenEnsureSlots(vm, wrenGetSlotCount(vm)+1);
	
	::Dynamic* value = (::Dynamic*)wrenGetSlotForeign(vm, 1);
	*value = wrenegade::helper::getFromSlot(vm, 1);
	::myclass::MyClass inst = (::myclass::MyClass)wrenegade::helper::getFromSlot(vm, 0);
	inst->prop = *value;
}

static void prop_get(WrenVM *vm){
	

	wrenEnsureSlots(vm, wrenGetSlotCount(vm)+1);
	
	::myclass::MyClass inst = (::myclass::MyClass)wrenegade::helper::getFromSlot(vm, 0);
	auto val = inst->prop;
	::ValueType type = ::Type_obj::_hx_typeof(val);
	wrenegade::helper::saveToSlot(vm, 0, val, type);
}

static void add(WrenVM *vm){
	

	wrenEnsureSlots(vm, wrenGetSlotCount(vm)+1);
	
	auto arg0 = wrenegade::helper::getFromSlot(vm, 1);
	auto arg1 = wrenegade::helper::getFromSlot(vm, 2);
	::myclass::MyClass inst = (::myclass::MyClass)wrenegade::helper::getFromSlot(vm, 0);
	::Dynamic value = (::Dynamic)inst->add(arg0, arg1);

	::Dynamic* val = (::Dynamic*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(::Dynamic));

	std::memcpy(val, &value, sizeof(::Dynamic));
	::ValueType type = ::Type_obj::_hx_typeof(value);
	wrenegade::helper::saveToSlot(vm, 0, val, type);

}

static void calldyn(WrenVM *vm){
	

	wrenEnsureSlots(vm, wrenGetSlotCount(vm)+1);
	
	auto arg0 = wrenegade::helper::getFromSlot(vm, 1);
	::myclass::MyClass inst = (::myclass::MyClass)wrenegade::helper::getFromSlot(vm, 0);
	::Dynamic value = (::Dynamic)inst->callDyn(arg0);

	::Dynamic* val = (::Dynamic*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(::Dynamic));

	std::memcpy(val, &value, sizeof(::Dynamic));
	::ValueType type = ::Type_obj::_hx_typeof(value);
	wrenegade::helper::saveToSlot(vm, 0, val, type);

}

static void superprop_set(WrenVM *vm){
	

	wrenEnsureSlots(vm, wrenGetSlotCount(vm)+1);
	
	::Dynamic* value = (::Dynamic*)wrenGetSlotForeign(vm, 1);
	*value = wrenegade::helper::getFromSlot(vm, 1);
	::myclass::MyClass inst = (::myclass::MyClass)wrenegade::helper::getFromSlot(vm, 0);
	inst->superProp = *value;
}

static void superprop_get(WrenVM *vm){
	

	wrenEnsureSlots(vm, wrenGetSlotCount(vm)+1);
	
	::myclass::MyClass inst = (::myclass::MyClass)wrenegade::helper::getFromSlot(vm, 0);
	auto val = inst->superProp;
	::ValueType type = ::Type_obj::_hx_typeof(val);
	wrenegade::helper::saveToSlot(vm, 0, val, type);
}

static void graphicsbeginfill(WrenVM *vm){
	

	wrenEnsureSlots(vm, wrenGetSlotCount(vm)+1);
	
	auto arg0 = wrenegade::helper::getFromSlot(vm, 1);
	auto arg1 = wrenegade::helper::getFromSlot(vm, 2);
	::myclass::MyClass inst = (::myclass::MyClass)wrenegade::helper::getFromSlot(vm, 0);
	::Dynamic value = (::Dynamic)inst->graphicsBeginFill(arg0, arg1);

	::Dynamic* val = (::Dynamic*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(::Dynamic));

	std::memcpy(val, &value, sizeof(::Dynamic));
	::ValueType type = ::Type_obj::_hx_typeof(value);
	wrenegade::helper::saveToSlot(vm, 0, val, type);

}
static void _new(WrenVM *vm){
	::myclass::MyClass* constructor = (myclass::MyClass*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(::myclass::MyClass));
	::myclass::MyClass_obj obj;
	auto data = obj.__new();
	std::memcpy(constructor, &data, sizeof(::myclass::MyClass));
}


WrenForeignMethodFn bindMethod(const char* signature) {
	if (strcmp(signature, "MyClass.prop=(_)") == 0) return prop_set;
	if (strcmp(signature, "MyClass.prop") == 0) return prop_get;
	if (strcmp(signature, "MyClass.add(_,_)") == 0) return add;
	if (strcmp(signature, "MyClass.callDyn(_)") == 0) return calldyn;
	if (strcmp(signature, "MyClass.superProp=(_)") == 0) return superprop_set;
	if (strcmp(signature, "MyClass.superProp") == 0) return superprop_get;
	if (strcmp(signature, "MyClass.graphicsBeginFill(_,_)") == 0) return graphicsbeginfill;
	return NULL;
}

void bindClass(WrenForeignClassMethods* methods) {
	methods->allocate = _new; 
 	return;
}
}
