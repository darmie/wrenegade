#ifndef _bindings_functions_h
#define _bindings_functions_h
#include <hxcpp.h>
extern "C"
{
#include </Users/damilare/Documents/projects/Wrenegade//lib/wren/src/include/wren.h>
}
namespace bindings {
namespace functions {
static void test_add(WrenVM *vm);
static void myclass_add(WrenVM *vm);

WrenForeignMethodFn bindMethod(const char* signature);
void bindClass(const char* className, WrenForeignClassMethods* methods);
}
}
#endif