
#include "wrenegade_helper.h"

#ifndef INCLUDED_Std
#include <Std.h>
#endif
#ifndef INCLUDED_Sys
#include <Sys.h>
#endif

#include <sstream>

namespace wrenegade
{

namespace helper
{
void writeErr(WrenVM *vm, int errorType, const char *module, int line, const char *message)
{

    switch ((int)(errorType))
    {
    case (int)0:
    {

        printf("compilation error: %s:%d: %s", module, line, message);
    }
    break;
    case (int)1:
    {
        printf("runtime error: %s\n", message);
    }
    break;
    case (int)2:
    {

        printf("\t%s:%d: %s", module, line, message);
    }
    break;
    default:
    {
        throw "impossible error type";
    }
    }
}

const char *interpretResultToErr(int result)
{

    switch ((int)(result))
    {
    case (int)0:
    {
        return null();
    }
    break;
    case (int)1:
    {
        return "compilation error";
    }
    break;
    case (int)2:
    {
        return "runtime error";
    }
    break;
    default:
    {
        throw "unreachable";
    }
    }
    return NULL;
}

void saveToSlot(WrenVM *vm, int slot, ::Dynamic value, ::ValueType type)
{
    switch ((int)(type->_hx_getIndex()))
    {
    case (int)0:
    {
        wrenSetSlotNull(vm, slot);
    }
    break;
    case (int)1:
    {
        wrenSetSlotDouble(vm, slot, ((Float)(value)));
    }
    break;
    case (int)2:
    {
        wrenSetSlotDouble(vm, slot, ((Float)(value)));
    }
    break;
    case (int)3:
    {
        wrenSetSlotBool(vm, slot, ((bool)(value)));
    }
    break;
    case (int)6:
    {
        hx::Class c = type->_hx_getObject(0).StaticCast<hx::Class>();
        if (hx::IsEq(c, hx::ClassOf<::String>()))
        {
            wrenSetSlotString(vm, slot, ((::String)(value)));
        }
    }
    break;
    case (int)8:
    {
        wrenSetSlotNull(vm, slot);
    }
    break;
    default:
    {
        std::string out_string = "don't know how to save this to a slot: ";
        std::stringstream ss;
        ss << ::Std_obj::string(type);
        out_string = ss.str();
        throw out_string;
    }
    }
}
::Dynamic getFromSlot(WrenVM *vm, int slot)
{

    switch ((int)(wrenGetSlotType(vm, slot)))
    {
    case (int)0:
    {

        return wrenGetSlotBool(vm, slot);
    }
    break;
    case (int)1:
    {

        return wrenGetSlotDouble(vm, slot);
    }
    break;
    case (int)2:
    {
        ::Dynamic *val = (::Dynamic *)wrenGetSlotForeign(vm, slot);

        return *val;
    }
    break;
    case (int)3:
    {

        int count = wrenGetListCount(vm, slot);
        ::cpp::VirtualArray bucket = ::cpp::VirtualArray_obj::__new(0);

        {

            int _g = 0;

            int _g1 = count;

            while ((_g < _g1))
            {

                _g = (_g + 1);

                int i = (_g - 1);

                wrenGetListElement(vm, slot, i, 0);
                ::Dynamic elem = getFromSlot(vm, 0);

                bucket->push(elem);
            }
        }

        return bucket;
    }
    break;
    case (int)4:
    {

        return null();
    }
    break;
    case (int)5:
    {

        return getSlotString(vm, slot);
    }
    break;
    case (int)6:
    {
        std::string out_string = "received an inaccessible-from-C parameter in slot ";
        std::stringstream ss;
        ss << slot;
        out_string = ss.str();
        throw out_string;
    }
    break;
    default:
    {
        throw "unreachable";
    }
    }

    return null();
}

::String getSlotString(WrenVM *vm, int slot)
{

    return ::String(wrenGetSlotString(vm, slot));
}

WrenType getSlotType(WrenVM *vm, int slot)
{
    return wrenGetSlotType(vm, slot);
}

void *setSlotNewForeign(WrenVM *vm, int slot, int classSlot, size_t size)
{
    return wrenSetSlotNewForeign(vm, 0, 0, 8);
}

} // namespace helper

} // namespace linc