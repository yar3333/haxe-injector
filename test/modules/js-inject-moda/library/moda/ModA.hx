package moda;

@:rtti @:jsRequire("js-inject-moda", "ModA") extern class ModA
{
	function new() : Void;
	@inject
	private var service : service.Service;
	function modFunc() : Void;
}