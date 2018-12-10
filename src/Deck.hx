package;

class Deck {

	var game:Game;
	var cards:Array<Card>;
	public var length(get, never):Int;
	inline function get_length():Int {
		return cards.length;
	}
	var onRefillListeners = [];

	public function new(game:Game) {
		this.game = game;
	}

	public function init():Void {
		cards = [
			for (id in 0...13)
				for (suit in 0...4)
					new Card(suit, id)
		];
		shuffle(cards);
	}

	public function shuffleDiscard():Void {
		var discard:Array<Card> = game.clearDiscard();
		shuffle(discard);
		for (card in discard) {
			card.isOpen = false;
			cards.unshift(card);
		}
		for (i in onRefillListeners) i();
	}

	public function pop():Card {
		return cards.pop();
	}

	function shuffle<T>(arr:Array<T>):Void {
		for (i in 0...arr.length) {
			var j = Std.random(arr.length);
			var a = arr[i];
			var b = arr[j];
			arr[i] = b;
			arr[j] = a;
		}
	}

	public function notifyOnRefill(listener:Void->Void): Void {
		onRefillListeners.push(listener);
	}

}
