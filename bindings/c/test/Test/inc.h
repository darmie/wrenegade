#ifndef test_test_h
#define test_test_h
#include <hxcpp.h>
extern "C"
{
#include <../lib/wren/src/include/wren.h>
}
WrenForeignMethodFn test_test_bindMethod(const char* signature);
#endif