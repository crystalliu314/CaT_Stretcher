void setupContents() {
  
  //listing all serial ports for user to select
  String[] serialPortList = Serial.list();
  String[] serialPortChoices = new String[serialPortList.length];
  for (int i = 0; i < Serial.list().length; i++) {
    serialPortChoices[i] = serialPortList[i];
  }

  serialPortName = (String) JOptionPane.showInputDialog(null, "Please Select The Serial Port for Cell Stretcher", "Serial Port", JOptionPane.QUESTION_MESSAGE, null, serialPortChoices, serialPortChoices[0]);

  System.out.println(serialPortName);
  serialPort = new Serial(this, serialPortName, 57600);

  //locating json file
  topSketchPath=sketchPath();
  userSettings=loadJSONObject(topSketchPath+"/users.json");

  cycleT = (timeA + timeB + timeC + timeD);

  surface.setLocation(100, 100);
  surface.setVisible(true);
  frameRate(25);
  cp5 = new ControlP5(this);

  int x = 0;
  int y = 0;

  fill(0, 0, 0);
  
  //******************************************
  //** Setting up CP5 objects (UI elements) **
  //******************************************
  
  //setup screen
  aux=cp5.addButton("Aux")
    .setFont(createFont("Arial Black", 20))
    .setPosition(x=37, y=470-120)
    .setSize(120, 55);

  jogBak=cp5.addButton("Jog Back")
    .setFont(createFont("Arial Black", 20))
    .setPosition(x+150, y)
    .setSize(120, 55);

  jogFwd=cp5.addButton("Jog Fwd")
    .setFont(createFont("Arial Black", 20))
    .setPosition(x+300, y)
    .setSize(120, 55);

  //holding jog buttons - callback functions
  jogBak.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {

      switch(theEvent.getAction()) {
        case(ControlP5.ACTION_PRESSED):

        if (isAux==1) {
          println("JogBack");
          serialPort.write("L");
          jogButtonPressed=true;
          tareButton.setColorBackground(#002b5c);
          tareButton.setColorForeground(#4B70FF);

          isTared=0;
        } else if (isAux==0) {
          displayAuxError=1;
        }
        break;

        case(ControlP5.ACTION_RELEASED):
        if (isAux==1) {
          println("stop");
          serialPort.write("l");
          jogButtonPressed=false;
        }
        break;
      }
    }
  }

  );

  jogFwd.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {

      switch(theEvent.getAction()) {
        case(ControlP5.ACTION_PRESSED):
        if (isAux==1) {
          println("jogFwd");
          serialPort.write("F");
          jogButtonPressed=true;
          tareButton.setColorBackground(#002b5c);
          tareButton.setColorForeground(#4B70FF);

          isTared=0;
        } else if (isAux==0) {
          displayAuxError=1;
        }
        break;

        case(ControlP5.ACTION_RELEASED):
        if (isAux==1) {
          println("stop");
          serialPort.write("f");
          jogButtonPressed=false;
        }
        break;
      }
    }
  }

  );
  tareButton=cp5.addButton("Tare")
    .setFont(createFont("Arial Black", 20))
    .setPosition(x+450, y)
    .setSize(120, 55);

  startButton=cp5.addButton("Ready")
    .setFont(createFont("Arial Black", 20))
    .setPosition(x+600, y)
    .setSize(120, 55);


  //control panel/user inputs screen
  controlPanelLabel=cp5.addTextlabel("label")
    .setText("Cell Stretcher Control Panel")
    .setPosition(x=15, y=7)
    .setColorValue(color(0, 0, 0))
    .setFont(createFont("Arial Bold", 25));

  square=cp5.addButton("Square")
    .setFont(createFont("Arial Black", 20))
    .setPosition(x, y=45)
    .setSize(120, 60);

  sine=cp5.addButton("Sinusoid")
    .setFont(createFont("Arial Black", 20))
    .setPosition(x+150, y)
    .setSize(120, 60);


  stretchLen=cp5.addTextfield("stretch length (mm)")
    .setPosition(x=15, y+70)
    .setColorValue(color(0, 0, 0))
    .setColorCursor(color(0, 0, 0))
    .setColorLabel(color(0, 0, 0))
    .setColorBackground(color(255, 255, 255))
    .setFont(createFont("Arial", 20))
    .setText("10")
    .setSize(100, 40)
    .setAutoClear(false);


  TimeA=cp5.addTextfield("time A")
    .setPosition(x, y = 270-70)
    .setColorValue(color(0, 0, 0))
    .setColorCursor(color(0, 0, 0))
    .setColorLabel(color(68, 114, 196))
    .setColorBackground(color(68, 114, 196))
    .setFont(createFont("Arial", 20))
    .setText("5")
    .setSize(60, 40)
    .setAutoClear(false);

  TimeB=cp5.addTextfield("time B")
    .setPosition(x+=85, y)
    .setColorValue(color(0, 0, 0))
    .setColorCursor(color(0, 0, 0))
    .setColorLabel(color(237, 125, 49))
    .setColorBackground(color(237, 125, 49))
    .setFont(createFont("Arial", 20))
    .setText("2")
    .setSize(60, 40)
    .setAutoClear(false);

  TimeC=cp5.addTextfield("time C")
    .setPosition(x+=85, y)
    .setColorValue(color(0, 0, 0))
    .setColorCursor(color(0, 0, 0))
    .setColorLabel(color(255, 192, 0))
    .setColorBackground(color(255, 192, 0))
    .setFont(createFont("Arial", 20))
    .setText("2")
    .setSize(60, 40)
    .setAutoClear(false);

  TimeD=cp5.addTextfield("time D")
    .setPosition(x+=85, y)
    .setColorValue(color(0, 0, 0))
    .setColorCursor(color(0, 0, 0))
    .setColorLabel(color(112, 173, 71))
    .setColorBackground(color(112, 173, 71))
    .setFont(createFont("Arial", 20))
    .setText("0.5")
    .setSize(60, 40)
    .setAutoClear(false);

  Hours=cp5.addTextfield("Hour")
    .setPosition(x=15, y=410-100)
    .setColorValue(color(0, 0, 0))
    .setColorCursor(color(0, 0, 0))
    .setColorLabel(color(0, 0, 0))
    .setColorBackground(color(255, 255, 255))
    .setFont(createFont("Arial", 20))
    .setText("1")
    .setSize(60, 40)
    .setAutoClear(false);

  Minutes=cp5.addTextfield("Min")
    .setPosition(x+=85, y)
    .setColorValue(color(0, 0, 0))
    .setColorCursor(color(0, 0, 0))
    .setColorLabel(color(0, 0, 0))
    .setColorBackground(color(255, 255, 255))
    .setFont(createFont("Arial", 20))
    .setText("0")
    .setSize(60, 40)
    .setAutoClear(false);

  Seconds=cp5.addTextfield("Sec")
    .setPosition(x+=85, y)
    .setColorValue(color(0, 0, 0))
    .setColorCursor(color(0, 0, 0))
    .setColorLabel(color(0, 0, 0))
    .setColorBackground(color(255, 255, 255))
    .setFont(createFont("Arial", 20))
    .setText("0")
    .setSize(60, 40)
    .setAutoClear(false);



  loadUser=cp5.addButton("Load User")
    .setPosition(x=15, y+75)
    .setFont(createFont("Arial Black", 16))
    .setSize(150, 50);

  run=cp5.addButton("Run")
    .setFont(createFont("Arial Black", 20))
    .setPosition(600, y+75)
    .setSize(150, 50)
    .setColorBackground(#FA0000)
    .setColorForeground(#FF7C80);

  userName=cp5.addTextfield("User Name")
    .setPosition(505-100, 10)
    .setColorValue(color(0, 0, 0))
    .setColorCursor(color(0, 0, 0))
    .setColorLabel(color(0, 0, 0))
    .setColorBackground(color(255, 255, 255))
    .setFont(createFont("Arial", 20))
    .setSize(300, 40)
    .setAutoClear(false);

  saveSettings=cp5.addButton("Save Settings")
    .setFont(createFont("Arial Black", 17))
    .setPosition(200, y+75)
    .setSize(150, 50);


  //select user screen
  user1=cp5.addButton("user1")
    .setFont(createFont("Arial Black", 17))
    .setPosition(x=140, y=60)
    .setSize(130, 65);

  user2=cp5.addButton("user2")
    .setFont(createFont("Arial Black", 17))
    .setPosition(x+=160, y)
    .setSize(130, 65);

  user3=cp5.addButton("vuser3")
    .setFont(createFont("Arial Black", 17))
    .setPosition(x+=160, y)
    .setSize(130, 65);

  user4=cp5.addButton("user4")
    .setFont(createFont("Arial Black", 17))
    .setPosition(x+=160, y)
    .setSize(130, 65);

  userBack=cp5.addButton("Back")
    .setFont(createFont("Arial Black", 20))
    .setPosition(10, 20)
    .setSize(90, 50);

  //run screen
  x=410;
  pause=cp5.addButton("pause")
    .setFont(createFont("Arial Black", 20))
    .setPosition(x, 390)
    .setSize(120, 50);

  resume=cp5.addButton("resume")
    .setFont(createFont("Arial Black", 20))
    .setPosition(x+=130, 390)
    .setSize(120, 50);

  cancel=cp5.addButton("Cancel")
    .setFont(createFont("Arial Black", 20))
    .setPosition(x+=130, 390)
    .setSize(120, 50)
    .setColorBackground(#FA0000)
    .setColorForeground(#FF7C80);

  eStopAux=cp5.addButton("eStopAux")
    .setFont(createFont("Arial Black", 20))
    .setPosition(400, 340)
    .setSize(150, 75)
    .setLabel("Aux");

  eStopResume=cp5.addButton("eStopResume")
    .setFont(createFont("Arial Black", 20))
    .setPosition(600, 340)
    .setSize(150, 75)
    .setLabel("Resume");
  ;

  textFont(createFont("Arial", 16, true));

  //hide all CP5 elements buttons upon startup
  stretchLen.hide();
  TimeA.hide();
  TimeB.hide();
  TimeC.hide();
  TimeD.hide();
  Hours.hide();
  Minutes.hide();
  Seconds.hide();
  sine.hide();
  square.hide();
  run.hide();
  cancel.hide();
  pause.hide();
  resume.hide();
  controlPanelLabel.hide();
  user1.hide();
  user2.hide();
  user3.hide();
  user4.hide();
  userName.hide();
  saveSettings.hide();
  loadUser.hide();
  userBack.hide();
  aux.hide();
  jogBak.hide();
  jogFwd.hide();
  tareButton.hide();
  startButton.hide();
}
