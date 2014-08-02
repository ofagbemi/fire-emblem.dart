library chapter;

import 'package:mapper/mapper.dart';
import 'package:unit/unit.dart';

import 'package:fire_emblem/game_state.dart';

import 'dart:html';
import 'dart:convert';
import 'dart:async';

class Chapter {

  GameState gameState;

  // map from src url to the image element
  Map _loadedImages = {};

  String url;

  Mapper map;
  Entity cursor;
  List<Entity> entities =[];
  List<Unit> units = [];

  bool loaded = false;

  // needed for constructor
  CanvasElement mapCanvas;
  CanvasElement rangeCanvas;
  CanvasElement overworldCanvas;
  int _tileWidth;
  int _tileHeight;

  int get tileWidth => _tileWidth;
  int get tileHeight => _tileHeight;

  void set tileWidth(int val) {
    _tileHeight = val;
  }

  void set tileHeight(int val){
    _tileHeight = val;
  }

  Chapter(this.url, this.mapCanvas, this.rangeCanvas,
          this.overworldCanvas,
          this._tileWidth, this._tileHeight) {
  }

  void loop(int f, void updateFn(Timer t)) {
    Timer timer = new Timer.periodic(
        new Duration(milliseconds: (1000~/f)),
        updateFn
    );
  }

  Map<String, ImageElement> getImages(Map chapterJSON) {
    Map<String, ImageElement> images = {};
    // get map tileset
    var tilesetSrc = chapterJSON['map']['tileset']['src'];
    images[tilesetSrc] = new ImageElement(src: tilesetSrc)
      ..className = 'spritesheet';

    // get unit spritesheets
    chapterJSON['units'].forEach((unitJSON) {
      AnimationData.ANIMATION_NAMES.forEach((type, List animationNames) {
        animationNames.forEach((animationName) {
          var spriteSrc = 'images/sprites/${unitJSON['id']}/' +
            AnimationData.data[type]['unit'][animationName]['sprite']['src'];
          images[spriteSrc] = new ImageElement(src: spriteSrc)
            ..className = 'spritesheet';
        });
      });
    });

    // get cursor spritesheet
    String cursorSrc = 'images/sprites/cursor/' +
        AnimationData.data['overworld']['misc']['cursor']['sprite']['src'];
    images[cursorSrc] = new ImageElement(src: cursorSrc)
      ..className = 'spritesheet';

    return images;
  }

  void loadChapter() {
    var request = HttpRequest.getString(url)
        .then((String responseText) {

      Map chapterJSON = JSON.decode(responseText);


      Map<String, ImageElement> images = getImages(chapterJSON);
      querySelector('body').children.addAll(images.values);
      var futures = [];
      images.forEach((src, img) {
        futures.add(img.onLoad.first);
      });

      Future.wait(futures).then((_) {

        _loadedImages.addAll(images);

        Map mapJSON = chapterJSON['map'];
        Map tilesetJSON = mapJSON['tileset'];

        List unitJSON = chapterJSON['units'];
        this.map = _loadMap(mapJSON);
        this.units = _loadUnits(unitJSON);
        this.cursor = _loadCursor(chapterJSON);

        this.entities.addAll(units);
        this.entities.add(cursor);

        loaded = true;
      });
    });
  }

  Entity _loadCursor(Map chapterJSON) {
    var cursorJSON = AnimationData.data['overworld']['misc']['cursor'];

    String src = 'images/sprites/cursor/' +
        cursorJSON['sprite']['src'];

    Sprite sprite = Sprite.loadSpritesheet(
        _loadedImages[src],
        cursorJSON['sprite']['width'],
        cursorJSON['sprite']['height'],
        cursorJSON['sprite']['tileWidth'],
        cursorJSON['sprite']['tileHeight'],
        cursorJSON['sprite']['offsetX'],
        cursorJSON['sprite']['offsetY'],
        cursorJSON['animation']
    );

    Map sprites = {};
    sprites['overworld'] = {};
    sprites['overworld']['cursor'] = sprite;

    return new Entity(sprites: sprites, map: map)
      ..setSprite('overworld', 'cursor')
      ..speed = 0.5
      ..setTile(
          chapterJSON['cursor_x'], chapterJSON['cursor_y']
      );
  }

  Mapper _loadMap(Map mapJSON) {
    Map tilesetJSON = mapJSON['tileset'];
    ImageElement tilesetImg = _loadedImages[tilesetJSON['src']];

    Tileset tileset = new Tileset(
        tilesetImg,
        tilesetJSON['width'], tilesetJSON['height']
    );

    return new Mapper(
        mapCanvas, tileset, mapJSON['tiles'],
        mapJSON['width'], mapJSON['height'],
        tileWidth, tileHeight, rangeCanvas
    );
  }

  // Builds the units, does not load their spritesheets
  // can optionally add URLs to an array to load the
  // spritesheets later
  List<Unit> _loadUnits(List<Map> unitsJSON) {
    List<Unit> newUnits = [];
    unitsJSON.forEach((unitJSON) {
      var sprites = _getUnitSprites(
          unitJSON['id'],
          'overworld'
      );

      Unit unit = new Unit(
          sprites: sprites,
          map: this.map,
          stats: unitJSON['stats']);

      unit.setTile(unitJSON['x'], unitJSON['y']);

      newUnits.add(unit);
      unit.setSprite('overworld', 'idle');
    });


    return newUnits;
  }

  Map _getUnitSprites(String unit_id, String type) {
    List animationNames = AnimationData.ANIMATION_NAMES[type];

    Map sprites = {};
    animationNames.forEach((animationName) {
      String src =  'images/sprites/$unit_id/' +
          AnimationData.data[type]['unit'][animationName]['sprite']['src'];

      ImageElement img = _loadedImages[src]
        ..className = 'spritesheet';

      if(sprites[type] == null) {
        sprites[type] = {};
      }
      sprites[type][animationName] = Sprite.loadSpritesheet(
          img,
          AnimationData.data[type]['unit'][animationName]['sprite']['width'],
          AnimationData.data[type]['unit'][animationName]['sprite']['height'],
          AnimationData.data[type]['unit'][animationName]['sprite']['tileWidth'],
          AnimationData.data[type]['unit'][animationName]['sprite']['tileHeight'],
          AnimationData.data[type]['unit'][animationName]['sprite']['offsetX'],
          AnimationData.data[type]['unit'][animationName]['sprite']['offsetY'],
          AnimationData.data[type]['unit'][animationName]['animation']
      );
    });
    return sprites;
  }
}
