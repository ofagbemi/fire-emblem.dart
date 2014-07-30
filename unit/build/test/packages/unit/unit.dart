library unit;

import 'dart:html';

class AnimationData {
  static final OVERWORLD_IDLE = [{40:0}, {42:1}, {82:2}, {84:1}];
  static final OVERWORLD_LEFT = [{10:0}, {20:1}, {30:2}, {40:3}];
  static final OVERWORLD_RIGHT = OVERWORLD_LEFT;
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
  Sprite(this.img, this.imgFrames, this.animationData) {
    frame = 0;
    animationLength = animationData[animationData.length-1].keys.first;
  }
  
  void drawSelf(CanvasRenderingContext2D context, int x, int y,
                int renderWidth, int renderHeight) {
    Frame f = imgFrames[frame];
    context.drawImageScaledFromSource(
                img, f.x, f.y, f.width, f.height,
                x, y, renderWidth, renderHeight
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

class Unit {
  Map<dynamic, num> stats;
  Map<dynamic, Sprite> sprites;
  
  Sprite currentSprite;
  
  
  
  Unit({this.stats, this.sprites});
  
  void setSprite(dynamic sprite) {
    currentSprite = sprites[sprite];
  }
}


