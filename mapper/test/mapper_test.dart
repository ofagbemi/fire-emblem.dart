library tile_mapper_test;

import 'package:mapper/mapper.dart';
import 'package:unittest/unittest.dart';

import 'dart:math';
import 'dart:html';
import 'dart:async';

void tileTests() {
  Random rng;
  Point p;
  Map properties;
  int numFrames;
  List<Point> frames;
  
  setUp(() {
    rng = new Random();
    
    numFrames = 8;
    
    frames = new List<Point>.generate(numFrames,
      (index) {
        return new Point(index, index * 2);
    });
    
    properties = {
      'movement': -1,
      'evade': 20
    };
  });
  
  test("tile basic constructor", () {
    Tile t = new Tile(frames);
    for(int i=0;i<frames.length;i++) {
      expect(t.frames[i], equals(frames[i]));
    }
  });
  
  test("tile properties constructor", () {
    Tile t = new Tile(frames, properties: properties);
    expect(t.properties['movement'], equals(properties['movement']));
  });
  
  test("tile incrementFrame", () {
    Tile t = new Tile(frames);
    for(int i=0;i<frames.length*2;i++) {
      expect(t.imgPos, frames[i%frames.length]);
      t.incrementFrame();
    }
  });
}

void tilesetTests() {
  Random rng;
  Point p;
  int tileWidth;
  int tileHeight;
  int width;
  int height;
  ImageElement img;
  String imgUrl;
  setUp(() {
    rng = new Random();
    tileWidth = 32;
    tileHeight = 32;
    width = 10;
    height = 8;
    imgUrl = "hi.jpg";
    
    img = new ImageElement(src:imgUrl, width:tileWidth*width,
                           height:tileHeight*height);
  });
  
  test("tileset constructor", () {
    Tileset tileset = new Tileset(img, width, height);
    expect(tileset.img, equals(img));
    expect(tileset.tileWidth, equals(tileWidth));
    expect(tileset.tileHeight, equals(tileHeight));
    
    expect(tileset.width, equals(width));
    expect(tileset.height, equals(height));
    
    expect(tileset.tiles[width-1].imgPos,
           equals(new Point((width-1)*tileWidth, 0)));
    expect(tileset.tiles[width].imgPos,
           equals(new Point(0, 1*tileWidth)));
  });
}

void mapperTests() {
  Random rng;
  Point p;
  int tilesetWidth;
  int tilesetHeight;
  int width;
  int height;
  int windowWidth;
  int windowHeight;
  int windowStartX;
  int windowStartY;
  num windowStartXCont;
  num windowStartYCont;
  int tileSize;
  ImageElement img;
  String imgUrl;
  Tileset tileset;
  List<int> tileIndices;
  CanvasElement canvas;
  Element body;
  setUp(() {
    body = querySelector('body');
    rng = new Random();
    tilesetWidth = 32;
    tilesetHeight = 32;
    imgUrl = "castle_blue.png";
    
    img = new ImageElement(src:imgUrl);
    
    width = 6;
    height = 5;
    
    windowStartX = 1;
    windowStartY = 2;
    windowStartXCont = 1.5;
    windowStartYCont = 2.5;
    windowWidth = 3;
    windowHeight = 2;
    
    tileSize = 16;
    
    tileIndices = [ 65, 65, 66, 67, 66, 66,
                    65, 65, 66, 67, 66, 66,
                    184, 97, 32, 32, 99, 99,
                    97, 129,130,131,132, 132,
                    97, 97, 97, 96, 97, 97];
    
    canvas = new CanvasElement(width: width*tileSize,
                               height: height*tileSize);
    
    tileset = new Tileset(img, tilesetWidth, tilesetHeight);
  });
  
  test("mapper constructor", () {
    Mapper map = new Mapper(canvas, tileset, tileIndices, width, height);
    expect(map.renderWidth, equals(canvas.width/width));
    expect(map.renderHeight, equals(canvas.height/height));
  });
  
  test("mapper drawSelf", () {
    ImageElement innerImg = new ImageElement(src:imgUrl);
    CanvasElement innerCanvas = new CanvasElement(width: width*tileSize,
                                                  height: height*tileSize);
    img.onLoad.listen((Event e) {
      
      HeadingElement header = new HeadingElement.h1();
      header.text = "mapper drawSelf";
      body.children.add(header);
      
      body.children.add(innerCanvas);
      
      tileset = new Tileset(innerImg, tilesetWidth, tilesetHeight);
      Mapper map = new Mapper(innerCanvas, tileset, tileIndices, width, height, tileSize, tileSize);
      map.drawSelf();
    });
    body.children.add(innerImg);
  });
  
  test("mapper drawWindow", () {
    ImageElement innerImg = new ImageElement(src:imgUrl);
    CanvasElement innerCanvas = new CanvasElement(width: width*tileSize,
                                                  height: height*tileSize);
    innerImg.onLoad.listen((Event e) {
      
      HeadingElement header = new HeadingElement.h1();
      header.text = "mapper drawWindow";
      body.children.add(header);
      
      body.children.add(innerCanvas);
      
      tileset = new Tileset(innerImg, tilesetWidth, tilesetHeight);
      Mapper map = new Mapper(innerCanvas, tileset, tileIndices, width, height, tileSize, tileSize);
      map.drawWindow(windowStartX, windowStartY, windowWidth, windowHeight);
    });
    
    body.children.add(innerImg);
  });
  
  test("mapper drawWindowContinuous", () {
    ImageElement innerImg = new ImageElement(src:imgUrl);
    CanvasElement innerCanvas = new CanvasElement(width: width*tileSize,
                                                  height: height*tileSize);
    innerImg.onLoad.listen((Event e) {
      
      HeadingElement header = new HeadingElement.h1();
      header.text = "mapper drawWindowContinuous";
      body.children.add(header);
      
      body.children.add(innerCanvas);
      
      tileset = new Tileset(innerImg, tilesetWidth, tilesetHeight);
      Mapper map = new Mapper(innerCanvas, tileset, tileIndices, width, height, tileSize, tileSize);
      map.drawWindowContinuous(windowStartXCont, windowStartYCont, windowWidth, windowHeight);
    });
    
    body.children.add(innerImg);
  });
  
  test("mapper drawWindowContinuousTrim", () {
    ImageElement innerImg = new ImageElement(src:imgUrl);
    CanvasElement innerCanvas = new CanvasElement(width: width*tileSize,
                                                  height: height*tileSize);
    innerImg.onLoad.listen((Event e) {
      
      HeadingElement header = new HeadingElement.h1();
      header.text = "mapper drawWindowContinuousTrim";
      body.children.add(header);
      
      body.children.add(innerCanvas);
      
      tileset = new Tileset(innerImg, tilesetWidth, tilesetHeight);
      Mapper map = new Mapper(innerCanvas, tileset, tileIndices, width, height, tileSize, tileSize);
      map.drawWindowContinuousTrim(windowStartXCont, windowStartYCont, windowWidth, windowHeight);
    });
    
    body.children.add(innerImg);
  });
  
  test("mapper drawWindowContinuous animation", () {
    ImageElement innerImg = new ImageElement(src:imgUrl);
    CanvasElement innerCanvas = new CanvasElement(width: width*tileSize,
                                                  height: height*tileSize);
    innerImg.onLoad.listen((Event e) {
      
      HeadingElement header = new HeadingElement.h1();
      header.text = "mapper drawWindowContinuous animation";
      body.children.add(header);
      
      body.children.add(innerCanvas);
      
      tileset = new Tileset(innerImg, tilesetWidth, tilesetHeight);
      Mapper map = new Mapper(innerCanvas, tileset, tileIndices, width, height, tileSize, tileSize);
      
      int frame = 0;
      void anim(Timer t) {
        num start = (frame % 30).toDouble()/10;
        map.drawWindowContinuousTrim(start, start, windowWidth, windowHeight);
        header.text = "($start, $start)";
        frame++;
      }
      
      Timer timer = new Timer.periodic(new Duration(milliseconds: (1000/60)~/1), anim);
    });
    
    body.children.add(innerImg);
  });
}

main() {
  tileTests();
  tilesetTests();
  mapperTests();
}