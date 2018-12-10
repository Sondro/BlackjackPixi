package;

class Player {

	static inline var BASE_BET = 20;
	var game:Game;
	public var money(default, null) = 1000;
	var bet = BASE_BET;
	public var hand(default, null):Array<Card> = [];
	public var canDouble(default, null):Bool;
	var cardDrawListeners = [];

	public function new(game:Game) {
		this.game = game;
	}

	public function setBet(num:Int):Void {
		bet = num;
	}

	public inline function hasNoMoney():Bool {
		return money < BASE_BET;
	}

	public function newRound():Void {
		money -= bet;
		canDouble = money >= bet;
	}

	public function addCard(card:Card):Void {
		card.isOpen = true;
		hand.push(card);
		for (i in cardDrawListeners) i();
	}

	public function doubleBet():Void {
		if (!canDouble) return;
		money -= bet;
		bet = bet * 2;
		drawCard();
	}

	public function drawCard():Void {
		if (game.isEmptyDeck()) return;
		canDouble = false;
		var card = game.drawCard();
		card.isOpen = true;
		hand.push(card);

		for (i in cardDrawListeners) i();

		game.checkPlayerHand(hand);
	}

	public function win():Void {
		money += bet * 2;
	}

	public function draw():Void {
		money += bet;
	}

	public function lose():Void {}

	public function notifyOnCardDraw(listener:Void->Void): Void {
		cardDrawListeners.push(listener);
	}

}
