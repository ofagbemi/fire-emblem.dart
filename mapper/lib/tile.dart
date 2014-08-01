part of mapper;

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