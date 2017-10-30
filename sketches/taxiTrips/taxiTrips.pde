/*
TransitFlow
https://github.com/transitland/transitland-processing-animation
Will Geary

Attribution:
Juan Francisco Saldarriaga's workshop on Processing: https://github.com/juanfrans-courses/DataScienceSocietyWorkshop
Till Nagel's Unfolding Maps library: http://unfoldingmaps.org/
*/

////// MAIN INPUTS ///////
String directoryName = "taxiTrips";
String inputFile = "yellow_2016_02_head.csv";
int totalFrames = 7200;
Location center = new Location(40.741014,-73.989830);
Integer zoom_start = 12;
String date_format = "M/d/yy";
String day_format = "EEEE";
String time_format = "h:mm a";
boolean recording = false;
boolean HQ = false;
///////////////////////////

// Import Unfolding Maps
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.mapdisplay.shaders.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.texture.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.ui.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.utils.*;

// Import some Java utilities
import java.util.Date;
import java.text.SimpleDateFormat;

// Import video export
import com.hamoid.*;
VideoExport videoExport;

// Declare Global Variables
UnfoldingMap map;
int totalSeconds;
Table tripTable;
ArrayList<Trips> trips = new ArrayList<Trips>();
ArrayList<String> vehicle_types = new ArrayList<String>();
Table vehicleCount;
IntList vehicleCounts;
int maxVehicleCount;
float hscale = float(totalFrames) / float(width)*0.075;

Table yellowCount;
ArrayList<Line> yellowLines = new ArrayList<Line>();
ArrayList<Integer> yellowFrames = new ArrayList<Integer>();
ArrayList<Integer> yellowCounts = new ArrayList<Integer>();
ArrayList<Float> yellowHeights = new ArrayList<Float>();

Table greenCount;
ArrayList<Line> greenLines = new ArrayList<Line>();
ArrayList<Integer> greenFrames = new ArrayList<Integer>();
ArrayList<Integer> greenCounts = new ArrayList<Integer>();
ArrayList<Float> greenHeights = new ArrayList<Float>();

Table fhvCount;
ArrayList<Line> fhvLines = new ArrayList<Line>();
ArrayList<Integer> fhvFrames = new ArrayList<Integer>();
ArrayList<Integer> fhvCounts = new ArrayList<Integer>();
ArrayList<Float> fhvHeights = new ArrayList<Float>();

ScreenPosition startPos;
ScreenPosition endPos;
Location startLocation;
Location endLocation;
Date minDate;
Date maxDate;
Date startDate;
Date endDate;
Date thisStartDate;
Date thisEndDate;
PImage clock;
PImage calendar;
PImage airport;
PFont raleway;
PFont ralewayBold;
Integer screenfillalpha = 120;
Float firstLat;
Float firstLon;
color c;

// define date format of raw data
SimpleDateFormat myDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
SimpleDateFormat hour = new SimpleDateFormat("h:mm a");
SimpleDateFormat weekday = new SimpleDateFormat("EEEE");

// Basemap providers
AbstractMapProvider provider1;
AbstractMapProvider provider2;
AbstractMapProvider provider3;
AbstractMapProvider provider4;
AbstractMapProvider provider5;
AbstractMapProvider provider6;
AbstractMapProvider provider7;
AbstractMapProvider provider8;
AbstractMapProvider provider9;
AbstractMapProvider provider0;
AbstractMapProvider providerq;
AbstractMapProvider providerw;
AbstractMapProvider providere;
AbstractMapProvider providerr;
AbstractMapProvider providert;
AbstractMapProvider providery;
AbstractMapProvider provideru;
AbstractMapProvider provideri;
String provider1Attrib;
String provider2Attrib;
String provider3Attrib;
String provider4Attrib;
String provider5Attrib;
String provider6Attrib;
String provider7Attrib;
String provider8Attrib;
String provider9Attrib;
String provider0Attrib;
String providerqAttrib;
String providerwAttrib;
String providereAttrib;
String providerrAttrib;
String providertAttrib;
String provideryAttrib;
String provideruAttrib;
String attrib;
Float attribWidth;

void setup() {
  size(1400, 1000, P3D);
  provider1 = new StamenMapProvider.TonerLite();
  provider2 = new StamenMapProvider.TonerBackground();
  provider3 = new CartoDB.Positron();
  provider4 = new Microsoft.AerialProvider();
  provider5 = new OpenStreetMap.OpenStreetMapProvider();
  provider6 = new OpenStreetMap.OSMGrayProvider();
  provider7 = new EsriProvider.WorldStreetMap();
  provider8 = new EsriProvider.DeLorme();
  provider9 = new EsriProvider.WorldShadedRelief();
  provider0 = new EsriProvider.NatGeoWorldMap();
  providerq = new EsriProvider.OceanBasemap();
  providerw = new EsriProvider.WorldGrayCanvas();
  providere = new EsriProvider.WorldPhysical();
  providerr = new EsriProvider.WorldStreetMap();
  providert = new EsriProvider.WorldTerrain();
  providery = new EsriProvider.WorldTopoMap();
  provideru = new Google.GoogleMapProvider();

  provider1Attrib = "Stamen Design";
  provider2Attrib = "Stamen Design";
  provider3Attrib = "Carto";
  provider4Attrib = "Bing Maps";
  provider5Attrib = "OpenStreetMap";
  provider6Attrib = "OpenStreetMap";
  provider7Attrib = "ESRI";
  provider8Attrib = "ESRI";
  provider9Attrib = "ESRI";
  provider0Attrib = "ESRI";
  providerqAttrib = "ESRI";
  providerwAttrib = "ESRI";
  providereAttrib = "ESRI";
  providerrAttrib = "ESRI";
  providertAttrib = "ESRI";
  provideryAttrib = "ESRI";
  provideruAttrib = "Google Maps";

  smooth();

  loadData();

  map = new UnfoldingMap(this, provider1);
  MapUtils.createDefaultEventDispatcher(this, map);

  attrib = "© Mapzen | Transitland | Unfolding Maps | Basemap by " + provider1Attrib;
  attribWidth = textWidth(attrib);

  map.zoomAndPanTo(zoom_start, center);

  // Fonts and icons
  raleway  = createFont("Raleway-Heavy", 32);
  ralewayBold  = createFont("Raleway-Bold", 28);
  clock = loadImage("clock_icon.png");
  clock.resize(0, 35);
  calendar = loadImage("calendar_icon.png");
  calendar.resize(0, 35);

  videoExport = new VideoExport(this);
  videoExport.setFrameRate(60);
  if (recording == true) videoExport.startMovie(); 
}

float h_offset;

void loadData() {
  tripTable = loadTable(inputFile, "header");
  println(str(tripTable.getRowCount()) + " records loaded...");

  // calculate min start time and max end time (must be sorted ascending)
  String first = tripTable.getString(0, "start_time");
  String last = tripTable.getString(tripTable.getRowCount()-1, "end_time");

  println("Min departure time: ", first);
  println("Max departure time: ", last);

  try {
    minDate = myDateFormat.parse(first); //first "2017-07-17 9:59:00"
    maxDate = myDateFormat.parse(last); //last
    totalSeconds = int(maxDate.getTime()/1000) - int(minDate.getTime()/1000);
  }
  catch (Exception e) {
    println("Unable to parse date stamp");
  }
  println("Min starttime:", minDate, ". In epoch:", minDate.getTime()/1000);
  println("Max starttime:", maxDate, ". In epoch:", maxDate.getTime()/1000);
  println("Total seconds in dataset:", totalSeconds);
  println("Total frames:", totalFrames);

  firstLat = tripTable.getFloat(0, "start_lat");
  firstLon = tripTable.getFloat(0, "start_lon");

  for (TableRow row : tripTable.rows()) {
    String vehicle_type = row.getString("vehicle_type");
    vehicle_types.add(vehicle_type);

    //Float bearing = row.getFloat("bearing");
    //bearings.add(bearing);

    int tripduration = row.getInt("duration");
    int duration = round(map(tripduration, 0, totalSeconds, 0, totalFrames));

    try {
      thisStartDate = myDateFormat.parse(row.getString("start_time"));
      thisEndDate = myDateFormat.parse(row.getString("end_time"));
    }
    catch (Exception e) {
      println("Unable to parse destination");
    }

    int startFrame = floor(map(thisStartDate.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, totalFrames));
    int endFrame = floor(map(thisEndDate.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, totalFrames));

    float startLat = row.getFloat("start_lat");
    float startLon = row.getFloat("start_lon");
    float endLat = row.getFloat("end_lat");
    float endLon = row.getFloat("end_lon");
    startLocation = new Location(startLat, startLon);
    endLocation = new Location(endLat, endLon);
    trips.add(new Trips(duration, startFrame, endFrame, startLocation, endLocation));
  }
  
  int lineAlpha = 80;
  
  // total vehicle counts
  //vehicleCount = loadTable(vehicleCountFile, "header");
  //vehicleCounts = new IntList();
  //for (int i = 0; i < vehicleCount.getRowCount(); i++) {
  //  TableRow row = vehicleCount.getRow(i);
  //  int count = row.getInt("count");
  //  vehicleCounts.append(count);
  //}
  //maxVehicleCount = int(vehicleCounts.max());
  //println("Max vehicles on road: " + maxVehicleCount);

  // maximum height of stacked bar chart in pixels
  int maxPixels = 140;
}


void draw() {

  if (frameCount < totalFrames) {
    map.draw();
    noStroke();
    fill(0, screenfillalpha);
    rect(0, 0, width, height);

    // handle time
    float epoch_float = map(frameCount, 0, totalFrames, int(minDate.getTime()/1000), int(maxDate.getTime()/1000));
    int epoch = int(epoch_float);

    String date = new java.text.SimpleDateFormat(date_format).format(new java.util.Date(epoch * 1000L));
    String day = new java.text.SimpleDateFormat(day_format).format(new java.util.Date(epoch * 1000L));
    String time = new java.text.SimpleDateFormat(time_format).format(new java.util.Date(epoch * 1000L));

    // draw trips
    noStroke();
    for (int i=0; i < trips.size(); i++) {

      Trips trip = trips.get(i);
      String vehicle_type = vehicle_types.get(i);

      switch(vehicle_type) {
      case "yellow":
        c = color(255, 255, 0);
        fill(c, 240);
        trip.plotRide();
        break;
      case "green":
        c = color(0, 255, 0);
        fill(c, 240);
        trip.plotRide();
        break;
      case("flight"):
        c = color(0, 173, 253);
        fill(c, 245);
        trip.plotFlight();
        break;
      }
    }
    
    // Time and icons
    textSize(32);
    fill(255, 255, 255, 255);
    image(clock, 30, 25);
    stroke(255, 255, 255, 255);
    line(30, 70, 210, 70);
    image(calendar, 30, 80 );

    textFont(raleway);
    noStroke();
    text(time, 75, 55);
    textFont(ralewayBold);
    
    text(day, 75, 107);
  
    textSize(16);
    text(date, 75, 128);

    textSize(12);
    text(attrib, width-(attribWidth+5), height-5);

    if (recording == true) {
      if (frameCount < totalFrames) {
        if (HQ == true) {
          saveFrame("frames/######.tiff");
        } else if (HQ == false) {
          videoExport.saveFrame();
          return;
        }
      } else {
        if (HQ == true) exit();
        if (HQ == false) videoExport.endMovie();
        exit();
      }
    }
  }
}

void keyPressed() {
  if (key == '1') {
    map.mapDisplay.setProvider(provider1);
    textFont(ralewayBold, 16);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + provider1Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '2') {
    map.mapDisplay.setProvider(provider2);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + provider2Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '3') {
    map.mapDisplay.setProvider(provider3);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + provider3Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '4') {
    map.mapDisplay.setProvider(provider4);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + provider4Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '5') {
    map.mapDisplay.setProvider(provider5);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + provider5Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '6') {
    map.mapDisplay.setProvider(provider6);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + provider6Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '7') {
    map.mapDisplay.setProvider(provider7);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + provider7Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '8') {
    map.mapDisplay.setProvider(provider8);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + provider8Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '9') {
    map.mapDisplay.setProvider(provider9);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + provider9Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '0') {
    map.mapDisplay.setProvider(provider0);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + provider0Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == 'q') {
    map.mapDisplay.setProvider(providerq);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + providerqAttrib;
    attribWidth = textWidth(attrib);
  } else if (key == 'w') {
    map.mapDisplay.setProvider(providerw);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + providerwAttrib;
    attribWidth = textWidth(attrib);
  } else if (key == 'e') {
    map.mapDisplay.setProvider(providere);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + providereAttrib;
    attribWidth = textWidth(attrib);
  } else if (key == 'r') {
    map.mapDisplay.setProvider(providerr);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + providerrAttrib;
    attribWidth = textWidth(attrib);
  } else if (key == 't') {
    map.mapDisplay.setProvider(providert);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + providertAttrib;
    attribWidth = textWidth(attrib);
  } else if (key == 'y') {
    map.mapDisplay.setProvider(providery);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + provideryAttrib;
    attribWidth = textWidth(attrib);
  } else if (key == 'u') {
    map.mapDisplay.setProvider(provideru);
    attrib = "© Mapzen | Transitland | Unfolding Maps | " + provideruAttrib;
    attribWidth = textWidth(attrib);
  }
}

class Line {
  float startx, starty, endx, endy;
  color c;
  Line(float _startx, float _starty, float _endx, float _endy, color _c) {
    startx = _startx;
    starty = _starty;
    endx = _endx;
    endy = _endy;
    c = _c;
  }
  void plot() {

    strokeWeight(0.7);
    stroke(c);
    line(startx, starty, endx, endy);
  }
}


class Trips {

 int tripFrames;
 int startFrame;
 int endFrame;
 Location start;
 Location end;
 Location currentLocation;
 ScreenPosition currentPosition;
 int s;
 float bearing;
 float radians;
 float xscale = 1.8;
 float yscale = 0.8;

 // class constructor
 Trips(int duration, int start_frame, int end_frame, Location startLocation, Location endLocation) {
       tripFrames = duration;
       startFrame = start_frame;
       endFrame = end_frame;
       start = startLocation;
       end = endLocation;
     }

   // function to draw each trip
   void plotRide(){
     if (frameCount >= startFrame && frameCount < endFrame){
       float percentTravelled = (float(frameCount) - float(startFrame)) / float(tripFrames);

       currentLocation = new Location(

         lerp(start.x, end.x, percentTravelled),
         lerp(start.y, end.y, percentTravelled));

       currentPosition = map.getScreenPosition(currentLocation);

       // Zoom dependent ellipse size
       float z = map.getZoom();
       if (z <= 32.0){ s = 2;
       } else if (z == 64.0){ s = 1;
       } else if (z == 128.0){ s = 1;
       } else if (z == 256.0){ s = 1;
       } else if (z == 512.0){ s = 2;
       } else if (z == 1024.0){ s = 3;
       } else if (z == 2048.0){ s = 4;
       } else if (z == 4096.0){ s = 5;
       } else if (z == 8192.0){ s = 6;
       } else if (z >= 16384.0){ s = 7;
       }
       ellipse(currentPosition.x, currentPosition.y, s, s);
    }
  }
  
  void plotFlight(){
     if (frameCount >= startFrame && frameCount < endFrame){
       float percentTravelled = (float(frameCount) - float(startFrame)) / float(tripFrames);

       currentLocation = new Location(

         lerp(start.x, end.x, percentTravelled),
         lerp(start.y, end.y, percentTravelled));

       currentPosition = map.getScreenPosition(currentLocation);

       // Zoom dependent ellipse size
       float z = map.getZoom();
       if (z <= 32.0){ s = 10;
       } else if (z == 64.0){ s = 10;
       } else if (z == 128.0){ s = 10;
       } else if (z == 256.0){ s = 10;
       } else if (z == 512.0){ s = 10;
       } else if (z == 1024.0){ s = 10;
       } else if (z == 2048.0){ s = 10;
       } else if (z == 4096.0){ s = 11;
       } else if (z == 8192.0){ s = 12;
       } else if (z >= 16384.0){ s = 13;
       }
       ellipse(currentPosition.x, currentPosition.y, s, s);
    }
  }
}
  