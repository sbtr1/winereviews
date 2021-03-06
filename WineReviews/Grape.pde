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
    } else {
      fill(255,225,180);
    }
    noStroke();
    ellipse(x,y,grapeSize,grapeSize);
    if (wineColour.equals("red")) {
      fill(255);
    } else {
      fill(0);
    }
    textFont(f2);
    textSize(11.7);
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
