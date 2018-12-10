package;

class Dealer {

	var game:Game;
	public var hand(default, null):Array<Card> = [];
	var cardDrawListeners = [];
	var onOpenCardListeners = [];

	public function new(game:Game) {
		this.game = game;
	}

	public function addCard(card:Card):Void {
		hand.push(card);
		for (i in cardDrawListeners) i();
	}

	public function update():Void {
		if (game.getState() != DealerTurn) return;
		for (card in hand) card.isOpen = true;
		for (i in onOpenCardListeners) i();
		if (game.isEmptyDeck()) {
			game.endTurn();
			return;
		}
		if (game.handCount(hand) < 17) drawCard();
		else game.endTurn();
	}

	function drawCard():Void {
		var card = game.drawCard();
		card.isOpen = true;
		hand.push(card);

		for (i in cardDrawListeners) i();
		// game.checkDealerHand(hand);
	}

	public function notifyOnCardDraw(listener:Void->Void): Void {
		cardDrawListeners.push(listener);
	}

	public function notifyOnOpenCard(listener:Void->Void): Void {
		onOpenCardListeners.push(listener);
	}

}
