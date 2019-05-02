#ifndef _bindings_functions_h
#define _bindings_functions_h
#include <hxcpp.h>
#ifndef INCLUDED_haxe_Log
#include <haxe/Log.h>
#endif
#ifndef INCLUDED_Type
#include <Type.h>
#endif
extern "C"
{
#include <wren.h>
}
namespace bindings {
namespace functions {
static void test_add(WrenVM *vm);
static void myclass_mysuperclass_superprop_set(WrenVM *vm);
static void myclass_mysuperclass_superprop_get(WrenVM *vm);
static void myclass_mysuperclass_hello(WrenVM *vm);
static void myclass_mysuperclass_mult(WrenVM *vm);
static void myclass_myclass_superprop_set(WrenVM *vm);
static void myclass_myclass_superprop_get(WrenVM *vm);
static void myclass_myclass_mult(WrenVM *vm);
static void myclass_myclass_prop_set(WrenVM *vm);
static void myclass_myclass_prop_get(WrenVM *vm);
static void myclass_myclass_add(WrenVM *vm);
static void myclass_myclass_calldyn(WrenVM *vm);

WrenForeignMethodFn bindMethod(const char* module, const char* signature);
void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods);
}
}
#endif