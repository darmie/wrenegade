#ifndef _bindings_myclass_MySuperClass_h
#define _bindings_myclass_MySuperClass_h
#include <hxcpp.h>
#ifndef INCLUDED_haxe_Log
#include <haxe/Log.h>
#endif
extern "C"
{
#include <wren.h>
}

namespace myclass_MySuperClass_functions  {
static void myclass_mysuperclass_superprop_set(WrenVM *vm);
static void myclass_mysuperclass_superprop_get(WrenVM *vm);
static void myclass_mysuperclass_graphicsbeginfill(WrenVM *vm);

WrenForeignMethodFn bindMethod(const char* module, const char* signature);
void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods);
}

#endif