package wren;


@:include('linc_wren.h')


@:native("WrenHandle")
extern private class Wren_Handle {}
typedef WrenHandle = cpp.Pointer<Wren_Handle>;
