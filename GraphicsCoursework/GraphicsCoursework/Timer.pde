////////////////////////////////////////////
// Useful timer class. Returns time in 
// floating point seconds

class Timer{
  
  int startMillis = 0;
  float lastNow;
  public Timer(){
    start();
  }
  
  // call this to reset the timer
  void start(){
    startMillis = millis();
    
    lastNow = 0;
  }
  
  // returns the elapsed time since you last called this function
  // or since start() if it's the first time called
  float getElapsedTime(){
    float now =  getTimeSinceStart();
    float elapsedTime = now - lastNow;
    lastNow = now;
    return elapsedTime;
    
  }
  
  // call this to get the time since you called start() or 
  // instantiated the object
  float getTimeSinceStart(){
    return ((millis()-startMillis)/1000.0);
  }
  
  
}
