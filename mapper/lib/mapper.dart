library mapper;

import 'dart:html';
import 'dart:math';
import 'dart:collection';

part 'tile.dart';
part 'tileset.dart';
part 'tile_path.dart';

class Mapper {
  /// canvas to draw the map to
  CanvasElement canvas;

  /// canvas to draw the range to
  CanvasElement rangeCanvas;

  /// tileset to use
  Tileset tileset;

  /// list of tile indices to use
  List<int> tileIndices;

  /// list of tiles that make up the actual map
  List<Tile> tiles;

  /// width, in tiles, of the map
  int width;

  /// height, in tiles, of the map
  int height;

  /// width, in pixels, that this tileset should render
  /// its tiles at
  int renderWidth;

  /// height, in pixels, that this tileset should render
  /// its tiles at
  int renderHeight;

  int get tileGutter => ((renderWidth * 0.02) ~/ 1) + 1;

  /**
   * If renderWidth and renderHeight aren't specified, they default
   * to sizes based on the width and the height of the canvas
   */
  Mapper(this.canvas, this.tileset, this.tileIndices,
         this.width, this.height, [this.renderWidth, this.renderHeight,
         this.rangeCanvas]) {

    if(renderWidth == null) renderWidth = canvas.width~/width;
    if(renderHeight == null) renderHeight = canvas.height~/height;
    updateTilesFromIndices(tileIndices);
  }

  /**
   * Returns a list of tiles from their indices in the tileset
   *
   *     List<int> tileIndices = [0, 1, 1, 0, null];
   *     List<Tile> tiles = getTilesFromIndices(tileIndices);
   */
  List<Tile> getTilesFromIndices(List<int> _indices) {
    return new List<Tile>.generate(_indices.length,
      (index) {
        if(_indices[index] == null) {
          return null;
        } else {
          return new Tile.from(tileset.tiles[_indices[index]]);
        }
    });
  }

  /**
   * Updates the list of tiles to the tile indices
   * provided
   *
   *     List<int> tileIndices = [0, 1, 1, null, 1];
   *     updateTileIndices(tileIndices);
   */
  void updateTilesFromIndices(_indices) {
    tiles = getTilesFromIndices(_indices);
  }

  /**
   * Draws the entire map to its canvas
   *
   *     Mapper map = new Mapper(Canvas c, ...);
   *     map.drawSelf();  // < draws map to canvas c
   */
  void drawSelf() {
    CanvasRenderingContext2D context = canvas.context2D;

    for(int i=0;i<tiles.length;i++) {
      int x = i % width;
      int y = i ~/ width;

      Tile tile = tiles[i];
      Point drawAt = new Point(x*renderWidth, y*renderHeight);
      tile.drawSelf(context, tileset, drawAt.x, drawAt.y,
                    tileset.tileWidth, tileset.tileHeight,
                    renderWidth, renderHeight);
    }
  }

  /**
   * Draws a portion of the map to its canvas
   *
   *     // make a new 24x24 map
   *     Mapper map = new Mapper(Canvas c, ...);
   *
   *     // draw the 16x12 tiles in the top left corner
   *     // to the canvas
   *     map.drawWindow(0, 0, 16, 12); // < 16x12 from tile (0, 0)
   *
   */
  void drawWindow(int startX, int startY, int _width, int _height) {

    CanvasRenderingContext2D context = canvas.context2D;

    for(int i=startY;i<_height+startY;i++) {
      for(int j=startX;j<_width+startX;j++) {
        Tile tile = getTileXY(j, i);

        int x = j - startX;
        int y = i - startY;

        Point drawAt = new Point(x*renderWidth, y*renderWidth);
        tile.drawSelf(context, tileset, drawAt.x, drawAt.y,
            tileset.tileWidth, tileset.tileHeight,
            renderWidth, renderHeight);
      }
    }
  }

  /**
   * Draws a portion of the map with double values for the
   * starting coordinates
   *
   * Useful for animating transitions
   */
  void drawWindowContinuous(num startX, num startY, int _width, int _height) {

    CanvasRenderingContext2D context = canvas.context2D;

    for(int i=startY~/1;i<(_height+(startY~/1)+1);i++) {
      for(int j=startX~/1;j<(_width+(startX~/1)+1);j++) {
        Tile tile = getTileXY(j, i);

        // skip rendering empty tiles
        if(tile == null) continue;

        int xPixels = ((j.toDouble() - startX) * renderWidth) ~/ 1;
        int yPixels = ((i.toDouble() - startY) * renderHeight) ~/ 1;

        Point drawAt = new Point(xPixels, yPixels);
        tile.drawSelf(context, tileset, drawAt.x, drawAt.y,
                      tileset.tileWidth, tileset.tileHeight,
                      renderWidth, renderHeight);
      }
    }
  }

  /**
   * Same as drawWindowContinuous, but doesn't render excess tile
   */
  void drawWindowContinuousTrim(num startX, num startY, int _width, int _height) {
    CanvasRenderingContext2D context = canvas.context2D;

    for(int i=startY~/1;i<(_height+(startY~/1)+1);i++) {
      int innerTileHeight;
      int innerRenderHeight;
      if(i == _height+(startY~/1)) {
        num diff = (startY-(startY~/1).toDouble());

        innerTileHeight = (diff * tileset.tileHeight).toInt();
        innerRenderHeight = (diff * tileset.tileWidth).toInt();
      } else {
        innerTileHeight = tileset.tileHeight;
        innerRenderHeight = renderHeight;
      }
      for(int j=startX~/1;j<(_width+(startX~/1)+1);j++) {
        Tile tile = getTileXY(j, i);

        int xPixels = ((j.toDouble() - startX) * renderWidth) ~/ 1;
        int yPixels = ((i.toDouble() - startY) * renderHeight) ~/ 1;

        // trim last column
        int innerTileWidth;
        int innerRenderWidth;
        if(j == _width+(startX~/1)) {
          num diff = (startX-(startX~/1).toDouble());

          innerTileWidth = (diff * tileset.tileWidth).toInt();
          innerRenderWidth = (diff * renderWidth).toInt();
        } else {
          innerTileWidth = tileset.tileWidth;
          innerRenderWidth = renderWidth;
        }

        Point drawAt = new Point(xPixels, yPixels);
        tile.drawSelf(context, tileset, drawAt.x, drawAt.y,
                      innerTileWidth, innerTileHeight,
                      innerRenderWidth, innerRenderHeight);
      }
    }
  }

  /**
   * Returns a Point that contains the pixel location of
   * a tile coordinate. For example,
   *
   *     map.getPixelsFromTiles(1, 1);
   *
   * would return (32, 32) for a map whose tiles were
   * currently being rendered at 32 by 32 pixels.
   */
  Point getPixelsFromTile(num x, num y) {
    return new Point(x * renderWidth, y * renderHeight);
  }

  /**
   * Returns a Point that contains the tile location of
   * a pixel coordinate. For example,
   *
   *     map.getPixelsFromTiles(32, 32);
   *
   * would return (1, 1) for a map whose tiles were
   * currently being rendered at 32 by 32 pixels.
   */
  Point getTileFromPixels(int x, int y) {
    return new Point(x~/renderWidth, y~/renderHeight);
  }

  /**
   * Steps each tile on the map's current frame forward
   *
   *     Mapper map = new Mapper(...);
   *     map.incrementFrames();
   */
  void incrementFrames() {
    for(Tile tile in tiles) {
      tile.incrementFrame();
    }
  }

  Tile getTileXY(int x, int y) {
    if(x < 0 || y < 0) return null;
    if(x >= width || y >= height) return null;
    try{
      return tiles[y*width+x];
    } on RangeError {
      return null;
    }
  }

  Tile getTile(Point p) {
    return getTileXY(p.x, p.y);
  }

  bool canMoveTo(Point p) {
    return (p.x >= 0 && p.y >=0) && (p.x < width && p.y < height);
  }

  void drawRange(Iterable<Point> points) {
    var context = rangeCanvas.context2D;
    points.forEach((p) {
      Point pixelPoint = getPixelsFromTile(p.x, p.y);
      context.rect(
          pixelPoint.x + tileGutter, pixelPoint.y + tileGutter,
          renderWidth - (2 * tileGutter),
          renderHeight - (2 * tileGutter)
      );
    });
    context.setFillColorRgb(0, 0, 255, 0.4);
    context.fill();
  }

  void clearRange() {
    rangeCanvas.context2D
      .clearRect(0, 0, rangeCanvas.width, rangeCanvas.height);
  }

  TilePath getPathToTile(Point start, Point end, {int filter}) {
    // TODO yeah
    return new TilePath(this,
        [
          new Point(start.x, end.y),
          new Point(end.x, end.y)
         ]);
  }
}