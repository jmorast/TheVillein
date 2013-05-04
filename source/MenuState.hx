package;

import nme.Assets;
import nme.geom.Rectangle;
import nme.net.SharedObject;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxPath;
import org.flixel.FlxSave;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxU;
import org.flixel.FlxPoint;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.Lib;
import Math;
import Std;
import nme.display.BitmapData;
import com.eclecticdesignstudio.motion.Actuate;
import nme.media.SoundChannel;
#if flash
import kong.Kongregate;
import kong.KongregateApi;
#end
class MenuState extends FlxState
{
	private var gameState:Int;
	private var gameStateTurn:Int=0;
	private var gameScore:Int=0;
	private var speakList:Array<Int>;
	private var commandType:Array<String>;
	private var spLocationX:Array<Int>;
	private var spLocationY:Array<Int>;
	private var bgGround:FlxSprite;
	private var bgSky:FlxSprite;
	private var bgSkySize:Int;
	private var bgRoad:FlxSprite;
	private var vHeight:Int;
	private var vWidth:Int;
	private var spCastle:FlxSprite;
	private var spMine:FlxSprite;
	private var spCrops:FlxSprite;
	private var spHerd:FlxSprite;
	private var spWater:FlxSprite;
	private var spForest:FlxSprite;
	private var spScroll:FlxSprite;
	private var spSelection:FlxSprite;
	private var soundMine:Dynamic;
	private var soundCastle:Dynamic;
	private var soundForest:Dynamic;
	private var soundHerd:Dynamic;
	private var soundCrops:Dynamic;
	private var soundWater:Dynamic;

	private var displayScore:FlxText;
	private var infoText:FlxText;
	#if flash
	private var myKong:KongregateApi;
	#end

	override public function create():Void
	{

		#if !neko
		FlxG.bgColor = 0xff131c1b;
		#else
		FlxG.camera.bgColor = {rgb: 0x131c1b, a: 0xff};
		#end	

		#if flash
			// show the mouse if flash
			FlxG.mouse.show();	
		#else
      		// hide mouse if not flash
			var cursor:BitmapData = new BitmapData(1, 1, 0x00000000);
			FlxG.mouse.show(cursor);
		#end

		speakList = [];
		commandType = ["mine","castle","forest","herd","crops","water"];
		spLocationX = [];
		spLocationY = [];

		// Define gameState
		// 0 = main menu
		// 1 = build/speak list of commands
		// 2 = player plays back commands
		// 3 = player repeats commands
		// 4 = end game screen
		gameState = 0;

		// play the soundtrack
		FlxG.playMusic("assets/audio/loop2.mp3");

		// setup stage vars
		if ( FlxG.height > FlxG.width ) {
			vHeight = FlxG.width;
			vWidth = FlxG.height;
		} else {
			vHeight = FlxG.height;
			vWidth = FlxG.width;
		}
		bgSkySize = Math.ceil(vHeight * .2);
		
		bgGround = new FlxSprite(0,0);
		bgGround.makeGraphic(vWidth,vHeight, 0xff117F20);
		add(bgGround);

		bgSky = new FlxSprite(0,0);
		bgSky.makeGraphic(vWidth, bgSkySize, 0xff3ec9f2);
		add(bgSky);

		spMine = new FlxSprite(1,(Math.ceil(bgSkySize/2)),"assets/images/mine.png");
		add(spMine);

		spCastle = new FlxSprite((Math.ceil(vWidth / 2)),(Math.ceil(bgSkySize/2)),"assets/images/castle.png");
		spCastle.x = spCastle.x - (Math.ceil(spCastle.width/2));
		add(spCastle);

		spForest = new FlxSprite(1,1,"assets/images/forest.png");
		spForest.x = vWidth - (Math.ceil(spForest.width * 1.2));
		spForest.y = bgSkySize + (Math.ceil(spForest.y * 1.5));
		add(spForest);

		
		spHerd = new FlxSprite(vWidth,vHeight ,"assets/images/herd.png");
		spHerd.x = vWidth - spHerd.width;
		spHerd.y = vHeight - spHerd.height;
		add(spHerd);
		
		
		spCrops = new FlxSprite(1,vHeight ,"assets/images/crops.png");
		spCrops.x = Math.ceil(spCrops.width * .05);
		spCrops.y = vHeight - Math.ceil(spCrops.height * 1.05);
		add(spCrops);

		spWater = new FlxSprite((Math.ceil((vWidth/2) - (vWidth * .1))),(Math.ceil(vHeight/2)),"assets/images/water.png");
		add(spWater);

		spSelection = new FlxSprite(1,1,"assets/images/selection.png");
		spSelection.alpha=0;
		add(spSelection);

		pushStackSP(spMine);		
		pushStackSP(spCastle);
		pushStackSP(spForest);
		pushStackSP(spHerd);
		pushStackSP(spCrops);
		pushStackSP(spWater);

		spScroll = new FlxSprite(1,1,"assets/images/textscroll-intro.png");
		spScroll.x = Math.ceil((vWidth/2) - (spScroll.width/2));
		spScroll.y = Math.ceil((vHeight/2) - (spScroll.height/2));
		spScroll.alpha = 1;
		add(spScroll);

		displayScore = new FlxText(0,Math.ceil(vHeight * .63),vWidth,"Total earned: 2 gp");
		displayScore.setFormat("assets/font/Eadui",40,0x000000,"center");
		displayScore.alpha=0;
		add(displayScore);
	
		//Kongregate.loadApi(onLoad_kong);
		
		setup_initial_environment();

	}

	private function setup_initial_environment():Void {
		
		soundMine   = ApplicationMain.getAsset("assets/audio/mine.wav");
		soundCastle = ApplicationMain.getAsset("assets/audio/castle.wav");
		soundForest = ApplicationMain.getAsset("assets/audio/forest.wav");
		soundHerd   = ApplicationMain.getAsset("assets/audio/herd.wav");
		soundCrops  = ApplicationMain.getAsset("assets/audio/crops.wav");
		soundWater  = ApplicationMain.getAsset("assets/audio/water.wav");
	}

	#if flash
	private function onLoad_kong(konginst:KongregateApi) {
		infoText.text="Got to pooint 1";
		myKong = konginst;
		infoText.text="Got to pooint 2";
		myKong.services.connect();
		infoText.text="Got to pooint 3";
	}
	#end
	
	private function pushStackSP(spriteStack:FlxSprite):Void {
		// Build spLocationX/Y sprite location arrays
		spLocationX.push(Math.ceil(spriteStack.x + spriteStack.width / 2 - spSelection.width / 2));
		spLocationY.push(Math.ceil(spriteStack.y + spriteStack.height / 2 - spSelection.height / 2));
	}

	private function addCommand():Void {
		speakList.push(Std.random(6));
	}

	private function commandList():Void {
		speakList.push(Std.random(6));
		trace("len0 " + speakList.length + " is " + speakList[speakList.length -2 ]);
		trace("len1  is " + speakList[speakList.length -1]);
		if (speakList.length > 1) {
			while (speakList[speakList.length - 2] == speakList[speakList.length - 1]) {
				trace("Detected dupe... attempting to fix" + speakList);
				
				var trash = speakList.pop();
				speakList.push(Std.random(6));
			}
		}
		trace("List of commands: " + speakList);
		var i = 0;
		while ( i < speakList.length) {
				//trace("Say sound: " + commandType[speakList[i]]);
				haxe.Timer.delay(callback(sayCommand,speakList[i]),(1000*i));
				//haxe.Timer.delay(callback(hidespSelection),(1500*i));
			i++;
		}
		haxe.Timer.delay(callback(nextGameState,2),(1200*i));
	}

	private function nextGameState(newGameState:Int):Void {
		gameState = newGameState;
		//trace("New Game State " + gameState);
	}

	private function sayCommand(commandNum):Void {
		trace("Play sound: " + commandType[commandNum]);
		spSelection.x = spLocationX[commandNum];
		spSelection.y = spLocationY[commandNum];
		spSelection.alpha = 1;
		Actuate.tween(spSelection, 1, {alpha: 0}, false).delay(2);
		//FlxG.play(commandType[commandNum]);
		switch(commandNum) {
			case 0: 
				soundMine.play();
			case 1:
				soundCastle.play();
			case 2:
				soundForest.play();
			case 3:
				soundHerd.play();
			case 4:
				soundCrops.play();
			case 5:
				soundWater.play();
		}
	}

	private function hidespSelection():Void {
		spSelection.alpha=0;
	}

	private function checkPlayerClick(commandEntered:Int):Void {
		//trace("Lady demands: " + speakList[gameStateTurn]);
		//trace("User entered: " + commandEntered);
		var commandSpoke = speakList[gameStateTurn];
		// check entry 0 in speaklist, does it equal commandEntered
		if (commandEntered == commandSpoke) {
			// it does, then continue
			gameStateTurn++;
			sayCommand(commandEntered);
			//trace("length: " + speakList.length);
			//trace("score: " + gameScore);
			if (speakList.length == gameStateTurn) {
				gameScore++;
				spScroll.loadGraphic("assets/images/textscroll-next.png");
				spScroll.alpha=1;
				displayScore.text="Total earned: " + gameScore + " gp";
				displayScore.alpha=1;
				nextGameState(3);
			}
		} else {
			// click failed
			//#if flash
			// submit high score
			//myKong.stats.submit("gold",gameScore);
			// #end
			trace(" boom fail");
			FlxG.play("fail");
			nextGameState(4);
			spScroll.loadGraphic("assets/images/textscroll-fail.png");
			spScroll.alpha = 1;
			speakList = [];
			gameStateTurn=0;

		}
	}

	override public function update():Void
	{
		switch(gameState) {
			case 0:
				if (FlxG.mouse.justPressed()) {
					if (spScroll.overlapsPoint(FlxG.mouse)) {
						spScroll.alpha = 0;
						gameScore = 0;
						commandList();
						gameState = 1;
					}
				}
			case 2:
				if (FlxG.mouse.justPressed()) {
					if (spMine.overlapsPoint(FlxG.mouse)) {
						checkPlayerClick(0);
					}
					if (spCastle.overlapsPoint(FlxG.mouse)) {
						checkPlayerClick(1);
					}
					if (spForest.overlapsPoint(FlxG.mouse)) {
						checkPlayerClick(2);
					}
					if (spHerd.overlapsPoint(FlxG.mouse)) {
						checkPlayerClick(3);
					}
					if (spCrops.overlapsPoint(FlxG.mouse)) {
						checkPlayerClick(4);
					}
					if (spWater.overlapsPoint(FlxG.mouse)) {
						checkPlayerClick(5);
					}
				
				}
			case 3:
				if (FlxG.mouse.justPressed()) {
					if (spScroll.overlapsPoint(FlxG.mouse)) {
						spScroll.alpha = 0;
						displayScore.alpha = 0;
						commandList();
						nextGameState(1);
						gameStateTurn=0;
					}
				}
			case 4:
				if (FlxG.mouse.justPressed()) {
					if (spScroll.overlapsPoint(FlxG.mouse)) {
						spScroll.loadGraphic("assets/images/textscroll-intro.png");
						spScroll.alpha = 1;
						gameScore = 0;
						nextGameState(0);
						gameStateTurn=0;
					}
				}
		}
		super.update();
	}	
}
