// Visualization of 130,000 reviews in Wine Enthusiast database
// Shawn Ban
// 10 March, 2018

// Used R to sort by variety and find the word count
// Processing sketch takes a clean csv file with data and other csv file with the word labels

// Initialize variables:
Table wineTable;  
String[] wineWords;
PImage mapImage;  

int nGrapes;
int bgCount = 0;

ArrayList <Grape> grapes = new ArrayList<Grape>();
Grape grape; 
String currentGrape, currentColour;
float grapePoints, grapePrice;

float minCount = MAX_FLOAT;
float minPrice = MAX_FLOAT;
float minPoints = MAX_FLOAT;
float maxCount = MIN_FLOAT;
float maxPrice = MIN_FLOAT;
float maxPoints = MIN_FLOAT;

PFont f1, f2, f3;

// Set-up:
void setup() {
  size(1400,800);
  frameRate(15);
  noStroke();
  mapImage = loadImage("worldCountries.png");
  f1 = createFont("Futura.ttc", 11.5);
  f2 = createFont("Gotham Narrow Book.otf", 24);
  f3 = createFont("Gotham Narrow Bold.otf", 30); 
  wineTable = loadTable("wine_clean.csv", "header,csv");
  wineWords = loadStrings("topwords.csv");
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
        grapePoints = wineTable.getFloat(i, "points");
        grapePrice = wineTable.getFloat(i, "price");
        bgCount--;
      } 
    }
  } 
  bgCount++;
  bgCount = bgCount % 2;
}

//Gets the minimum and maximum for a couple of values:
void getMinMax() {
  for (int i=0; i<nGrapes; i++) {
    minCount = min(minCount,wineTable.getFloat(i,"n"));
    maxCount = max(maxCount,wineTable.getFloat(i,"n"));
    minPrice = min(minPrice,wineTable.getFloat(i,"price"));
    maxPrice = max(maxPrice,wineTable.getFloat(i,"price"));
    minPoints = min(minPoints,wineTable.getFloat(i,"points"));
    maxPoints = max(maxPoints,wineTable.getFloat(i,"points"));    
  }
}

//Draws first background:
void drawBackgroundOne() {
  background(18);
    cursor(ARROW);
    fill(255);
    textFont(f2);
    textAlign(CENTER);
    text("Most frequent words in 130,000 wine reviews by variety. Click anywhere to continue!", width/2, height-15);
    textFont(f1);
    textSize(11.5);
    textAlign(RIGHT);
    float ystart = 82; //move table up or down
    float xstart = 200; //move table left or right
    
    for (int i=0; i < nGrapes; i++) {
      String varietyName = wineTable.getString(i,"variety");
      String wineColour = wineTable.getString(i, "colour");
      fill(200);
      text(varietyName, 180, 17*i+ystart+3); 
      if (wineColour.equals("red")) {
        fill(144,10,10);
      } else {
        fill(248,253,183);
      }
      
      //Normalizes the bubbles by row:
      float maxRelFreq = MIN_FLOAT;      
      for (int j=0; j < 40; j++) {
        maxRelFreq = max(maxRelFreq,wineTable.getFloat(i,j+19));   
      }  
      
      for (int j=0; j < 40; j++) {
        float relFreq = wineTable.getFloat(i, j+19);
        float pointSize = map(relFreq,0,maxRelFreq,0,35);
        ellipse(j*27+xstart, 17*i+ystart, pointSize/2, pointSize/2);    
      }  
   }
   textFont(f1);
   textAlign(LEFT);
   fill(200);
   for (int j=0; j < 40; j++) {
     pushMatrix();
     translate(j*27+xstart+3, ystart-20);
     rotate(0.6-HALF_PI);
     text(wineWords[j+1], 0, 0);
     popMatrix(); 
   }  
}

//Draws second background:
void drawBackgroundTwo() {
    float plotX1, plotX2, plotY1, plotY2;
    plotX1 = width/2+100;
    plotX2 = width-50;
    plotY1 = height/2+50;
    plotY2 = height-100;
    
    background(18);
    cursor(CROSS);
    textAlign(CENTER);
    
    if (currentGrape == null) {
      fill(150);
      textFont(f2);
      text("Click on a grape to learn more!", width/2, 50);
    } else {
      if (currentColour.equals("red")) {
        fill(144,10,10);
      } else {
        fill(248,253,183);
      }
      textFont(f3);
      text("You've selected " + currentGrape.toUpperCase() + ":", width/2, 50);
      fill(150);
      textFont(f2);
      text("Choose another grape or click anywhere else to return.", width*0.27, plotY2+60);
      text("Average Rating: " + nf(grapePoints, 2, 1), 0.77*width, plotY2+50);
      text("Average Price: $" + nf(grapePrice, 2, 1), 0.77*width, plotY2+85);
    }
    
    textFont(f1);
    textSize(16);   
    text("Price", plotX2, plotY2+22);
    text("Rating", plotX1, plotY1-10);
    stroke(150);
    strokeWeight(1);
    line(plotX1, plotY2, plotX2, plotY2);
    line(plotX1, plotY1, plotX1, plotY2);
    noStroke();
    fill(100);
    
    for (int i=0; i < nGrapes; i++) {
      float winePoints = wineTable.getFloat(i, "points");
      float winePrice = wineTable.getFloat(i, "price");
      float pointX = map(winePrice, minPrice, maxPrice, plotX1+20, plotX2-20);
      float pointY = map(winePoints, minPoints, maxPoints, plotY2-20, plotY1+20);
      ellipse(pointX, pointY, 7, 7);
    }
    
    for (int i=0; i < nGrapes; i++) {
      String varietyName = wineTable.getString(i,"variety");
      String wineColour = wineTable.getString(i, "colour");
      float varietyCount = wineTable.getFloat(i, "n");
      float circleSize = map(varietyCount,minCount,maxCount,80,105);
      float r = wineTable.getFloat(i, "r")*0.9;
      float theta = radians(wineTable.getFloat(i, "theta"));
      float x = r * cos(theta);
      float y = r * sin(theta);
      grape = new Grape(x+0.27*width,y+height/2, circleSize, wineColour, varietyName, varietyCount); 
      grape.drawGrape();
      grapes.add(grape);
    }
    
    image(mapImage,plotX1,80,550,300);     
}