package js.injecting;

@:rtti
class InjectContainer
{
	public function new(injector:InjectorRO)
	{
		injector.injectInto(this);
	}
}