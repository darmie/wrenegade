#ifndef _bindings_myclass_MyClass_h
#define _bindings_myclass_MyClass_h
#include <hxcpp.h>
#ifndef INCLUDED_haxe_Log
#include <haxe/Log.h>
#endif
extern "C"
{
#include <wren.h>
}

namespace myclass_MyClass_functions  {
static void myclass_myclass_prop_set(WrenVM *vm);
static void myclass_myclass_prop_get(WrenVM *vm);
static void myclass_myclass_add(WrenVM *vm);
static void myclass_myclass_calldyn(WrenVM *vm);
static void myclass_myclass_superprop_set(WrenVM *vm);
static void myclass_myclass_superprop_get(WrenVM *vm);
static void myclass_myclass_graphicsbeginfill(WrenVM *vm);

WrenForeignMethodFn bindMethod(const char* module, const char* signature);
void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods);
}

#endif