#ifndef _bindings_myclass_subpack_Hello_h
#define _bindings_myclass_subpack_Hello_h
#include <hxcpp.h>
#ifndef INCLUDED_haxe_Log
#include <haxe/Log.h>
#endif
extern "C"
{
#include <wren.h>
}

namespace myclass_subpack_Hello_functions  {
static void myclass_subpack_hello_shout(WrenVM *vm);

WrenForeignMethodFn bindMethod(const char* signature);
void bindClass(WrenForeignClassMethods* methods);
}

#endif