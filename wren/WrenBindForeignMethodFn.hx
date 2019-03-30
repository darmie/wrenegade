package wren;


typedef WrenBindForeignMethodFn = cpp.Callable<WrenVM -> cpp.ConstCharStar -> cpp.ConstCharStar -> Bool -> cpp.ConstCharStar -> WrenForeignMethodFn>;

// typedef ForeignMethod = cpp.Callable.CallableData<WrenVM -> cpp.ConstCharStar -> cpp.ConstCharStar -> Bool -> cpp.ConstCharStar -> WrenForeignMethodFn>;