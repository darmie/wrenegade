package wren;

@:include('linc_wren.h')
@:native("WrenFinalizerFn")
extern private class Wren_FinalizerFn {}
typedef WrenFinalizerFn = cpp.Reference<Wren_FinalizerFn>;