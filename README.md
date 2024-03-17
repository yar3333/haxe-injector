# injector haxe library #

Light library implements DI (dependency injection) pattern.
Library use haxe `RTTI` to get information about types (macro-related stuff not used).

Compared to other haxe DI libraries:
	
	* simple design with minimal magic (only RTTI);
	* no macro, so library may be used without haxe (just emulate RTTI data for class in your native js code);
	* ready to separated compilation on JavaScript target (useful for using with `webpack` and similar);
	* only classes and interfaces are supported.


Using
-----

Injector fills the fields marked with `@inject` meta.

Extending your classes from `InjectContainer` allow to do injection before your constructor starts. 

You can avoid extending from `InjectContainer`, but don't forget to add `@:rtti` to your classes in that case.

You can use `injector.injectInto()` to manually inject dependencies into container object.

Example:

```haxe
class MyInstance
{
    public function new()
    {
        trace("MyInstance.new");
    }
}

class MyService extends InjectContainer
{
    @inject var a : MyInstance;

    // just example, constructor may be ommited
    public function new(injector:InjectorRO)
    {
        super(injector);
        
        trace("MyService.new: " + (a != null ? "`a` defined" : "`a` NOT DEFINED"));
    }
}

class Main
{
	public static function main()
	{
		final injector = new Injector();
		
        trace("injector.addSingleton(MyService)");
        injector.addSingleton(MyService);

        trace("injector.addInstance(MyInstance)");
        injector.addInstance(MyInstance);
		
		trace("injector.getService(MyService)");
        final service = injector.getService(MyService);
        trace(service != null ? "`service` defined" : "`service` NOT DEFINED");
	}
}
```

Output:
```shell
injector.addSingleton(MyService)
injector.addInstance(MyInstance)
injector.getService(MyService)
MyInstance.new
MyService.new: `a` defined
`service` defined
```
