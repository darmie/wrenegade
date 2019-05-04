#ifndef _bindings_test_Test_h
#define _bindings_test_Test_h
#include <hxcpp.h>
#ifndef INCLUDED_haxe_Log
#include <haxe/Log.h>
#endif
extern "C"
{
#include <wren.h>
}

namespace test_Test_functions  {
static void test_test_add(WrenVM *vm);

WrenForeignMethodFn bindMethod(const char* module, const char* signature);
void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods);
}

#endif