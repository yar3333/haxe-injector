# injector haxe library #

Light library to implement DI (dependency injection) pattern.
Library use haxe `RTTI` to get information about types (macro-related stuff not used).

Compared to other haxe DI libraries:
	
	* simple design with minimal magic (only RTTI);
	* no macro, so library may be used without haxe (just emulate RTTI data for class in your native code);
	* ready to separated compilation on JavaScript target (useful for using with `webpack` and similar);
	* only classes and interfaces are supported.

```haxe
@:rtti
class MyClass
{
	@inject var myService : Service;

	public function new() {}
	
	public function myFunc()
	{
		trace("myFunc");
		service.serviceFunc();
	}
	
	// this method need because MyClass can be in other module
	public function getClass() return Type.getClass(this);
}

@:rtti
class Service
{
	public function new() {}
	
	public function testFunc()
	{
		trace("testFunc!!!");
	}
}

class Main
{
	public static function main()
	{
		var injector = new Injector();
		injector.map(Service, new Service());
		
		var myObj = new MyClass();
		injector.injectInto(myObj);
		
		myObj.myFunc();
	}
}
```
