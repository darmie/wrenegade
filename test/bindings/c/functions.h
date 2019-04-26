#ifndef _bindings_functions_h
#define _bindings_functions_h
#include <hxcpp.h>
extern "C"
{
#include <wren.h>
}
namespace bindings {
namespace functions {
static void test_init(WrenVM *vm);
static void test_add(WrenVM *vm);
static void myclass_myclass_add(WrenVM *vm);
static void myclass_myclass_calldyn(WrenVM *vm);

WrenForeignMethodFn bindMethod(const char* module, const char* signature);
void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods);
}
}
#endif