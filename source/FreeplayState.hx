package;

import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	var blackBox:FlxSprite;
    var infoText:FlxText;
	var ableToPress:Bool = true;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:FlxTypedGroup<HealthIcon>;

	override function create()
	{
		if (FlxG.save.data.pacifistEnding && FlxG.save.data.genocideEnding && !FlxG.save.data.unlockedWoundedShooting)
			FlxG.save.data.unlockedWoundedShooting = true;

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
		}

		 #if windows
		 // Updating Discord Rich Presence
		 DiscordClient.changePresence("In the Freeplay Menu", null);
		 #end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC



		// LOAD CHARACTERS

	    var	menubg = new FlxSprite(0,0);

		menubg.frames = Paths.getSparrowAtlas('menu');
        menubg.animation.addByPrefix('bg', 'bg', 24, true);
        add(menubg);
        menubg.visible = true;
        menubg.animation.play('bg');

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		iconArray = new FlxTypedGroup<HealthIcon>();
		add(iconArray);
		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);

			if (!FlxG.save.data.unlockedRealityCheck && songs[i].songName == 'Reality Check' || !FlxG.save.data.genocideEnding && songs[i].songName == 'Hallucinations' || !FlxG.save.data.pacifistEnding && songs[i].songName == 'Last Hope' || !FlxG.save.data.unlockedWoundedShooting && songs[i].songName == 'Wounded Shooting')
				icon = new HealthIcon('lock');

			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.add(icon);
			icon.animation.play('default', true);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		iconArray.members[curSelected].animation.play('default', false);

		if (songs[curSelected].songName == 'Last Hope' && !FlxG.save.data.pacifistEnding)
			FlxG.sound.music.volume = 0;
		else if (songs[curSelected].songName == 'Hallucinations' && !FlxG.save.data.genocideEnding)
			FlxG.sound.music.volume = 0;
		else if (songs[curSelected].songName == 'Reality Check' && !FlxG.save.data.unlockedRealityCheck)
			FlxG.sound.music.volume = 0;
		else if (songs[curSelected].songName == 'Wounded Shooting' && !FlxG.save.data.unlockedWoundedShooting)
			FlxG.sound.music.volume = 0;
		else
		{
			if (FlxG.sound.music.volume < 0.7)
			{
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			}
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		comboText.text = combo + '\n';

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = controls.ACCEPT;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null && ableToPress)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
			if (gamepad.justPressed.DPAD_LEFT)
			{
				changeDiff(-1);
			}
			if (gamepad.justPressed.DPAD_RIGHT)
			{
				changeDiff(1);
			}
		}

		if (upP && ableToPress)
		{
			changeSelection(-1);
		}
		if (downP && ableToPress)
		{
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.LEFT && ableToPress)
			changeDiff(-1);
		if (FlxG.keys.justPressed.RIGHT && ableToPress)
			changeDiff(1);

		if (controls.BACK && ableToPress)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (FlxG.keys.justPressed.P && ableToPress)
		{
			var songFormat = StringTools.replace('Cringe', " ", "-");
			var poop:String = Highscore.formatSong('Cringe', curDifficulty);

			trace(poop);
			
			PlayState.SONG = Song.loadFromJson(poop, 'Cringe');
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if (accepted && ableToPress)
		{
			// adjusting the song name to be compatible
			var songFormat = StringTools.replace(songs[curSelected].songName, " ", "-");
			switch (songFormat) {
				case 'Dad-Battle': songFormat = 'Dadbattle';
				case 'Philly-Nice': songFormat = 'Philly';
			}
			
			trace(songs[curSelected].songName);

			if (songs[curSelected].songName == 'Last Hope' && FlxG.save.data.pacifistEnding == false)
			{
				ableToPress = false;
				blackBox = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
				blackBox.alpha = 0;
				blackBox.antialiasing = true;
				add(blackBox);

				infoText = new FlxText(-10, 580, 1280, 'You need to unlock the Pacifist Ending first.', 72);
				infoText.scrollFactor.set(0, 0);
				infoText.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				infoText.borderSize = 2;
				infoText.borderQuality = 3;
				infoText.alpha = 0;
				infoText.antialiasing = true;
				infoText.screenCenter();
				add(infoText);

				FlxTween.tween(infoText, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});
				FlxTween.tween(blackBox, {alpha: 0.7}, 1, {ease: FlxEase.expoInOut});

				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxTween.tween(blackBox, {alpha: 0}, 1.1, {ease: FlxEase.expoInOut, onComplete: function(tween:FlxTween)
					{
						ableToPress = true;
					}});
					FlxTween.tween(infoText, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
				});
			}
			else if (songs[curSelected].songName == 'Hallucinations' && FlxG.save.data.genocideEnding == false)
			{
				ableToPress = false;
				blackBox = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
				blackBox.alpha = 0;
				blackBox.antialiasing = true;
				add(blackBox);

				infoText = new FlxText(-10, 580, 1280, 'You need to unlock the Genocide Ending first.', 72);
				infoText.scrollFactor.set(0, 0);
				infoText.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				infoText.borderSize = 2;
				infoText.borderQuality = 3;
				infoText.alpha = 0;
				infoText.antialiasing = true;
				infoText.screenCenter();
				add(infoText);

				FlxTween.tween(infoText, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});
				FlxTween.tween(blackBox, {alpha: 0.7}, 1, {ease: FlxEase.expoInOut});

				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxTween.tween(blackBox, {alpha: 0}, 1.1, {ease: FlxEase.expoInOut, onComplete: function(tween:FlxTween)
						{
							ableToPress = true;
						}});
					FlxTween.tween(infoText, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
				});
			}
			else if (songs[curSelected].songName == 'Reality Check' && FlxG.save.data.unlockedRealityCheck == false)
			{
				ableToPress = false;
				blackBox = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
				blackBox.alpha = 0;
				blackBox.antialiasing = true;
				add(blackBox);

				infoText = new FlxText(-10, 580, 1280, 'Beat Story Mode first!', 72);
				infoText.scrollFactor.set(0, 0);
				infoText.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				infoText.borderSize = 2;
				infoText.borderQuality = 3;
				infoText.alpha = 0;
				infoText.antialiasing = true;
				infoText.screenCenter();
				add(infoText);

				FlxTween.tween(infoText, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});
				FlxTween.tween(blackBox, {alpha: 0.7}, 1, {ease: FlxEase.expoInOut});

				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxTween.tween(blackBox, {alpha: 0}, 1.1, {ease: FlxEase.expoInOut, onComplete: function(tween:FlxTween)
						{
							ableToPress = true;
						}});
					FlxTween.tween(infoText, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
				});
			}
			else if (songs[curSelected].songName == 'Wounded Shooting' && FlxG.save.data.unlockedWoundedShooting == false)
			{
				ableToPress = false;
				blackBox = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
				blackBox.alpha = 0;
				blackBox.antialiasing = true;
				add(blackBox);

				infoText = new FlxText(-10, 580, 1280, 'Unlock the Genocide and Pacifist Endings!', 72);
				infoText.scrollFactor.set(0, 0);
				infoText.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				infoText.borderSize = 2;
				infoText.borderQuality = 3;
				infoText.alpha = 0;
				infoText.antialiasing = true;
				infoText.screenCenter();
				add(infoText);

				FlxTween.tween(infoText, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});
				FlxTween.tween(blackBox, {alpha: 0.7}, 1, {ease: FlxEase.expoInOut});

				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxTween.tween(blackBox, {alpha: 0}, 1.1, {ease: FlxEase.expoInOut, onComplete: function(tween:FlxTween)
					{
						ableToPress = true;
					}});
					FlxTween.tween(infoText, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
				});
			}
			else
			{
				var poop:String = Highscore.formatSong(songFormat, curDifficulty);

				trace(poop);
				
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);
				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 0;
		if (curDifficulty > 0)
			curDifficulty = 0;

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore) {
			case 'Dad-Battle': songHighscore = 'Dadbattle';
			case 'Philly-Nice': songHighscore = 'Philly';
		}
		
		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end

		diffText.text = CoolUtil.difficultyFromInt(curDifficulty).toUpperCase();
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;
		
		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore) {
			case 'Dad-Battle': songHighscore = 'Dadbattle';
			case 'Philly-Nice': songHighscore = 'Philly';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		// lerpScore = 0;
		#end

		var bullShit:Int = 0;

		for (i in iconArray.members)
		{
			i.alpha = 0.6;
		}

		iconArray.members[curSelected].alpha = 1;

		#if PRELOAD_ALL
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		for (item in grpSongs.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;
				if (item.text == 'Last Hope' && !FlxG.save.data.pacifistEnding)
				{
					item.alpha = 0.1;
				}
				else if (item.text == 'Hallucinations' && !FlxG.save.data.genocideEnding)
				{
					item.alpha = 0.1;
				}
				else if (item.text == 'Reality Check' && !FlxG.save.data.unlockedRealityCheck)
				{
					item.alpha = 0.1;
				}
				else if (item.text == 'Wounded Shooting' && !FlxG.save.data.unlockedWoundedShooting)
				{
					item.alpha = 0.1;
				}
				else
				{
					item.alpha = 0.6;
				}
					
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
