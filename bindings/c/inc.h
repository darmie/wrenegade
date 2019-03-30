#ifndef myclass_h
#define myclass_h
#include <hxcpp.h>
#include "./linc/linc_wren.h"
extern "C"
{
#include <../lib/wren/src/include/wren.h>
}
WrenForeignMethodFn bindMethod(const char* signature);
void bindClass(const char* className, WrenForeignClassMethods* methods);
#endif