package cmds;

import tileobjs.Coin;
import tileobjs.TileObj;

/**
 * take a coin/key if it's in the same tile of the player
 */
class Take extends Cmd
{
	private var obj:TileObj;
	
	public function new(world:World) 
	{
		super(world);
	}
	
	override public function run():Void 
	{
		world.player.take(obj);
	}
	
	override public function canRun():Bool 
	{
		var player:Player = world.player;
		
		obj = world.getObject(player.tileX, player.tileY);
		if (!obj.canBeTaken) obj = null;
		
		return obj != null;
	}
}