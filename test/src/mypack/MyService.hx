package mypack;

import js.injecting.InjectorRO;
import js.injecting.InjectContainer;

class MyService extends InjectContainer
{
    @inject var a : MyInstance;

    public function new(injector:InjectorRO)
    {
        super(injector);
        
        trace("MyService.new: " + (a != null ? "`a` defined" : "`a` NOT DEFINED"));
    }
}
