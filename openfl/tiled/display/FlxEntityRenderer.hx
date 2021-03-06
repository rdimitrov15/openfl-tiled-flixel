// Copyright (C) 2013 Christopher "Kasoki" Kaster
//
// This file is part of "openfl-tiled-flixel". <http://github.com/Kasoki/openfl-tiled-flixel>
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
package openfl.tiled.display;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import openfl.tiled.display.Renderer;

class FlxEntityRenderer implements Renderer {

	private var map:TiledMap;

	private var _tileCache:Map<Int, BitmapData>;

	public function new() {
		this._tileCache = new Map<Int, BitmapData>();
	}

	public function setTiledMap(map:TiledMap):Void {
		this.map = map;
	}

	public function drawLayer(on:Dynamic, layer:Layer):Void {
		var gidCounter:Int = 0;
		var flxLayer:FlxLayer = new FlxLayer(layer);

		if(layer.visible) {
			for(y in 0...map.heightInTiles) {
				for(x in 0...map.widthInTiles) {
					var tile = layer.tiles[gidCounter];

					var nextGID = tile.gid;

					if(nextGID != 0) {
						var position:Point = new Point();

						switch (map.orientation) {
							case TiledMapOrientation.Orthogonal:
								position = new Point(x * map.tileWidth, y * map.tileHeight);
							case TiledMapOrientation.Isometric:
								position = new Point((map.width + x - y - 1) * map.tileWidth * 0.5, (y + x) * map.tileHeight * 0.5);
						}

						var bitmapData:BitmapData;

						if(!this._tileCache.exists(nextGID)) {
							var tileset:Tileset = map.getTilesetByGID(nextGID);
							var rect:Rectangle = tileset.getTileRectByGID(nextGID);
							var texture:BitmapData = tileset.image.texture;

							bitmapData = new BitmapData(map.tileWidth, map.tileHeight,
								true, map.backgroundColor);

							bitmapData.copyPixels(texture, rect, new Point(0, 0));

							this._tileCache.set(nextGID, bitmapData);
						} else {
							bitmapData = this._tileCache.get(nextGID);
						}

						if(map.orientation == TiledMapOrientation.Isometric) {
							position.x += map.totalWidth * 0.5;
						}

						var flxTile:FlxTile = new FlxTile(tile, bitmapData);

						flxTile.x = position.x;
						flxTile.y = position.y;

						flxTile.alpha = layer.opacity;

						flxLayer.add(flxTile);
					}

					gidCounter++;
				}
			}
		}
		
		on.layers.push(flxLayer);
		
		// add layer to map
		on.add(flxLayer);
	}

	public function drawImageLayer(on:Dynamic, imageLayer:ImageLayer):Void {
		var sprite = new FlxSprite();

		sprite.pixels = imageLayer.image.texture;
		sprite.active = false;
		sprite.immovable = true;

		sprite.alpha = imageLayer.opacity;

		on.add(sprite);
	}

	public function clear(on:Dynamic):Void {
	}
}