#ifndef _WREN_BINDINGS_
#define _WREN_BINDINGS_
#include "c/myclass/subpack/Hello/Hello.h"
#include "c/myclass/MySuperClass/MySuperClass.h"
#include "c/myclass/MyClass/MyClass.h"

extern "C"
{
#include <wren.h>
}
namespace wrenegade {
void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods);
WrenForeignMethodFn bindMethod(const char* module, const char *className, const char* signature);}
#endif