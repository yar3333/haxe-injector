# injector #

Light haxe library implements DI (dependency injection) pattern for `JavaScript` platform.
Haxe's `RTTI` feature used to get information about types (no macro-related stuff).

Compared to other haxe DI libraries:
	
	* simple design with minimal magic;
	* may be used without haxe (you need to emulate RTTI XML data in your native js code);
	* ready to separated compilation (`npm`/`webpack` compatible);
	* support latest javascript standard (ES6).


Synopsis
--------
```haxe
    final injector = new Injector();
    
    injector
        .addSingleton(MyClass)
        .addSingletonMappedToClass(MyInterface, MyClass)
        .addSingletonMappedToValue(MyInterface, myObject)
        .addInstance(MyClass)
        .addInstanceMappedToClass(MyInterface, MyClass);

    final service = injector.getService(MyInterface);

    // if you prefer manual injecting
    @:rtti
    class MyClass
    {
        @inject var myVarA : MyInterface;
        @inject var myVarB : MyClass;

        public function new(injector:InjectorRO)
        {
            injector.injectInto(this); // fills @inject fields
        }
    }

    // `InjectContainer` already has @:rtti and appropriate constructor
    class MyClass extends InjectContainer
    {
        @inject var myVarA : MyInterface;
        @inject var myVarB : MyClass;
    }
```


Details
-------

Injector fills the fields marked with `@inject` meta.

Extending your classes from `InjectContainer` allow to do injection before your constructor starts (even with `-D js-es=6`). 

You can avoid extending from `InjectContainer`, but don't forget to add `@:rtti` to your classes
(**in that case your constuctor will be called before injection due to ES6 limitations**).

You can use `injector.injectInto()` to manually inject dependencies into container object.

`InjectorRO` is read-only interface for `Injector` (without `add***` methods).


Full example
------------

```haxe
@:rtti
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
