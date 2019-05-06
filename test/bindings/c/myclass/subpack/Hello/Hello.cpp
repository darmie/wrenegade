#include "Hello.h"

#include <wrenegade_helper.h>

#ifndef INCLUDED_type
#include <Type.h>
#endif


#include <myclass/subpack/Hello.h>

namespace myclass_subpack_Hello_functions {

static void shout(WrenVM *vm){
	

	wrenEnsureSlots(vm, wrenGetSlotCount(vm)+1);
	
	auto arg0 = wrenegade::helper::getFromSlot(vm, 1);
	::myclass::subpack::Hello inst = (::myclass::subpack::Hello)wrenegade::helper::getFromSlot(vm, 0);
	::Dynamic value = (::Dynamic)inst->shout(arg0);

	::Dynamic* val = (::Dynamic*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(::Dynamic));

	std::memcpy(val, &value, sizeof(::Dynamic));
	::ValueType type = ::Type_obj::_hx_typeof(value);
	wrenegade::helper::saveToSlot(vm, 0, val, type);

}
static void _new(WrenVM *vm){
	::myclass::subpack::Hello* constructor = (myclass::subpack::Hello*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(::myclass::subpack::Hello));
	::myclass::subpack::Hello_obj obj;
	auto data = obj.__new();
	std::memcpy(constructor, &data, sizeof(::myclass::subpack::Hello));
}


WrenForeignMethodFn bindMethod(const char* signature) {
	if (strcmp(signature, "Hello.shout(_)") == 0) return shout;
	return NULL;
}

void bindClass(WrenForeignClassMethods* methods) {
	methods->allocate = _new; 
 	return;
}
}
