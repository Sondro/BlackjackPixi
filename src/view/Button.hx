package view;

import pixi.core.textures.Texture;
import pixi.core.sprites.Sprite;
import pixi.core.display.Container;
import pixi.core.text.TextStyle;
import pixi.core.text.Text;
import pixi.core.math.Point;

@:enum abstract ButtonColor(String) {
	var Blue = "blue";
	var Green = "green";
	var Red = "red";
	var Yellow = "yellow";
}

@:enum abstract ButtonState(String) {
	var Disabled = "disabled";
	var Glow = "glow";
	var Over = "over";
	var PressDisabled = "press_disabled";
	var Press = "press";
	var Release = "release";
}

class Button extends Container {

	public var disabled(default, set) = false;
	var state:ButtonState = Release;
	var color:ButtonColor;
	var bg:Sprite;
	var text:Text;

	public function new(color:ButtonColor, text:Text) {
		super();
		this.color = color;
		bg = new Sprite(getTexture());
		addChild(bg);
		this.text = text;
		text.x = width / 2 - text.width / 2;
		text.y = height / 2 - text.height / 2;
		addChild(text);
		buttonMode = true;
		interactive = true;

		pointerdown = function(e) {
			state = Press;
			if (disabled) state = PressDisabled;
			update();
		}

		pointerup = function(e) {
			state = Over;
			if (disabled) state = Disabled;
			update();
		}

		pointerover = function(e) {
			state = Over;
			if (disabled) state = Disabled;
			update();
		}

		pointerout = function(e) {
			state = Release;
			if (disabled) state = Disabled;
			update();
		}
	}

	function set_disabled(b:Bool):Bool {
		if (disabled == b) return b;
		disabled = b;
		if (b) disable();
		else enable();
		return b;
	}

	inline function update():Void {
		text.alpha = disabled ? 0.5 : 1;
		bg.texture = getTexture();
	}

	inline function enable():Void {
		state = Release;
		update();
	}

	inline function disable():Void {
		state = Disabled;
		update();
	}

	inline function getTexture():Texture {
		return Assets.images.get('buttons_${color}_$state').texture;
	}

	public static inline function btnWidth():Float {
		return Assets.images.get('buttons_blue_over').texture.width;
	}

	public static inline function btnHeight():Float {
		return Assets.images.get('buttons_blue_over').texture.height;
	}

}
