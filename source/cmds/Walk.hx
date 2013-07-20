/*
 * Copyright 2013 Tux4Kids 
 * Distributed under the terms of the MIT License. 
 * 
 * Author(s): 
 * Abdelhakim Deneche 
 */

package cmds;

/**
 * make the character walk forward if nothing blocks it's way
 */
class Walk extends Cmd
{

	public function new(world:World) 
	{
		super(world);
	}
	
	override public function run():Bool
	{
		world.player.walk();
		return false;
	}
	
	override public function canRun():Bool 
	{
		// can move forward if :
		// player faces an empty (but existing) tile
		// there is a tile below the facing tile
		var player:Player = world.player;
		var tileX:Int = player.tileX + (player.facingLeft ? -1 : 1);
		
		if (!world.insideMap(tileX, player.tileY)) return false;
		if (!world.isEmpty(tileX, player.tileY)) return false;
		return !world.insideMap(tileX, player.tileY + 1) || !world.isEmpty(tileX, player.tileY + 1);
	}
}