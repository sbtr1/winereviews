// Visualization of 130,000 reviews in Wine Enthusiast database
// Shawn Ban
// 4 April, 2018

//Import Geomap:
import org.gicentre.geomap.*;

// Initialize variables:
Table wineTable, countryTable;
String[] wineWords;
PImage rightArrow, leftArrow;
GeoMap geoMap;
color maxRed, maxYellow;

ArrayList <Grape> grapes = new ArrayList<Grape>();
Grape grape; 
String currentGrape, currentColour;
float grapePoints, grapePrice;

int nGrapes, currentNumber;
int bgCount = 0;

float minCount = MAX_FLOAT;
float maxCount = MIN_FLOAT;
float maxRelFreq = MIN_FLOAT;

PFont f1, f2;

// Set-up:
void setup() {
  size(1400,810);
  rightArrow = loadImage("rightarrow.png");
  leftArrow = loadImage("leftarrow.png");
  f1 = loadFont("Futura-Medium-36.vlw"); //Headers
  f2 = loadFont("Futura-Medium-12.vlw"); //Small text
  wineTable = loadTable("wine_clean.csv", "header,csv");
  countryTable = loadTable("country_by_wine.csv", "header,csv");
  wineWords = loadStrings("words.csv");
  nGrapes = wineTable.getRowCount();
  geoMap = new GeoMap(width/2+110,80,550,300, this);
  geoMap.readFile("world");
  maxRed = color(178, 34, 34);    // Dark red.
  maxYellow = color(255, 200, 0);    // Dark yellow.
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


//Draws first background:
void drawBackgroundOne() {
    background(18);
    cursor(ARROW);
    fill(225);
    noStroke();
    textFont(f1);
    textAlign(CENTER);
    text("Most Common Words in Wine Reviews by Variety", width/2, 35);
    textFont(f2);
    textSize(12.5);
    textAlign(RIGHT);
    float ystart = 115; //move table up or down
    float xstart = 200; //move table left or right
    
    for (int i=0; i < nGrapes; i++) {
      String varietyName = wineTable.getString(i,"variety");
      String wineColour = wineTable.getString(i, "colour");
      fill(200);
      text(varietyName, 180, 17*i+ystart+3); 
      if (wineColour.equals("red")) {
        fill(160,10,10);
      } else {
        fill(255,225,180);
      }
      
      for (int j=0; j < 40; j++) {
        float relFreq = wineTable.getFloat(i, j+7);
        float pointSize = map(relFreq,0,maxRelFreq,0,200);
        pointSize = pow(pointSize,0.6); //Exponent of 0.6 for perception.
        ellipse(j*27+xstart, 17*i+ystart, pointSize, pointSize);    
      }  
   }
   
   textAlign(LEFT);
   fill(200);
   textSize(13.5);
   for (int j=0; j < 40; j++) {
     pushMatrix();
     translate(j*27+xstart+3, ystart-15);
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
    background(18);
    cursor(CROSS);  
    image(leftArrow,20,height/2,50,50); 
    drawNavigationBar();
    if (currentGrape == null) {
      fill(225);
      textFont(f1);
      textAlign(CENTER,CENTER);
      text("Click on a grape to learn more!", width/2, 35);
    } else {
      drawScatterPlot();
      drawMap();
    }
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
  float maxCountry = MIN_FLOAT;
  
  fill(255);   
  rectMode(CORNERS);
  noStroke();
  rect(width/2+110, 80, width-40, 380);
  stroke(255);
  strokeWeight(0.2);
  
  for (int j=0; j < 12; j++) {
    maxCountry = max(maxCountry,countryTable.getFloat(j, currentNumber+1));   
  }      
  
  for (int id : geoMap.getFeatures().keySet()) {
    String countryCode = geoMap.getAttributeTable().findRow(str(id),0).getString("ISO_A3");    
    TableRow dataRow = countryTable.findRow(countryCode, 0);
    if (dataRow != null) {
      float grapeInCountry = log(dataRow.getFloat(currentNumber+1))/log(maxCountry); //Apply log transform to reduce skew.
      if (currentColour.equals("red")) {
        fill(lerpColor(color(225), maxRed, grapeInCountry));
      } else {
        fill(lerpColor(color(225), maxYellow, grapeInCountry));
      }
    } else {
      fill(225);
    }
    geoMap.draw(id);
  }
    
  fill(225);
  textFont(f1);
  textSize(20);
  text("Country of Origin", width*0.78, height*0.5-15);
}

void drawScatterPlot() {
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
    float regressLineY1 = 87.1;
    float regressLineY2 = 90.6;
  
    textAlign(CENTER,CENTER);
    fill(255);   
    rectMode(CORNERS);
    noStroke();
    rect(plotX1, plotY1, plotX2, plotY2);
    textFont(f2);
    textSize(14);
    fill(200);
    text("Price", (plotX1+plotX2)/2, plotY2+30);
    pushMatrix();
    translate(plotX1-40, (plotY1+plotY2)/2);
    rotate(-HALF_PI);
    text("Rating", 0,0);
    popMatrix(); 
    
    //Draw plot with labels:
    textSize(12);
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
    
    stroke(100);
    strokeWeight(0.5);
    float lineX1 = map(minPrice, minPrice, maxPrice, plotX1, plotX2);
    float lineX2 = map(maxPrice, minPrice, maxPrice, plotX1, plotX2);
    float lineY1 = map(regressLineY1, minPoints, maxPoints, plotY2, plotY1);
    float lineY2 = map(regressLineY2, minPoints, maxPoints, plotY2, plotY1);
    line(lineX1, lineY1, lineX2, lineY2);
    noStroke();
        
    if (currentColour.equals("red")) {
        fill(178,34,34);
      } else {
        stroke(0);
        strokeWeight(0.5);
        fill(255,225,180);
      }
      float currentPoints = wineTable.getFloat(currentNumber, "points");
      float currentPrice = wineTable.getFloat(currentNumber, "price");
      float currentX = map(currentPrice, minPrice, maxPrice, plotX1, plotX2);
      float currentY = map(currentPoints, minPoints, maxPoints, plotY2, plotY1);
      ellipse(currentX, currentY, 15, 15);  
      
      noStroke();
      textFont(f1);
      text("You've selected " + currentGrape.toUpperCase() + ":", width/2, 35);
      fill(225);
      textFont(f1);
      textSize(20);
      text("Choose another grape or click the left arrow to return.", width*0.3, plotY2+60);
      text("Average Rating: " + nf(grapePoints, 2, 1) + "    Average Price: $" + nf(grapePrice, 2, 1), 0.77*width, plotY2+60);
}

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
      maxRelFreq = max(maxRelFreq,wineTable.getFloat(i,j+7));   
    }  
  }
}
