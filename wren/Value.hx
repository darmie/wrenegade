package wren;

import wren.Wren;

class Value {
    private var vm:wren.WrenVM;
    public var value:wren.WrenHandle;
    public var methods:Map<String, wren.WrenHandle>;

    public function new(vm:wren.WrenVM){
        this.vm = vm;
        this.methods = new Map(); 
    }


    public function call(signature:String, params:Array<Dynamic>):Dynamic {
        var f:wren.WrenHandle = this.methods.get(signature);
        
        if(f == null){
            f = Wren.makeCallHandle(this.vm, signature);
            this.methods.set(signature, f);
        }

        Wren.ensureSlots(this.vm, (params.length+1));
        Wren.setSlotHandle(this.vm, 0, this.value);
        for(i in 0...params.length){
            Helper.saveToSlot(this.vm, i+1, params[i], Type.typeof(params[i]));
        }

        var err = Helper.interpretResultToErr(wren.Wren.call(this.vm, f));

        if(err != null){
            trace(err);
            return null;
        }

        var retval = Helper.getFromSlot(this.vm, 0);

        if(retval != null){
            return retval;
        }

        return null;
    }
}