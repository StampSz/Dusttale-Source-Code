package;

import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class CreditState extends MusicBeatState
{
	var creditsPage1:FlxTypedGroup<FlxSprite>;
	var textPage1:FlxTypedGroup<FlxSprite>;

	override function create()
	{

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

	    var	menubg = new FlxSprite(0,0);

		menubg.frames = Paths.getSparrowAtlas('menu');
        menubg.animation.addByPrefix('bg', 'bg', 24, true);
        add(menubg);
        menubg.visible = true;
        menubg.animation.play('bg');

		var icon = new FlxSprite(0, 0).loadGraphic(Paths.image('credits/icons/CreditIcons'));
		icon.scrollFactor.set();
		icon.antialiasing = true;
		icon.visible = true;
		icon.x = -20;
		add(icon);

		super.create();

		FlxTween.tween(FlxG.camera, {zoom: 1.05}, 1.2, {
			ease: FlxEase.cubeOut,
			onComplete: function (twn:FlxTween) {
				FlxTween.tween(FlxG.camera, {zoom: 1}, 0.2, {
					ease: FlxEase.quadIn
				});
			}
		});

		super.create();
	}

	override function update(elapsed:Float)
	{
	var movedBack:Bool = false;

	if (!movedBack)
		{
		   if (controls.BACK && !movedBack)
		  {
			  FlxG.sound.play(Paths.sound('cancelMenu'));
			  movedBack = true;
			  FlxG.switchState(new MainMenuState());
		  }
		super.update(elapsed);
	}
}
}