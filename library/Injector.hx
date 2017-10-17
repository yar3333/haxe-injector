import haxe.rtti.CType;
import haxe.rtti.Rtti;
using Lambda;

class Injector
{
	var objects = new Map<String, Dynamic>();
	
	public function new()
	{
	}
	
	public function map<T>(type:Class<T>, object:T) : Injector
	{
		var rtti = Rtti.getRtti(type);
		if (rtti == null) throw new js.Error("Mapped type must have @:rtti meta.");
		objects.set(rtti.path, object);
		return this;
	}
	
	public function injectInto<T>(target:T) : T
	{
		var klass = untyped __js__("target.__proto__.__class__");
		if (klass == null) throw new js.Error("InjectTarget.getClass() must return not null value.");
		
		var rtti = Rtti.getRtti(klass);
		if (rtti == null) throw new js.Error("InjectTarget type must have @:rtti meta.");
		
		for (field in rtti.fields)
		{
			if (field.meta.exists(function(m) return m.name == "inject"))
			{
				switch (field.type)
				{
					case CType.CClass(name, paramsList):
						if (!objects.exists(name)) throw new js.Error("Type '" + name + "' not found in injector.");
						Reflect.setField(target, field.name, objects.get(name));
						
					default:
						throw new js.Error("Only classes are supported.");
				}
			}
		}
		
		return target;
	}
}