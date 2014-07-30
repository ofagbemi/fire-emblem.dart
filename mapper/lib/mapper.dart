library tile_mapper;

import 'dart:html';
import 'dart:math';
import 'dart:collection';

class Tile {
  Point imgPos;
  Map properties;
  
  // list of positions to find the tiles
  // that make up the frames of the animation
  List<Point> frames;
  
  int frame;
  
  Tile(this.frames, {this.properties}) {
    if(properties == null) {
      properties = {};
    }
    frame = 0;
    imgPos = frames[frame];
    
    if(properties['move'] == null) {
      properties['move'] = 1;
    }
  }
  
  void drawSelf(CanvasRenderingContext2D context, Tileset tileset,
                int x, int y, int width, int height,
                int drawWidth, int drawHeight) {
    
    context.drawImageScaledFromSource(
            tileset.img, imgPos.x, imgPos.y, width, height,
            x, y, drawWidth, drawHeight
        );
  }
  
  void incrementFrame() {
    frame = (frame + 1) % frames.length;
    imgPos = frames[frame];
  }
  
  void setFrame(int _frame) {
    frame = _frame % frames.length;
  }
}

class TilePath {
  Mapper map;
  Queue<Point> points;
  
  TilePath(this.map, Iterable<Point> tiles) {
    points = new Queue<Point>();
    tiles.forEach((t) {
      points.add(new Point(t.x * map.renderWidth, t.y * map.renderHeight));
    });
  }
  
  Point next() {
    if(points.isNotEmpty) {
      return points.removeFirst();
    } else {
      return null;
    }
  }
  
  Point peek() {
    if(points.isNotEmpty) {
      return new Point(points.first.x, points.first.y);
    } else {
      return null;
    }
  }
  
  void add(Point p) {
    points.add(new Point(p.x * map.renderWidth, p.y * map.renderHeight));
  }
}

class Tileset {
  ImageElement img;
  
  // width, in blocks, of the tileset [avoid]
  int width;
  
  // height, in blocks, of the tileset [avoid]
  int height;
  
  // width, in pixels, of this tileset's tiles
  int tileWidth;
  
  // height, in pixels, of this tileset's tiles
  int tileHeight;
  
  List<Tile> tiles;
  
  Tileset(ImageElement _img, int _width, int _height) {
    img = _img; width = _width; height = _height;
    
    tileWidth = img.width ~/ _width;
    tileHeight = img.height ~/height;
    
    tiles = _generateTiles(img, tileWidth, tileHeight,
                          width, height);
  }
  
  
  /*
   * Returns a list of tiles constructed from the passed in parameters.
   * 
   *     List<Tile> tiles = generateTiles(img, tileWidth, tileHeight);
   */
  static List<Tile> _generateTiles(ImageElement _img, int _tileWidth,
      int _tileHeight, int _width, int _height) {
    
    List<Tile> ret = new List<Tile>.generate(_width*_height,
      (index) {
        int x = index % _width;
        int y = index ~/ _width;
        return new Tile([new Point(x*_tileWidth, y*_tileWidth)]);
    });
    
    return ret;
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
}

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
          return tileset.tiles[_indices[index]];
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
  
  TilePath getPathToTile(Point start, Point end, {int filter}) {
    // TODO yeah
    return new TilePath(this,
        [
          new Point(start.x, end.y),
          new Point(end.x, end.y)
         ]);
  }
}