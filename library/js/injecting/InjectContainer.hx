package js.injecting;

class InjectContainer
{
	public function new(injector:InjectorRO)
	{
		injector.injectInto(this);
	}
}