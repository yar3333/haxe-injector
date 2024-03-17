package js.injecting;

import js.lib.Error;
import js.lib.Map;
import haxe.rtti.CType;
import haxe.rtti.Rtti;
using Lambda;
using StringTools;

class Injector implements InjectorRO
{
    var singletons = new Map<String, Dynamic>();
    var instances = new Map<String, Class<Dynamic>>();
	
	public function new()
	{
	}
	
    public function addSingleton<T>(type:Class<T>, ?object:T) : Void
    {
        final name = Rtti.getRtti(type).path;
        singletons.set(name, object);
    }

    public function addInstance(type:Class<Dynamic>) : Void
    {
        final name = Rtti.getRtti(type).path;
        instances.set(name, type);
    }
	
	public function injectInto(target:Dynamic) : Void
	{
		injectIntoInner(target, Type.getClass(target));
	}

    public function getService<T>(type:Class<T>) : T
    {
        final name = Rtti.getRtti(type).path;
        return getObject(name);
    }
    	
	function injectIntoInner(target:Dynamic, type:Class<Dynamic>) : Void
	{
		if (type == null) throw new Error("Inject target must have reference to class in `__proto__.__class__` property.");
		
		final rtti = Rtti.getRtti(type);
		for (field in rtti.fields)
		{
			if (field.meta.exists(m -> m.name == "inject"))
			{
				switch (field.type)
				{
					case CType.CClass(name, paramsList):
                        if (!Syntax.field(target, field.name))
                        {
                            final obj = getObject(name);
                            if (obj == null) throw new Error("Type '" + name + "' not found in injector.");
                            Reflect.setField(target, field.name, obj);
                        }
						
					default:
						throw new Error("Only classes are supported.");
				}
			}
		}
		
		if (rtti.superClass != null)
		{
			injectIntoInner(target, Type.getSuperClass(type));
		}
	}

    function getObject(name:String) : Dynamic
    {
        var r = singletons.get(name);
        if (r != null) return r;
        
        if (singletons.has(name))
        {
            r = createObject(Type.resolveClass(name));
            singletons.set(name, r);
            return r;
        }

        return createObject(instances.get(name));
    }

    function createObject(type:Class<Dynamic>) : Dynamic
    {
        if (type == null) return null;

        final r = Type.createInstance(type, [ this ]);
        if (!Std.isOfType(r, InjectContainer)) injectInto(r);

        return r;
    }
}