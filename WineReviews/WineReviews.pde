// Visualization of 130,000 reviews in Wine Enthusiast database
// Shawn Ban
// 10 March, 2018

// Initialize variables:
Table wineTable;  
Table latLongTable;
String[] wineWords;
PImage mapImage, rightArrow, leftArrow;  

int nGrapes, currentNumber;
int bgCount = 0;

ArrayList <Grape> grapes = new ArrayList<Grape>();
Grape grape; 
String currentGrape, currentColour;
float grapePoints, grapePrice;

float minCount = MAX_FLOAT;
float maxCount = MIN_FLOAT;
float maxRelFreq = MIN_FLOAT;

PFont f1, f2, f3;

// Set-up:
void setup() {
  size(1400,810);
  mapImage = loadImage("worldCountries.png");
  rightArrow = loadImage("rightarrow.png");
  leftArrow = loadImage("leftarrow.png");
  f1 = createFont("Gotham Narrow Bold.otf", 30); //Headers 
  f2 = createFont("Gotham Narrow Book.otf", 24); //Instructions
  f3 = createFont("Futura.ttc", 11.5); //Small text
  wineTable = loadTable("wine_clean.csv", "header,csv");
  latLongTable = loadTable("latlong.csv", "header,csv");
  wineWords = loadStrings("words.csv");
  nGrapes = wineTable.getRowCount();
  getMinMax();
}

void draw() {
  if (bgCount == 0) {
    drawBackgroundOne();
  } else {
    drawBackgroundTwo();
  }
}

//Methods

//Toggles background:
void mouseClicked() {
  
  if (bgCount == 1) {
    for (int i=0; i< nGrapes; i++) {
      if (grapes.get(i).isOver()) {
        currentGrape = wineTable.getString(i,"variety");
        currentColour = wineTable.getString(i, "colour");
        currentNumber = i;
        grapePoints = wineTable.getFloat(i, "points");
        grapePrice = wineTable.getFloat(i, "price");
      } 
    }
    if (dist(45,height/2+25, mouseX, mouseY) < 25) {
      bgCount++;
    }
  } else {
    if (dist(width-75,height/2+25, mouseX, mouseY) < 25) {
      bgCount++;
    }
  }
  bgCount = bgCount % 2;
}

//Gets the minimum and maximum for a couple of values:
void getMinMax() {
  for (int i=0; i<nGrapes; i++) {
    minCount = min(minCount,wineTable.getFloat(i,"n"));
    maxCount = max(maxCount,wineTable.getFloat(i,"n"));
    for (int j=0; j < 40; j++) {
      maxRelFreq = max(maxRelFreq,wineTable.getFloat(i,j+19));   
    }  
  }

}

//Draws first background:
void drawBackgroundOne() {
    background(18);
    cursor(ARROW);
    fill(255);
    noStroke();
    textFont(f1);
    textAlign(CENTER);
    text("Most Common Words in Wine Reviews by Variety", width/2, 30);
    textFont(f3);
    textSize(12);
    textAlign(RIGHT);
    float ystart = 110; //move table up or down
    float xstart = 200; //move table left or right
    
    for (int i=0; i < nGrapes; i++) {
      String varietyName = wineTable.getString(i,"variety");
      String wineColour = wineTable.getString(i, "colour");
      fill(200);
      text(varietyName, 180, 17*i+ystart+3); 
      if (wineColour.equals("red")) {
        fill(160,10,10);
      } else {
        fill(255,250,205);
      }
      
      for (int j=0; j < 40; j++) {
        float relFreq = wineTable.getFloat(i, j+19);
        float pointSize = map(relFreq,0,maxRelFreq,0,55);
        ellipse(j*27+xstart, 17*i+ystart, pointSize/2, pointSize/2);    
      }  
   }
   
   textAlign(LEFT);
   fill(200);
   for (int j=0; j < 40; j++) {
     pushMatrix();
     translate(j*27+xstart+3, ystart-20);
     rotate(0.7-HALF_PI);
     text(wineWords[j+1], 0, 0);
     popMatrix(); 
   }
   textAlign(RIGHT);
   text("Data from 130,000 reviews in Wine Enthusiast database. Word frequency normalized by row.", width-130, height-10);
   image(rightArrow,width-100,height/2,50,50); 
}

//Draws second background:
void drawBackgroundTwo() {
    float minPrice = 10;
    float maxPrice = 75;
    float minPoints = 85.5;
    float maxPoints = 91;    
    float plotX1 = width/2+110;
    float plotX2 = width-40;
    float plotY1 = height/2+10;
    float plotY2 = height-90;
    int[] xlabels = {10, 20, 30, 40, 50, 60, 70};
    int[] ylabels = {86, 87, 88, 89, 90, 91};
    
    background(18);
    cursor(CROSS);
    
    image(leftArrow,20,height/2,50,50); 
    textAlign(CENTER,CENTER);
    fill(255);   
    rectMode(CORNERS);
    noStroke();
    rect(plotX1, plotY1, plotX2, plotY2);
    textFont(f3);
    textSize(14);
    fill(200);
    text("Price", (plotX1+plotX2)/2, plotY2+30);
    pushMatrix();
    translate(plotX1-40, (plotY1+plotY2)/2);
    rotate(-HALF_PI);
    text("Rating", 0,0);
    popMatrix(); 
    textSize(12);
    
    //Draws base plot with labels:
    stroke(200);
    strokeWeight(1);
    for (int i=0; i<7; i++) {
      float xPos = map(xlabels[i], minPrice, maxPrice, plotX1, plotX2);
      text(xlabels[i], xPos, plotY2+15);
      line(xPos, plotY2, xPos, plotY2+3);
    }
    for (int i=0; i<6; i++) {
      float yPos = map(ylabels[i], minPoints, maxPoints, plotY2, plotY1);
      text(ylabels[i], plotX1-15, yPos);
      line(plotX1-3, yPos, plotX1, yPos);
    }
    
    noStroke();
    for (int i=0; i < nGrapes; i++) {
      float winePoints = wineTable.getFloat(i, "points");
      float winePrice = wineTable.getFloat(i, "price");
      float pointX = map(winePrice, minPrice, maxPrice, plotX1, plotX2);
      float pointY = map(winePoints, minPoints, maxPoints, plotY2, plotY1);
      ellipse(pointX, pointY, 7, 7);
    }
    
    //Draws text and coloured points:
    if (currentGrape == null) {
      fill(200);
      textFont(f1);
      text("Click on a grape to learn more!", width/2, 40);
    } else {
      if (currentColour.equals("red")) {
        fill(178,34,34);
      } else {
        stroke(0);
        strokeWeight(1);
        fill(255,255,150);
      }
      float currentPoints = wineTable.getFloat(currentNumber, "points");
      float currentPrice = wineTable.getFloat(currentNumber, "price");
      float currentX = map(currentPrice, minPrice, maxPrice, plotX1, plotX2);
      float currentY = map(currentPoints, minPoints, maxPoints, plotY2, plotY1);
      ellipse(currentX, currentY, 15, 15);  
      noStroke();
      textFont(f1);
      text("You've selected " + currentGrape.toUpperCase() + ":", width/2, 40);
      fill(200);
      textFont(f2);
      text("Choose another grape or click the left arrow to return.", width*0.3, plotY2+60);
      text("Average Rating: " + nf(grapePoints, 2, 1) + "    Average Price: $" + nf(grapePrice, 2, 1), 0.77*width, plotY2+60);
    }
    drawNavigationBar();
    drawMap();
    
}

void drawNavigationBar() {
  //Draws grapes for navigation:
  for (int i=0; i < nGrapes; i++) {
    String varietyName = wineTable.getString(i,"variety");
    String wineColour = wineTable.getString(i, "colour");
    float varietyCount = wineTable.getFloat(i, "n");
    float circleSize = map(varietyCount,minCount,maxCount,90,105);
    float r = wineTable.getFloat(i, "r")*0.95;
    float theta = radians(wineTable.getFloat(i, "theta"));
    float x = r * cos(theta);
    float y = r * sin(theta);
    grape = new Grape(x+0.3*width,y+height/2, circleSize, wineColour, varietyName, varietyCount); 
    grape.drawGrape();
    grapes.add(grape);
  }       
}

void drawMap() {
  image(mapImage,width/2+110,80,550,300); 
  if (currentGrape != null) {
    if (currentColour.equals("red")) {
        fill(178,34,34,80);
        stroke(180,10,10);
        strokeWeight(0.5);
    } else {
        fill(255,255,150,80);
        stroke(0);
        strokeWeight(0.5);
    }
    
    float maxCountry = MIN_FLOAT;
    for (int j=4; j < 16; j++) {
        maxCountry = max(maxCountry,wineTable.getFloat(currentNumber,j));   
    }  
    
    for (int k=0; k < 12; k++) {
      float wineCount = wineTable.getFloat(currentNumber, k+4);
      float circleSize = map(wineCount,0,maxCountry,0,25);
      float latitude = latLongTable.getFloat(k, "latitude");
      float longitude = latLongTable.getFloat(k, "longitude");
      float x = map(longitude, -180, 180, width/2+110, width/2+660);
      float y = map(latitude, -60, 85, 380, 80);
      ellipse(x, y, circleSize, circleSize);
    }
    
    
    
  }
  
  
}