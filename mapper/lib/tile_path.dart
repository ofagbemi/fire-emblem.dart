part of mapper;

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
    }
      return null;
  }

  Point peek() {
    if(points.isNotEmpty) {
      return new Point(points.first.x, points.first.y);
    }
    return null;
  }

  Point last() {
    if(points.isNotEmpty) {
      return new Point(points.last.x, points.last.y);
    }
    return null;
  }

  void add(Point p) {
    points.add(new Point(p.x * map.renderWidth, p.y * map.renderHeight));
  }
}