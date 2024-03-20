import js.injecting.Injector;

import mypack.*;

class Main
{
	public static function main()
	{
		final injector = new Injector();
		
        trace("injector.addSingleton(MyService)");
        injector.addSingleton(MyService);

        trace("injector.addSingletonMappedToValue(MyService2, new MyService2(true))");
        injector.addSingletonMappedToValue(MyService2, new MyService2(true));

        trace("injector.addInstance(MyInstance)");
        injector.addInstance(MyInstance);
		
		trace("injector.getService(MyService)");
        final service = injector.getService(MyService);
        trace(service != null ? "`service` defined" : "`service` NOT DEFINED");
	}
}
