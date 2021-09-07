package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;
	var starThing:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var currentLeftPortraitAnim:String = "normal";
	var currentRightPortraitAnim:String = "normal";

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFF000000);
		bgFade.scrollFactor.set();
		bgFade.alpha = 1;
		add(bgFade);

		box = new FlxSprite(-20, 45);
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'the-murderer' | 'red-megalovania' | 'drowning' | 'anthropophobia' | 'd.i.e' | 'psychotic-breakdown':
				hasDialog = true;
				box.loadGraphic(Paths.image('dialogue/box', 'shared'));
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		
		portraitLeft = new FlxSprite(-20, 40);
		portraitLeft.antialiasing = true;

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'the-murderer':
				portraitLeft.frames = Paths.getSparrowAtlas('dialogue/dialogue_sans_snowdin', 'shared');
				portraitLeft.animation.addByPrefix('mad', 'mad', 24, false);
				portraitLeft.animation.addByPrefix('normal', 'normal', 24, false);
				portraitLeft.animation.addByPrefix('worried', 'worry', 24, false);
			case 'red-megalovania' | 'drowning':
				portraitLeft.frames = Paths.getSparrowAtlas('dialogue/dialogue_sans_waterfall', 'shared');
				portraitLeft.animation.addByPrefix('mad', 'mad', 24, false);
				portraitLeft.animation.addByPrefix('normal', 'normal', 24, false);
				portraitLeft.animation.addByPrefix('worried', 'worry', 24, false);
			case 'anthropophobia':
				portraitLeft.frames = Paths.getSparrowAtlas('dialogue/dialogue_sans_mad', 'shared');
				portraitLeft.animation.addByPrefix('mad', 'mad', 24, false);
				portraitLeft.animation.addByPrefix('normal', 'normal', 24, false);
				portraitLeft.animation.addByPrefix('worried', 'worry', 24, false);
			default:
				portraitLeft.frames = Paths.getSparrowAtlas('dialogue/sans_dia', 'shared');
				portraitLeft.animation.addByPrefix('angry', 'angry', 24, false);
				portraitLeft.animation.addByPrefix('mad', 'mad', 24, false);
				portraitLeft.animation.addByPrefix('normal', 'normal', 24, false);
				portraitLeft.animation.addByPrefix('strange', 'strange', 24, false);
				portraitLeft.animation.addByPrefix('worried', 'worry', 24, false);
		}

		portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 0.9));
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		portraitLeft.alpha = 0.25;
		add(portraitLeft);

		portraitRight = new FlxSprite(0, 40);
		portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf_dia', 'shared');
		portraitRight.antialiasing = true;
		portraitRight.animation.addByPrefix('normal', 'BF_normal', 24, false);
		portraitRight.animation.addByPrefix('chara', 'bf_chara', 24, false);
		portraitRight.setGraphicSize(Std.int(portraitRight.width * 0.9));
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		portraitRight.alpha = 0.25;
		add(portraitRight);
		
		box.setGraphicSize(Std.int(box.width * 1));
		box.updateHitbox();
		add(box);

		box.screenCenter();
		portraitLeft.screenCenter();
		portraitRight.screenCenter();

		portraitLeft.x -= 170;
		portraitLeft.y += 595;
		portraitRight.x += 200;
		portraitRight.y += 600;

		box.y += 800;

		starThing = new FlxText(260, 1050, Std.int(FlxG.width * 0.6), "*", 32);
		starThing.antialiasing = true;
		starThing.setFormat(Paths.font('DTM-Mono.otf'), 40, FlxColor.WHITE);
		add(starThing);

		swagDialogue = new FlxTypeText(300, 450, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.antialiasing = true;
		swagDialogue.setFormat(Paths.font('comic.ttf'), 40, FlxColor.WHITE);
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);

		FlxTween.tween(bgFade, {alpha: 0.7}, 0.7, {ease: FlxEase.smootherStepIn});
		FlxTween.tween(portraitLeft, {y: portraitLeft.y - 590}, 1, {ease: FlxEase.expoIn, startDelay: 1});
		FlxTween.tween(portraitRight, {y: portraitRight.y - 640}, 1, {ease: FlxEase.expoIn, startDelay: 1});
		FlxTween.tween(starThing, {y: starThing.y - 600}, 1, {ease: FlxEase.expoIn, startDelay: 1});
		FlxTween.tween(box, {y: box.y - 600}, 1, {ease: FlxEase.expoIn, startDelay: 1, onComplete: function(tween:FlxTween)
		{
			dialogueOpened = true;
		}});
		// dialogue.x = 90;
		// add(dialogue);
	}

	override function update(elapsed:Float)
	{
		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		portraitLeft.animation.play(currentLeftPortraitAnim);
		portraitRight.animation.play(currentRightPortraitAnim);

		if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted == true)
		{
			remove(dialogue);
				
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						FlxTween.tween(bgFade, {alpha: 0}, 0.5, {ease: FlxEase.smootherStepIn});
						FlxTween.tween(box, {alpha: 0}, 0.5, {ease: FlxEase.smootherStepIn});
						FlxTween.tween(portraitLeft, {alpha: 0}, 0.5, {ease: FlxEase.smootherStepIn});
						FlxTween.tween(portraitRight, {alpha: 0}, 0.5, {ease: FlxEase.smootherStepIn});
						FlxTween.tween(swagDialogue, {alpha: 0}, 0.5, {ease: FlxEase.smootherStepIn});
						FlxTween.tween(starThing, {alpha: 0}, 0.5, {ease: FlxEase.smootherStepIn});
					});

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		if (curCharacter.contains('sans'))
		{
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('voice_sans'), 0.6)];
			swagDialogue.setFormat(Paths.font('comic.ttf'), 40, FlxColor.WHITE);
			swagDialogue.y = 450;
		}
		else
		{
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('bf'), 0.6)];

			if (curCharacter == 'bfchararedtext')
				swagDialogue.setFormat(Paths.font('vcr.ttf'), 40, FlxColor.RED);
			else
				swagDialogue.setFormat(Paths.font('vcr.ttf'), 40, FlxColor.WHITE);

			swagDialogue.y = 460;
		}

		switch (curCharacter)
		{
			case 'sansnormal':
				currentLeftPortraitAnim = 'normal';
				if (portraitLeft.alpha != 1)
					FlxTween.tween(portraitLeft, {alpha: 1}, 0.5, {ease: FlxEase.smootherStepIn});		
				
				if (portraitRight.alpha == 1)
				{
					FlxTween.tween(portraitRight, {alpha: 0.25}, 0.5, {ease: FlxEase.smootherStepIn});
				}
				portraitLeft.animation.play('normal');
			case 'sansmad':
				currentLeftPortraitAnim = 'mad';
				if (portraitLeft.alpha != 1)
					FlxTween.tween(portraitLeft, {alpha: 1}, 0.5, {ease: FlxEase.smootherStepIn});		

				if (portraitRight.alpha == 1)
				{
					FlxTween.tween(portraitRight, {alpha: 0.25}, 0.5, {ease: FlxEase.smootherStepIn});
				}
				portraitLeft.animation.play('mad');
			case 'sansworried':
				currentLeftPortraitAnim = 'worried';
				if (portraitLeft.alpha != 1)
					FlxTween.tween(portraitLeft, {alpha: 1}, 0.5, {ease: FlxEase.smootherStepIn});
						

				if (portraitRight.alpha == 1)
				{
					FlxTween.tween(portraitRight, {alpha: 0.25}, 0.5, {ease: FlxEase.smootherStepIn});
				}
				portraitLeft.animation.play('worried');
			case 'sansstrange':
				currentLeftPortraitAnim = 'strange';
				if (portraitLeft.alpha != 1)
					FlxTween.tween(portraitLeft, {alpha: 1}, 0.5, {ease: FlxEase.smootherStepIn});
						
				if (portraitRight.alpha == 1)
				{
					FlxTween.tween(portraitRight, {alpha: 0.25}, 0.5, {ease: FlxEase.smootherStepIn});
				}
				portraitLeft.animation.play('strange');
			case 'sansangry':
				currentLeftPortraitAnim = 'angry';
				if (portraitLeft.alpha != 1)
					FlxTween.tween(portraitLeft, {alpha: 1}, 0.5, {ease: FlxEase.smootherStepIn});
				
				if (portraitRight.alpha == 1)
				{
					FlxTween.tween(portraitRight, {alpha: 0.25}, 0.5, {ease: FlxEase.smootherStepIn});
				}
				portraitLeft.animation.play('angry');
			case 'bfnormal':
				currentRightPortraitAnim = 'normal';
				if (portraitRight.alpha != 1)
					FlxTween.tween(portraitRight, {alpha: 1}, 0.5, {ease: FlxEase.smootherStepIn});
				
				if (portraitLeft.alpha == 1)
				{
					FlxTween.tween(portraitLeft, {alpha: 0.25}, 0.5, {ease: FlxEase.smootherStepIn});
				}
				portraitRight.animation.play('normal');
			case 'bfchara':
				currentRightPortraitAnim = 'chara';
				if (portraitRight.alpha != 1)
					FlxTween.tween(portraitRight, {alpha: 1}, 0.5, {ease: FlxEase.smootherStepIn});
				
				if (portraitLeft.alpha == 1)
				{
					FlxTween.tween(portraitLeft, {alpha: 0.25}, 0.5, {ease: FlxEase.smootherStepIn});
				}
				portraitRight.animation.play('chara');
			case 'bfchararedtext':
				currentRightPortraitAnim = 'chara';
				if (portraitRight.alpha != 1)
					FlxTween.tween(portraitRight, {alpha: 1}, 0.5, {ease: FlxEase.smootherStepIn});
				
				if (portraitLeft.alpha == 1)
				{
					FlxTween.tween(portraitLeft, {alpha: 0.25}, 0.5, {ease: FlxEase.smootherStepIn});
				}
				portraitRight.animation.play('chara');
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
