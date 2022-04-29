Mover mover1;
Mover mover2;
Mover mover3;
Mover mover4;
Mover mover5;
Mover mover6;
Mover mover7;
SimSurfaceMesh bottom;
SimSurfaceMesh bottom2;
SimSurfaceMesh bottom3;
SimSurfaceMesh bottom4;
SimSurfaceMesh back;
SimpleUI myUI;
SimSphere ball1;
SimSurfaceMesh mover;
SimCamera myCamera;

boolean grav = false;

PImage[] textures = new PImage[7];

PVector wind = new PVector(1,0);
PVector gravity = new PVector(0,20,0);
float colorx = random(0,255);
float colory = random(0,255);
float colorz = random(0,255);

float colorx1 = random(0,255);
float colory1 = random(0,255);
float colorz1 = random(0,255);

float colorx2 = random(0,255);
float colory2 = random(0,255);
float colorz2 = random(0,255);

float colorx3 = random(0,255);
float colory3 = random(0,255);
float colorz3 = random(0,255);

float colorx4 = random(0,255);
float colory4 = random(0,255);
float colorz4 = random(0,255);

float colorx5 = random(0,255);
float colory5 = random(0,255);
float colorz5 = random(0,255);
int score = 0;

void setup() {
  size(800, 800, P3D);
  
  mover1 = new Mover();
  bottom = new SimSurfaceMesh(80,20,10.0);
  bottom2 = new SimSurfaceMesh(80,20,10.0);   
  bottom3 = new SimSurfaceMesh(80,20,10.0);
  bottom4 = new SimSurfaceMesh(80,20,10.0);
  back = new SimSurfaceMesh(20,20,40.0);  
  
  bottom.setTextureMap( loadImage("fractalNoise2.png"));
  bottom.setTransformAbs(1,0,0,0, vec(0,800,-100));
  bottom2.setTextureMap( loadImage("fractalNoise2.png"));
  bottom2.setTransformAbs(1,0,0,0, vec(0,0,-100));    
  bottom3.setTextureMap( loadImage("fractalNoise2.png"));
  bottom3.setTransformAbs(1,0,0, -PI*.5, vec(0,800,-100));
  bottom4.setTextureMap( loadImage("fractalNoise2.png"));
  bottom4.setTransformAbs(1,0,0, PI*.5, vec(800,0,-100));
  back.setTextureMap( loadImage("fractalNoise2.png"));
  back.setTransformAbs(1,PI*.5,0,0, vec(0,800,-100));
  
  myCamera = new SimCamera();
  myUI = new SimpleUI();
  //myUI.addToggleButton("gravityOn", 20,20);
  myUI.addToggleButton("reset", 20,50);  
  mover1.location = new PVector(400, 400, 0);
  mover1.setMass(1);
  mover1.colour = new PVector(0,255,0);

  mover2 = new Mover();
  mover2.location = new PVector(600, 400, 0);
  mover2.setMass(0.5);
  
  mover3 = new Mover();
  mover3.location = new PVector(200, 400, 0);
  mover3.setMass(0.5);
  
  mover4 = new Mover();
  mover4.location = new PVector(400, 600, 0);
  mover4.setMass(0.2);
  
  mover5 = new Mover();
  mover5.location = new PVector(400, 200, 0);
  mover5.setMass(0.2);  
  
  mover6 = new Mover();
  mover6.location = new PVector(400, 400, 50);
  mover6.setMass(0.1);
  
  mover7 = new Mover();
  mover7.location = new PVector(400, 400, -50);
  mover7.setMass(0.1);
}

void draw() {
  background(170, 200, 255);
  lights();
  drawMajorAxis(vec(400, 400,0), 100);
  myCamera.update();

  myCamera.startDrawHUD();

  myCamera.endDrawHUD();
  myCamera.setHUDArea(20,20,120,120);

  pushMatrix();
  stroke(255);
  noFill();
  translate(400, 400, 0);
  box(800, 800, 200);
  popMatrix();
  
  if ( keyPressed ) {
    doKeyPress();
  } 
  
  mover1.update();
  mover1.display(); 

  mover2.update();
  mover2.display();
  
  mover3.update();
  mover3.display(); 

  mover4.update();
  mover4.display();

  mover5.update();
  mover5.display();  

  mover6.update();
  mover6.display();

  mover7.update();
  mover7.display();
 
  noStroke();
  fill(200,200,200); 
  bottom.drawMe(); 
  bottom2.drawMe();    
  bottom3.drawMe(); 
  bottom4.drawMe();    
  back.drawMe();   
  showCollisions();
  
  myCamera.startDrawHUD();
  text("Score: " + score, 600, 30);
  textSize(20);
  myUI.update();  
  myCamera.endDrawHUD();   
  
  if  (mousePressed){
    mover1.applyGrav();
    mover2.applyGrav();
    mover3.applyGrav(); 
    mover4.applyGrav();
    mover5.applyGrav();
    mover6.applyGrav();    
    mover7.applyGrav();      
  }
}


void doKeyPress() {

  float forceAmmount = 500;
  
    if (key == 'a') {
      mover1.addForce( new PVector(-forceAmmount, 0, 0) );
    }
    if (key == 'd') {
      mover1.addForce( new PVector(forceAmmount, 0, 0) );
    }
    if (key == 'w') {
      mover1.addForce( new PVector(0, -forceAmmount, 0) );
    }
    if (key == 's') {
      mover1.addForce( new PVector(0, forceAmmount, 0) );
    }
    if (key == 'q') {
      mover1.addForce( new PVector(0, 0, -forceAmmount) );
    }
    if (key == 'e') {
      mover1.addForce( new PVector(0, 0, forceAmmount) );
    }     
}
void keyPressed(){

  float movement = 20f;
  
  if(key == 'c'){ 
     myCamera.isMoving = !myCamera.isMoving;
  }

  if( myCamera.isMoving ) return;
  
  if(key == CODED){
    if(keyCode == LEFT){
      moveObject(-movement,0,0);
      }
    if(keyCode == RIGHT){ 
     moveObject(movement,0,0);
      }
    if(keyCode == UP){
      moveObject(0,0,-movement);
      }
     if(keyCode == DOWN){
      moveObject(0,0,movement);
       }  
    }
}

void handleUIEvent(UIEventData uied){

  uied.print(1);
    
    if(uied.eventIsFromWidget("reset") ){
      mover1.location = new PVector(400, 400, 0);
      mover1.velocity.x = 0;
      mover1.velocity.y = 0;
      mover1.velocity.z = 0;
      mover2.location = new PVector(600, 400, 0);      
      mover2.velocity.x = 0;
      mover2.velocity.y = 0;
      mover2.velocity.z = 0;
      mover3.location = new PVector(200, 400, 0);      
      mover3.velocity.x = 0;
      mover3.velocity.y = 0;
      mover3.velocity.z = 0;
      mover4.location = new PVector(400, 600, 0);
      mover4.velocity.x = 0;
      mover4.velocity.y = 0;
      mover4.velocity.z = 0;
      mover5.location = new PVector(400, 200, 0);  
      mover5.velocity.x = 0;
      mover5.velocity.y = 0;
      mover5.velocity.z = 0;
      mover6.location = new PVector(400, 400, 50);  
      mover6.velocity.x = 0;
      mover6.velocity.y = 0;
      mover6.velocity.z = 0;           
      mover7.location = new PVector(400, 400, -50);  
      mover7.velocity.x = 0;
      mover7.velocity.y = 0;
      mover7.velocity.z = 0;          
    }    
}

void moveObject(float x, float y, float z){
  ball1.setTransformRel( 1, 0,0,0, vec(x,y,z));
}

void showCollisions(){
  
  stroke(255,255,255);
  fill(255,0,0);

  if( mover1.collisionCheck(mover2) ){
    mover1.collisionResponse(mover2);
    mover1.colour = new PVector(colorx,colory,colorz);
    mover2.colour = new PVector(colorx,colory,colorz);  
    score++;
  }
  
    if( mover1.collisionCheck(mover3) ){
    mover1.collisionResponse(mover3);
    mover1.colour = new PVector(colorx1,colory1,colorz1);
    mover3.colour = new PVector(colorx1,colory1,colorz1); 
        score++;
  }

  if( mover1.collisionCheck(mover4) ){
    mover1.collisionResponse(mover4);
    mover1.colour = new PVector(colorx2,colory2,colorz2);
    mover4.colour = new PVector(colorx2,colory2,colorz2);     
    score++;
  }
  
  if( mover1.collisionCheck(mover5) ){
    mover1.collisionResponse(mover5);
    mover1.colour = new PVector(colorx3,colory3,colorz3);
    mover5.colour = new PVector(colorx3,colory3,colorz3);    
    score++;
  }
  
  if( mover1.collisionCheck(mover6) ){
    mover1.collisionResponse(mover6);
    mover1.colour = new PVector(colorx4,colory4,colorz4);
    mover6.colour = new PVector(colorx4,colory4,colorz4);   
    score++;
  }
  
  if( mover1.collisionCheck(mover7) ){
    mover1.collisionResponse(mover7);
    mover1.colour = new PVector(colorx5,colory5,colorz5);
    mover7.colour = new PVector(colorx5,colory5,colorz5);      
    score++;
  }  
  
  if( mover2.collisionCheck(mover3) ){
    mover2.collisionResponse(mover3);
  }    
  
  if( mover2.collisionCheck(mover4) ){
    mover2.collisionResponse(mover4);
  }  
  
  if( mover2.collisionCheck(mover5) ){
    mover2.collisionResponse(mover5);
  }
  
  if( mover2.collisionCheck(mover6) ){
    mover2.collisionResponse(mover6);
  }  
  
  if( mover2.collisionCheck(mover7) ){
    mover2.collisionResponse(mover7);
  }

  if( mover3.collisionCheck(mover4) ){
    mover3.collisionResponse(mover4);
  }
  
  if( mover3.collisionCheck(mover5) ){
    mover3.collisionResponse(mover5);
  }  
  
  if( mover3.collisionCheck(mover6) ){
    mover3.collisionResponse(mover4);
  }
  
  if( mover3.collisionCheck(mover7) ){
    mover3.collisionResponse(mover5);
  }  
  
  if( mover4.collisionCheck(mover5) ){
    mover4.collisionResponse(mover5);
  }  
  
  if( mover4.collisionCheck(mover6) ){
    mover4.collisionResponse(mover6);
  }     
  
  if( mover4.collisionCheck(mover7) ){
    mover4.collisionResponse(mover7);
  }    
  
  if( mover5.collisionCheck(mover6) ){
    mover5.collisionResponse(mover6);
  }     
  
  if( mover5.collisionCheck(mover7) ){
    mover5.collisionResponse(mover7);
  }  
  
  if( mover6.collisionCheck(mover7) ){
    mover6.collisionResponse(mover7);
  }    
}
