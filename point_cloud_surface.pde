ArrayList <PVector> points = new ArrayList <PVector>();
PVector current = new PVector();

//PVector average = new PVector();

final float SURFACE_CONCAVITY = 0.15;
final float BLOB_MIN_SEPARATION = 100.0;
void setup() {
  size(1600, 1000, P2D);
  add_random_points(-500 + width/2, height/2, 300);
  add_random_points(300+ width/2, height/2, 300);
}

void draw() {
  background(0xcc);
  if (keyPressed && key == ' ') {
    points.clear();
    add_random_points(width/2, height/2, 300);
  }
  points.get(0).set(mouseX, mouseY);

  colorMode(HSB);
  randomSeed(1729);
  for (ArrayList<PVector> blob : separate_blobs(points)) {
    ArrayList<PVector> surface = generate_surface(blob);
    fill(random(0, 255), 255, 255);
    for (PVector b : blob) {
      stroke(0);
      circle(b.x, b.y, 16);
    }
    
    noFill();
    stroke(0);
    beginShape();
    for (PVector p : surface) {
      curveVertex(p.x, p.y);
    }
    if (surface.size() >= 3) {
      curveVertex(surface.get(0).x, surface.get(0).y);
      curveVertex(surface.get(1).x, surface.get(1).y);
      curveVertex(surface.get(2).x, surface.get(2).y);
    }
    endShape();
  }
  colorMode(RGB);

  stroke(0);
  //for (PVector pv : points) {
  //  fill(255);
  //  circle(pv.x, pv.y, 4);
  //}
  //stroke(#FF0000);
  //circle(average.x, average.y, 10);
}

void mousePressed() {
  if (mouseButton == LEFT) {
    points.add(points.get(0).copy());
  } else if (mouseButton == RIGHT) {
    add_random_points(mouseX, mouseY, 100);
  }
}

void add_random_points(float posX, float posY, float size) {
  for (int i = 0; i < sq(size)/1000; i++) {
    points.add(PVector.random2D().mult(sqrt(random(sq(size)))).add(posX, posY));
  }
}

ArrayList<PVector> find_blob(ArrayList <PVector> remains) {
  if (remains.isEmpty()) {
    return null;
  }
  //ArrayList <PVector> remains = new ArrayList <PVector>();
  //remains.addAll(points);
  ArrayList<PVector> blob = new ArrayList <PVector>();
  PVector next = remains.get(0);
  float min_dist;
  do {
    blob.add(next);
    remains.remove(next);
    min_dist = Float.MAX_VALUE;
    for (PVector r : remains) {
      for (PVector b : blob) {
        float dist = r.dist(b);
        if (dist < min_dist) {
          min_dist = dist;
          next = r;
        }
      }
    }
  } while (remains.size() > 0 && min_dist < BLOB_MIN_SEPARATION);
  return blob;
}

ArrayList<ArrayList<PVector>> separate_blobs(ArrayList<PVector> all_points) {
  ArrayList <PVector> remains = (ArrayList<PVector>)all_points.clone();

  ArrayList<ArrayList<PVector>> blobs = new ArrayList<ArrayList<PVector>>();
  while (!remains.isEmpty()) {
    blobs.add(find_blob(remains));
  }
  return blobs;
}

ArrayList<PVector> generate_surface(ArrayList<PVector> blob_points) {

  PVector average = new PVector();
  for (PVector p : blob_points) {
    average.add(p);
  }
  average.div(blob_points.size());

  fill(0);
  circle(average.x, average.y, 4);

  current = blob_points.get(0);
  for (PVector pv : blob_points) {
    if (PVector.dist(average, pv) > PVector.dist(average, current)) {
      current = pv;
    }
  }
  fill(#00FF00);
  circle(current.x, current.y, 10);
  ArrayList <PVector> remains = new ArrayList <PVector>();
  remains.addAll(blob_points);
  // remains.remove(current);
  PVector start = current.copy();
  
  ArrayList <PVector> surface = new ArrayList<PVector>();
  do {
    surface.add(current);
    PVector normal = PVector.sub(current, average).normalize();
    float maxDot = -1;
    int maxDotIndex = 0;
    for (int i = 0; i < remains.size(); i++) {
      PVector diff = PVector.sub(remains.get(i), current);
      float delta = diff.mag();
      diff.normalize();
      if (PVector.dot(new PVector(-normal.y, normal.x), diff) > 0) {
        float dot = (PVector.dot(normal, diff)+1)/pow(delta, SURFACE_CONCAVITY);
        if (dot > maxDot) {
          maxDot = dot;
          maxDotIndex = i;
        }
      }
    }
    PVector next = remains.get(maxDotIndex);
    stroke(0);
    //line(current.x, current.y, next.x, next.y);
    current = next;
    remains.remove(current);
  } while (!remains.isEmpty() && !current.equals(start));
  
  return surface;
}
