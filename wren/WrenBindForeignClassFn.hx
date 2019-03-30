package wren;


typedef WrenBindForeignClassFn = cpp.Callable<WrenVM -> cpp.ConstCharStar -> cpp.ConstCharStar -> WrenForeignClassMethods>;

// typedef ForeignClass = cpp.Callable.CallableData<WrenVM -> cpp.ConstCharStar -> cpp.ConstCharStar -> WrenForeignClassMethods>;