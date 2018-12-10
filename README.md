Онлайн сборка:
http://mssite.org/projects/dev/blackjack/

Haxelib-зависимости:
* pixijs (git)
* actuate (git)

Для сборки с помощью Haxe 4 достаточно закомментировать `implements Dynamic` [на данной строке](https://github.com/pixijs/pixi-haxe/blob/dev/src/pixi/core/renderers/webgl/filters/Filter.hx#L103) pixi-биндингов.

С Haxe 3 проблем не замечено.
