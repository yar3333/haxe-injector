package moda;

@:rtti
class ModA
{
	@inject var service : service.Service;

	public function new()
	{
		trace("ModA.new");
	}
	
	public function modFunc()
	{
		service.testFunc();
	}
}