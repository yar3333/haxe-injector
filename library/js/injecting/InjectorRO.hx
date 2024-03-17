package js.injecting;

interface InjectorRO
{
	function injectInto(target:Dynamic) : Void;
    function getService<T>(type:Class<T>) : T;
}