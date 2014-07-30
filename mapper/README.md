mapper
======

A simple Dart library for drawing tile maps to an HTML5 canvas

How to use:

```javascript

ImageElement img = new ImageElement( ... );

img.onLoad.listen( (Event e) {
  // tilesetWidth and tilesetHeight are width and height 
  // of the tileset image in tiles
  Tileset tileset = new Tileset(img, tilesetWidth, tilesetHeight);
  
  // Build an array of the tile positions in the tileset. The first tile,
  // for example, is tile 0. The first tile on row x of tiles is
  // tile [tilesetWidth * x].
  
  List<int> tileList = [0,0,0,
                        0,1,0,
                        0,0,0];

  // mapWidth and mapHeight are width and height 
  // of the map image in tiles
  // renderWidth and renderHeight are the width and height
  // to draw each tile at in pixels
  Mapper map = new Mapper(canvas, tileset, tileList,
                          mapWidth, mapHeight, renderWidth, renderHeight);
  map.drawSelf();
});

querySelector("body").children.add(img);
```

Other methods and sample code can be found in `mapper_test.dart`
