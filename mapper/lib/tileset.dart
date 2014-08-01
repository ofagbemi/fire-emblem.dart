part of mapper;

class Tileset {
  ImageElement img;

  /// width, in blocks, of the tileset [avoid]
  int width;

  /// height, in blocks, of the tileset [avoid]
  int height;

  /// width, in pixels, of this tileset's tiles
  int tileWidth;

  /// height, in pixels, of this tileset's tiles
  int tileHeight;

  List<Tile> tiles;

  Tileset(ImageElement _img, int _width, int _height) {
    img = _img; width = _width; height = _height;

    tileWidth = img.width ~/ _width;
    tileHeight = img.height ~/height;

    tiles = _generateTiles(img, tileWidth, tileHeight,
                          width, height);
  }


  /**
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