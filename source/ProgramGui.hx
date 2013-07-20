/*
 * Copyright 2013 Tux4Kids 
 * Distributed under the terms of the MIT License. 
 * 
 * Author(s): 
 * Abdelhakim Deneche 
 */

package ;

import cmds.Cmd;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;

class ProgramGui extends FlxGroup
{

	private var memory:FlxSprite;

	private var world:World;
	
	private var onEnd:Void -> Void; // callback to be called at the end of the execution of this program
	public var running:Bool;

	private var cmds:Array<Cmd>;
	private var curCmd:Int;
	private var curTime:Float;
	
	private var cmdPool:Array<Cmd>;
	
	private var numRows:Int;
	private var numCols:Int;
	
	public function new(world:World, NumRows:Int, NumCols:Int, X:Float = 0, Y:Float = 0) 
	{
		super(NumRows * NumCols);
		numRows = NumRows;
		numCols = NumCols;
		this.world = world;
		
		// memory is just used to test mouse overlap
		memory = new FlxSprite(X, Y);
		memory.makeGraphic(Std.int(CmdIcon.Size * NumCols), Std.int(CmdIcon.Size * NumRows), 0x00000000);

		for (r in 0...NumRows) {
			for (c in 0...NumCols) {
				add(new CmdIcon(memory.x + CmdIcon.Size * c, memory.y + CmdIcon.Size * r));
			}
		}
		
		cmdPool = [];
	}
	
	/**
	 * Finds which program's command is under the mouse
	 * @param	X x-coordinate of the mouse
	 * @param	Y y-coordinate of the mouse
	 * @return overlaped cmd or null if no command found
	 */
	public function getSelectedCmd(point:FlxPoint):CmdIcon
	{
		if (!memory.overlapsPoint(point)) return null;

		var c:Int = Std.int( Math.floor((point.x - memory.x) / CmdIcon.Size));
		var r:Int = Std.int( Math.floor((point.y - memory.y) / CmdIcon.Size));
		var index:Int = (r * numCols + c);
		
		return cast(members[index], CmdIcon);
	}
	
	private function recycleCmd(cmdClass:Class<Cmd>):Cmd
	{
		for (cmd in cmdPool) {
			if (Std.is(cmd, cmdClass) && !cmd.active) {
				cmd.active = true;
				return cmd;
			}
		}
	
		var cmd = Type.createInstance(cmdClass, [world]);
		cmdPool.push(cmd);
		
		return cmd;
	}
	
	public function run(OnEnd:Void -> Void = null):Bool 
	{
		onEnd = OnEnd;
		
		cmds = [];
		for (obj in members) {
			var cmd:CmdIcon = cast(obj, CmdIcon);
			if (cmd != null && cmd.type != -1) {
				var cmdClass:Class<Cmd> = Cmd.getCmdClass(cmd.type);
				if (cmdClass != null) cmds.push(recycleCmd(cmdClass));
				
			}
		}
		
		curCmd = 0;
		if (cmds.length > 0) {
			runCmd();
			running = true;
		}
		
		return cmds.length > 0;
	}

	function runCmd() 
	{
		var canRun:Bool = cmds[curCmd].canRun();
		if (canRun)
		{
			cmds[curCmd].run();
			curTime = 1;
			curCmd++;
		}
		
		if (!canRun || curCmd == cmds.length)
		{
			// program ended
			running = false;
			if (onEnd != null) onEnd();
		}
	}

	override public function update():Void
	{
		if (running)
		{
			if (curTime > 0) curTime -= FlxG.elapsed;
			else if (!cmds[curCmd].isRunning)
			{
				//time to run next command
				runCmd();
			}
		}
	}
	
}