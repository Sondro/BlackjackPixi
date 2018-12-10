package;

enum GameState {
	Bet;
	PlayerTurn;
	DealerTurn;
	RoundOver;
	GameOver;
}

class Game {

	var player:Player;
	var dealer:Dealer;
	var deck:Deck;
	var discard:Discard;
	var state:GameState;
	var betListeners = [];
	var newRoundListeners = [];
	var roundEndListeners = [];
	var gameOverListeners = [];

	public function new() {}

	public function init():Void {
		deck = new Deck(this);
		deck.init();
		discard = new Discard();
		player = new Player(this);
		dealer = new Dealer(this);
		state = Bet;
	}

	public function newRound():Void {
		while (player.hand.length > 0) {
			discard.push(player.hand.pop());
		}
		while (dealer.hand.length > 0) {
			discard.push(dealer.hand.pop());
		}

		if (deck.length < 10) {
			deck.shuffleDiscard();
			return;
		}

		player.newRound();
		for (i in newRoundListeners) i();

		for (i in 0...2) player.addCard(deck.pop());
		for (i in 0...2) dealer.addCard(deck.pop());
		state = PlayerTurn;
	}

	public inline function getState():GameState {
		return state;
	}

	public inline function clearDiscard():Array<Card> {
		var cards = discard.cards;
		discard.cards = [];
		return cards;
	}

	public function isEmptyDeck():Bool {
		return deck.length == 0;
	}

	function isGameOver():Bool {
		if (player.hasNoMoney()) {
			state = GameOver;
			for (i in gameOverListeners) i();
			return true;
		}
		return false;
	}

	// public function checkDealerHand(hand:Array<Card>):Void {
	// 	var count = handCount(hand);
	// 	if (count > 21) playerWin();
	// }

	public function checkPlayerHand(hand:Array<Card>):Void {
		var count = handCount(hand);
		if (count > 21) playerLose();
	}

	public function handCount(hand:Array<Card>):Int {
		var count = 0;
		for (card in hand) {
			if (card.type == Ace) count += 1;
			else count += card.count;
		}
		if (count >= 21) return count;
		for (card in hand) {
			if (card.type != Ace) continue;
			count += 10;
			if (count > 21) return count - 10;
		}
		return count;
	}

	public function drawCard():Card {
		return deck.pop();
	}

	function playerWin():Void {
		player.win();
		for (i in roundEndListeners) i("win");
		state = RoundOver;
	}

	function playerLose():Void {
		player.lose();
		if (isGameOver()) return;
		for (i in roundEndListeners) i("lose");
		state = RoundOver;
	}

	function gameDraw():Void {
		player.draw();
		for (i in roundEndListeners) i("draw");
		state = RoundOver;
	}

	public function endTurn():Void {
		switch (state) {
			case Bet:
				state = PlayerTurn;
			case PlayerTurn:
				state = DealerTurn;
				dealer.update();
			case DealerTurn:
				state = RoundOver;
				scoring();
			case RoundOver:
				if (isGameOver()) return;
				state = Bet;
				for (i in betListeners) i();
			case GameOver:
		}
	}

	function scoring():Void {
		var playerScore = handCount(player.hand);
		var dealerScore = handCount(dealer.hand);
		if (playerScore > dealerScore || dealerScore > 21) playerWin();
		else if (dealerScore > playerScore) playerLose();
		else gameDraw();
	}

	// public function onUpdate():Void {
	// 	switch (state) {
	// 		case Bet:
	// 			endTurn();
	// 		case PlayerTurn:
	// 		case DealerTurn:
	// 			dealer.update();
	// 		case RoundOver:
	// 			endTurn();
	// 	}
	// }

	public function notifyOnBet(listener:Void->Void): Void {
		betListeners.push(listener);
	}

	public function notifyOnNewRound(listener:Void->Void): Void {
		newRoundListeners.push(listener);
	}

	public function notifyOnRoundEnd(listener:String->Void): Void {
		roundEndListeners.push(listener);
	}

	public function notifyOnGameOver(listener:Void->Void): Void {
		gameOverListeners.push(listener);
	}

}
