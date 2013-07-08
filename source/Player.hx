package ;

import org.flixel.FlxObject;
import org.flixel.FlxPath;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;

class Player extends FlxSprite
{
	private var walkingDist:Float;
	
	public var idle(get_idle, null):Bool;
	
	private function get_idle():Bool {
		return curAnim == null;
	}
	
	private function facingLeft():Bool {
		return facing == FlxObject.LEFT;
	}
	
	public function new() 
	{
		super();

		loadGraphic(AssetNames.Player, true, true, 35, 47);
		addAnimation("idle", [0]);
		addAnimation("jump", [3]);
		addAnimation("walk", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 15);
		
		maxVelocity.y = 300;
	}
	
	public function setPos(Xcenter:Float, Ybottom:Float):Void {
		x = Xcenter - width / 2;
		y = Ybottom - height;
	}
	
	/**
	 * Change player facing (left/right)
	 */
	public function turn():Void
	{
		facing = facingLeft() ? FlxObject.RIGHT : FlxObject.LEFT;
	}
	
	public function walk(dist:Float):Void 
	{
		curAnim = "walk";
		velocity.x = facingLeft() ? -50 : 50;
		walkingDist = dist;
	}
	
	public function jumpUp():Void
	{
		curAnim = "jump";
		var ts:Float = PlayState.TileSize;
		followPath(new FlxPath([
			new FlxPoint(x + width * .5 + (facingLeft() ? -ts:ts), y + height * .5 - ts)]));
	}
	
	public function jumpDown():Void
	{
		curAnim = "jump";
		var ts:Float = PlayState.TileSize;
		followPath(new FlxPath([
			new FlxPoint(x + width * .5 + (facingLeft() ? -ts:ts), y + height * .5 + ts)]));
	}
	
	override public function update():Void 
	{
		super.update();

		if (curAnim == "walk")
		{
			if (walkingDist <= 0) {
				curAnim = "idle";
				velocity.x = 0;
				if (walkingDist < 0)
				{
					// make sure we don't walk more than walkingDist
					x += facing == FlxObject.LEFT ? -walkingDist : walkingDist;
				}
			}
		}
		else if (curAnim == "jump")
		{
			if (pathSpeed == 0) curAnim = "idle";
		}
	}
	
	override public function postUpdate():Void 
	{
		var oldx:Float = x;
		
		super.postUpdate();
		
		if (curAnim == "walk")
			walkingDist -= Math.abs(x - oldx);
	}
}