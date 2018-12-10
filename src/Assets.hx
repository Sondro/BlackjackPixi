package;

import pixi.core.textures.Texture;
import pixi.loaders.Resource;
import pixi.loaders.Loader;

class Assets {

	static var loader:Loader;
	static var resources:Resource;

	public static function loadEverything(callback:Void->Void):Void {
		loader = new Loader();
		loader.add("cards_back", "cards/back.png");
		var suits = ["pika", "hearts", "clover", "diam"];
		for (suit in suits) {
			for (i in 0...13) {
				loader.add('cards_${suit}_$i', 'cards/${suit}_$i.png');
			}
		}

		var colors = ["blue", "green", "red", "yellow"];
		var states = ["disabled", "glow", "over", "press_disabled", "press", "release"];
		for (color in colors) {
			for (state in states) {
				loader.add('buttons_${color}_$state', 'buttons/btn_ingame_${color}_$state.png');
			}
		}

		loader.load(function(loader, res) {
			resources = res;
			callback();
		});
	}

	public static var images = new ImageList();

}

@:access(Assets)
private class ImageList {

	public function new() {}

	public inline function get(name:String):Resource {
		return Assets.resources.get(name);
	}

}
