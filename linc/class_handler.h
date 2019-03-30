

#include <hxcpp.h>
extern "C"
{
#include <../lib/wren/src/include/wren.h>
}

typedef struct
{
    bool isStatic;
    const char *signature;
} MethodRegistry;

class MethodHandler
{
  public:
    MethodRegistry registry;
    ::cpp::Function<void(cpp::Reference<WrenVM>)> handler;
    MethodHandler(bool isStatic, const char *signature, ::cpp::Function<void(cpp::Reference<WrenVM>)> _handler)
    {
        registry.isStatic = isStatic;
        registry.signature = signature;
        handler = _handler;
    }
    // void allocate(WrenForeignMethodFn m)
    // {
    //     printf("allocated => %s\n", registry.signature);
    //     m = (WrenForeignMethodFn)handler.get_call();
    //     printf("allocated => %s\n", registry.signature);
    // }
    void caller(WrenVM* vm)
    {
        printf("%s\n", "method caller set");
        handler.call(vm);
    }
};
class ClassHandler
{
  private:
    MethodHandler* methods[20];
    int counter = 0;

  public:
    int id;
    const char *name;
    ClassHandler(const char *_name, ::cpp::Function<void(cpp::Reference<WrenVM>)> _handler)
    {
        name = _name;
        handler = _handler;
    }
    ::cpp::Function<void(cpp::Reference<WrenVM>)> handler;
    void _constructor(WrenVM* vm)
    {
        printf("%s\n", "constructor set");
        handler.call(vm);
    }

    void setMethod(MethodHandler *method)
    {
        methods[counter] = method;
        counter++;
    }

    MethodHandler* getMethod(const char *signature, bool isStatic)
    {
        MethodHandler* ret = nullptr;
        for (int i = 0; i < 20; i++)
        {
            // printf("getMethod %s\n", methods[i]->registry.signature);
            if (strcmp(methods[i]->registry.signature, signature) == 0 && methods[i]->registry.isStatic == isStatic)
            {
                ret = methods[i];
                printf("getMethod %s\n", ret->registry.signature);
            }
            continue;
        }

        return ret;
    }
    // void allocate(WrenForeignClassMethods *m)
    // {
    //     printf("allocated => %s\n", name);
    //     m->allocate = (WrenForeignMethodFn)handler.get_call();
    //     printf("allocated => %s\n", name);
    // }
};
