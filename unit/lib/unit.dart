library unit;

import 'package:mapper/mapper.dart';

import 'dart:html';
import 'dart:math';

class AnimationData {
  static final ANIMATION_NAMES = {
    'overworld': ['left', 'right', 'up', 'down', 'idle', 'active']
  };

  static final data = {
    'overworld': {
      'misc': {
        'cursor': {
          'animation': [{20:0}, {25:1}, {30:2}],
          'sprite': {
            'src': 'overworld/cursor.png',
            'width': 3,
            'height': 1,
            'tileWidth': 2,
            'tileHeight': 2,
            'offsetX': 0.1875,
            'offsetY': 0.171875
          }
        }
      },
      'unit': {
        'idle': {
          'animation': [{40:0}, {42:1}, {82:2}, {84:1}],
          'sprite': {
            'src': 'overworld/idle.png',
            'width': 3,
            'height': 1,
            'tileWidth': 1,
            'tileHeight': 2,
            'offsetX': 0,
            'offsetY': 0.5
          },
        },
        'left': {
          'animation': [{10:0}, {20:1}, {30:2}, {40:3}],
          'sprite': {
            'src': 'overworld/left.png',
            'width': 4,
            'height': 1,
            'tileWidth': 2,
            'tileHeight': 2,
            'offsetX': 0.25,
            'offsetY': 0.5
          },
        },
        'right': {
          'animation': [{10:0}, {20:1}, {30:2}, {40:3}],
          'sprite': {
            'src': 'overworld/right.png',
            'width': 4,
            'height': 1,
            'tileWidth': 2,
            'tileHeight': 2,
            'offsetX': 0.25,
            'offsetY': 0.5
          },
        },
        'down': {
          'animation': [{10:0}, {20:1}, {30:2}, {40:3}],
          'sprite': {
            'src': 'overworld/down.png',
            'width': 4,
            'height': 1,
            'tileWidth': 2,
            'tileHeight': 2,
            'offsetX': 0.25,
            'offsetY': 0.5
          },
        },
        'up': {
          'animation': [{10:0}, {20:1}, {30:2}, {40:3}],
          'sprite': {
            'src': 'overworld/up.png',
            'width': 4,
            'height': 1,
            'tileWidth': 2,
            'tileHeight': 2,
            'offsetX': 0.25,
            'offsetY': 0.5
          },
        },
        'active': {
          'animation': [{28:0}, {30:1}, {58:2}, {60:1}],
          'sprite': {
            'src': 'overworld/active.png',
            'width': 3,
            'height': 1,
            'tileWidth': 2,
            'tileHeight': 2,
            'offsetX': 0.25,
            'offsetY': 0.5
          }
        }
      }
    }
  };
}

class Frame {
  int x;
  int y;
  int width;
  int height;

  Frame(this.x, this.y, this.width, this.height);

  String toString() {
    return "{($x, $y), width: $width, height: $height}";
  }
}

class Sprite {
  int frame;
  List<Frame> imgFrames;
  ImageElement img;

  int animationFrame;
  int animationLength;

  int tileWidth;
  int tileHeight;

  num tileXOffset;
  num tileYOffset;

  /**
   * List of tick counts. For example
   *
   *     animationData = [{40:0}, {42:1}, {82:2}, {84:1}];
   *
   * describes an animation for a three frame sprite where
   * the first frame of the sprite is shown for 40 ticks,
   * the second for 2 ticks, the third for 40 ticks, and
   * the first again for 2 more ticks.
   *
   * The keys are NOT indices. They are frame counts, meaning
   * the last number in the list should be the number of
   * frames there are in the animation total.
   */
  List<Map<int, int>> animationData;

  /**
   * Constructor.
   */
  Sprite(this.img, this.imgFrames, this.tileWidth, this.tileHeight,
         this.tileXOffset, this.tileYOffset, this.animationData) {
    frame = 0;
    animationLength = animationData[animationData.length-1].keys.first;
  }

  /**
   * Returns a Sprite object built from an image element
   * and animation data. For example
   *
   *     Sprite s = Sprite.loadSpritesheet(img, width, height,
   *                    tileWidth, tileHeight,
   *                    tileXOffset, tileYOffset,
   *                    AnimationData.OVERWORLD_IDLE);
   *
   * returns a sprite from a spritesheet `width` tiles by `height`
   * tiles that are each `tileWidth` tiles wide by `tileHeight`
   * tiles high with the animation data for an idle overworld
   * animation.
   */
  static Sprite loadSpritesheet(ImageElement img, int width, int height,
                         int tileWidth, int tileHeight,
                         num tileXOffset, num tileYOffset,
                         List<Map<int, int>> animationData) {
    List<Frame> frames = new List<Frame>.generate(width*height,(i) {
      int x = i % width;
      int y = i ~/ width;

      int spriteWidth = img.width ~/ width;
      int spriteHeight = img.height ~/ height;

      return new Frame(x * spriteWidth, y * spriteHeight, spriteWidth, spriteHeight);
    });
    return new Sprite(img, frames, tileWidth, tileHeight, tileXOffset, tileYOffset, animationData);
  }

  /**
   * Draws the sprite at coordinate (x, y) resized to the renderSize
   * for each tile in the sprite. For example
   *
   *     s.drawSelf(context, 0, 0, 32, 32);
   *
   * draws the sprite at coordinate (0, 0) and draws each of the sprite's
   * tiles at 32 by 32 pixels. A sprite that is 1 tile by 2 tiles would
   * be rendered at 32 by 64 pixels.
   */
  void drawSelf(CanvasRenderingContext2D context, int x, int y,
                int renderWidth, int renderHeight) {
    Frame f = imgFrames[frame];
    context.drawImageScaledFromSource(
                img, f.x, f.y, f.width, f.height,
                x - (tileXOffset * tileWidth * renderWidth),
                y - (tileYOffset * tileHeight * renderHeight),
                tileWidth * renderWidth, tileHeight * renderHeight
            );
  }

  /**
   * Sets the sprite frame.
   *
   * For example
   *
   *     s.setFrame(1);
   *
   * sets the sprite's frame to the second frame in
   * its list of frames.
   */
  void setFrame(int f) {
    frame = f % imgFrames.length;
  }

  /**
   * Sets the sprite frame based on animation data.
   *
   * For example
   *
   *     s.setAnimationFrame(40);
   *
   * would set the sprite's frame to whatever frame is supposed
   * to be displayed at frame index 40 of the animation.
   */
  void setAnimationFrame(int a) {
    animationFrame = a % animationLength;
    for(int i=0; i<animationData.length;i++) {
      if(animationFrame < animationData[i].keys.first) {
        frame = animationData[i].values.first;
        return;
      }
    }
  }
}

class Direction {
  static const LEFT = const Direction._('left');
  static const RIGHT = const Direction._('right');
  static const UP = const Direction._('up');
  static const DOWN = const Direction._('down');

  static const IDLE = const Direction._('idle');

  final String value;
  const Direction._(this.value);
}

class Entity {
  dynamic id;

  Map<dynamic, Map<dynamic, Sprite>> sprites;

  Map<dynamic, num> stats;

  Sprite currentSprite;

  Point dest;

  TilePath currentPath;

  bool isMoving;

  bool canMove = true;
  bool visible = true;

  Mapper map;

  // position, in pixels, of an entity
  int x = 0;
  int y = 0;

  lock() {
    canMove = false;
  }

  unlock() {
    canMove = true;
  }

  /// proportion of a tile this entity can move
  /// in one frame
  num get speed => stats['movement_speed'];
  void set speed(var val) {
    stats['movement_speed'] = val;
  }

  Entity({this.id, this.sprites, this.map, this.stats}) {
    if(stats == null) {
      stats = {};
    }
  }

  num absoluteValue(num a) {
    return (a < 0? -a : a);
  }

  Direction get direction {
    if(dest == null) return Direction.IDLE;
    if(dest.x < x) {
      return Direction.LEFT;
    } else if(dest.x > x) {
      return Direction.RIGHT;
    } else if(dest.y < y) {
      return Direction.UP;
    } else if(dest.y > y) {
      return Direction.DOWN;
    } else {
      return Direction.IDLE;
    }
  }


  void move({void onDone()}) {
    if(!canMove || currentPath == null) return;

    if(dest == null || (x==dest.x && y == dest.y)) {
      dest = currentPath.next();

      if(dest == null) {
        isMoving = false;
        // set the map tile's unit to this one
        if(onDone != null) {
          onDone();
        }
        // map.getTileXY(currentTile.x~/1, currentTile.y~/1).properties['unit'] = this;
        return;
      }
    }

    // keep from going off of map
    Point tilePoint = map.getTileFromPixels(dest.x~/1, dest.y~/1);
    if(map.getTileXY(tilePoint.x~/1, tilePoint.y~/1) == null) {
      dest = currentPath.next();
      return;
    }

    isMoving = true;

    // reset direction when the destination changes
    switch(direction) {
      case Direction.UP:
        setSprite('overworld', 'up');
        break;
      case Direction.DOWN:
        setSprite('overworld', 'down');
        break;
      case Direction.LEFT:
        setSprite('overworld', 'left');
        break;
      case Direction.RIGHT:
        setSprite('overworld', 'right');
        break;
    }

    if(dest.x != x) {  // moving sideways
      // number of pixels we'll step in either
      // direction
      int step = (speed * map.renderWidth) ~/ 1;
      int delta = (dest.x - x)~/1;
      if(step > absoluteValue(delta)) {
        step = absoluteValue(delta);
      }
      x += step * (delta > 0 ? 1 : -1);
    } else {  // moving vertically
      int step = (speed * map.renderHeight) ~/ 1;
      int delta = (dest.y - y)~/1;
      if(step > absoluteValue(delta)) {
        step = absoluteValue(delta);
      }
      y+= step * (delta > 0 ? 1 : -1);
    }
  }

  /**
   * Returns the entity's current tile
   *
   *     entity.currentTile
   *
   * returns (0, 1) if the unit is at the tile (0, 1) and
   * returns (4.3, 7.7) if the unit is between tiles.
   */
  Point get currentTilePoint => new Point(x/map.renderWidth, y/map.renderWidth);
  void set currentTilePoint(Point p) {
    x = p.x * map.renderWidth;
    y = p.y * map.renderHeight;
  }

  num get currentTileX => x/map.renderWidth;
  num get currentTileY => y/map.renderHeight;


  Point get currentTilePointRounded => new Point(
      x~/map.renderWidth,
      y~/map.renderHeight
  );

  int get currentTileXRounded => x~/map.renderWidth;
  int get currentTileYRounded => y~/map.renderHeight;

  Tile get currentTile => map.getTileXY(
      currentTileXRounded,
      currentTileYRounded
  );

  /**
   * Sets the current sprite to the sprite with type `type`
   * and identifier `sprite`. For example
   *
   *     entity.setSprite('overworld', 'idle');
   *
   * sets the current sprite to the overworld idle sprite,
   * if it's available.
   */
  void setSprite(dynamic type, dynamic sprite) {
    if(sprites[type][sprite] != null) {
      currentSprite = sprites[type][sprite];
    }
  }

  /**
   * Sets this entity's location to the tile at x, y. For
   * example
   *
   *     entity.setTile(4, 7.8);
   *
   * sets the entity's location to the tile at (4, 7.8). Note
   * that the function can take continuous values. This is
   * to allow this function to animate movement between
   * tiles.
   */
  void setTile(num x, num y) {
    this.x = map.renderWidth * x;
    this.y = map.renderHeight * y;
  }

  /**
   * Returns whether or not an entity is at a certain tile. For
   * example
   *
   *     entity.atTile(4, 3);
   *
   * returns true only if the entity is precisely on tile
   * (4, 3). If the entity is currently transitioning between
   * tiles, this function will return false.
   */
  bool atTile(num x, num y) {
    return (this.x == x * map.renderWidth) && (this.y == y * map.renderHeight);
  }

  void drawSelf(CanvasRenderingContext2D context,
                  int renderWidth, int renderHeight) {
    if(!visible) return;
    this.currentSprite.drawSelf(context, x, y, renderWidth, renderHeight);
  }

  /**
   * Draws this entity at its current tile location. For example,
   *
   *     entity.drawSelfAtTile(map, context);
   *
   * renders this unit at its current x and y values.
   */
  void drawSelfAtTile(Mapper map, CanvasRenderingContext2D context) {
    if(!visible) return;
    currentSprite.drawSelf(context, x ~/ 1, y ~/ 1,
                           map.renderWidth, map.renderHeight);
  }

  void up() {
    Point p = new Point(
      this.currentTilePoint.x,
      (this.currentTilePointRounded.y-1));

    if(currentPath == null) {
      currentPath = new TilePath(map, [p]);
    } else {
      currentPath.add(p);
    }
  }

  void down() {
    Point p = new Point(
      this.currentTilePoint.x,
      (this.currentTilePointRounded.y+1));

    if(currentPath == null) {
      currentPath = new TilePath(map, [p]);
    } else {
      currentPath.add(p);
    }
  }

  void left() {
    Point p = new Point(
      (this.currentTilePointRounded.x-1),
      this.currentTilePoint.y);

    if(currentPath == null) {
      currentPath = new TilePath(map, [p]);
    } else {
      currentPath.add(p);
    }
  }

  void right() {
    Point p = new Point(
      (this.currentTilePointRounded.x+1),
      this.currentTilePoint.y);

    if(currentPath == null) {
      currentPath = new TilePath(map, [p]);
    } else {
      currentPath.add(p);
    }
  }
}

class Unit extends Entity {
  List<Entity> inventory;
  bool selected = false;

  Unit({id, sprites, map, stats, this.inventory}) :
    super(id: id, sprites: sprites, map: map, stats: stats) {

  }

  /**
   * Sets this entity's location to the tile at x, y. For
   * example
   *
   *     unit(4, 7.8);
   *
   * sets the entity's location to the tile at (4, 7.8). Note
   * that the function can take continuous values. This is
   * to allow this function to animate movement between
   * tiles, though this isn't recommended, epecially for units.
   */
  void setTile(num x, num y) {

    if(currentTile != null) {
      currentTile.properties['unit'] = null;
    }
    super.setTile(x, y);
    currentTile.properties['unit'] = this;
  }

  Set<Point> getRange() {
    Set<Point> points = new Set<Point>();
    _getPointsInRange(
        this.currentTilePointRounded,
        points,
        stats['move'] != null ? stats['move'] : 0
    );
    return points;
  }

  void _getPointsInRange(Point current, Set<Point> points, int movement) {
    points.add(current);

    if(movement == 0) return;

    Point up = new Point(current.x, current.y-1);
    if(map.canMoveTo(up)) {
      int m = map.getTile(up).properties['move'];
      if(m <= movement) {
        _getPointsInRange(up, points, movement - m);
      }
    }

    Point left = new Point(current.x-1, current.y);
    if(map.canMoveTo(left)) {
      int m = map.getTile(left).properties['move'];
      if(m <= movement) {
        _getPointsInRange(left, points, movement - m);
      }
    }

    Point right = new Point(current.x+1, current.y);
    if(map.canMoveTo(right)) {
      int m = map.getTile(right).properties['move'];
      if(m <= movement) {
        _getPointsInRange(right, points, movement - m);
      }
    }

    Point down = new Point(current.x, current.y+1);
    if(map.canMoveTo(down)) {
      int m = map.getTile(down).properties['move'];
      if(m <= movement) {
        _getPointsInRange(down, points, movement - m);
      }
    }
  }

  void move({void onDone()}) {
    super.move(
      onDone: () {
        this.currentTile.properties['unit'] = this;
        if(onDone != null) {
          onDone();
        }
      }
    );
  }

}
