package wren;

import wren.WrenClass;
import wren.Wren;

class Value {
    private var vm:wren.WrenVM;
    // public var value:wren.WrenHandle;
    private var methods:Map<String, wren.WrenHandle>;

    public function new(vm:wren.WrenVM){
        this.vm = vm;
        this.methods = new Map(); 
    }


    public function call(f:wren.WrenHandle):Dynamic {
       
        trace(f);
        var errMsg = wren.Wren.call(this.vm, f);
        var err = Helper.interpretResultToErr(errMsg);
        
        if(err != null){
            
            throw err;
        }

        var retval = Helper.getFromSlot(this.vm, 0);

        if(retval != null){
            return retval;
        }

        // Wren.releaseHandle(this.vm, this.value);
        // Wren.releaseHandle(this.vm, f);

        return null;
    }
}