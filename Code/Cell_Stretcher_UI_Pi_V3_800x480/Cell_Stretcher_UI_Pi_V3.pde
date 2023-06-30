import controlP5.*; // http://www.sojamo.de/libraries/controlP5/
import processing.serial.*;
import java.lang.Math.*;
import java.util.*;
import javax.swing.JOptionPane;

PFont buttonTitle_f, mmtkState_f, indicatorTitle_f, indicatorNumbers_f;

// Cell Stretcher States
enum State {
  tare, userProfile, getInput, running, returnInitPos, stopped
};
State currentState=State.tare;

// Serial Setup
String serialPortName;
Serial serialPort;  // Create object from Serial class

// creating object of ControlP5 class
ControlP5 cp5;

// Saved User Settings are stored in this config file. Other vars for saving and retrieving settings
JSONObject userSettings;
String topSketchPath="";
int userNumber=0;
boolean displayedUser=false;
int numberOfUsers;
int numberOfSettings;

// ************************
// ** Variables for Data **
// ************************

int squareWave = 0;
int sinWave = 0;
int startT = 0;
int currentT = 0;
float runT = 0;
int cycleN = 0;
double roundN = 0;

float mmtkVel = 50.0;
int bgColor = 200;
float stretchL = 10000;
float timeA = 5000;
float timeB = 2000;
float timeC = 5000;
float timeD = 2000;
float cycleT = 0;
float currentt = 0.0;
float lastt = 0.0;
double nextPosition1 = 0;
double nextVel1 = 0;

int newLoadcellData = 0;
int sendData = 0;
float velocity = 0.0;
float position = 0.0;
float positionCorrected = 0.0;
float loadCell = 0.0;
int feedBack = 0;
int MMTKState = 1;
int eStop = 0;
int stall = 0;
int direction = 0;
float inputVolts = 12.0;
int isTared=0;
int isTaredTemp=0;
int isAuxTemp=0;
int isAux=0;
int stallCountf = 0;
int stallCountb = 0;

int btBak = 0;
int btFwd = 0;
int btTare = 0;
int btStart = 0;
int btAux = 0;

float[] correctionFactors = new float[2];
float maxForce = 0;
float maxDisplacment = 0;

// initialization of CP5 elements (buttons, texts etc.)
Textfield stretchLen, TimeA, TimeB, TimeC, TimeD, Hours, Minutes, Seconds, userName;
Button sine, square, run, cancel, pause, resume, user1, user2, user3, user4, saveSettings, loadUser, jogBak, jogFwd, tareButton, startButton, aux, userBack, eStopAux, eStopResume;
Textlabel controlPanelLabel;

// vars for runtime timer
int start=0;
long runTime=0;
long endTime=999999999;
long nextSec;  //used to store millis() of next second, used to adjust countdown timer every second
int hours;
int mins;
int secs;

// vars for pause/resume
long pauseStart;  //millis() of start of pause
long pauseFin;   //millis() of end of pause
long pauseShift;   //sum of all paused durations, subtract from system millis() to resume pattern where it was paused
boolean isPaused=false;

// keeping track of errors on user input screen
boolean hasError=false;
LinkedList<String> errors = new LinkedList<String>();

// vars for setup screen
boolean jogButtonPressed=false;
int displayAuxError=0;
int displayTareError=0;

// vars for returning stretcher to initial position at end of stretch
long returnInitPosTime;  //millis() of when stretch has ended
int StateTransitionPause;  //how long to pause for to allow stretcher to return to init position

boolean loadedUser=false;

// Wave pattern image
PImage wavePattern;

// vars for Estop
int timerAdjust;
State lastCurrentState;
int lastIsAux;
int isAuxCounter;
boolean savedLastState=false;

boolean firstAux=false;
int displayEstopError=0;

boolean firstEstopAux=false;

// sleep function used for testing
public static void sleep(int time) {
  try {
    Thread.sleep(time);
  }
  catch (Exception e) {
  }
}

boolean windowPosFlag;

// ************************
// **** Void Setup () *****
// ************************

void setup() {
  windowPosFlag=false;
  //size (1024, 570);  //window size
  size (800, 480);  //window size (-224, -98)
  surface.setTitle("CaT Stretcher");

  //refer to "setup" tab for contents
  setupContents();
}

// ************************
// ***** Void Draw () *****
// ************************
void draw() {

  //refer to "Draw" tab for contents
  drawContents();
}


// ************************
// ****** Plotting ********
// ************************

import java.util.Arrays;

// Generate the plot
int[] XYplotFloatDataDims = {5, 10000};
int[] XYplotIntDataDims = {5, 10000};

// XY Plot
int[] XYplotOrigin = {133, 80};
int[] XYplotSize = {575, 150};
int XYplotColor = color(20, 20, 200);

Graph XYplot = new Graph(XYplotOrigin[0], XYplotOrigin[1], XYplotSize[0], XYplotSize[1], XYplotColor); //(X,Y,W,H,C)

float[][] XYplotFloatData = new float[XYplotFloatDataDims[0]][XYplotFloatDataDims[1]];  //creating plot array [5 possible vars] [10000 spots per var]
int[][] XYplotIntData = new int[XYplotIntDataDims[0]][XYplotIntDataDims[1]];

// This value grows and is used for slicing
int XYplotCurrentSize = 0;

int plotSetup=0;
int periodsDisplayed=3;
int clearPlotCounter=1;

//this function plots data
void plot() {
  if (plotSetup==0) {
    XYplot.xLabel="Run Time (sec)";
    XYplot.yLabel="Stretch Length (mm)";
    XYplot.Title="Stretch Length vs Run Time";
    XYplot.xDiv=2;
    XYplot.xMax=(timeA+timeB+timeC+timeD)/1000*periodsDisplayed;
    XYplot.xMin=0;
    XYplot.yMax=stretchL/1000*1.1;  //1.1 just so plot doesnt reach all the way to yMax
    XYplot.yMin=0;

    plotSetup=1;
  }

  // Update the data buffer
  XYplotFloatData[0][XYplotCurrentSize] = velocity;
  XYplotFloatData[1][XYplotCurrentSize] = -position;
  float nextP = (float) nextPosition1/1000;
  XYplotFloatData[2][XYplotCurrentSize] = loadCell;
  XYplotFloatData[3][XYplotCurrentSize] = (runT+pauseShift)/1000;
  XYplotFloatData[4][XYplotCurrentSize] = nextP;

  XYplotIntData[0][XYplotCurrentSize] = feedBack;
  XYplotIntData[1][XYplotCurrentSize] = MMTKState;
  XYplotIntData[2][XYplotCurrentSize] = eStop;
  XYplotIntData[3][XYplotCurrentSize] = stall;
  XYplotIntData[4][XYplotCurrentSize] = direction;

  XYplotCurrentSize ++;

  // Copy data to plot into new array for plotting
  float[] plotTime = Arrays.copyOfRange(XYplotFloatData[3], 0, XYplotCurrentSize);
  float[] plotDisplacement = Arrays.copyOfRange(XYplotFloatData[1], 0, XYplotCurrentSize);
  float[] plotNewDisplacement = Arrays.copyOfRange(XYplotFloatData[4], 0, XYplotCurrentSize);

  // Check if graph needs to expand
  if (plotTime[plotTime.length-1] > XYplot.xMax ) {
    Arrays.fill(XYplotFloatData[0], 0);
    Arrays.fill(XYplotFloatData[1], 0);
    Arrays.fill(XYplotFloatData[2], 0);
    Arrays.fill(XYplotFloatData[3], 0);
    Arrays.fill(XYplotFloatData[4], 0);
    XYplotCurrentSize=0;


    XYplot.xMin=XYplot.xMax;
    XYplot.xMax=((timeA+timeB+timeC+timeD)/1000)*periodsDisplayed*clearPlotCounter;
    clearPlotCounter++;
  }

  // Setup the graph
  XYplot.DrawAxis();
  XYplot.DotXY(plotTime, plotDisplacement);
  XYplot.GraphColor = color(200, 20, 20);
  XYplot.GraphColor = XYplotColor;
}

// Function for checking if user inputs are numbers
boolean onlyDigits(String str, int n)
{
  boolean onlyDigits=true;

  if (n==0) {
    return true;
  } else {
    for (int i=0; i<n; i++) {
      if (!(str.charAt(i) >= '0' && str.charAt(i) <= '9' || str.charAt(i)=='.')) {   //if character is not between 0 and 9 or not equal to .
        onlyDigits=false;
      }
    }
    return onlyDigits;
  }
}

// Function to check for incorrect inputs - Errors
void checkErrors() {
  hasError=false;
  errors.clear();
  if (sinWave==0 && squareWave==0) {
    hasError=true;
    errors.add("ERROR: Missing waveform");
  }
  if (stretchLen.getText().isEmpty()==true ||
    TimeA.getText().isEmpty()==true||
    TimeB.getText().isEmpty()==true||
    TimeC.getText().isEmpty()==true||
    TimeD.getText().isEmpty()==true||
    Hours.getText().isEmpty()==true||
    Minutes.getText().isEmpty()==true||
    Seconds.getText().isEmpty()==true) {
    hasError=true;
    errors.add("ERROR: Empty text field(s)");
  }
  if (onlyDigits(stretchLen.getText(), stretchLen.getText().length())==false||
    onlyDigits(TimeA.getText(), TimeA.getText().length())==false||
    onlyDigits(TimeB.getText(), TimeB.getText().length())==false||
    onlyDigits(TimeC.getText(), TimeC.getText().length())==false||
    onlyDigits(TimeD.getText(), TimeD.getText().length())==false||
    onlyDigits(Hours.getText(), Hours.getText().length())==false||
    onlyDigits(Minutes.getText(), Minutes.getText().length())==false||
    onlyDigits(Seconds.getText(), Seconds.getText().length())==false) {
    hasError=true;
    errors.add("ERROR: Input(s) contain invalid characters");
  }
}

// Function to retrieve user specified stretch parameters
void getUserSettings(int userNumber) {

  Hours.setText(str(userSettings.getFloat("hours"+userNumber)));
  Minutes.setText(str(userSettings.getFloat("mins"+userNumber)));
  Seconds.setText(str(userSettings.getFloat("secs"+userNumber)));
  stretchLen.setText(str(userSettings.getFloat("stretchLength"+userNumber)));
  TimeA.setText(str(userSettings.getFloat("timeA"+userNumber)));
  TimeB.setText(str(userSettings.getFloat("timeB"+userNumber)));
  TimeC.setText(str(userSettings.getFloat("timeC"+userNumber)));
  TimeD.setText(str(userSettings.getFloat("timeD"+userNumber)));

  println(Minutes.getValue());
  if (userSettings.getString("wavePattern"+userNumber).equals("sine")) {
    sinWave=1;
    squareWave=0;
  } else if (userSettings.getString("wavePattern"+userNumber).equals("square")) {
    squareWave=1;
    sinWave=0;
  }
}

// Function controlling all CP5 element actions
void controlEvent(ControlEvent theEvent) {
  //refer to "controlEvent" tab for contents
  controlEventContents(theEvent);
}
