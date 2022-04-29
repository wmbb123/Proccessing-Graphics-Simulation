
////////////////////////////////////////////////////////////////////////////
// SimSurfaceMesh
// A xdim by zdim mesh of vertices, whihc forms a surface
// Each of these vertices can be given a Y height, so as to form a landscape
//
//
// The mesh can be transformed using setTransformAbs(...) or setTransformRel(....)
// afterwhich you need to call applyTransform() to fix it permanently in the mesh vertices.
//


class SimSurfaceMesh  extends SimTransform{

    int numFacetsX, numFacetsZ;

    PVector[] meshVertices;
    public int numTriangles = 0;
    // mesh coordinates are stored in this array. It is made at the start
    
    //SimRay pick information
    public int rayIntersectionTriangleNum; 
    public PVector rayIntersectionPoint;
    
    PImage textureMap;
    
    public SimSurfaceMesh(int numInX, int numInZ, float scale)
    {
        // numInX and Z represent the number of Facets generated.
        // The number of triangles is (number of Facets)*2
        
        // the number of vertices to make this is (numFacetsX+1) * (numFacetsY+1) 
        numFacetsX = numInX;
        numFacetsZ = numInZ;
        //meshVertices = new ArrayList<PVector>();
        meshVertices = new PVector[(numFacetsX+1)*(numFacetsZ+1)];
        for(int z = 0; z < numFacetsZ+1; z++)
        {
            for (int x = 0; x < numFacetsX+1; x++)
            {
                float xf = x * scale;
                float yf = 0.0f;
                float zf = z * scale;
                setMeshVertex(x,z,  new PVector(xf, yf, zf) );
            }
            
        }

    }
    
    
    void setHeightsFromImage(PImage im, float maxAltitude){
    
      int numInX = getNumVerticesX();
      int numInZ = getNumVerticesZ();
      int imWidth = im.width;
      int imHeight = im.height;
      
      for(int z = 0; z < numInZ; z++)
          {
              for (int x = 0; x < numInX; x++)
              {
                 int imx = (int) map(x,0,numInX,0,imWidth);
                 int imy = (int) map(z,0,numInZ,0,imHeight);
                 color col = im.get(imx,imy);
                 float hght = map(red(col),0,255,0,maxAltitude);
                 setVertexY(x,z,hght );
              }
              
          }
    
  }
    
    
    void setTextureMap(PImage t){
      textureMap = t.copy();
    }
    
    
    // this permanently applies the transform
    void bakeInTransform(){
      meshVertices = getTransformedVertices(meshVertices);
      setTransformAbs(1.0,0.0,0.0,0.0, vec(0,0,0));
    }
    

    boolean intersectsSphere(SimSphere sphere){
      for(PVector thisVertex: meshVertices){
        PVector transformedVertex = transform(thisVertex);
        if( sphere.isPointInside(transformedVertex) ){
          swapColliderIDs(sphere);
          return true;
        }
      }
     return false; 
    }
    
     boolean intersectsBox(SimBox box){
      for(PVector thisVertex: meshVertices){
        PVector transformedVertex = transform(thisVertex);
        if( box.isPointInside(transformedVertex) ) {
          swapColliderIDs(box);
          return true;
        }
      }
     return false; 
    }
    
    void drawMe(){
      if ( textureMap != null) {
      drawMe_Texture();
      return;
      }
      int numFacets = getNumFacets();
      beginShape(TRIANGLES);
        
        // Center point
        
        for (int i = 0; i < numFacets; i++) {
          SimFacet f = getFacet(i);
          SimTriangle t1 = f.tri1;
          SimTriangle t2 = f.tri2;
          // draws ok
          drawTransformedVertex(t1.p1);
          drawTransformedVertex(t1.p2);
          drawTransformedVertex(t1.p3);
          // doenst draw
          drawTransformedVertex(t2.p1);
          drawTransformedVertex(t2.p2);
          drawTransformedVertex(t2.p3);
        }
        endShape();
    }
    
    void drawMe_Texture() {
      int numFacets = getNumFacets();
      beginShape(TRIANGLES);
      texture(textureMap);
      //g3d.blendMode(REPLACE); 
      for (int i = 0; i < numFacets; i++) {
       
        SimFacet f = getFacet(i);
        SimTriangle t1 = f.tri1;
        SimTriangle t2 = f.tri2;
   
        drawTransformedVertex_Texture(t1.p1);
        drawTransformedVertex_Texture(t1.p2);
        drawTransformedVertex_Texture(t1.p3);
  
        drawTransformedVertex_Texture(t2.p1);
        drawTransformedVertex_Texture(t2.p2);
        drawTransformedVertex_Texture(t2.p3);
        }
      
      endShape();
  }
  
  public void  drawTransformedVertex_Texture(PVector vertex) {
    PVector transformedVector = transform(vertex);
    PVector uv = getTextureUV(vertex);
    vertex(transformedVector.x, transformedVector.y, transformedVector.z, uv.x, uv.y);
  }
  
  PVector getTextureUV(PVector vertex){
    int w = textureMap.width;
    int h = textureMap.height;
    PVector minVertex = getMeshVertex(0, 0);
    PVector maxVertex = getMeshVertex(numFacetsX, numFacetsZ);
    float u = map(vertex.x, minVertex.x, maxVertex.x, 0, w-1);
    float v = map(vertex.z, minVertex.z, maxVertex.z, 0, h-1);
    return new PVector(u,v);
  }
  
  
  public boolean collidesWith(SimTransform other){
    if(other == this) return false;
    String otherClass = getClassName(other);
    //println("collidesWith between this ", getClassName(this), " and " , otherClass);
    switch(otherClass) {
      case "SimSphere":
        return intersectsSphere((SimSphere)other);
      case "SimBox": 
        return intersectsBox((SimBox)other);
      case "SimSurfaceMesh": 
        println("SimSurfaceMesh collides with sim surface mesh implemented - use rays");
        break;
      case "SimModel": 
        SimTransform boundingGeom  = ((SimModel)other).getPreferredBoundingVolume();
        return boundingGeom.collidesWith(this);
    }
    
    return false;
  }
  
  
   
  public boolean calcRayIntersection(SimRay sr){
    boolean intersectionFound = false;
    
    int numFacets = getNumFacets();
    sr.clearIntersectingTriangles();
    for (int i = 0; i < numFacets; i++) {
          
          SimFacet f = getTransformedFacet(i);
          SimTriangle t1 = f.tri1;
          SimTriangle t2 = f.tri2;

          if( sr.addIntersectingTriangle(t1) ) intersectionFound = true;
          if( sr.addIntersectingTriangle(t2) ) intersectionFound = true; 
        }
       
    if(intersectionFound){
      sr.getNearestTriangleIntersectionPoint();
      sr.swapColliderIDs(this);
      //println("camera", getCameraPosition(),"grid hit",sr.intersectionPoint);
    }
    return intersectionFound;
  } 
  

   //////////////////////////////////////////////// 
    public void setVertexY(int vertexX, int vertexZ, float y){
      // there are meshSizeX+1, meshSizeY+1 vertices in this messh
      int vertexGridWidth = numFacetsX + 1;
      int index =  vertexZ * vertexGridWidth + vertexX;
      PVector p = meshVertices[index];
      p.y = y;
      meshVertices[index] = p;
    }
    
    public PVector getMeshVertex(int vertexX, int vertexZ){
      int vertexGridWidth = numFacetsX + 1;
      int index =  vertexZ * vertexGridWidth + vertexX;
      return meshVertices[index];
    }
    
    public void setMeshVertex(int vertexX, int vertexZ, PVector v){
      int vertexGridWidth = numFacetsX + 1;
      int index =  vertexZ * vertexGridWidth + vertexX;
      meshVertices[index] = v;
    }
    
    /////////////////////////////////////////////
    // private below here

    int getNumFacets(){
      return (numFacetsX)* (numFacetsZ); 
    }
    
    int getNumTriangles(){
        return (numFacetsX)* (numFacetsZ)*2;
    }
    
    private int getNumVerticesX(){ return  numFacetsX+1;}
    private int getNumVerticesZ(){ return  numFacetsZ+1;}

    SimFacet getTransformedFacet(int index){
      SimFacet facet = getFacet( index);
      PVector[] verts = facet.getVertices();
      PVector[] transformedVerts = new PVector[4];
      for(int n = 0; n < 4; n++) transformedVerts[n] = transform(verts[n]);
      return new SimFacet(transformedVerts[0],transformedVerts[1],transformedVerts[2],transformedVerts[3]);
    }
    
    SimFacet getFacet(int index){
        
        //the vertices under consideration
        // A B
        // C D
        // as indices into the meshVertices array
        int vertextGridWidth = numFacetsX+1;
        int rowNum = (int)(index/numFacetsX);
        int A = index + rowNum;
        int B = A + 1;
        int C = A + vertextGridWidth;
        int D = C + 1;

        //println("index ", index, "row ", rowNum," vertices nums ", A,B,C,D);
        SimFacet facet = new SimFacet();
        // triangle 1
        facet.tri1.p1 = meshVertices[D];
        facet.tri1.p2 = meshVertices[B];
        facet.tri1.p3 = meshVertices[A];
 
        // triangle 2
        facet.tri2.p1  = meshVertices[D];
        facet.tri2.p2  = meshVertices[A];
        facet.tri2.p3  = meshVertices[C];

        return facet;

      
    }

    SimFacet getFacet(int x, int z)
    {
        int vertexGridWidth = numFacetsX + 1;
        int index =  z * vertexGridWidth + x;
        
        return getFacet(index); 
    }
    
  
  

}// end SimSurfaceMesh class





////////////////////////////////////////////////////////////////////////////
// SimTriangle
// simple containter for a 2d or 3d triange
//

class SimTriangle{
  public PVector p1,p2,p3;
  public SimTriangle(PVector p1, PVector p2, PVector p3){
    this.p1 = p1;
    this.p2 = p2;
    this.p3 = p3;
  }
  
  public SimTriangle(){
    this.p1 = new PVector(0,0,0);
    this.p2 = new PVector(0,0,0);
    this.p3 = new PVector(0,0,0);
  }
  
  void flip(){
    // flips the direction from CW to CCW or visa-versa
    PVector oldP2 = this.p2.copy();
    PVector oldP3 = this.p3.copy();
    this.p2 = oldP3;
    this.p3 = oldP2;
    // p1 stays the same
  }
  
  void printMe(){
    println("triange:",p1,p2,p3);
    
  }
  
   void drawMe(){
      beginShape(TRIANGLE);
      vertex(this.p1.x,this.p1.y,this.p1.z);
      vertex(this.p2.x,this.p2.y,this.p2.z);
      vertex(this.p3.x,this.p3.y,this.p3.z);
      endShape(CLOSE);
    }
    

  PVector surfaceNormal(){ 
    PVector edgep1p2 = PVector.sub(p2,p1);
    PVector edgep1p3 = PVector.sub(p3,p1);
    PVector cross = edgep1p2.cross(edgep1p3);
    cross.y *= -1;
    return cross;
  }
  
  /*
  boolean isBackFacing(){
    PVector sn = surfaceNormal();
    PVector cameraPos = getCameraPosition();
    if( sn.dot( cameraPos.sub(p1) ) > 0.0 ) return true;
    return false;
  }
  */
  
  
  public boolean calcRayIntersection(SimRay ray) 
        {
        
        
        //MOLLER_TRUMBORE algorithm
        ray.intersectionPoint = null;
        
        // make local copies so we don't change anything ouside the function
        PVector dir = ray.direction.copy();
        PVector orig = ray.origin.copy();
        PVector v0 = this.p1.copy();
        PVector v1 = this.p2.copy();
        PVector v2 = this.p3.copy();
        
        
        PVector edge_v0v1 = v1.sub(v0);
        PVector edge_v0v2 = v2.sub(v0);
        PVector pvec = dir.cross(edge_v0v2);
        
        float det = edge_v0v1.dot(pvec);
        
        if( nearZero(det) ){
          // ray is parallel with triangle plane
          // this ignores the direction of triangle winding
          return false;
        }
        
        float invDet = 1.0/det;
        PVector tvec = PVector.sub(orig,v0);
        float u = tvec.dot(pvec) * invDet;
        if( u < 0 || u > 1) {
          return false;
        }
        
        PVector qvec = tvec.cross(edge_v0v1);
        float v = dir.dot(qvec) * invDet;
        if(v < 0 || u + v > 1){
          return false;
        }
        
        float t = edge_v0v2.dot(qvec) * invDet;
        if(t < EPSILON){
          // line intersection, not ray intersection... 
          // to avoid hitting a point behind the camera
          return false;
        }
        PVector addToOrigin = PVector.mult(dir,t);
        ray.intersectionPoint = PVector.add(orig,addToOrigin);
        
       // if(isBackFacing()){
       //   //println("is back facing");
       //   //return false;
       // }
        
        
        return true;
        
    }
}





////////////////////////////////////////////////////////////////////////////
// SimFacet
// Two triangles ake a facet
//
class SimFacet{
  public SimTriangle tri1;
  public SimTriangle tri2;
  
  public SimFacet(){
    tri1 = new SimTriangle();
    tri2 = new SimTriangle();
  }
  
  public SimFacet(PVector p1, PVector p2, PVector p3, PVector p4){
    setVertices(p1,p2,p3,p4);
  }
    
  void setVertices( PVector p1, PVector p2, PVector p3, PVector p4){ 
    // give 4 vertices of a facet, in either winding, create a correct 2-triangle facet
    // currently cannot handle "butterfly" quads
   tri1 = new SimTriangle(p1,p2,p3);
   tri2 = new SimTriangle(p1,p3,p4); 
  }
  
  PVector[] getVertices(){
    PVector[] verts = new PVector[4];
    verts[0] = tri1.p1.copy();//p1
    verts[1] = tri1.p2.copy();//p2
    verts[2] = tri1.p3.copy();//p3
    verts[3] = tri2.p3.copy();//p4
    return verts;
  }
}
