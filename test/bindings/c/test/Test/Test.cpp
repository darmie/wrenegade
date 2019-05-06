#include "Test.h"

#include <wrenegade_helper.h>

#ifndef INCLUDED_type
#include <Type.h>
#endif


#include <test/Test.h>

namespace test_Test_functions {

static void add(WrenVM *vm){
	

	wrenEnsureSlots(vm, wrenGetSlotCount(vm)+1);
	
	auto arg0 = wrenegade::helper::getFromSlot(vm, 1);
	auto arg1 = wrenegade::helper::getFromSlot(vm, 2);
	auto value = ::test::Test_obj::add(arg0, arg1);

	::Dynamic* val = (::Dynamic*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(::Dynamic));

	std::memcpy(val, &value, sizeof(::Dynamic));
	::ValueType type = ::Type_obj::_hx_typeof(value);
	wrenegade::helper::saveToSlot(vm, 0, val, type);

}


WrenForeignMethodFn bindMethod(const char* signature) {
	if (strcmp(signature, "static Test.add(_,_)") == 0) return add;
	return NULL;
}

void bindClass(WrenForeignClassMethods* methods) {
}
}
