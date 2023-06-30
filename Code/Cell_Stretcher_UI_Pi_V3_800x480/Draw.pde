void drawContents() {
  if (!windowPosFlag) {
    surface.setLocation(0, -1);
    windowPosFlag=true;
  }

  //serial parsing
  while (serialPort.available()>0) {
    String myString = "";

    try {
      myString = serialPort.readStringUntil('\n');
    }
    catch (Exception e) {
    }

    if (myString == null) {
      return;
    }

    //incoming data stored as string array
    String[] tempData = split(myString, '\t');

    lastIsAux=isAuxTemp;

    //storing all incoming data in appropriate variables
    if (tempData.length ==  12) {
      // This is a normal data frame
      // SPEED POSITION LOADCELL FEEDBACK_COUNT STATE ESTOP STALL DIRECTION INPUT_VOLTAGE BT_FWD BT_BAK BT_TARE BT_START BT_AUX and a space
      try {
        velocity = Float.parseFloat(trim(tempData[0]));
        position = Float.parseFloat(trim(tempData[1]));
        MMTKState = Integer.parseInt(trim(tempData[2]));  // this is the state Arduino is in
        eStop = Integer.parseInt(trim(tempData[3]));
        stall = Integer.parseInt(trim(tempData[4]));
        direction = Integer.parseInt(trim(tempData[5]));
        inputVolts = Float.parseFloat(trim(tempData[6]));
        isTaredTemp = Integer.parseInt(trim(tempData[7]));
        isAuxTemp = Integer.parseInt(trim(tempData[8]));
        stallCountf = Integer.parseInt(trim(tempData[9]));
        stallCountb = Integer.parseInt(trim(tempData[10]));
      }
      catch (NumberFormatException e) {
        System.out.println(e);
      }
    }
    println(myString);

    //changing button aux and tare colors in processing tare state upon press
    if (isTaredTemp==1) {
      isTared=1;
      tareButton.setColorBackground(#0ACB15);
      tareButton.setColorForeground(#5DFF5E);
      displayTareError=0;
    }
    if (isAuxTemp==1) {
      isAux=1;
      aux.setColorBackground(#0ACB15);
      aux.setColorForeground(#5DFF5E);
      displayAuxError=0;
      displayEstopError=0;
    } else if (isAuxTemp==0) {
      isAux=0;
    }

    //processing states: tare, userProfile, getInput, running, stopped
    //Arduino states: running, stopped, hold, jogFwd, jogBak, fastFwd, fastBak, noChange

    //if Arduino sends that it is in tared state, transition to next state
    if (currentState == State.tare) {
      if (MMTKState == 0) {     //if arduino is sending running state, transition to state 1
        currentState = State.getInput ;
      }
    }
  }

  //saves current state upon eStop press in any state other than processing tare state
  if (currentState!=State.tare&& eStop==1) {
    if (savedLastState==false) {
      lastCurrentState=currentState;  //save state before eStop
      savedLastState=true;
    }

    //keeping track of
    if (currentState==State.running||currentState==State.returnInitPos) {
      isPaused=true;
      pauseStart=millis();
    }
    currentState=State.stopped;
  }


  // ************************
  // *** Processing States **
  // ************************
  switch (currentState) {
  case tare:  //set-up state
    {
      background(bgColor);

      //hiding and showing select UI elements
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
      eStopAux.hide();
      eStopResume.hide();
      aux.show();
      jogFwd.show();
      jogBak.show();
      tareButton.show();
      startButton.show();

      //resetting colours of running screen buttons
      resume.setColorBackground(#002b5c);
      pause.setColorBackground(#002b5c);

      //displaying text
      fill(255, 255, 255);
      rect(25, 25, 970-224, 425-98);
      fill(0, 0, 0);
      textFont(createFont("Arial Bold", 40, true));
      textAlign(CENTER);
      text("Please Set Initial Position", 500-100, 90-10);
      textAlign(LEFT);
      textFont(createFont("Arial", 25, true));
      fill(#FF3B3B); //red
      text("1. Make sure EMERGENCY STOP button is released", 100-30, 170-35);
      fill(0, 0, 0);
      text("2. Press the AUX button ", 100-30, 220-35);
      text("3. Jog stretcher using the FORWARD and BACK jog buttons", 100-30, 270-35);
      text("4. Press the TARE button to set initial position", 100-30, 320-35);
      text("5. Press the READY button to ready stretcher for pattern input", 100-30, 370-35);

      if (MMTKState==1) {
        aux.setColorBackground(#002b5c);
        aux.setColorForeground(#4B70FF);
      }

      //displaying errors
      if (displayAuxError==1) {
        fill(#FF3B3B); //red
        textSize(10);
        text("ERROR: Please AUX button before JOGGING, TARE, or READY", 50, 460);
      }

      if (displayTareError==1) {
        fill(#FF3B3B); //red
        textSize(10);
        text("ERROR: Please AUX and TARE before READY", 350, 460);
      }

      if (displayEstopError==1) {
        fill(#FF3B3B); //red
        textSize(10);
        text("ERROR: Please release ESTOP before AUX", 580, 460);
      }

      break;
    }
  case userProfile:
    {
      background(bgColor);
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
      loadUser.hide();
      userName.hide();
      saveSettings.hide();
      eStopAux.hide();
      eStopResume.hide();

      userBack.show();

      //creating table/matrix labels
      user1.setCaptionLabel(userSettings.getString("name0"));
      user2.setCaptionLabel(userSettings.getString("name1"));
      user3.setCaptionLabel(userSettings.getString("name2"));
      user4.setCaptionLabel(userSettings.getString("name3"));

      user1.show();
      user2.show();
      user3.show();
      user4.show();

      fill(0, 0, 0);
      textFont(createFont("Arial Bold", 30, true));
      text("Select User", 400, 60-20);

      int y;
      textFont(createFont("Arial", 20, true));
      text("Wave: ", 12, y=165);
      text("Length: ", 12, y+=35);
      text("Time A: ", 12, y+=35);
      text("Time B: ", 12, y+=35);
      text("Time C: ", 12, y+=35);
      text("Time D: ", 12, y+=35);
      text("Run Hrs: ", 12, y+=35);
      text("Run Mins: ", 12, y+=35);
      text("Run Secs: ", 12, y+=35);

      //Retrieving and displaying all saved user settings
      String[] settings= {"wavePattern", "stretchLength", "timeA", "timeB", "timeC", "timeD", "hours", "mins", "secs"};
      String[] units={"", " mm", " s", " s", " s", " s", " hrs", " mins", " s"};
      int[] xPositions={150, 315, 480, 645};

      for (int i=0; i<4; i++) {   //cycles through user
        y=130;
        for (int j=0; j<9; j++) {   //cycles through all settings of one user
          //user1 info
          if (j==0) {
            text(userSettings.getString(settings[j]+str(i))+units[j], xPositions[i], y=y+35);
          } else {
            text(float(userSettings.getString(settings[j]+str(i)))+units[j], xPositions[i], y=y+35);
          }
        }
      }
      break;
    }
  case getInput:
    {
      background(bgColor);
      textSize(16);

      user1.hide();
      user2.hide();
      user3.hide();
      user4.hide();
      stretchLen.show();
      TimeA.show();
      TimeB.show();
      TimeC.show();
      TimeD.show();
      Hours.show();
      Minutes.show();
      Seconds.show();
      sine.show();
      square.show();
      run.show();
      controlPanelLabel.show();
      loadUser.show();
      aux.hide();
      jogFwd.hide();
      jogBak.hide();
      tareButton.hide();
      startButton.hide();
      userBack.hide();
      eStopAux.hide();
      eStopResume.hide();

      if (loadedUser==true) {
        saveSettings.show();
        userName.show();
        if (displayedUser==false) {
          userName.setText(userSettings.getString("name"+userNumber));
          displayedUser=true;
        }
      }

      //dispaying user-selected pattern image
      if (sinWave == 1) {
        sine.setColorBackground(#4B70FF);
        square.setColorBackground(#002b5c);
        wavePattern = loadImage(topSketchPath+
          "/images/SinPattern.jpg");

        image(wavePattern, 505-130, 90, 500/1.3, 309/1.3);
      }

      if (squareWave == 1) {
        square.setColorBackground(#4B70FF);
        sine.setColorBackground(#002b5c);
        wavePattern = loadImage(topSketchPath+
          "/images/SquarePattern.jpg");

        image(wavePattern, 505-130, 90, 500/1.3, 309/1.3);
      }
      textSize(25);
      fill(0, 0, 0);
      text("Machine run time: ", 15, 395-70);

      stretchL = float(stretchLen.getText())*1000;
      timeA = float(TimeA.getText())*1000;
      timeB = float(TimeB.getText())*1000;
      timeC = float(TimeC.getText())*1000;
      timeD = float(TimeD.getText())*1000;
      cycleT = (timeA + timeB + timeC + timeD);

      //checking and displaying errors if needed
      checkErrors();
      if (hasError==true) {
        fill(#FF3B3B); //red
        textSize(15);
        for (int i=0; i<errors.size(); i++) {
          text(errors.get(i), 500, 370+(25*i));
        }
      }

      break;
    }
  case running:
    {
      displayedUser=false;

      //wipe last displayed timer off canvas
      background(bgColor);

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
      controlPanelLabel.hide();
      cancel.show();
      pause.show();
      resume.show();
      userName.hide();
      saveSettings.hide();
      loadUser.hide();
      eStopAux.hide();
      eStopResume.hide();

      //keep track of seconds to adjust timer
      if (start==1 && millis()<endTime) {
        if (millis()>=nextSec&&isPaused==false) {
          timerAdjust=int(millis()-nextSec);
          nextSec=millis()+1000-timerAdjust;

          secs--;
          if (secs<0) {
            mins--;
            secs=59;
          }

          if (mins<0) {
            hours--;
            mins=59;
          }
        }

        //displaying timer

        //making rectangles that border timer and settings
        fill(255, 255, 255);
        rect(37, 300, 370, 140);//for settings (x, y, len, wid)
        rect(417, 300, 340, 90);//for timer

        fill(0, 0, 0);

        //displaying settings
        textAlign(LEFT);
        int x=45, y=320;
        textSize(15);
        if (sinWave==1) {
          text("Wave: "+"Sinusoid", x, y);
        } else if (squareWave==1) {
          text("Wave: "+"Square", x, y);
        }
        text("Len: "+float(stretchLen.getText())+" mm", x, y+=25);
        text("Run Hrs: "+float(Hours.getText())+" hrs", x, y+=25);
        text("Run Mins: "+float(Minutes.getText())+" mins", x, y+=25);
        text("Run Secs: "+float(Seconds.getText())+" s", x, y+=25);
        text("A: "+float(TimeA.getText())+" s", x=250, y=320);
        text("B: "+float(TimeB.getText())+" s", x, y+=25);
        text("C: "+float(TimeC.getText())+" s", x, y+=25);
        text("D: "+float(TimeD.getText())+" s", x, y+=25);
        textFont(createFont("Arial Bold", 55, true));

        //displaying timer
        if (hours>9) {
          text(hours+":", 460, 365);
        } else {
          text("0"+hours+":", 460, 365);
        }

        if (mins>9) {
          text(mins+":", 560, 365);
        } else {
          text("0"+mins+":", 560, 365);
        }

        if (secs>9) {
          text(secs, 660, 365);
        } else {
          text("0"+secs, 660, 365);
        }
        textFont(createFont("Arial", 55, true));


        //sending waveforms
        lastt = currentt;
        currentT = millis()-(int)pauseShift;
        runT = (currentT - startT);   //time now to start
        roundN = Math.floor(runT/cycleT);   //which "round" of wave length are we on?
        cycleN = (int) roundN;
        currentt = (float) (runT - cycleN*cycleT);   //converts running time to limited domain loop (0 and runT)


        //calculating positions and velocities that define movement - kinematics

        // for square wave
        if (squareWave == 1&&isPaused==false) {
          if (currentt <= timeA) {   //for time segment A
            nextPosition1 = currentt/timeA * stretchL;  //nextPosition = x, x is a function of t(currentT)
            nextVel1 = stretchL/timeA*60;  //v(t)=x'(t), in this case V is independent of t(current T)
          } else if (currentt > timeA && currentt < (timeA + timeB)) {   //for time segment B
            nextPosition1 = stretchL;
            nextVel1 = 60;
          } else if (currentt >= (timeA+timeB) && currentt <= (timeA+timeB+timeC)) {   //for time segment C
            nextPosition1 = stretchL - (currentt - timeA - timeB)/timeC * stretchL;
            nextVel1 = stretchL/timeC*60;
          } else if (currentt > (timeA+timeB+timeC) && currentt < (timeA+timeB+timeC+timeD)) {   //for time segment D
            nextPosition1 = 0;
            nextVel1 = 60;
          }
        }

        // for sine wave
        if (sinWave == 1&&isPaused==false) {
          if (currentt <= timeA/2) {
            float nextt = currentt + currentt - lastt;
            nextPosition1 = (Math.sin(currentt/timeA * Math.PI-Math.PI*0.5)+1)*0.5*stretchL;
            nextVel1 = Math.max(60*Math.cos(nextt/timeA * Math.PI - Math.PI/2)*Math.PI*stretchL/(2*timeA), 10);
          }
          if (currentt > timeA/2 && currentt <= timeA) {
            nextPosition1 = (Math.sin(currentt/timeA * Math.PI-Math.PI*0.5)+1)*0.5*stretchL;
            nextVel1 = Math.max(60*Math.cos(lastt/timeA * Math.PI - Math.PI/2)*Math.PI*stretchL/(2*timeA), 10);
          } else if (currentt > timeA && currentt < (timeA + timeB)) {
            nextPosition1 = stretchL;
            nextVel1 = stretchL/timeA*60;
          } else if (currentt >= (timeA+timeB) && currentt <= (timeA+timeB+timeC/2)) {
            currentt = currentt - timeA - timeB;
            float nextt = currentt + currentt - lastt;
            nextPosition1 = (Math.sin(currentt/timeC * Math.PI+Math.PI*0.5)+1)*0.5*stretchL;
            nextVel1 = Math.max (Math.abs(60*Math.cos(nextt/timeC * Math.PI + Math.PI*0.5)*Math.PI*stretchL/(2*timeC)), 10);
          } else if (currentt >= (timeA+timeB+timeC/2) && currentt <= (timeA+timeB+timeC)) {
            currentt = currentt - timeA - timeB;
            nextPosition1 = (Math.sin(currentt/timeC * Math.PI+Math.PI*0.5)+1)*0.5*stretchL;
            nextVel1 = Math.max (Math.abs(60*Math.cos(lastt/timeC * Math.PI + Math.PI*0.5)*Math.PI*stretchL/(2*timeC)), 10);
          } else if (currentt > (timeA+timeB+timeC) && currentt < (timeA+timeB+timeC+timeD)) {
            nextPosition1 = 0;
            nextVel1 = stretchL/timeC*60;
          }
        }
      }

      //sending positions and velocities thorugh serial port to Arduino during running state
      if (millis()<endTime) {
        int nextP = -(int) nextPosition1;    //negative to flip direction
        float nextV = (float) nextVel1;
        String printthis = "p" + nextP + "\nv" + nextV + "\n";
        serialPort.write(printthis);
        System.out.println(printthis);
      } else {   //reseting some stuff when timer runs out
        currentState=State.returnInitPos;
        endTime=999999999;
        start=0;
        pauseShift=0;
        isPaused=false;
        returnInitPosTime=(int)Math.ceil(millis()+(Math.abs(nextPosition1))/5)+500;  //+500 to leave enough time for arduino to send proper state
      }

      //plotting during rinning state
      plot();
      stroke(0, 0, 0);
      strokeWeight(1);

      break;
    }

  case returnInitPos:  //returns stretcher to initially tared position after each stretch session
    {
      background(bgColor);
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
      user1.hide();
      user2.hide();
      user3.hide();
      user4.hide();
      userName.hide();
      saveSettings.hide();
      eStopAux.hide();
      eStopResume.hide();

      isTared=0;
      isAux=0;
      tareButton.setColorBackground(#002b5c);
      tareButton.setColorForeground(#4B70FF);
      aux.setColorBackground(#002b5c);
      aux.setColorForeground(#4B70FF);

      //resetting plot
      Arrays.fill(XYplotFloatData[0], 0);
      Arrays.fill(XYplotFloatData[1], 0);
      Arrays.fill(XYplotFloatData[2], 0);
      Arrays.fill(XYplotFloatData[3], 0);
      Arrays.fill(XYplotFloatData[4], 0);
      XYplotCurrentSize=0;
      clearPlotCounter=1;

      plotSetup=0;

      textAlign(LEFT);
      fill(0, 0, 0);
      textFont(createFont("Arial Bold", 55, true));
      text("Please Wait...", 300, 250);

      nextPosition1=0;  //making sure last run's 'nextPosition1' value gets reset
      if (millis()<returnInitPosTime) {
        int nextP =0;   //moving back to initial position so sample can be removed
        float nextV = 500;
        String printthis = "p" + nextP + "\nv" + nextV + "\n";
        serialPort.write(printthis);
        System.out.println(printthis);
        StateTransitionPause=millis()+100;
      } else {
        if (millis()>StateTransitionPause) {   //making sure arduino has time to change state before processing
          serialPort.write("B");

          //sending to hold state momentarily so machine will not skip past tare screen
          if (millis()>StateTransitionPause+100) {//more delay to make sure arduino state has transitioned before UI is set to tare state (to prevent occasional skipping of UI tare state)
            currentState=State.tare;
          }
        }
      }
      break;
    }

  case stopped:  //this state is mostly during Estop press
    {
      background(bgColor);
      //hide everything
      user1.hide();
      user2.hide();
      user3.hide();
      user4.hide();
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
      loadUser.hide();
      userName.hide();
      saveSettings.hide();
      aux.hide();
      jogFwd.hide();
      jogBak.hide();
      tareButton.hide();
      startButton.hide();
      userBack.hide();

      eStopAux.show();
      eStopResume.show();

      fill(255, 255, 255);
      rect(25, 25, 970-220, 400-120);
      fill(0, 0, 0); //red
      textFont(createFont("Arial Bold", 35, true));
      textAlign(CENTER);
      text("Emergency Stop Engaged", 400, 100);
      textAlign(LEFT);
      textFont(createFont("Arial ", 25, true));

      fill(#FF3B3B); //red
      text("1. Release THE EMERGENCY STOP button WHEN SAFE", 70, 170);
      fill(0, 0, 0);
      text("2. Press the AUX button ", 70, 220);
      text("3. Press the RESUME button to pick up where you left off", 70, 270);

      if (isAux==1) {
        eStopAux.setColorBackground(#0ACB15);
        eStopAux.setColorForeground(#5DFF5E);
      } else {
        eStopAux.setColorBackground(#002b5c);
        eStopAux.setColorForeground(#4B70FF);
      }

      if (displayAuxError==1) {
        fill(#FF3B3B); //red
        textSize(15);
        text("ERROR: Please AUX button before RESUME", 50, 340);
      }

      if (displayEstopError==1) {
        fill(#FF3B3B); //red
        textSize(15);
        text("ERROR: Please release ESTOP before AUX", 50, 365);
      }
      break;
    }
  }
}
