package view;

import pixi.core.textures.Texture;
import pixi.core.sprites.Sprite;
import pixi.core.display.Container;
import pixi.core.math.Point;
import motion.Actuate;
import motion.easing.Linear;

class CardView extends Container {

	var sprite:Sprite;
	var card:Card;

	public function new(card:Card) {
		super();
		this.card = card;
		var path = getTexturePath(card);
		var img = Assets.images.get(path);
		var tex = card.isOpen ? img.texture : Assets.images.get("cards_back").texture;
		sprite = new Sprite(tex);
		addChild(sprite);
	}

	function getTexturePath(card:Card):String {
		var suit = switch (card.suit) {
			case Pika: "pika";
			case Hearts: "hearts";
			case Clover: "clover";
			case Diam: "diam";
		}
		var type = switch (card.type) {
			case Ace: 12;
			default: card.type - 1;
		}
		return 'cards_${suit}_$type';
	}

	function showCard():Void {
		var path = getTexturePath(card);
		var img = Assets.images.get(path);
		sprite.texture = img.texture;
	}

	public function hide():Void {
		sprite.texture = Assets.images.get("cards_back").texture;
	}

	public function show():Void {
		if (sprite.texture != Assets.images.get("cards_back").texture) return;
		var tintSpeed = 0x10101 * 5;
		var time = 0.3;
		Actuate.tween(sprite, time, {x: sprite.width / 2})
		.ease(Linear.easeNone)
		.onUpdate (function() {
			if (sprite.tint - tintSpeed > 0) sprite.tint -= tintSpeed;
		});

		Actuate.tween(sprite.scale, time, {x: 0})
		.ease(Linear.easeNone)
		.onComplete(function() {
			showCard();

			Actuate.tween(sprite, time, {x: 0})
			.ease(Linear.easeNone)
			.onUpdate (function() {
				if (sprite.tint + tintSpeed < 0xFFFFFF) sprite.tint += tintSpeed;
			})
			.onComplete(function() {
				sprite.tint = 0xFFFFFF;
			});

			Actuate.tween(sprite.scale, time, {x: 1})
			.ease(Linear.easeNone);
		});
	}

}
