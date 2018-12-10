package;

import pixi.plugins.app.Application;
import pixi.core.graphics.Graphics;
import pixi.core.textures.Texture;
import pixi.core.sprites.Sprite;
import js.Browser.window;
import view.GameView;

class Main extends Application {

	static function main() {
		Assets.loadEverything(function() {
			new Main();
		});
	}

	public function new() {
		super();
		position = Application.POSITION_FIXED;
		width = window.innerWidth;
		height = window.innerHeight;
		backgroundColor = 0x007030;
		transparent = false;
		antialias = false;
		autoResize = true;
		roundPixels = true;
		super.start();

		var game = new Game();
		game.init();
		var gameView = new GameView(app, game);
		stage.addChild(gameView);
		gameView.init();
		onUpdate = gameView.onUpdate;
		onResize = function() {
			width = window.innerWidth;
			height = window.innerHeight;
			gameView.onResize();
		};
	}
}
