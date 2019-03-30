#include "inc.h"

static void test_test_add(WrenVM *vm);{
	::Dynamic arg0 = (::Dynamic) wrenGetSlotForeign(vm, 0);
	auto arg1 = linc::wren::getFromSlot(vm, 1);
	auto arg2 = linc::wren::getFromSlot(vm, 2);
	::test::Test::add(arg0, arg1, arg2);
}


WrenForeignMethodFn test_test_bindMethod(const char* signature) {
	if (strcmp(signature, "test.Test.add(_,_,_,_)") == 0) return test_test_add;
	return NULL;
}