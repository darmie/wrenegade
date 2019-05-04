#include "Test.h"

#include <linc_helper.h>

#ifndef INCLUDED_type
#include <Type.h>
#endif


#include <test/Test.h>
static WrenHandle* test_Test_handle;

namespace test_Test_functions {

static void test_test_add(WrenVM *vm){
	
	auto arg0 = linc::helper::getFromSlot(vm, 1);
	auto arg1 = linc::helper::getFromSlot(vm, 2);
	::test::Test_obj::add(arg0, arg1);
}


WrenForeignMethodFn bindMethod(const char* module, const char* signature) {
	if (strcmp(module, "test") == 0){		if (strcmp(signature, "static Test.add(_,_)") == 0) return test_test_add;	}
	return NULL;
}

void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods) {
}
}