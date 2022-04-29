// Complete Mover class
// With collision detection and response
//
// This mover class accelerates according to the force accumulated over TIME
// MASS is taken into consideration by using F=MA (or acceleation = force/mass)
// Mass is represented by the surface area of the ball
// 
// The system works thus:-
// within each FRAME of the system
// 1/ calculate the cumulative acceleration (by acceleration += force/mass) by adding all the forces, including friction
// 2/ scale the acceleration by the elapsed time since the last frame (will be about 1/60th second)
// 3/ Add this acceleration to the velocity
// 5/ Move the ball by the velocity scaled by the elapsed time since the last frame
// 5/ Set the acceleration back to zero again
// repeat

class Mover {
  Timer timer = new Timer();
  PVector location = new PVector(width/2, height/2, 0);
  PVector velocity = new PVector(0, 0, 0);
  PVector acceleration = new PVector(0,0,0);

  private float mass = 1;
  float radius;
  float frictionAmount = 0.3;
  PVector colour = new PVector(255,0,0);
  SimSphere sphere = new SimSphere();

  Mover() {
    setMass(1);
  }
  
  ////////////////////////////////////////////////////////////
  // movement code has not changed except we now set the mass
  // by a method, which calculates the radius of the ball
  // required for drawing and collision checking
  
  void setMass(float m){
    // converts mass into surface area
    mass=m;
    radius = 60 * sqrt( mass/ PI );
    
  }

  void update() {
    float ellapsedTime = timer.getElapsedTime();
    
    applyFriction();
    
    // scale the acceleration by time elapsed
    PVector accelerationOverTime = PVector.mult(acceleration, ellapsedTime);
    velocity.add(accelerationOverTime);
    
    // scale the movement by time elapsed
    PVector distanceMoved = PVector.mult(velocity, ellapsedTime);
    location.add(distanceMoved);
    
    // now that you have "used" your accleration it needs to be re-zeroed
    acceleration = new PVector(0,0);
    
    checkForBounceOffEdges();
  }
  
  void addForce(PVector f){
    // use F= MA or (A = F/M) to calculated acceleration caused by force
    PVector accelerationEffectOfForce = PVector.div(f, mass);
    acceleration.add(accelerationEffectOfForce);
  }

  void display() {
    stroke(0);
    strokeWeight(1);
    fill(colour.x,colour.y, colour.z);
    sphere = new SimSphere(vec (location.x, location.y, location.z), radius) ;
    sphere.drawMe();
    //ellipse(location.x, location.y, radius*2, radius*2);
  }
  
  
  void applyFriction(){
    // modify the acceleration by applying
    // a force in the opposite direction to its velociity
    // to simulate friction
    PVector reverseForce = PVector.mult( velocity, -frictionAmount );
    addForce(reverseForce);
  }
 
  void applyGrav(){
    acceleration = new PVector(0,500);
  }
  
  
  ////////////////////////////////////////////////////////////
  // new collision code
  // call collisionCheck just before or after update in the "main" tab
  
  boolean collisionCheck(Mover otherMover){
    
    if(otherMover == this) return false; // can't collide with yourself!
    
    float distance = otherMover.location.dist(this.location);
    float minDist = otherMover.radius + this.radius;
    if (distance < minDist)  return true;
    return false;
  }
  
  
  void collisionResponse(Mover otherMover) {
    // based on 
    // https://en.wikipedia.org/wiki/Elastic_collision
    
     if(otherMover == this) return; // can't collide with yourself!
     
     
    PVector v1 = this.velocity;
    PVector v2 = otherMover.velocity;
    
    PVector cen1 = this.location;
    PVector cen2 = otherMover.location;
    
    // calculate v1New, the new velocity of this mover
    float massPart1 = 2*otherMover.mass / (this.mass + otherMover.mass);
    PVector v1subv2 = PVector.sub(v1,v2);
    PVector cen1subCen2 = PVector.sub(cen1,cen2);
    float topBit1 = v1subv2.dot(cen1subCen2);
    float bottomBit1 = cen1subCen2.mag()*cen1subCen2.mag();
    
    float multiplyer1 = massPart1 * (topBit1/bottomBit1);
    PVector changeV1 = PVector.mult(cen1subCen2, multiplyer1);
    
    PVector v1New = PVector.sub(v1,changeV1);
    
    // calculate v2New, the new velocity of other mover
    float massPart2 = 2*this.mass/(this.mass + otherMover.mass);
    PVector v2subv1 = PVector.sub(v2,v1);
    PVector cen2subCen1 = PVector.sub(cen2,cen1);
    float topBit2 = v2subv1.dot(cen2subCen1);
    float bottomBit2 = cen2subCen1.mag()*cen2subCen1.mag();
    
    float multiplyer2 = massPart2 * (topBit2/bottomBit2);
    PVector changeV2 = PVector.mult(cen2subCen1, multiplyer2);
    
    PVector v2New = PVector.sub(v2,changeV2);
    
    this.velocity = v1New;
    otherMover.velocity = v2New;
    ensureNoOverlap(otherMover);
  }
  
 
  void ensureNoOverlap(Mover otherMover){
    // the purpose of this method is to avoid Movers sticking together:
    // if they are overlapping it moves this Mover directly away from the other Mover to ensure
    // they are not still overlapping come the next collision check 
    
    
    PVector cen1 = this.location;
    PVector cen2 = otherMover.location;
    
    float cumulativeRadii = (this.radius + otherMover.radius)+2; // extra fudge factor
    float distanceBetween = cen1.dist(cen2);
    
    float overlap = cumulativeRadii - distanceBetween;
    if(overlap > 0){
      // move this away from other
      PVector vectorAwayFromOtherNormalized = PVector.sub(cen1, cen2).normalize();
      PVector amountToMove = PVector.mult(vectorAwayFromOtherNormalized, overlap);
      this.location.add(amountToMove);
    }
  }
  
  void checkForBounceOffEdges() {
    if (location.x > width || location.x < 0) {
      velocity.x *= -1;
    } 
    if (location.y > height || location.y < 0) {
      velocity.y *= -1;
    } 
    if (location.z > height/8 || location.z < -height/8) {
      velocity.z *= -1;
    } 
    
  }
  
}
