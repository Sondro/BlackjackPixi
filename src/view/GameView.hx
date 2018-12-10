package view;

import pixi.core.Application;
import pixi.core.display.Container;
import pixi.core.textures.Texture;
import pixi.core.sprites.Sprite;
import pixi.core.math.Point;
import pixi.core.text.TextStyle;
import pixi.core.text.Text;
import motion.Actuate;

@:access(Game)
class GameView extends Container {

	var app:Application;
	var game:Game;
	public var gameScale = 0.75;
	var bg:Sprite;
	var playerHeight:Float;
	var minPlayerWidth:Float;
	var playerView:PlayerView;
	var dealerView:DealerView;
	var deckView:DeckView;
	var playerPoints:Text;
	var dealerPoints:Text;
	var textStyle = new TextStyle({
		fontFamily: 'Arial',
		fontSize: 36,
		fontStyle: 'italic',
		fontWeight: 'normal',
		fill: ['#fffff0', '#ffff44'],
		stroke: '#303020',
		strokeThickness: 4,
		dropShadow: true,
		dropShadowColor: '#000000',
		dropShadowAlpha: 0.75,
		dropShadowAngle: Math.PI / 6,
		dropShadowDistance: 6,
		lineJoin: "round"
	});
	var betButtons:Array<Button> = [];
	var draw:Button;
	var end:Button;
	var double:Button;
	var replay:Button;
	var roundText:Text;

	public function new(app:Application, game:Game) {
		super();
		this.app = app;
		this.game = game;
	}

	public function init():Void {
		initBG();
		var scale = new Point(gameScale, gameScale);

		deckView = new DeckView(game.deck);
		deckView.scale = scale;
		deckView.x = app.renderer.width - deckView.width;
		deckView.y = app.renderer.height / 2;
		addChild(deckView);
		game.player.notifyOnCardDraw(deckView.onCardDraw);
		game.dealer.notifyOnCardDraw(deckView.onCardDraw);

		dealerView = new DealerView(this, game.dealer);
		dealerView.scale = scale;
		dealerView.x = (app.renderer.width - dealerView.width) / 2;
		dealerView.y = 0;
		addChild(dealerView);

		playerView = new PlayerView(this, game.player);
		playerView.scale = scale;
		playerHeight = Assets.images.get("cards_back").texture.height * gameScale;
		minPlayerWidth = playerView.cardsWidth(2) * gameScale;
		playerView.x = (app.renderer.width - minPlayerWidth) / 2;
		playerView.y = app.renderer.height - playerHeight;
		addChild(playerView);

		addPoints();
		if (game.state == Bet) addBetButtons();
		else addButtons();

		game.notifyOnBet(onBet);
		game.notifyOnNewRound(onNewRound);
		game.notifyOnRoundEnd(onRoundEnd);
		game.notifyOnGameOver(onGameOver);
		game.deck.notifyOnRefill(onRefill);
	}

	function initBG():Void {
		var canvas = js.Browser.document.createCanvasElement();
		canvas.width = Std.int(app.renderer.width);
		canvas.height = Std.int(app.renderer.height);
		var ctx = canvas.getContext("2d");
		var w = canvas.width * 2;
		var h = canvas.height * 2;
		var grd = ctx.createRadialGradient(w / 4, h / 2, 0, w / 4, h / 2, w / 3);
		grd.addColorStop(0, "#00d150");
		grd.addColorStop(1, "#007030");
		ctx.fillStyle = grd;
		ctx.translate(0, 0);
		ctx.scale(1, 0.5);
		ctx.fillRect(0, 0, w, h);

		removeChild(bg);
		bg = new Sprite(Texture.fromCanvas(canvas));
		addChildAt(bg, 0);
	}

	function addPoints():Void {
		var bet = playerView.bet;
		bet.scale = new Point(gameScale, gameScale);
		bet.x = app.renderer.width / 2 - minPlayerWidth / 2 - bet.width / 2;
		bet.y = playerView.y - bet.height;
		addChild(playerView.bet);
		var money = playerView.money;
		money.scale = new Point(gameScale, gameScale);
		money.x = app.renderer.width / 2 + minPlayerWidth / 2 - money.width / 2;
		money.y = playerView.y - money.height;
		addChild(playerView.money);
		var offY = Math.max(bet.height, money.height);

		var points = game.handCount(game.player.hand);
		playerPoints = new Text("", textStyle);
		addChild(playerPoints);

		dealerPoints = new Text("", textStyle);
		addChild(dealerPoints);
	}

	function addBetButtons():Void {
		var bets = [20, 50, 100];
		var colors:Array<Button.ButtonColor> = [Green, Yellow, Red];
		var offY = -Button.btnHeight();
		for (i in 0...bets.length) {
			var bet = bets[i];
			var text = new Text('Bet: $bet$$', textStyle);
			var btn = new Button(colors[i], text);
			btn.y = (app.renderer.height - btn.height) / 2 + offY;
			offY += btn.height;
			betButtons.push(btn);
			addChild(btn);
			if (game.player.money < bet) {
				btn.disabled = true;
				continue;
			}
			btn.pointertap = function(e) {
				if (game.state != Bet) return;
				hideBetButtons();
				addButtons();
				game.player.setBet(bet);
				game.newRound();
			};
		}

		if (game.player.money < bets[0]) {
			onRoundEnd("gameOver");
		}
	}

	function hideBetButtons():Void {
		while (betButtons.length > 0) removeChild(betButtons.pop());
	}

	function addButtons():Void {
		var text = new Text('Hit', textStyle);
		draw = new Button(Yellow, text);
		draw.pointertap = function(e) {
			if (game.state != PlayerTurn) return;
			game.player.drawCard();
		};
		draw.y = (app.renderer.height - draw.height) / 2 - Button.btnHeight();
		addChild(draw);

		var text = new Text('Stand', textStyle);
		end = new Button(Blue, text);
		end.pointertap = function(e) {
			if (game.state != PlayerTurn) return;
			game.endTurn();
		};
		end.y = draw.y + draw.height;
		addChild(end);

		var text = new Text('Double', textStyle);
		double = new Button(Red, text);
		double.pointertap = function(e) {
			if (game.state != PlayerTurn) return;
			game.player.doubleBet();
		};
		double.y = end.y + end.height;
		addChild(double);
	}

	function hideButtons():Void {
		removeChild(draw);
		removeChild(end);
		removeChild(double);
	}

	function onBet():Void {
		hideButtons();
		addBetButtons();
	}

	function onNewRound():Void {
		playerView.newRound();
		dealerView.newRound();
		dealerPoints.text = "";
		// var x = (app.renderer.width - playerView.width) / 2;
		// Actuate.tween(playerView, 1, {x: x});
		// var x = (app.renderer.width - dealerView.width) / 2;
		// Actuate.tween(dealerView, 1, {x: x});
	}

	public function onCardDraw(view:Container, width:Float):Void {
		Actuate.tween(view, 1, {x: (app.renderer.width - width) / 2});
	}

	public function deckCords(view:Container):Point {
		return new Point(deckView.x - view.x, deckView.y - view.y);
	}

	function onRoundEnd(state:String):Void {
		var text = switch (state) {
			case "win": "You win!";
			case "lose": "You lose!";
			case "draw": "Draw!";
			case "refill": "Deck shuffled!";
			case "gameOver": "Game Over";
			default: "Error";
		}
		var style = textStyle.clone();
		style.fontSize = 50;
		style.align = "center";

		roundText = new Text(text, style);
		if (state != "gameOver") {
			roundText.interactive = true;
			roundText.buttonMode = true;
		}
		roundText.pointertap = function(e) {
			newRoundBtn(state);
		};
		roundText.x = (app.renderer.width - roundText.width) / 2;
		roundText.y = (app.renderer.height - roundText.height) / 2;
		addChild(roundText);

		updateDealerPoints();
		if (state == "gameOver") return;

		var text = new Text("Replay", style);
		replay = new Button(Green, text);
		replay.pointertap = function(e) {
			newRoundBtn(state);
		};
		replay.x = Button.btnWidth();
		replay.y = (app.renderer.height - replay.height) / 2;
		addChild(replay);
	}

	function newRoundBtn(state:String):Void {
		if (state == "gameOver") return;
		removeChild(replay);
		removeChild(roundText);
		if (state == "refill") {
			game.newRound();
			return;
		}
		game.endTurn();
	}

	public function updateDealerPoints():Void {
		if (!dealerView.isOpenHand()) return;
		var points = game.handCount(game.dealer.hand);
		dealerPoints.text = '$points';
		dealerPoints.x = (app.renderer.width - dealerPoints.width) / 2;
		dealerPoints.y = dealerView.y + dealerView.getHeight();
	}

	public function onRefill():Void {
		onRoundEnd("refill");
		deckView.onDeckRefill();
	}

	public function onGameOver():Void {
		onRoundEnd("gameOver");
	}

	public function onUpdate(e:Float) {
		if (draw != null) {
			var off = game.state == PlayerTurn ? false : true;
			draw.disabled = off;
			end.disabled = off;
			if (!game.player.canDouble) double.disabled = true;
			else double.disabled = off;
		}

		if (playerView.points > 0) {
			playerPoints.text = '${playerView.points}';
			playerPoints.x = (app.renderer.width - playerPoints.width) / 2;
			playerPoints.y = playerView.y - playerPoints.height;
		}
		playerView.update();
	}

	public function onResize():Void {
		initBG();
	}

}
