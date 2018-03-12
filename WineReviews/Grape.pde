//Makes a bunch of grapes as a navigation bar

class Grape {
  //Members 
  float x, y, grapeSize, n; 
  String wineColour, name;
   
  //Constructor 
  Grape(float tempX, float tempY, float tempGrapeSize, String tempWineColour, String s, float varietyCount) {
    x = tempX;
    y = tempY;
    grapeSize = tempGrapeSize;
    wineColour = tempWineColour;
    name = s;
    n = varietyCount;
  }
 
  //Methods 
  void drawGrape() {
    if (wineColour.equals("red")) {
      fill(160,10,10);
      //fill(178,34,34);
    } else {
      fill(255,250,205);
      //fill(255,255,150);
    }
    strokeWeight(0);
    ellipse(x,y,grapeSize,grapeSize);
    if (wineColour.equals("red")) {
      fill(255);
    } else {
      fill(0);
    }
    textFont(f3);
    textSize(11);
    textAlign(CENTER);
    text(name + "\n" + nf(n) +" reviews", x, y); 
  }
  
  //Boolean to tell if grape is clicked: 
  boolean isOver() {
    if (dist(x, y, mouseX, mouseY) < grapeSize/2) {
      return true;
    } else {
      return false;
    }
  }
  
}