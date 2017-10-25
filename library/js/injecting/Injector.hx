package js.injecting;

import haxe.rtti.CType;
import haxe.rtti.Rtti;
using Lambda;

private typedef Proto =
{
	var __class__ : Class<Dynamic>;
	var __proto__ : Proto;
}

class Injector implements InjectorRO
{
	var allowNoRttiForClasses = new Array<Class<Dynamic>>();
	
	var objects = new Map<String, Dynamic>();
	
	public function new()
	{
	}
	
	public function map<T>(type:Class<T>, object:T) : Void
	{
		var rtti = Rtti.getRtti(type);
		if (rtti == null) throw new js.Error("Mapped type must have @:rtti meta.");
		if (object == null) throw new js.Error("Map type `" + rtti.path + "` to null.");
		objects.set(rtti.path, object);
	}
	
	public function injectInto(target:Dynamic) : Void
	{
		injectIntoInner(target, target.__proto__);
	}
	
	public function allowNoRttiForClass(type:Class<Dynamic>)
	{
		allowNoRttiForClasses.push(type);
	}
	
	function injectIntoInner(target:Dynamic, proto:Proto) : Void
	{
		var klass = proto.__class__;
		if (klass == null) throw new js.Error("Inject target must have reference to class in `__proto__.__class__` property.");
		
		if (!Rtti.hasRtti(klass) && allowNoRttiForClasses.indexOf(klass) >= 0) return;
		
		var rtti = Rtti.getRtti(klass);
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
		
		if (rtti.superClass != null)
		{
			injectIntoInner(target, proto.__proto__);
		}
	}
}