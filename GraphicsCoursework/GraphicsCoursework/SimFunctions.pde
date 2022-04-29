
///////////////////////////////////////////////////////////////////////////////////////////
//  maths functions, and short-hands, generally used

// shorthand to get a PVector
PVector vec(float x, float y, float z) {
  return new PVector(x, y, z);
}

static float sqr(float a) {
  return a*a;
}

boolean isBetweenInc(float v, float lo, float hi) {

  float sortedLo = min(lo, hi);
  float sortedHi = max(lo, hi);

  if (v >= sortedLo && v <= sortedHi) return true;
  return false;
}

boolean nearZero(float v) {

  if ( abs(v) <= EPSILON ) return true;
  return false;
}



void setCamera(PVector pos, PVector lookat) {
  camera(pos.x, pos.y, pos.z, lookat.x, lookat.y, lookat.z, 0, 1, 0);
}

void drawMajorAxis(PVector p, float len) { 

  PVector topOfLine = new PVector(p.x, p.y+len, p.z);
  PVector intoScene = new PVector(p.x, p.y, p.z+len);
  PVector sideways  = new PVector(p.x+len, p.y, p.z);

  hint(DISABLE_DEPTH_TEST);
  // line x (red)
  stroke(255, 0, 0);
  line(p.x, p.y, p.z, sideways.x, sideways.y, sideways.z);

  // line y (green)
  stroke(0, 255, 0);
  line(p.x, p.y, p.z, topOfLine.x, topOfLine.y, topOfLine.z);

  // line z (blue)
  stroke(0, 0, 255);
  line(p.x, p.y, p.z, intoScene.x, intoScene.y, intoScene.z);
  hint(ENABLE_DEPTH_TEST);
}



/////////////////////////////////////////////////////////////////
// SphereGraphic class
// Just draws a sphere from scratch so we don't have to use
// processings Sphere, with it's inherent problems of updating draw style.
class SimSphereGraphic {
  SimSphere parent;
  PVector[][] globe;
  int levelOfDetail = 10;

  public SimSphereGraphic(SimSphere owningObject, int lod) {
    parent = owningObject;
    levelOfDetail = lod;

    globe = new PVector[levelOfDetail+1][levelOfDetail+1];

    float r = 1;
    for (int i = 0; i < levelOfDetail+1; i++) {
      float lat = map(i, 0, levelOfDetail, 0, PI);
      for (int j = 0; j < levelOfDetail+1; j++) {
        float lon = map(j, 0, levelOfDetail, 0, TWO_PI);

        float x = r * sin(lat) * cos(lon);
        float y = r * cos(lat);
        float z = r * sin(lat) * sin(lon);

        globe[i][j] = new PVector(x, y, z);
      }
    }
  }


  void drawMe() {


    float sw =  g.strokeWeight ;

    strokeWeight(sw / parent.radius );
    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < levelOfDetail; i++) {
      //beginShape(TRIANGLE_STRIP);
      for (int j = 0; j < levelOfDetail+1; j++) {
        PVector v1 = globe[i][j];
        vertex(v1.x, v1.y, v1.z);
        PVector v2 = globe[i+1][j];
        vertex(v2.x, v2.y, v2.z);
      }
      //endShape();
    }
    endShape();
    strokeWeight(sw);
  }// end drawMe()
}



/////////////////////////////////////////////////////////////////
// simple rectangle class for SimFunctions
//

class SimRect {

  float left, top, right, bottom;

  public SimRect(float x1, float y1, float x2, float y2) {
    setRect(x1, y1, x2, y2);
  }

  void setRect(float x1, float y1, float x2, float y2) {
    this.left = x1;
    this.top = y1;
    this.right = x2;
    this.bottom = y2;
  }

  PVector getCentre() {
    float cx =  (this.right - this.left)/2.0;
    float cy =  (this.bottom - this.top)/2.0;
    return new PVector(cx, cy);
  }
  boolean isPointInside(PVector p) {
    // inclusive of the boundries
    if (   isBetweenInc(p.x, this.left, this.right) && isBetweenInc(p.y, this.top, this.bottom) ) return true;
    return false;
  }

  float getWidth() {
    return (this.right - this.left);
  }

  float getHeight() {
    return (this.bottom - this.top);
  }
}
