import injector.Injector;

class Main
{
	public static function main()
	{
		var injector = new Injector();
		injector.map(service.Service, new service.Service());
		
		var modA = new moda.ModA();
		injector.injectInto(modA);
		
		modA.modFunc();
	}
}
