#include "Globals.h"

#include <wrenegade_helper.h>

#ifndef INCLUDED_type
#include <Type.h>
#endif


#include <wren/Globals.h>

namespace wrenegade_Globals_functions {

static void callback(WrenVM *vm){
	

	wrenEnsureSlots(vm, wrenGetSlotCount(vm)+1);
	
	auto arg0 = wrenegade::helper::getFromSlot(vm, 1);
	auto arg1 = wrenegade::helper::getFromSlot(vm, 2);
	auto arg2 = wrenegade::helper::getFromSlot(vm, 3);
	auto value = ::wren::Globals_obj::callback(arg0, arg1, arg2);

	::Dynamic* val = (::Dynamic*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(::Dynamic));

	std::memcpy(val, &value, sizeof(::Dynamic));
	::ValueType type = ::Type_obj::_hx_typeof(value);
	wrenegade::helper::saveToSlot(vm, 0, val, type);

}


WrenForeignMethodFn bindMethod(const char* signature) {
	if (strcmp(signature, "static Globals.callback(_,_,_)") == 0) return callback;
	return NULL;
}

void bindClass(WrenForeignClassMethods* methods) {
}
}
