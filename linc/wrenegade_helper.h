#ifndef _WRENEGADE_HELPER_H_
#define _WRENEGADE_HELPER_H_

#include <hxcpp.h>

#ifndef INCLUDED_ValueType
#include <ValueType.h>
#endif

extern "C"
{
#include <wren.h>
}


namespace wrenegade
{

namespace helper
{
    void writeErr(WrenVM *vm, int errorType, const char *module, int line, const char *message);
    const char* interpretResultToErr(int result);
    void saveToSlot(WrenVM *vm, int slot, ::Dynamic value, ::ValueType type);
    ::Dynamic getFromSlot(WrenVM *vm, int slot);
    ::String getSlotString(WrenVM *vm, int slot);
    WrenType getSlotType(WrenVM *vm, int slot);
    void *setSlotNewForeign(WrenVM *vm, int slot, int classSlot, size_t size);
}

}

#endif