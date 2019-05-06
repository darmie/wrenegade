#ifndef _bindings_wrenegade_Globals_h
#define _bindings_wrenegade_Globals_h
#include <hxcpp.h>
#ifndef INCLUDED_haxe_Log
#include <haxe/Log.h>
#endif
extern "C"
{
#include <wren.h>
}

namespace wrenegade_Globals_functions  {
static void callback(WrenVM *vm);

WrenForeignMethodFn bindMethod(const char* signature);
void bindClass(WrenForeignClassMethods* methods);
}

#endif