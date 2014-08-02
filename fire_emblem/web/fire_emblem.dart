import 'package:mapper/mapper.dart';
import 'package:unit/unit.dart';

import 'package:fire_emblem/chapter.dart';
import 'package:fire_emblem/game_state.dart';

import 'dart:html';
import 'dart:async';

void main() {
  BodyElement body = querySelector('body');

  ImageElement sacaeTilesetImg = new ImageElement(src: 'images/tilesets/sacae1.png');
  sacaeTilesetImg.className = 'spritesheet';

  CanvasElement mapCanvas = querySelector('#map');
  CanvasElement rangeCanvas = querySelector('#range');
  CanvasElement overworldCanvas = querySelector('#overworld');

  List<CanvasElement> canvases = [mapCanvas, rangeCanvas, overworldCanvas];

  int tileSize = 32;

  canvases.forEach((c) {
    c.width = 15 * tileSize;
    c.height = 10 * tileSize;
    c.context2D.imageSmoothingEnabled = false;
  });

  Chapter ch = new Chapter(
      'json/test_chapter.json',
      mapCanvas, rangeCanvas, overworldCanvas,
      tileSize, tileSize
  );
  ch.loadChapter();

  Unit getUnitAtTile(Point p) {
    return ch.map.getTileXY(p.x, p.y).properties['unit'];
  }

  Unit selectedUnit;
  window.onKeyDown.listen((KeyboardEvent e) {
    var cursor = ch.cursor;
    switch(e.keyCode) {
      case KeyCode.UP:
        cursor.up();
        break;
      case KeyCode.DOWN:
        cursor.down();
        break;
      case KeyCode.LEFT:
        cursor.left();
        break;
      case KeyCode.RIGHT:
        cursor.right();
        break;
      case KeyCode.X:
        switch(ch.gameState.state) {
          case MOVING_UNIT:
            var tile = selectedUnit.currentTilePointRounded;
            ch.cursor.setTile(tile.x, tile.y);
            selectedUnit.setSprite('overworld', 'active');
            selectedUnit = null;
            ch.map.clearRange();
            ch.gameState = new GameState.onMap(
                cursorPosition: cursor.currentTilePointRounded
            );
            break;
          case MOVED_UNIT:
            cursor.unlock();
            cursor.visible = true;

            var from = ch.gameState.properties['from'];

            cursor.setTile(from.x, from.y);
            selectedUnit.setTile(from.x, from.y);

            selectedUnit.setSprite('overworld', 'down');
            ch.map.drawRange(selectedUnit.getRange());

            ch.gameState = new GameState.movingUnit();
            break;
        }
        break;
      case KeyCode.Z:
        if(selectedUnit != null) {
          // check if unit can move to this spot
          if(true) {

            var fromTilePoint = selectedUnit.currentTilePointRounded;
            var toTilePoint = cursor.currentTilePointRounded;

            ch.gameState = new GameState.movedUnit(
                from: fromTilePoint, to: toTilePoint
            );

            ch.cursor.lock();
            ch.cursor.visible = false;
            ch.map.clearRange();
            selectedUnit.currentPath = ch.map.getPathToTile(
                fromTilePoint, toTilePoint,
                filter: selectedUnit.stats['move']
            );
          }
        } else {
          selectedUnit = getUnitAtTile(cursor.currentTilePointRounded);
          if(selectedUnit != null) {
            selectedUnit.selected = true;
            selectedUnit.setSprite('overworld', 'down');
            ch.map.drawRange(selectedUnit.getRange());

            ch.gameState = new GameState.movingUnit();;
          }
        }
        break;
    }
  });

  int frame = 0;
  void update(Timer t) {
    if(!ch.loaded) return;

    if(ch.map != null) ch.map.drawSelf();

    ch.overworldCanvas.context2D.clearRect(0, 0, overworldCanvas.width, overworldCanvas.height);

    ch.entities.forEach((u) {
      u.move(onDone: () {});
      u.currentSprite.setAnimationFrame(frame);
      u.drawSelfAtTile(ch.map, ch.overworldCanvas.context2D);
    });
    frame++;
  }
  ch.loop(60, update);
}