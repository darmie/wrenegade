#ifndef _LINC_WREN_H_
#define _LINC_WREN_H_



// #include "../lib/____"

#include <hxcpp.h>

extern "C"
{
#include <../lib/wren/src/include/wren.h>
}

namespace linc
{

namespace wren
{


extern WrenVM *newVM(Dynamic _config);
extern ::String getSlotString(WrenVM *vm, int slot);
static void* getFromSlot(WrenVM * vm, int slot);
static WrenType getSlotType(WrenVM *vm, int slot);
static void *setSlotNewForeign(WrenVM *vm, int slot, int classSlot, size_t size);
static void saveToSlot(WrenVM *vm, int slot, void *value, const char *type);

} // namespace wren

} // namespace linc

#endif //_LINC_WREN_H_
