library tile_mapper_test;

import 'package:unit/unit.dart';
import 'package:unittest/unittest.dart';

import 'dart:math';
import 'dart:html';
import 'dart:async';

main() {
  String imgUrl = "images/idle.png";
  BodyElement body = querySelector('body');
  
  ImageElement innerImg = new ImageElement(src:imgUrl);
  CanvasElement innerCanvas = new CanvasElement(width: 400, height: 300);
  innerImg.onLoad.listen((Event e) {
    HeadingElement header = new HeadingElement.h1();
    header.text = "Nothing";
    body.children.add(header);
    
    body.children.add(innerCanvas);
    
    Map<dynamic, num> stats;
    Map<dynamic, Sprite> sprites = new Map<dynamic, Sprite>();
    
    List<Frame> idleFrames = new List<Frame>.generate(3, (i) {
      return new Frame(i*64, 0, 64, 128);
    });
    
    sprites["overworld"] = new Sprite(innerImg, idleFrames, AnimationData.OVERWORLD_IDLE);
    
    Unit lyn = new Unit(stats: stats, sprites: sprites);
    
    int frame = 0;
    innerCanvas.context2D.fillStyle = "white";
    void anim(Timer t) {
      innerCanvas.context2D.fillRect(0, 0, innerCanvas.width, innerCanvas.height);
      lyn.sprites["overworld"].setAnimationFrame(frame);
      lyn.sprites["overworld"].drawSelf(innerCanvas.context2D,
                                        0, 0, 32, 64);
      frame++;
    }
    
    Timer timer = new Timer.periodic(new Duration(milliseconds: (1000/60)~/1), anim);
  });

  body.children.add(innerImg);
}