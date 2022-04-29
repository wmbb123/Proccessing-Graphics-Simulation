

///////////////////////////////////////////////////////////////////////////////////////
// SimShapes V Alpha 1.4 7 Feb 2020 by Simon Schofield
//
// SimShapes is a set of 3D shapes you can make, transform around 3D space, 
// and ... CRITICALLY... get their transformed geometry (locations/extents/ bounding sphere etc.)
// This is necessary for running physisc simulations.
//
// IN this version you can load an .obj file and transform it and get it's location etc.

///////////////////////////////////////////////////////////////////////////////////////
// SimObjectManager
// This is a sort of "database" for you to add SimObjects to. Once added
// You can get them from the manager via their "id" tag - a string (make sure its unique) 
// You can iterate through them usng a simple index number
// Other uses...
// Ray Intersection calculations - all objects can be intersected by a SimRay and return intersection points etc.
// Inter-object collision - The manager will determine all inter-object collitions and report them back (not finishe yet)
// Drawing them, all at once, or individually
// 

class SimObjectManager{
  ArrayList<SimTransform> simObjList = new ArrayList<SimTransform>();
  
  
  void addSimObject(SimTransform obj, String id){
    obj.setID(id);
    simObjList.add(obj);
  }
  
  SimTransform getSimObject(String id){
    for(SimTransform thisObj: simObjList){
      if( thisObj.idMatches(id) ) return thisObj;
    }
    // if it can't find a match then ...
    return null;
  }
  
  int getNumSimObjects(){
    return simObjList.size();
  }
  
  SimTransform getSimObject(int n){
    return simObjList.get(n);
  }
  
  
  void drawAll(){
    for(SimTransform obj: simObjList){
      obj.drawMe();
    }
  }
  
  
  
  
  
}






abstract class SimTransform{
  // this part of the class contains id information about this shape
  // and also stores the id of shapes which are colliding with this shape
  String id;
  String colliderID;

  void setID(String i) {
    id = i;
  }

  String getID() {
    return id;
  }

  String getColliderID() {
    return colliderID;
  }
  
  void setColliderID(String n){
    colliderID = n;
  }

  void swapColliderIDs(SimTransform otherthing) {
    this.colliderID = otherthing.getID();
    otherthing.setColliderID(this.id);
  }
  
  boolean idMatches(String s){
    if( id.equals(s)) return true;
    return false;
  }
  
  boolean isClass(Object o, String s){
    return (getClassName(o).equals(s));
  }
  
  String getClassName(Object o){
    return o.getClass().getSimpleName();
  }
  
  // abstract methods your sub class has to implement
  abstract boolean collidesWith(SimTransform c);
  
  abstract boolean calcRayIntersection(SimRay sr);
  
  abstract void drawMe();
  
  ///////////////////////////////////////////////////////////////////////
  // this part of the class is the main sim transform stuff to 
  // do with vertices and geometry transforms
  
  
  // all objects have one
  PVector origin = new PVector(0, 0, 0);

  float scale = 1;
  PVector translate = new PVector(0, 0, 0);
  float rotateX, rotateY, rotateZ = 0.0;


  void setTransformAbs(float scale, float rotateX, float rotateY, float rotateZ, PVector translate) {
    this.scale = scale;
    if (translate!=null) this.translate = translate.copy();
    this.rotateX = rotateX;
    this.rotateY = rotateY;
    this.rotateZ = rotateZ;
    //printCurrentTransform();
  }

  void setTransformRel( float scale, float rotateX, float rotateY, float rotateZ, PVector translate) {
    this.scale *= scale;
    if (translate!=null) this.translate.add(translate);
    this.rotateX += rotateX;
    this.rotateY += rotateY;
    this.rotateZ += rotateZ;
  }

  void setIdentityTransform() {
    setTransformAbs( 1, 0, 0, 0, vec(0, 0, 0));
  }

  void printCurrentTransform() {

    println("Current transform:  Scale ", scale, " Rotxyz ", rotateX, rotateY, rotateZ, " Translate ", translate.x, translate.y, translate.z);
  }

  // given a cardinal shape vertex p, transform the point
  // scale
  // rotate
  // translate
  // This uses basic triganometry, could be sped up using matrices
  public PVector transform(PVector pIn) {
    // because we definately don't want to affect the vector coming in!
    PVector p = pIn.copy();

    // first scale the point
    PVector scaled = p.mult(this.scale);

    float x = scaled.x;
    float y = scaled.y;
    float z = scaled.z;

    // rotate round X axis
    float y1 = y*cos( rotateX ) - z*sin( rotateX );
    float z1 = y*sin( rotateX ) + z*cos( rotateX );
    float x1 = x;
    // rotate round Y axis
    float z2 = z1*cos( rotateY ) - x1*sin( rotateY );
    float x2 = z1*sin( rotateY ) + x1*cos( rotateY );
    float y2 = y1;
    // rotate round Z axis
    float x3 = x2*cos( rotateZ ) - y2*sin( rotateZ );
    float y3 = x2*sin( rotateZ ) + y2*cos( rotateZ );
    float z3 = z2;

    PVector rotated = new PVector(x3, y3, z3);

    PVector translated = rotated.add(translate);
    return translated;
  }

  // useful shorthand for subclasses to return either the cadinal or transformed values
  //public PVector transform(PVector vectorIn, boolean applyTransform){
  //  if(applyTransform) return transform(vectorIn);
  //  return vectorIn.copy();
  //  
  //}

  // useful shorthand function that draws a transformed vertices
  public void  drawTransformedVertex(PVector v) {
    PVector transformedVector = transform(v);
    vertex(transformedVector.x, transformedVector.y, transformedVector.z);
  }

  PVector getOrigin() {
    return transform(this.origin);
  }

  // useful for things which can be Axis Aligned, or not
  boolean isRotated() {
    if ( isQuarterTurn(this.rotateX)  && isQuarterTurn(this.rotateY) && isQuarterTurn(this.rotateZ)) return false;
    return true;
  }
  
  boolean isQuarterTurn(float a){
    // return true is the value of a is (very close to) 0, 90 degrees, 
    int degs = (int) (degrees(a) + 0.5f);
    
    if(degs == 0 || degs == 90 || degs == 180 || degs == 270 || degs == 360) return true;
    return false;
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////
  // useful function for all shapes made from a list of vertices
  // returns the extents in the array, in order...
  // the lower extent of the bounding box, 
  // the upper extent of the bounding, 
  // the centre point (of the above)
  // the furthest vertices from the centre point
  PVector[] getExents_DoNotApplyTransform(PVector[] vertices){

    PVector[] extents = new PVector[4];
    float minx = Float.MAX_VALUE;
    float miny = Float.MAX_VALUE;
    float minz = Float.MAX_VALUE;

    float maxx = -Float.MAX_VALUE;
    float maxy = -Float.MAX_VALUE;
    float maxz = -Float.MAX_VALUE;
    for (PVector p : vertices) {
      if (p.x < minx) minx = p.x;
      if (p.y < miny) miny = p.y;
      if (p.z < minz) minz = p.z;
      if (p.x > maxx) maxx = p.x;
      if (p.y > maxy) maxy = p.y;
      if (p.z > maxz) maxz = p.z;
    }
    PVector minExtents = new PVector(minx, miny, minz);
    PVector maxExtents = new PVector(maxx, maxy, maxz);

    PVector centrePoint = midPoint(minExtents, maxExtents);
    // need to work out point furthest from the centre point
    PVector furthest = centrePoint.copy();
    for (PVector p : vertices) {
      if (centrePoint.dist(p) > centrePoint.dist(furthest)) {
        furthest = p.copy();
      }
    }

    extents[0] = minExtents;
    extents[1] = maxExtents;
    extents[2] = centrePoint;
    extents[3] = furthest;
    return extents;
    
  }
  
  PVector[] getExtents(PVector[] vertices) {
    vertices = getTransformedVertices(vertices);
    return getExents_DoNotApplyTransform(vertices);
  }


  PVector[] getTransformedVertices(PVector[] vertices) {
    int numVerts = vertices.length;
    PVector[] transformedVerts = new PVector[numVerts];
    for (int n = 0; n < numVerts; n++) {
      transformedVerts[n] = transform(vertices[n]);
    }
    return transformedVerts;
  }

  PVector midPoint(PVector p1, PVector p2) {
    PVector copyP1 = p1.copy();
    return copyP1.lerp(p2, 0.5);
  }
}




//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// SimSphere
//

class SimSphere extends SimTransform{

  private float radius = 1;

  public int levelOfDetail = 10;
  SimSphereGraphic drawSphere; 
  
  public SimSphere() {
    init( vec(0,0,0),  1);
  }

  public SimSphere(float rad) {

    init( vec(0,0,0),  rad);
  }

  public SimSphere(PVector cen, float rad) {
    init( cen,  rad);
    
  }
  
  
  
  void init(PVector cen, float rad){
     radius = rad;
     origin = cen.copy();
     drawSphere = new SimSphereGraphic(this, levelOfDetail);
  }
  
  void setLevelOfDetail(int lod){
    if(lod < 6) {
      lod = 6;
      println("Sphere level of detail cannot be below 6");
    }
    levelOfDetail = lod;
    init(origin, radius);
  }

  public PVector getCentre() {
    return getOrigin();
  }

  public void setCentre(PVector c) {
    this.origin = c;
  }

  public void setRadius(float r) {
    this.radius = r;
  }

  float getRadius() {
    float tradius = this.radius;
    tradius *= this.scale;
    return tradius;
  }

  // You set centre and radius by using setTransformAbs()


  public boolean isPointInside(PVector p) {
    PVector transCen = getCentre();
    float transRad = getRadius();
    float distP_Cen = transCen.dist(p);
    if (distP_Cen < transRad) return true;
    return false;
  }

  boolean intersectsSphere(SimSphere otherSphere) {
    PVector otherCen = otherSphere.getCentre();
    PVector thisCen = this.getCentre();
    float otherRadius = otherSphere.getRadius();
    float thisRadius = this.getRadius();
    if ( thisCen.dist(otherCen) < thisRadius+otherRadius ) {
      swapColliderIDs(otherSphere);  
      return true;
    }
    return false;
  }
  
  
  public boolean collidesWith(SimTransform other){
    if(other == this) return false;
    
    String otherClass = getClassName(other);
    //println("collidesWith between this ", getClassName(this), " and " , otherClass);
    switch(otherClass) {
      case "SimSphere": 
          return intersectsSphere((SimSphere) other);
      case "SimBox": 
          return ((SimBox)other).intersectsSphere(this);
      case "SimSurfaceMesh": 
          return ((SimSurfaceMesh)other).intersectsSphere(this);
      case "SimModel": 
          SimTransform boundingGeom  = ((SimModel)other).getPreferredBoundingVolume();
          return boundingGeom.collidesWith(this);
    }
    
    return false;
  }

  public boolean calcRayIntersection(SimRay ray) {
    ray.isIntersection = false;
    PVector sphereCen = this.getCentre();
    //println("ray orig ,dir:", this.origin.x,  this.origin.y,  this.origin.z,"  " ,direction.x,  direction.y,  direction.z);
    //println("sphere centre:", sphereCen.x,  sphereCen.y,  sphereCen.z);
    float sphereRad = this.getRadius();
    PVector sphereCenToRayOrigin = PVector.sub(ray.origin, sphereCen); //m
    float b = PVector.dot(sphereCenToRayOrigin, ray.direction);
    float c = PVector.dot(sphereCenToRayOrigin, sphereCenToRayOrigin) - (sphereRad*sphereRad);

    if (c > 0 && b > 0) return false;
    // goes on to calculate the actual interetxection now
    float discr = b*b - c;

    // a negative discriminant means sphere behind ray origin
    if (discr < 0) return false;

    // ray now found to interesect
    float t = -b - sqrt(discr);

    // if t is negative then ray origin inside sphere, clamp t to zero
    if (t < 0) { 
      t = 0;
      
    }
    

    PVector dirMult = PVector.mult(ray.direction, t);
    ray.intersectionPoint = PVector.add(ray.origin, dirMult );
    ray.setIntersectionNormal(  PVector.sub(ray.intersectionPoint, sphereCen) );
    ray.isIntersection = true;
    swapColliderIDs(ray);
    return true;
  }


  void drawMe() {
    
    
    float r = getRadius();
    //println("shpere radius",r);
    
     
      PVector transCen = getCentre();
      pushMatrix();
      translate(transCen.x, transCen.y, transCen.z);
      scale(r);
      drawSphere.drawMe();
      popMatrix();
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// SimBox, for AABB or OBB boxes
// Ray picking works in all cases
// isPointInside only works for AABBs
// intersects does not work yet

class SimBox extends SimTransform{
  // Bounding Box SimObject
  // It can only be initially defined in the major axis, but after that can be rotated
  // It can be used as an Axis Aligned Bounding Box
  // It can be be rotated, but used to estimate geometric collisions/intersectons
  PVector minCorner;
  PVector maxCorner;

  // index of top, and bottom vertices
  int
    T1 = 0, 
    T2 = 1, 
    T3 = 2, 
    T4 = 3, 
    B1 = 4, 
    B2 = 5, 
    B3 = 6, 
    B4 = 7;


  PVector[] vertices;


  public SimBox() {
    PVector c1 = new PVector(-1, -1, -1);
    PVector c2 = new PVector(1, 1, 1);
    setExtents(c1, c2);
  }

  public SimBox(PVector c1, PVector c2) {
    setExtents(c1, c2);
  }



  void setExtents(PVector c1, PVector c2) {
    vertices = new PVector[8];
    // sorts the data into min x,y,z, and max x,y,z
    // does not yet catch "illegal" boxes (zero width etc)
    setIdentityTransform();
    float minx = min(c1.x, c2.x);
    float miny = min(c1.y, c2.y);
    float minz = min(c1.z, c2.z);

    float maxx = max(c1.x, c2.x);
    float maxy = max(c1.y, c2.y);
    float maxz = max(c1.z, c2.z);

    minCorner = new PVector(minx, miny, minz);
    maxCorner = new PVector(maxx, maxy, maxz);
    createVertices();
  }

  int getNumFacets() { 
    return 6;
  }

  PVector[] getExtents() {
    //if (isRotated()) {
      // if rotated, need to find new extents
      return getExtents(vertices);
    // }

    

    //PVector[] extents = new PVector[4];
    //extents[0] = transform(minCorner);
   // extents[1] = transform(maxCorner);
    //extents[2] = getCentre();
    //extents[3] = extents[1]; // max and min corner will be the same distance from centre
    //return extents;
  }

  private void createVertices() {
    //top corner
    float tx = minCorner.x;
    float ty = minCorner.y;
    float tz = minCorner.z;

    float bx = maxCorner.x;
    float by = maxCorner.y;
    float bz = maxCorner.z;
    // top face corners
    vertices[T1] = new PVector(tx, ty, tz);
    vertices[T2] = new PVector(tx, ty, bz);
    vertices[T3] = new PVector(bx, ty, bz);
    vertices[T4] = new PVector(bx, ty, tz);
    // bottom face corners
    vertices[B1] = new PVector(tx, by, tz);
    vertices[B2] = new PVector(tx, by, bz);
    vertices[B3] = new PVector(bx, by, bz);
    vertices[B4] = new PVector(bx, by, tz);
  }

  //////////////////////////////////////////////////////////////////////
  // returns the transformed values depending on boolean
  //
  //
  public PVector getCentre() {
    // sould work for both AABB and OBB's
    PVector minCornerTrans = transform(minCorner);
    PVector maxCornerTrans = transform(maxCorner);

    return minCornerTrans.lerp(maxCornerTrans, 0.5);
  }






  SimBox getTransformedCopy() {
    // returns a copy of the current bounding box with the transformation "baked in"
    PVector transvertices[] = getTransformedVertices(vertices);
    SimBox copyOut = new SimBox();
    copyOut.vertices = transvertices;
    PVector exts[] = copyOut.getExtents();
    copyOut.minCorner = exts[0];
    copyOut.maxCorner = exts[1];
    return copyOut;
  }


  SimFacet getFacet(int num) {
    // returns the transformed facet
    // 0 = top, 1 = front, 2 = left, 3 = right, 4 = back, 5 = bottom 
    int v1, v2, v3, v4;

    //forward face
    // initialise them to this as default
    v1 = T1;
    v2 = T4;
    v3 = B4;
    v4 = B1;

    // top
    if (num == 0) {
      v1 = T1;
      v2 = T2;
      v3 = T3;
      v4 = T4;
    }

    //lhs face 
    if (num == 2) {
      v1 = T1;
      v2 = B1;
      v3 = B2;
      v4 = T2;
    }

    //rhs face 
    if (num == 3) {
      v1 = T4;
      v2 = T3;
      v3 = B3;
      v4 = B4;
    }

    //back face 
    if (num == 4) {
      v1 = T2;
      v2 = B2;
      v3 = B3;
      v4 = T3;
    }

    //bottom face 
    if (num == 5) {
      v1 = B1;
      v2 = B4;
      v3 = B3;
      v4 = B2;
    }

    PVector p1 = transform(vertices[v1]);
    PVector p2 = transform(vertices[v2]);
    PVector p3 = transform(vertices[v3]);
    PVector p4 = transform(vertices[v4]);

    return new SimFacet(p1, p2, p3, p4);
  }

  /////////////////////////////////////////////////////////////////////
  // intersection/collision methods
  //
  public boolean isPointInside(PVector p) {
    
    if( isRotated() ){
      println("non axis aligned BB point intersection not implemented yet");
      return false;
    }
      
      // is AABB
      PVector minCornerTrans = transform(minCorner);
      PVector maxCornerTrans = transform(maxCorner);

      if (  isBetweenInc(p.x, maxCornerTrans.x , minCornerTrans.x)   &&
            isBetweenInc(p.y, maxCornerTrans.y , minCornerTrans.y)   &&
            isBetweenInc(p.z, maxCornerTrans.z , minCornerTrans.z)  ) return true;
            
      return false;
  }
  
  
  
  public boolean collidesWith(SimTransform other){
    if(other == this) return false;
    String otherClass = getClassName(other);
    
    switch(otherClass) {
      case "SimSphere": 
          return  intersectsSphere((SimSphere)other);
      case "SimBox": 
          return  intersectsBox((SimBox)other);
      case "SimSurfaceMesh": 
          return  ((SimSurfaceMesh)other).intersectsBox(this);
      case "SimModel": 
          SimTransform boundingGeom  = ((SimModel)other).getPreferredBoundingVolume();
          return boundingGeom.collidesWith(this);
    }
    //println("collidesWith between this ", getClassName(this), " and " , otherClass, " false");
    return false;
  }

  public boolean calcRayIntersection(SimRay sr) {
    boolean intersectionFound = false;

    sr.clearIntersectingTriangles();
    for (int i = 0; i < 6; i++) {

      SimFacet f = getFacet(i);
      SimTriangle t1 = f.tri1;
      SimTriangle t2 = f.tri2;

      if ( sr.addIntersectingTriangle(t1) ) intersectionFound = true;
      if ( sr.addIntersectingTriangle(t2) ) intersectionFound = true;
    }

    if (intersectionFound) {
      sr.getNearestTriangleIntersectionPoint();
      sr.swapColliderIDs(this);
      //println("camera", getCameraPosition()," box hit ",sr.intersectionPoint);
    }
    return intersectionFound;
  } 




  public boolean intersectsSphere(SimSphere sphere) {
    // Thanks to Jim Arvo in Graphics Gems 2   
    if ( isRotated() == false ) {
      PVector[] exts = getExtents();
      PVector bmin = exts[0];
      PVector bmax = exts[1];
      PVector c = sphere.getCentre();
      float r = sphere.getRadius();
      float r2 = r * r;
      float dmin = 0;

      if ( c.x < bmin.x ) {
        dmin += sqr( c.x - bmin.x );
      } else {
        if ( c.x > bmax.x ) {
          dmin += sqr( c.x - bmax.x );
        }
      }

      if ( c.y < bmin.y ) {
        dmin += sqr( c.y - bmin.y );
      } else {
        if ( c.y > bmax.y ) {
          dmin += sqr( c.y - bmax.y );
        }
      }

      if ( c.z < bmin.z ) {
        dmin += sqr( c.z - bmin.z );
      } else {
        if ( c.z > bmax.z ) {
          dmin += sqr( c.z - bmax.z );
        }
      }

      boolean intersects = dmin <= r2;
      if (intersects) swapColliderIDs(sphere);  
      return intersects;
    }

    println("SimBox::intersectsSphere not implemented for non AABB's");
    return false;
  }



  public boolean intersectsBox(SimBox otherBox) {
    // tbd

    if ( isRotated() == false || otherBox.isRotated()==false) {
      // is AABB
      PVector[] thisExts = getExtents();
      PVector[] otherExts = otherBox.getExtents();
      int MIN = 0;
      int MAX = 1;

      boolean intersects =  (thisExts[MIN].x < otherExts[MAX].x) && (thisExts[MAX].x > otherExts[MIN].x) &&
        (thisExts[MIN].y < otherExts[MAX].y) && (thisExts[MAX].y > otherExts[MIN].y) &&
        (thisExts[MIN].z < otherExts[MAX].z) && (thisExts[MAX].z > otherExts[MIN].z);

      if (intersects) swapColliderIDs(otherBox);  
      return intersects;
    }



    println("Rotated box intersection not implemented yet, use rays");
    return false;
  }

  // draws the transformed shape
  public void drawMe() {
    //topface
    beginShape();
    drawTransformedVertex(vertices[T1]);
    drawTransformedVertex(vertices[T2]);
    drawTransformedVertex(vertices[T3]);
    drawTransformedVertex(vertices[T4]);
    endShape(CLOSE);


    //forward face
    beginShape();
    drawTransformedVertex(vertices[T1]);
    drawTransformedVertex(vertices[T4]);
    drawTransformedVertex(vertices[B4]);
    drawTransformedVertex(vertices[B1]);
    endShape(CLOSE);


    //lhs face 
    beginShape();
    drawTransformedVertex(vertices[T1]);
    drawTransformedVertex(vertices[B1]);
    drawTransformedVertex(vertices[B2]);
    drawTransformedVertex(vertices[T2]);
    endShape(CLOSE);


    //rhs face 
    beginShape();
    drawTransformedVertex(vertices[T4]);
    drawTransformedVertex(vertices[T3]);
    drawTransformedVertex(vertices[B3]);
    drawTransformedVertex(vertices[B4]);
    endShape(CLOSE);


    //back face 
    beginShape();
    drawTransformedVertex(vertices[T2]);
    drawTransformedVertex(vertices[B2]);
    drawTransformedVertex(vertices[B3]);
    drawTransformedVertex(vertices[T3]);
    endShape(CLOSE);

    //bottom face 
    beginShape();
    drawTransformedVertex(vertices[B1]);
    drawTransformedVertex(vertices[B4]);
    drawTransformedVertex(vertices[B3]);
    drawTransformedVertex(vertices[B2]);
    endShape(CLOSE);
  }
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This is a shape initialsed with a PShape. It keeps this copy in cardinalModel, and you can set the shapes
// transformation usnig the standard setTrasnformAbs/Rel.
// The shape is then drawn with these transforms.
// When you need to get the geometry of the shape, using getBoundingBox or getBoundingSphere, getCentre or getVertices
// it temporality creates a falttedned shape from the original model (whihc will then have the actual 
// transformed vertices)
// 
// array of vertices.
// It can be set by copying in a PShape. This will then be "flattened" (children and transforms removed)
// texture and material will also be lost

class SimModel extends SimTransform{

  // stores the cardinal model
  private PShape cardinalModel;
  private PVector[] rawvertices;
  
  // cardinal bounding volumes
  private SimSphere boundingSphere = new SimSphere();
  private SimBox boundingBox = new SimBox();

  private String preferredBoundingVolume;
  public int boundingVolumeTransparency = 100;
  public boolean showBoundingVolume = true;

  public SimModel() {
  }
  
  public SimModel(String filename){
    PShape mod = loadShape(filename);
    if(mod == null){
      println("SimModel: cannot load file name ", filename);
      return;
    }
    setWithPShape(mod);
  }

  void setWithPShape(PShape shapeIn) {
    cardinalModel = shapeIn;
    calculateBoundingGeometry();
  }

  void calculateBoundingGeometry() {
    // calculates the boundig sphere of thr cardinal geometry
    // the transformed sphere is returned by getBoundingSphere() 
    rawvertices = getRawVertices();
    PVector[] extents = getExtents(rawvertices);
    //println("extents are ", extents[0],extents[1]);
    PVector centrePoint = extents[2];
    PVector furthestVerticesFromCentre = extents[3];
    float radius = furthestVerticesFromCentre.dist(centrePoint);
    boundingBox = new SimBox(extents[0], extents[1]);
    
    
    boundingSphere = new SimSphere(centrePoint, radius);
 
    preferredBoundingVolume = "box";
  }
  
  PVector[] getExtents(){
    return boundingBox.getExtents();
  }
  
  void setID(String i){
    // this overrides the simtransform setID method, to give the bounding
    // shapes the same id
    id = i;
    boundingBox.setID(id + "_boundingBox");
    boundingSphere.setID(id + "_boundingSphere");
  }
  
  void setPreferredBoundingVolume(String BOXorSPHERE){
    String s = BOXorSPHERE.toLowerCase();
    if(s.equals("box")) preferredBoundingVolume = "box";
    if(s.equals("sphere")) preferredBoundingVolume = "sphere";
  }
  
  SimTransform getPreferredBoundingVolume(){
    if(preferredBoundingVolume.equals("box")) {return getBoundingBox();}
    else {  return getBoundingSphere(); }
  }
  
  void showBoundingVolume(boolean show){
    showBoundingVolume = show;
  }
  
  boolean calcRayIntersection(SimRay sr){ 
    SimTransform obj = null;
    if(preferredBoundingVolume.equals("sphere")) { obj = getBoundingSphere();}
    else { obj = getBoundingBox();}
    
    return obj.calcRayIntersection(sr);
  }

  public boolean collidesWith(SimTransform other){
    
    if(other == this) return false;
    
    SimTransform thisCollidingShape = getPreferredBoundingVolume();
    
    return thisCollidingShape.collidesWith(other);
  }
  
  

  PVector[] getRawVertices() {
    PShape flatmodel = cardinalModel.getTessellation(); 

    int total = flatmodel.getVertexCount();
    PVector[] vertices = new PVector[total];
    for (int j = 0; j < total; j++) {
      vertices[j] = flatmodel.getVertex(j);
    }
    return vertices;
  }

  PVector[] getTransformedVertices(){
    PVector[] rawVertices = getRawVertices();
    return getTransformedVertices(rawVertices);
  }


  SimSphere getBoundingSphere() {
    boundingSphere.setTransformAbs( this.scale, this.rotateX, this.rotateY, this.rotateZ, this.translate);
    boundingSphere.setID( getID() );
    return boundingSphere;
  }

  SimBox getBoundingBox() {
    boundingBox.setTransformAbs( this.scale, this.rotateX, this.rotateY, this.rotateZ, this.translate);
    boundingBox.setID( getID() );
    return boundingBox;
  }
  
  
  
  SimBox getAABB(){
    PVector[] transformedVertices = getTransformedVertices();
    PVector[] extents = getExents_DoNotApplyTransform(transformedVertices);
    //println("AABB extents are ", extents[0],extents[1]);
    return new SimBox(extents[0], extents[1]);

  }
  
  

  private void transformOriginalForDrawing() {
    cardinalModel.resetMatrix();
    cardinalModel.scale(this.scale);
    cardinalModel.rotateX(this.rotateX);
    cardinalModel.rotateY(this.rotateY);
    cardinalModel.rotate(this.rotateZ, 0, 0, 1); // fix for bug

    cardinalModel.translate(this.translate.x, this.translate.y, this.translate.z);

    // bounding shapes
  }

  void drawMe() {

    transformOriginalForDrawing();

    shape(cardinalModel);
    cardinalModel.resetMatrix();
    
    if(showBoundingVolume) drawBoundingVolume();
  }
  
  void drawBoundingVolume(){
    if(preferredBoundingVolume.equals("sphere")) drawBoundingSphere();
    if(preferredBoundingVolume.equals("box")) drawBoundingBox();
  }

  void drawBoundingSphere() {
    color cc = g.fillColor;
    pushStyle();
    fill( red(cc),green(cc), blue(cc),boundingVolumeTransparency);
    SimSphere bs = getBoundingSphere();
    bs.drawMe();
    popStyle();
  }

  void drawBoundingBox() {
    SimBox bb = getBoundingBox();
    color cc = g.fillColor;
    pushStyle();
    fill( red(cc),green(cc), blue(cc),boundingVolumeTransparency);
    bb.drawMe();
    popStyle();
  }
  
  void drawAABB() {
    SimBox bb = getAABB();
    bb.drawMe();
  }
}


////////////////////////////////////////////////////////////////////////////////////////
// SimRay. a class for defining a ray. It is defined by 2 3d points that are both on the ray
// 
class SimRay extends SimTransform {

  PVector direction = vec(0, 0, -1);
  private PVector intersectionPoint = vec(0, 0, 0);

  // this is the surface normal at the point of intersection
  private PVector intersectionNormal;

  boolean isIntersection = false;
  ArrayList<SimTriangle> intersectingTriangleList = new ArrayList<SimTriangle>();

  public SimRay() {
  }

  public SimRay(PVector v1, PVector v2) {
    origin = v1.copy();
    direction = PVector.sub(v2, v1);
    direction.normalize();
  }

  void printMe() {
    println("SimRay: origin - ", this.origin, " direction - ", this.direction);
  }
  
  
  
  
  void drawMe(){
    PVector farPoint = PVector.add(origin, direction);
    farPoint.mult(10000);
    line(origin.x,origin.y,origin.z, farPoint.x,farPoint.y,farPoint.z); 
  }

  //////////////////////////////////////////////////////////////////////////////
  // once an intersection calculation has been made, the intersection can be queried
  //

  boolean isIntersection() {
    return isIntersection;
  }
  
  boolean collidesWith(SimTransform otherObject){
    return calcIntersection(otherObject);
  }
  
  // this is here to satify the abtract class SimTransform methods
  // in this universe, a sim ray can never intersect another sim ray
  public boolean calcRayIntersection(SimRay ray){ return false;}
  
  int getNumIntersections(){
    // this works only with triangulated shapes (so doesnot work with spheres)
    return intersectingTriangleList.size();
  }

  public PVector getIntersectionPoint() {
    // this returns the intersection point nearest to the Ray's origin
    return this.intersectionPoint;
  }

  public PVector getIntersectionNormal() {
    return this.intersectionNormal;
  }
  
  void setIntersectionNormal(PVector n){
    this.intersectionNormal = n.copy();
    this.intersectionNormal.normalize();
  }



  SimRay copy() {
    SimRay sr =  new SimRay();
    sr.origin = this.origin.copy();
    sr.direction = this.direction.copy();

    return sr;
  }

  PVector getPointAtDistance(float d) {
    // returns the point on the ray at distance d from the origin
    PVector p1 = PVector.mult(direction, d);
    return PVector.add(p1, origin);
  }


  ///////////////////////////////////////////////////////////////////////////////////////////////////////
  // SimRay intersection calculations
  // Any shape that can intersect with a ray, must have the calcRayIntersection() method implemented
  //
  //
  boolean calcIntersection(SimTransform shape) {
    return shape.calcRayIntersection(this);
  }



  ///////////////////////////////////////////////////////////////////////////////////////////////////////
  // SimRay multiple triangle intersection calculations
  // would like these to be private, but have to be public
  //
  //
  public boolean addIntersectingTriangle(SimTriangle t) {
    if ( t.calcRayIntersection(this) ) {
      intersectingTriangleList.add(t);
      return true;
    }
    return false;
  }

  public void clearIntersectingTriangles() {
    intersectingTriangleList.clear();
  }

  PVector getNearestTriangleIntersectionPoint() {
    PVector nearestIntersectionPoint = vec(0, 0, 0);
    float nearestIntersectionDistance = 10000000000.0;
    PVector nearestSurfaceNormal = vec(0, 0, 0);
    for (SimTriangle t : intersectingTriangleList) {

      if ( t.calcRayIntersection(this)) {
        PVector rayIntersectionPoint = getIntersectionPoint();
        PVector rayOrigin = getOrigin();
        float thisPointDistToRayOrigin = PVector.dist(rayIntersectionPoint, rayOrigin);
        if (thisPointDistToRayOrigin < nearestIntersectionDistance) {
          nearestIntersectionDistance = thisPointDistToRayOrigin;
          nearestIntersectionPoint = rayIntersectionPoint;
          nearestSurfaceNormal = t.surfaceNormal();
        }//end if
      }//end if
    }// end for
    this.intersectionPoint = nearestIntersectionPoint;
    this.setIntersectionNormal(nearestSurfaceNormal);
    return nearestIntersectionPoint;
  }// end method
}// end ray class
////////////////////////////////////////////////////////////////
