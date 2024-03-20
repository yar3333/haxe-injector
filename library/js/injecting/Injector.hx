package js.injecting;

import js.lib.Error;
import js.lib.Map;
import js.lib.Set;
import haxe.rtti.CType;
import haxe.rtti.Rtti;
using Lambda;

private typedef Singlenton =
{
    var mapTo : String;
    var value : Dynamic;
}

class Injector implements InjectorRO
{
    final allowNoRttiForClasses = new Set<Class<Dynamic>>();
    
    final singletons = new Map<String, Singlenton>();
    final instances = new Map<String, String>();
	
	public function new()
	{
	}
    
    public function addSingleton(type:Class<Dynamic>) : Injector
    {
        if (type == null) throw new Error("Argument `type` must not be null.");
        
        final rtti = Rtti.getRtti(type);
        if (rtti.isInterface) throw new Error("Interface must be mapped. Use class instead or injector's method with mapping.");

        singletons.set(rtti.path, { mapTo:rtti.path, value:null });
        return this;
    }

    public function addSingletonMappedToClass<T,Z:T>(type:Class<T>, mapTo:Class<Z>) : Injector
    {
        if (type == null) throw new Error("Argument `type` must not be null.");
        if (mapTo == null) throw new Error("Argument `mapTo` must not be null.");
        
        final rtti2 = Rtti.getRtti(mapTo);
        if (rtti2.isInterface) throw new Error("Could't map to interface.");

        singletons.set(Rtti.getRtti(type).path, { mapTo:rtti2.path, value:null });
        return this;
    }
    
    public function addSingletonMappedToValue<T,Z:T>(type:Class<T>, value:Z) : Injector
    {
        if (type == null) throw new Error("Argument `type` must not be null.");
        if (value == null) throw new Error("Argument `value` must not be null.");
        
        final rtti = Rtti.getRtti(type);

        singletons.set(rtti.path, { mapTo:rtti.path, value:value });
        return this;
    }
	
    public function addInstance(type:Class<Dynamic>) : Injector
    {
        if (type == null) throw new Error("Argument `type` must not be null.");
        
        final rtti = Rtti.getRtti(type);
        if (rtti.isInterface) throw new Error("Interface must be mapped. Use class instead or injector's method with mapping.");

        instances.set(rtti.path, rtti.path);
        return this;
    }

    public function addInstanceMappedToClass<T,Z:T>(type:Class<T>, mapTo:Class<Z>) : Injector
    {
        if (type == null) throw new Error("Argument `type` must not be null.");
        if (mapTo == null) throw new Error("Argument `mapTo` must not be null.");
        
        final rtti2 = Rtti.getRtti(mapTo);
        if (rtti2.isInterface) throw new Error("Could't map to interface.");

        instances.set(Rtti.getRtti(type).path, rtti2.path);
        return this;
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

    public function allowNoRttiForClass(type:Class<Dynamic>) : Void
    {
        allowNoRttiForClasses.add(type);
    }
    	
	function injectIntoInner(target:Dynamic, type:Class<Dynamic>) : Void
	{
		if (type == null) throw new Error("Inject target must have reference to class in `__proto__.__class__` property.");
		
        if (allowNoRttiForClasses.has(type) && !Rtti.hasRtti(type)) return;

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
        var data = singletons.get(name);
        if (data?.value != null) return data.value;
        
        if (data != null)
        {
            data.value = createObject(data.mapTo);
            return data.value;
        }

        return createObject(instances.get(name));
    }

    function createObject(mapToName:String) : Dynamic
    {
        final type = Type.resolveClass(mapToName);
        if (type == null) return null;

        final r = Type.createInstance(type, [ this ]);
        if (!Std.isOfType(r, InjectContainer)) injectInto(r);

        return r;
    }
}