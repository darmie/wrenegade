#include "Hello.h"

#include <linc_helper.h>

#ifndef INCLUDED_type
#include <Type.h>
#endif


#include <myclass/subpack/Hello.h>

namespace myclass_subpack_Hello_functions {

static void myclass_subpack_hello_shout(WrenVM *vm){
	
	auto arg0 = linc::helper::getFromSlot(vm, 1);
	::myclass::subpack::Hello inst = (::myclass::subpack::Hello)linc::helper::getFromSlot(vm, 0);
	inst->shout(arg0);
}
static void myclass_subpack_hello_new(WrenVM *vm){
	::myclass::subpack::Hello* constructor = (myclass::subpack::Hello*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(::myclass::subpack::Hello));
	::myclass::subpack::Hello_obj obj;
	auto data = obj.__new();
	std::memcpy(constructor, &data, sizeof(::myclass::subpack::Hello));
}


WrenForeignMethodFn bindMethod(const char* signature) {
	if (strcmp(signature, "Hello.shout(_)") == 0) return myclass_subpack_hello_shout;
	return NULL;
}

void bindClass(WrenForeignClassMethods* methods) {
	methods->allocate = myclass_subpack_hello_new; 
 	return;
}
}
