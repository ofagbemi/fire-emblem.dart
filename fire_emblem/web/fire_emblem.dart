import 'package:mapper/mapper.dart';
import 'package:unit/unit.dart';

import 'package:fire_emblem/cursor.dart';

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


  Unit overUnit;
  // set selected unit on cursor move event
  window.on[CURSOR_MOVE_EVENT].listen((CustomEvent e) {
    var newOverUnit = ch.getUnitAtTile(e.detail['to']);
    print('$newOverUnit from ${e.detail['from']} to ${e.detail['to']}');
    if(overUnit != null && newOverUnit != overUnit) {
      overUnit.setSprite('overworld', 'idle');
    } else if(newOverUnit != null) {
      overUnit = newOverUnit;
      overUnit.setSprite('overworld', 'active');
    }
  });

  window.onKeyDown.listen((KeyboardEvent e) {
    var cursor = ch.cursor;
    switch(e.keyCode) {
      case KeyCode.UP:
        var to = cursor.up();

        if(ch.gameState.state == ON_MAP) {
          var gameState = new GameState.onMap(
              cursorPosition: to
          );
          ch.setState(gameState);
        }
        break;
      case KeyCode.DOWN:
        Point<int> to = cursor.down();

        // NOTE: double for some reason
        // print(to.x.runtimeType);

        if(ch.gameState.state == ON_MAP) {
          var gameState = new GameState.onMap(
              cursorPosition: to
          );
          ch.setState(gameState);
        }
        break;
      case KeyCode.LEFT:
        var to = cursor.left();

        if(ch.gameState.state == ON_MAP) {
          var gameState = new GameState.onMap(
              cursorPosition: to
          );
          ch.setState(gameState);
        }
        break;
      case KeyCode.RIGHT:
        var to = cursor.right();

        if(ch.gameState.state == ON_MAP) {
          var gameState = new GameState.onMap(
              cursorPosition: to
          );
          ch.setState(gameState);
        }
        break;

      case KeyCode.X:
        // 'B' button
        switch(ch.gameState.state) {
          case MOVING_UNIT:
            var gameState = new GameState.onMap(
                cursorPosition: cursor.currentTilePointRounded
            );
            ch.setState(gameState);

            break;
          case MOVED_UNIT:
            // set state to moving unit
            Unit unit = ch.gameState.properties['unit'];
            var from = ch.gameState.properties['from'];
            var gameState = new GameState.movingUnit(
                unit: unit,
                from: from
            );
            ch.setState(gameState);
            break;
        }
        break;
      case KeyCode.Z:
        if(ch.selectedUnit != null) {
          // TODO: check if unit can move to this spot
          if(true && ch.gameState.state != MOVED_UNIT) {
            // set state to moved unit
            var fromTilePoint = ch.selectedUnit.currentTilePointRounded;
            var toTilePoint = cursor.currentTilePointRounded;
            var gameState = new GameState.movedUnit(
                from: fromTilePoint, to: toTilePoint,
                unit: ch.selectedUnit
            );
            ch.setState(gameState);
          } else {
            // TODO: play sound and block movement
          }
        } else {
          Unit unit = ch.getUnitAtTile(cursor.currentTilePoint);
          if(unit != null) { // TODO: check if the unit can still move
            // set state to moving unit
            var gameState = new GameState.movingUnit(
                unit: unit,
                from: unit.currentTilePointRounded
            );
            ch.setState(gameState);
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

  // initialize game state
  ch.gameState = new GameState.onMap(cursorPosition: new Point(0, 0));
  ch.loop(60, update);
}