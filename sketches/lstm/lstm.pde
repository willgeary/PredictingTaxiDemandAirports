// Import some Java utilities
import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.Collections;


String inputFile = "lstm_results.csv";
boolean recording = true;
Table csvFile;
Date minDate;
Date maxDate;
Date time1;
Date time2;
int totalSeconds;
int totalFrames = 14400;
PFont raleway;
PFont ralewayBold;
PImage clock;
PImage calendar;

color orange = color(255,165,0);
color blue = color(0, 173, 253);

int hscale = 50;
int ymargbottom = 50;
int ymargtop = 180;


ArrayList<Float> predictions = new ArrayList<Float>();
ArrayList<Line> prediction_lines = new ArrayList<Line>();
ArrayList<Float> actuals = new ArrayList<Float>();
ArrayList<Line> actual_lines = new ArrayList<Line>();
ArrayList<String> pickup_times = new ArrayList<String>();
ArrayList<Integer> frames = new ArrayList<Integer>();
Date[] xdates = new Date[13];
String[] xlabels = new String[13];

SimpleDateFormat datetime = new SimpleDateFormat("yyyy-MM-dd HH:mm");
SimpleDateFormat hour = new SimpleDateFormat("h:mm a");
SimpleDateFormat day = new SimpleDateFormat("MMMM dd, yyyy");
SimpleDateFormat weekday = new SimpleDateFormat("EEEE");

// X Axis Labels



void setup(){
  size(1400,1000);
  frameRate(60);
  smooth();
  loadData();
  background(0);
  raleway  = createFont("Raleway-Heavy", 32);
  ralewayBold  = createFont("Raleway-Bold", 28);
  clock = loadImage("clock_icon.png");
  clock.resize(0, 35);
  calendar = loadImage("calendar_icon.png");
  calendar.resize(0, 35);
  
  String[] xlabels = {"January 1\n2017", "January 15", "February 1", "February 15",
                      "March 1", "March 15", "April 1", "April 15",
                     "May 1", "May 15", "June 1", "June 15", "June 30"};
                                          
    try {
    Date[] xdates = {datetime.parse("2017-01-01 00:00"),
                     datetime.parse("2017-01-15 00:00"),
                     datetime.parse("2017-02-01 00:00"),
                     datetime.parse("2017-02-15 00:00"),
                     datetime.parse("2017-03-01 00:00"),
                     datetime.parse("2017-03-15 00:00"),
                     datetime.parse("2017-04-01 00:00"),
                     datetime.parse("2017-04-15 00:00"),
                     datetime.parse("2017-05-01 00:00"),
                     datetime.parse("2017-05-15 00:00"),
                     datetime.parse("2017-06-01 00:00"),
                     datetime.parse("2017-06-15 00:00"),
                     datetime.parse("2017-06-30 00:00")};
    } catch (Exception e) {
      println("error parsing dates");
    }
}

void loadData(){
  csvFile = loadTable(inputFile, "header");
  println(str(csvFile.getRowCount()) + " records loaded...");
  
  // calculate min start time and max end time (must be sorted ascending)
  String first = csvFile.getString(0, "pickup_time");
  String last = csvFile.getString(csvFile.getRowCount()-1, "pickup_time");
  println("Min pickup time: ", first);
  println("Max pickup time: ", last);
  
  try {
    minDate = datetime.parse(first); //first "2017-07-17 9:59:00"
    maxDate = datetime.parse(last); //last
    totalSeconds = int(maxDate.getTime()/1000) - int(minDate.getTime()/1000);
  }
  catch (Exception e) {
    println("Unable to parse date stamp");
  }
  println("total seconds: " + totalSeconds); 
  
  // get all predictions to calc min and max
  for (int i=0; i<csvFile.getRowCount()-1; i++) {
  
    float pred = csvFile.getFloat(i, "prediction");
    predictions.add(pred);
    
    float actual = csvFile.getFloat(i, "actual");
    actuals.add(actual);
  
  }
  
  
  for (int i=0; i<csvFile.getRowCount()-1; i++) {
    String startTimeString = csvFile.getString(i, "pickup_time");
    String endTimeString = csvFile.getString(i+1, "pickup_time");
    pickup_times.add(startTimeString);
    try {
      time1 = datetime.parse(startTimeString);
      time2 = datetime.parse(endTimeString);
    }
    catch (Exception e) {
      println("Date parse failure.");
    }
    
    
    
    float pred1 = csvFile.getFloat(i, "prediction");
    float pred1_y = map(pred1, Collections.min(actuals), Collections.max(actuals), height-ymargbottom, ymargtop);
    float pred1_x = map(time1.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale);
    int startFrame = floor(map(time1.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, totalFrames));
    
    float pred2 = csvFile.getFloat(i+1, "prediction");
    float pred2_y = map(pred2, Collections.min(actuals), Collections.max(actuals), height-ymargbottom, ymargtop);
    float pred2_x = map(time2.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale);
    
    Line pred_line = new Line(startFrame, pred1_x, pred1_y, pred2_x, pred2_y, blue);
    prediction_lines.add(pred_line);
    
    float act1 = csvFile.getFloat(i, "actual");
    float act1_y = map(act1, Collections.min(actuals), Collections.max(actuals), height-ymargbottom, ymargtop);
    float act1_x = map(time1.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale);
    
    float act2 = csvFile.getFloat(i+1, "actual");
    float act2_y = map(act2, Collections.min(actuals), Collections.max(actuals), height-ymargbottom, ymargtop);
    float act2_x = map(time2.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale);
    
    Line act_line = new Line(startFrame, act1_x, act1_y, act2_x, act2_y, orange);
    actual_lines.add(act_line);

  }
}


void draw() {
  
  background(0);

  pushMatrix();
  translate(width / 1.3,0);
  
  pushMatrix();
  
  translate(-frameCount*4.86, 0);
  
  for (int i=0; i< prediction_lines.size()-1; i++) {

      Line pred_line = prediction_lines.get(i);
      pred_line.plot();
      
      Line act_line = actual_lines.get(i);
      act_line.plot();      
  }
  
  
  
  for (int i=0; i<xdates.length; i++){
    
      try{
        Date dec31 = datetime.parse("2016-12-31 01:00");
        Date jan1 = datetime.parse("2017-01-01 01:00");
        Date jan2 = datetime.parse("2017-01-02 01:00");
        Date jan3 = datetime.parse("2017-01-03 01:00");
        Date jan4 = datetime.parse("2017-01-04 01:00");
        Date jan5 = datetime.parse("2017-01-05 01:00");
        Date jan6 = datetime.parse("2017-01-06 01:00");
        Date jan7 = datetime.parse("2017-01-07 01:00");
        Date jan8 = datetime.parse("2017-01-08 01:00");
        Date jan9 = datetime.parse("2017-01-09 01:00");
        Date jan10 = datetime.parse("2017-01-10 01:00");
        Date jan11 = datetime.parse("2017-01-11 01:00");
        Date jan12 = datetime.parse("2017-01-12 01:00");
        Date jan13 = datetime.parse("2017-01-13 01:00");
        Date jan14 = datetime.parse("2017-01-14 01:00");
        Date jan15 = datetime.parse("2017-01-15 01:00");
        Date jan16 = datetime.parse("2017-01-16 01:00");
        Date jan17 = datetime.parse("2017-01-17 01:00");
        Date jan18 = datetime.parse("2017-01-18 01:00");
        Date jan19 = datetime.parse("2017-01-19 01:00");
        Date jan20 = datetime.parse("2017-01-20 01:00");
        Date jan21 = datetime.parse("2017-01-21 01:00");
        Date jan22 = datetime.parse("2017-01-22 01:00");
        Date jan23 = datetime.parse("2017-01-23 01:00");
        Date jan24 = datetime.parse("2017-01-24 01:00");
        Date jan25 = datetime.parse("2017-01-25 01:00");
        Date jan26 = datetime.parse("2017-01-26 01:00");
        Date jan27 = datetime.parse("2017-01-27 01:00");
        Date jan28 = datetime.parse("2017-01-28 01:00");
        Date jan29 = datetime.parse("2017-01-29 01:00");
        Date jan30 = datetime.parse("2017-01-30 01:00");
        Date jan31 = datetime.parse("2017-01-31 01:00");
        
        Date feb1 = datetime.parse("2017-02-01 01:00");
        Date feb2 = datetime.parse("2017-02-02 01:00");
        Date feb3 = datetime.parse("2017-02-03 01:00");
        Date feb4 = datetime.parse("2017-02-04 01:00");
        Date feb5 = datetime.parse("2017-02-05 01:00");
        Date feb6 = datetime.parse("2017-02-06 01:00");
        Date feb7 = datetime.parse("2017-02-07 01:00");
        Date feb8 = datetime.parse("2017-02-08 01:00");
        Date feb9 = datetime.parse("2017-02-09 01:00");
        Date feb10 = datetime.parse("2017-02-10 01:00");
        Date feb11 = datetime.parse("2017-02-11 01:00");
        Date feb12 = datetime.parse("2017-02-12 01:00");
        Date feb13 = datetime.parse("2017-02-13 01:00");
        Date feb14 = datetime.parse("2017-02-14 01:00");
        Date feb15 = datetime.parse("2017-02-15 01:00");
        Date feb16 = datetime.parse("2017-02-16 01:00");
        Date feb17 = datetime.parse("2017-02-17 01:00");
        Date feb18 = datetime.parse("2017-02-18 01:00");
        Date feb19 = datetime.parse("2017-02-19 01:00");
        Date feb20 = datetime.parse("2017-02-20 01:00");
        Date feb21 = datetime.parse("2017-02-21 01:00");
        Date feb22 = datetime.parse("2017-02-22 01:00");
        Date feb23 = datetime.parse("2017-02-23 01:00");
        Date feb24 = datetime.parse("2017-02-24 01:00");
        Date feb25 = datetime.parse("2017-02-25 01:00");
        Date feb26 = datetime.parse("2017-02-26 01:00");
        Date feb27 = datetime.parse("2017-02-27 01:00");
        Date feb28 = datetime.parse("2017-02-28 01:00");

        Date mar1 = datetime.parse("2017-03-01 01:00");
        Date mar2 = datetime.parse("2017-03-02 01:00");
        Date mar3 = datetime.parse("2017-03-03 01:00");
        Date mar4 = datetime.parse("2017-03-04 01:00");
        Date mar5 = datetime.parse("2017-03-05 01:00");
        Date mar6 = datetime.parse("2017-03-06 01:00");
        Date mar7 = datetime.parse("2017-03-07 01:00");
        Date mar8 = datetime.parse("2017-03-08 01:00");
        Date mar9 = datetime.parse("2017-03-09 01:00");
        Date mar10 = datetime.parse("2017-03-10 01:00");
        Date mar11 = datetime.parse("2017-03-11 01:00");
        Date mar12 = datetime.parse("2017-03-12 01:00");
        Date mar13 = datetime.parse("2017-03-13 01:00");
        Date mar14 = datetime.parse("2017-03-14 01:00");
        Date mar15 = datetime.parse("2017-03-15 01:00");
        Date mar16 = datetime.parse("2017-03-16 01:00");
        Date mar17 = datetime.parse("2017-03-17 01:00");
        Date mar18 = datetime.parse("2017-03-18 01:00");
        Date mar19 = datetime.parse("2017-03-19 01:00");
        Date mar20 = datetime.parse("2017-03-20 01:00");
        Date mar21 = datetime.parse("2017-03-21 01:00");
        Date mar22 = datetime.parse("2017-03-22 01:00");
        Date mar23 = datetime.parse("2017-03-23 01:00");
        Date mar24 = datetime.parse("2017-03-24 01:00");
        Date mar25 = datetime.parse("2017-03-25 01:00");
        Date mar26 = datetime.parse("2017-03-26 01:00");
        Date mar27 = datetime.parse("2017-03-27 01:00");
        Date mar28 = datetime.parse("2017-03-28 01:00");
        Date mar29 = datetime.parse("2017-03-29 01:00");
        Date mar30 = datetime.parse("2017-03-30 01:00");
        Date mar31 = datetime.parse("2017-03-31 01:00");
       
        Date apr1 = datetime.parse("2017-04-01 01:00");
        Date apr2 = datetime.parse("2017-04-02 01:00");
        Date apr3 = datetime.parse("2017-04-03 01:00");
        Date apr4 = datetime.parse("2017-04-04 01:00");
        Date apr5 = datetime.parse("2017-04-05 01:00");
        Date apr6 = datetime.parse("2017-04-06 01:00");
        Date apr7 = datetime.parse("2017-04-07 01:00");
        Date apr8 = datetime.parse("2017-04-08 01:00");
        Date apr9 = datetime.parse("2017-04-09 01:00");
        Date apr10 = datetime.parse("2017-04-10 01:00");
        Date apr11 = datetime.parse("2017-04-11 01:00");
        Date apr12 = datetime.parse("2017-04-12 01:00");
        Date apr13 = datetime.parse("2017-04-13 01:00");
        Date apr14 = datetime.parse("2017-04-14 01:00");
        Date apr15 = datetime.parse("2017-04-15 01:00");
        Date apr16 = datetime.parse("2017-04-16 01:00");
        Date apr17 = datetime.parse("2017-04-17 01:00");
        Date apr18 = datetime.parse("2017-04-18 01:00");
        Date apr19 = datetime.parse("2017-04-19 01:00");
        Date apr20 = datetime.parse("2017-04-20 01:00");
        Date apr21 = datetime.parse("2017-04-21 01:00");
        Date apr22 = datetime.parse("2017-04-22 01:00");
        Date apr23 = datetime.parse("2017-04-23 01:00");
        Date apr24 = datetime.parse("2017-04-24 01:00");
        Date apr25 = datetime.parse("2017-04-25 01:00");
        Date apr26 = datetime.parse("2017-04-26 01:00");
        Date apr27 = datetime.parse("2017-04-27 01:00");
        Date apr28 = datetime.parse("2017-04-28 01:00");
        Date apr29 = datetime.parse("2017-04-29 01:00");
        Date apr30 = datetime.parse("2017-04-30 01:00");

        Date may1 = datetime.parse("2017-05-01 01:00");
        Date may2 = datetime.parse("2017-05-02 01:00");
        Date may3 = datetime.parse("2017-05-03 01:00");
        Date may4 = datetime.parse("2017-05-04 01:00");
        Date may5 = datetime.parse("2017-05-05 01:00");
        Date may6 = datetime.parse("2017-05-06 01:00");
        Date may7 = datetime.parse("2017-05-07 01:00");
        Date may8 = datetime.parse("2017-05-08 01:00");
        Date may9 = datetime.parse("2017-05-09 01:00");
        Date may10 = datetime.parse("2017-05-10 01:00");
        Date may11 = datetime.parse("2017-05-11 01:00");
        Date may12 = datetime.parse("2017-05-12 01:00");
        Date may13 = datetime.parse("2017-05-13 01:00");
        Date may14 = datetime.parse("2017-05-14 01:00");
        Date may15 = datetime.parse("2017-05-15 01:00");
        Date may16 = datetime.parse("2017-05-16 01:00");
        Date may17 = datetime.parse("2017-05-17 01:00");
        Date may18 = datetime.parse("2017-05-18 01:00");
        Date may19 = datetime.parse("2017-05-19 01:00");
        Date may20 = datetime.parse("2017-05-20 01:00");
        Date may21 = datetime.parse("2017-05-21 01:00");
        Date may22 = datetime.parse("2017-05-22 01:00");
        Date may23 = datetime.parse("2017-05-23 01:00");
        Date may24 = datetime.parse("2017-05-24 01:00");
        Date may25 = datetime.parse("2017-05-25 01:00");
        Date may26 = datetime.parse("2017-05-26 01:00");
        Date may27 = datetime.parse("2017-05-27 01:00");
        Date may28 = datetime.parse("2017-05-28 01:00");
        Date may29 = datetime.parse("2017-05-29 01:00");
        Date may30 = datetime.parse("2017-05-30 01:00");
        Date may31 = datetime.parse("2017-05-31 01:00");
  
        Date jun1 = datetime.parse("2017-06-01 01:00");
        Date jun2 = datetime.parse("2017-06-02 01:00");
        Date jun3 = datetime.parse("2017-06-03 01:00");
        Date jun4 = datetime.parse("2017-06-04 01:00");
        Date jun5 = datetime.parse("2017-06-05 01:00");
        Date jun6 = datetime.parse("2017-06-06 01:00");
        Date jun7 = datetime.parse("2017-06-07 01:00");
        Date jun8 = datetime.parse("2017-06-08 01:00");
        Date jun9 = datetime.parse("2017-06-09 01:00");
        Date jun10 = datetime.parse("2017-06-10 01:00");
        Date jun11 = datetime.parse("2017-06-11 01:00");
        Date jun12 = datetime.parse("2017-06-12 01:00");
        Date jun13 = datetime.parse("2017-06-13 01:00");
        Date jun14 = datetime.parse("2017-06-14 01:00");
        Date jun15 = datetime.parse("2017-06-15 01:00");
        Date jun16 = datetime.parse("2017-06-16 01:00");
        Date jun17 = datetime.parse("2017-06-17 01:00");
        Date jun18 = datetime.parse("2017-06-18 01:00");
        Date jun19 = datetime.parse("2017-06-19 01:00");
        Date jun20 = datetime.parse("2017-06-20 01:00");
        Date jun21 = datetime.parse("2017-06-21 01:00");
        Date jun22 = datetime.parse("2017-06-22 01:00");
        Date jun23 = datetime.parse("2017-06-23 01:00");
        Date jun24 = datetime.parse("2017-06-24 01:00");
        Date jun25 = datetime.parse("2017-06-25 01:00");
        Date jun26 = datetime.parse("2017-06-26 01:00");
        Date jun27 = datetime.parse("2017-06-27 01:00");
        Date jun28 = datetime.parse("2017-06-28 01:00");
        Date jun29 = datetime.parse("2017-06-29 01:00");
        Date jun30 = datetime.parse("2017-06-30 01:00");
        
        Date jul1 = datetime.parse("2017-07-01 00:00");
        
        //float pred1_x = map(time1.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale);
        
        textFont(raleway, 22);
        int xlabelmargin = 15;
        
        //text("December 31", map(dec31.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        
        text("January 1", map(jan1.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 2", map(jan2.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 3", map(jan3.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 4", map(jan4.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 5", map(jan5.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 6", map(jan6.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 7", map(jan7.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 8", map(jan8.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 9", map(jan9.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 10", map(jan10.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 11", map(jan11.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 12", map(jan12.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 13", map(jan13.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 14", map(jan14.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 15", map(jan15.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 16", map(jan16.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 17", map(jan17.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 18", map(jan18.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 19", map(jan19.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 20", map(jan20.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 21", map(jan21.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 22", map(jan22.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 23", map(jan23.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 24", map(jan24.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 25", map(jan25.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 26", map(jan26.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 27", map(jan27.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 28", map(jan28.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 29", map(jan29.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 30", map(jan30.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("January 31", map(jan31.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
      
        text("Feburary 1", map(feb1.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 2", map(feb2.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 3", map(feb3.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 4", map(feb4.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 5", map(feb5.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 6", map(feb6.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 7", map(feb7.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 8", map(feb8.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 9", map(feb9.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 10", map(feb10.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 11", map(feb11.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 12", map(feb12.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 13", map(feb13.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 14", map(feb14.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 15", map(feb15.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 16", map(feb16.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 17", map(feb17.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 18", map(feb18.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 19", map(feb19.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 20", map(feb20.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 21", map(feb21.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 22", map(feb22.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 23", map(feb23.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 24", map(feb24.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 25", map(feb25.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 26", map(feb26.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 27", map(feb27.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("Feburary 28", map(feb28.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        

        text("March 1", map(mar1.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 2", map(mar2.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 3", map(mar3.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 4", map(mar4.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 5", map(mar5.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 6", map(mar6.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 7", map(mar7.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 8", map(mar8.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 9", map(mar9.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 10", map(mar10.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 11", map(mar11.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 12", map(mar12.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 13", map(mar13.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 14", map(mar14.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 15", map(mar15.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 16", map(mar16.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 17", map(mar17.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 18", map(mar18.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 19", map(mar19.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 20", map(mar20.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 21", map(mar21.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 22", map(mar22.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 23", map(mar23.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 24", map(mar24.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 25", map(mar25.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 26", map(mar26.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 27", map(mar27.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 28", map(mar28.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 29", map(mar29.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 30", map(mar30.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("March 31", map(mar31.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        

        text("April 1", map(apr1.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 2", map(apr2.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 3", map(apr3.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 4", map(apr4.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 5", map(apr5.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 6", map(apr6.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 7", map(apr7.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 8", map(apr8.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 9", map(apr9.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 10", map(apr10.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 11", map(apr11.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 12", map(apr12.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 13", map(apr13.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 14", map(apr14.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 15", map(apr15.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 16", map(apr16.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 17", map(apr17.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 18", map(apr18.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 19", map(apr19.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 20", map(apr20.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 21", map(apr21.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 22", map(apr22.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 23", map(apr23.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 24", map(apr24.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 25", map(apr25.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 26", map(apr26.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 27", map(apr27.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 28", map(apr28.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 29", map(apr29.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("April 30", map(apr30.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        
        text("May 1", map(may1.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 2", map(may2.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 3", map(may3.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 4", map(may4.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 5", map(may5.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 6", map(may6.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 7", map(may7.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 8", map(may8.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 9", map(may9.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 10", map(may10.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 11", map(may11.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 12", map(may12.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 13", map(may13.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 14", map(may14.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 15", map(may15.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 16", map(may16.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 17", map(may17.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 18", map(may18.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 19", map(may19.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 20", map(may20.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 21", map(may21.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 22", map(may22.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 23", map(may23.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 24", map(may24.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 25", map(may25.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 26", map(may26.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 27", map(may27.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 28", map(may28.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 29", map(may29.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 30", map(may30.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("May 31", map(may31.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);

        text("June 1", map(jun1.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 2", map(jun2.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 3", map(jun3.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 4", map(jun4.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 5", map(jun5.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 6", map(jun6.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 7", map(jun7.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 8", map(jun8.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 9", map(jun9.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 10", map(jun10.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 11", map(jun11.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 12", map(jun12.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 13", map(jun13.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 14", map(jun14.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 15", map(jun15.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 16", map(jun16.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 17", map(jun17.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 18", map(jun18.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 19", map(jun19.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 20", map(jun20.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 21", map(jun21.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 22", map(jun22.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 23", map(jun23.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 24", map(jun24.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 25", map(jun25.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 26", map(jun26.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 27", map(jun27.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 28", map(jun28.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 29", map(jun29.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        text("June 30", map(jun30.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
        
        text("July 1", map(jul1.getTime()/1000, minDate.getTime()/1000, maxDate.getTime()/1000, 0, width * hscale), height-xlabelmargin);
      
      } catch (Exception e) {
      
      }
    
      
  
  };
  
  
  
  
 
  popMatrix();
  popMatrix();
  
  pushStyle();
   fill(0);
   noStroke();
   rect(width-80, height-40,150, 40);
  popStyle();
  
  // handle time
  float epoch_float = map(frameCount, 0, totalFrames, int(minDate.getTime()/1000), int(maxDate.getTime()/1000));
  int epoch = int(epoch_float);
  String day = new java.text.SimpleDateFormat("EEEE").format(new java.util.Date(epoch * 1000L));
  String date = new java.text.SimpleDateFormat("MMM d yyyy ").format(new java.util.Date(epoch * 1000L));
  String time = new java.text.SimpleDateFormat("HH:00 a").format(new java.util.Date(epoch * 1000L));

  pushMatrix();
  translate(-60,0);
  textFont(ralewayBold, 32);
  image(clock, 100, 40);
  text(time, 140, 70);
  image(calendar, 100, 80);
  text(day , 140, 108);
  textFont(ralewayBold, 22);
  text(date, 140, 140);
  popMatrix();
  
  
  pushMatrix();
  pushStyle();
    
    textFont(raleway, 46);
    textAlign(LEFT);
    text("Predicting Taxi Demand \nat LaGuardia Airport",360,80); 
    
    textFont(raleway, 22);
    textAlign(LEFT);
    text("with Long Short-Term Memory (LSTM) Recurrent Neural Networks",360,200);
    
    textFont(raleway, 16);
    text("Will Geary, Keerti Agrawal, Adam Coviensky, Anuj Katiyal",360,235);
  
  popMatrix();
  popStyle();

  
  pushMatrix();
  translate(750,38);
  pushStyle();
  noStroke();
  fill(orange);
  rect(370, 85, 30, 5, 8);
  text("Actual", 420, 94);
  
  fill(blue);
  rect(370, 115, 30, 5, 8);
  text("Predicted", 420, 124);
  popStyle();
  popMatrix();
  
  // Draw scale
  
  pushMatrix();
  pushStyle();
  
  float yAxisBottom = map(0, Collections.min(actuals), Collections.max(actuals), height-ymargbottom, ymargtop);
  float yAxisTop = map(Collections.max(actuals), Collections.min(actuals), Collections.max(actuals), height-ymargbottom, ymargtop);
  
  float ytick0 = map(0, Collections.min(actuals), Collections.max(actuals), height-ymargbottom, ymargtop);
  float ytick200 = map(200, Collections.min(actuals), Collections.max(actuals), height-ymargbottom, ymargtop);
  float ytick400 = map(400, Collections.min(actuals), Collections.max(actuals), height-ymargbottom, ymargtop);
  float ytick600 = map(600, Collections.min(actuals), Collections.max(actuals), height-ymargbottom, ymargtop);
  float ytick800 = map(800, Collections.min(actuals), Collections.max(actuals), height-ymargbottom, ymargtop);
  float ytick870 = map(870, Collections.min(actuals), Collections.max(actuals), height-ymargbottom, ymargtop);
  float ytick900 = map(930, Collections.min(actuals), Collections.max(actuals), height-ymargbottom, ymargtop);
  
  stroke(255);
  strokeWeight(1);
  line(width-80, yAxisTop, width-80, yAxisBottom+5);
  line(0, yAxisBottom+5, width-80, yAxisBottom+5);
  
  text("0", width-70,ytick0);
  text("200", width-70,ytick200);
  text("400", width-70,ytick400);
  text("600", width-70,ytick600);
  text("800", width-70,ytick800);
 
  text("Hourly\nPickups", width-90, ytick900);

  popStyle();
  popMatrix();
  
  if (recording) {
    saveFrame("frames/#####.png");
  }
  
}

class Line {
  int start_frame;
  float startx, starty, endx, endy;
  color c;
  Line(int _start_frame, float _startx, float _starty, float _endx, float _endy, color _c) {
    start_frame = _start_frame;
    startx = _startx;
    starty = _starty;
    endx = _endx;
    endy = _endy;
    c = _c;
  }
  void plot() {
    
    if (frameCount >= start_frame){

      strokeWeight(3);
      stroke(c);
      line(startx, starty, endx, endy);
     }
  }
}