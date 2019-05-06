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
static void prop_set(WrenVM *vm);
static void prop_get(WrenVM *vm);
static void add(WrenVM *vm);
static void calldyn(WrenVM *vm);
static void superprop_set(WrenVM *vm);
static void superprop_get(WrenVM *vm);
static void graphicsbeginfill(WrenVM *vm);

WrenForeignMethodFn bindMethod(const char* signature);
void bindClass(WrenForeignClassMethods* methods);
}

#endif