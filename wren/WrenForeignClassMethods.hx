package wren;

@:include('linc_wren.h')
@:structAccess
@:native("WrenForeignClassMethods")
extern class WrenForeignClassMethods {
    @:native('allocate')
	public var allocate:WrenForeignMethodFn;

    @:native('finalize')
    public var finalize:WrenFinalizerFn;

    // //@:native('linc::wren::NewWrenForeignClassMethods')
    // public static function init():WrenForeignClassMethods {

    // }
}
