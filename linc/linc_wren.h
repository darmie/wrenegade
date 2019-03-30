#ifndef _LINC_WREN_H_
#define _LINC_WREN_H_

#include "./class_handler.h"
// #include "../lib/____"

#include <hxcpp.h>
#include <map>
extern "C"
{
#include <../lib/wren/src/include/wren.h>
}

namespace linc
{

namespace wren
{


#define MAX_REGISTRATIONS 500

static int counter = 0;

static ClassHandler* _classes[MAX_REGISTRATIONS];

extern void setClass(const char *name, ::cpp::Function<void(cpp::Reference<WrenVM>)> handler);
// extern ClassHandler* getClass(const char* name);
extern void setMethod(const char *className, const char *signature, bool isStatic, ::cpp::Function<void(cpp::Reference<WrenVM>)> handler);

WrenForeignClassMethods bindClass(WrenVM *vm, const char *module, const char *className);
WrenForeignMethodFn bindMethod(WrenVM *vm, const char *module, const char *className, bool isStatic, const char *signature);
extern WrenVM *newVM(Dynamic _config);
extern ::String getSlotString(WrenVM *vm, int slot);
static void * linc::wren::getFromSlot(WrenVM * vm, int slot);

} // namespace wren

} // namespace linc

#endif //_LINC_WREN_H_
