package;

import flixel.FlxG;
import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	
	public var defaultIconScale:Float = 1;
	public var iconScale:Float = 1;
	public var iconSize:Float;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();

		if(FlxG.save.data.antialiasing)
			{
				antialiasing = true;
			}
		if (char == 'sm')
		{
			loadGraphic(Paths.image("stepmania-icon"));
			return;
		}
		switch(char)
		{
			case 'sans' | 'sansWorried' | 'sansUpset' | 'sansMad':
				frames = Paths.getSparrowAtlas('icons/sans_icons', 'shared');
				iconScale = 0.5;
				defaultIconScale = 0.5;

				antialiasing = true;
				animation.addByPrefix('default', "normal", 24, false, isPlayer);
				animation.addByPrefix('losing', "loosing", 24, false, isPlayer);
				animation.addByPrefix('winning', "winning", 24, false, isPlayer);
			case 'sansTired': //only for freeplay
				frames = Paths.getSparrowAtlas('icons/sans_icons', 'shared');
				iconScale = 0.5;
				defaultIconScale = 0.5;

				antialiasing = true;
				animation.addByPrefix('default', "loosing", 24, false, isPlayer);
			case 'sansWinning': //only for freeplay
				frames = Paths.getSparrowAtlas('icons/sans_icons', 'shared');
				iconScale = 0.5;
				defaultIconScale = 0.5;

				antialiasing = true;
				animation.addByPrefix('default', "winning", 24, false, isPlayer);
			case 'lock': //only for freeplay
				frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
				iconScale = 0.5;
				defaultIconScale = 0.5;

				antialiasing = true;
				animation.addByPrefix('default', "lock", 24, false, isPlayer);
			case 'pico':
				frames = Paths.getSparrowAtlas('icons/pico_icons', 'shared');
				iconScale = 0.4;
				defaultIconScale = 0.4;

				antialiasing = true;
				animation.addByPrefix('default', "normal", 24, false, isPlayer);
				animation.addByPrefix('losing', "loosing", 24, false, isPlayer);
				animation.addByPrefix('winning', "winning", 24, false, isPlayer);
			case 'paps':
				frames = Paths.getSparrowAtlas('icons/paps_icons', 'shared');
				iconScale = 0.5;
				defaultIconScale = 0.5;

				antialiasing = true;
				animation.addByPrefix('default', "normal_paps", 24, false, isPlayer);
				animation.addByPrefix('losing', "loosing_paps", 24, false, isPlayer);
				animation.addByPrefix('winning', "winning_paps", 24, false, isPlayer);
			default:
				frames = Paths.getSparrowAtlas('icons/bf_icons', 'shared');
				iconScale = 0.5;
				defaultIconScale = 0.5;

				antialiasing = true;
				animation.addByPrefix('default', "normal_bf", 24, false, isPlayer);
				animation.addByPrefix('losing', "loosing_bf", 24, false, isPlayer);
				animation.addByPrefix('winning', "winning_bf", 24, false, isPlayer);
			case 'bfKR':
				frames = Paths.getSparrowAtlas('icons/iconsKR', 'shared');
				iconScale = 0.5;
				defaultIconScale = 0.5;

				antialiasing = true;
				animation.addByPrefix('default', "normal_bf", 24, false, isPlayer);
				animation.addByPrefix('losing', "loosing_bf", 24, false, isPlayer);
				animation.addByPrefix('winning', "winning_bf", 24, false, isPlayer);

			case 'bf-chara':
				frames = Paths.getSparrowAtlas('icons/bf_chara', 'shared');
				iconScale = 0.5;
				defaultIconScale = 0.5;

				antialiasing = true;
				animation.addByPrefix('default', "normal_bf", 24, false, isPlayer);
				animation.addByPrefix('losing', "loosing_bf", 24, false, isPlayer);
				animation.addByPrefix('winning', "winning_bf", 24, false, isPlayer);
			case 'chara':
				frames = Paths.getSparrowAtlas('icons/chara_icons', 'shared');
				iconScale = 0.5;
				defaultIconScale = 0.5;

				antialiasing = true;
				animation.addByPrefix('default', "normal_chara", 24, false, isPlayer);
				animation.addByPrefix('losing', "loosing_chara", 24, false, isPlayer);
				animation.addByPrefix('winning', "winning_chara", 24, false, isPlayer);
		}

		animation.play('default');

		iconSize = width;

		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		setGraphicSize(Std.int(iconSize * iconScale));
		updateHitbox();

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
