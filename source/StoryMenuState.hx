package;

import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	var weekData:Array<Dynamic> = [
		['The-murderer', 'red-megalovania', 'drowning', 'psychotic-breakdown', 'd.i.e', 'anthropophobia'],
	];
	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true];

	var weekCharacters:Array<Dynamic> = [
		['', 'bf', 'gf'],
	];

	var weekNames:Array<String> = [
		"",
		"Daddy Dearest",
		"Spooky Month",
		"PICO",
		"MOMMY MUST MURDER",
		"RED SNOW",
		"Hating Simulator ft. Moawling"
	];

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var HeartSoul:FlxSprite;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('story_mode');
		var arrow_tex = Paths.getSparrowAtlas('arrow');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);
		var heart = Paths.getSparrowAtlas('start_soul');

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");

		for (i in 0...weekData.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}
		}

		trace("Line 96");

		grpWeekCharacters.add(new MenuCharacter(0, 100, 0.5, false));
		grpWeekCharacters.add(new MenuCharacter(450, 25, 0.9, true));
		grpWeekCharacters.add(new MenuCharacter(850, 100, 0.5, true));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

	    var	menubg = new FlxSprite(0,0);

		menubg.frames = Paths.getSparrowAtlas('menu');
        menubg.animation.addByPrefix('bg', 'bg', 24, true);
        add(menubg);
        menubg.visible = true;

        var bg2 = new FlxSprite(0, 0).loadGraphic(Paths.image("menu_story_mode"));
		bg2.antialiasing = true;
		bg2.visible = true;
        bg2.x = 0;
		bg2.y = 0;
		bg2.updateHitbox();
		bg2.screenCenter(X);
		bg2.screenCenter(Y);
		bg2.alpha = 0.3;
		add(bg2);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = arrow_tex;
		leftArrow.animation.addByPrefix('idle', "arrow leftarrow0", 24, false);
		leftArrow.animation.addByPrefix('press', "arrow leftarrowanim");
		leftArrow.animation.play('idle');
		leftArrow.screenCenter();
		leftArrow.y += 170;
		leftArrow.x -= 240;
		leftArrow.antialiasing = true;

		add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'easy');
		sprDifficulty.animation.addByPrefix('normal', 'normal');
		sprDifficulty.animation.addByPrefix('hard', 'mad');
		sprDifficulty.animation.play('easy');
        sprDifficulty.x = 64;
		sprDifficulty.y = 110;
		sprDifficulty.antialiasing = true;
		changeDifficulty();

		add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = arrow_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow rightarrow0', 24, false);
		rightArrow.animation.addByPrefix('press', "arrow rightarrowanim", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.screenCenter();
		rightArrow.y += 170;
		rightArrow.x += 260;
		rightArrow.antialiasing = true;

		add(rightArrow);

		HeartSoul = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		HeartSoul.frames = heart;
		HeartSoul.x = -207.8;
		HeartSoul.y = 231.45;
		HeartSoul.animation.addByPrefix('idle', 'soul');
		HeartSoul.animation.addByPrefix('press', "soul", 24, false);
		HeartSoul.animation.play('idle');

		var madTime = new FlxSprite(0, 0).loadGraphic(Paths.image("mad_time"));
		madTime.antialiasing = true;
		madTime.visible = true;
        madTime.x = 64;
		madTime.y = 60;
		madTime.updateHitbox();
		madTime.screenCenter(X);
		add(madTime);




		add(HeartSoul);
        menubg.animation.play('bg');

		trace("Line 150");

		add(grpWeekCharacters);


		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		trace("Line 165");

		super.create();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

				if (gamepad != null)
				{
					if (gamepad.justPressed.DPAD_UP)
					{
						changeWeek(-1);
					}
					if (gamepad.justPressed.DPAD_DOWN)
					{
						changeWeek(1);
					}

					if (gamepad.pressed.DPAD_RIGHT)
					{
						rightArrow.animation.play('press');
						rightArrow.centerOffsets();
					}
					else
					{
						rightArrow.animation.play('idle');
						rightArrow.centerOffsets();
					}			
					if (gamepad.pressed.DPAD_LEFT)
						leftArrow.animation.play('press');
					else
						leftArrow.animation.play('idle');

					if (gamepad.justPressed.DPAD_RIGHT)
					{
						changeDifficulty(1);
					}
					if (gamepad.justPressed.DPAD_LEFT)
					{
						changeDifficulty(-1);
					}
				}

				if (FlxG.keys.justPressed.UP)
				{
					changeWeek(-1);
				}

				if (FlxG.keys.justPressed.DOWN)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
				{
					rightArrow.animation.play('press');
				}
				else
				{
					rightArrow.animation.play('idle');
				}		

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[1].animation.play('bfConfirm');
				FlxTween.tween(HeartSoul, { y: -400 }, 0.7, {ease: FlxEase.quadInOut});
				//FlxTween.tween(HeartSoul, {angle: 180}, 1, {ease: FlxEase.quadInOut});
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;


			PlayState.storyDifficulty = curDifficulty;

			// adjusting the song name to be compatible
			var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
			switch (songFormat) {
				case 'Dad-Battle': songFormat = 'Dadbattle';
				case 'Philly-Nice': songFormat = 'Philly';
			}

			var poop:String = Highscore.formatSong(songFormat, curDifficulty);
			PlayState.sicks = 0;
			PlayState.bads = 0;
			PlayState.shits = 0;
			PlayState.goods = 0;
			PlayState.campaignMisses = 0;
			PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 0;
		if (curDifficulty > 0)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.screenCenter(X);
				sprDifficulty.animation.play('hard');
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 330;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: sprDifficulty.y + 22, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		

		updateText();
	}

	function updateText()
	{
		grpWeekCharacters.members[0].setCharacter(weekCharacters[curWeek][0]);
		grpWeekCharacters.members[1].setCharacter(weekCharacters[curWeek][1]);
		grpWeekCharacters.members[2].setCharacter(weekCharacters[curWeek][2]);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}
