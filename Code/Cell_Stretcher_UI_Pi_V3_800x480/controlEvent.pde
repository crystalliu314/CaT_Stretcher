void controlEventContents(ControlEvent theEvent) {

  //getting the event
  if (theEvent.isController()) {
    String parameter=theEvent.getController().getName();
    print(theEvent);

    String value = "";

    value = theEvent.getValue()+"";

    if (parameter == "input speed") {
      mmtkVel = float(value);
      serialPort.write("V" + mmtkVel + "\n");
    }

    if (parameter == "Run") {
      println("run pressed");

      if (hasError==false) {
        start=1;
        currentState=State.running;
        loadedUser=false;
        startT=millis();
        hours=int(Hours.getText());
        mins=int(Minutes.getText());
        secs=int(Seconds.getText());
        stretchL=float(stretchLen.getText())*1000;

        runTime=hours*3600 +mins*60 +secs;  //in seconds
        endTime=millis()+runTime*1000;
        nextSec=millis()+1000;
      }
    }

    if (parameter == "Square") {
      squareWave = 1;
      sinWave = 0;
      square.setColorBackground(#4B70FF);
      sine.setColorBackground(#002b5c);
    }

    if (parameter == "Sinusoid") {
      sinWave = 1;
      squareWave = 0;
      sine.setColorBackground(#4B70FF);
      square.setColorBackground(#002b5c);
    }

    if (parameter == "Cancel") {
      if (isPaused==true) {
        isPaused=false;
      }

      //reset everything
      currentState=State.returnInitPos;
      endTime=999999999;
      start=0;
      pauseShift=0;
      returnInitPosTime=(int)Math.ceil(millis()+(Math.abs(nextPosition1))/5);
    }

    if (parameter == "pause") {
      isPaused=true;
      pauseStart=millis();
      pause.setColorBackground(#4B70FF);
      resume.setColorBackground(#002b5c);
    }

    if (parameter == "resume") {
      if (isPaused==true) {
        isPaused=false;
        pauseFin=millis();
        endTime=endTime+(pauseFin-pauseStart);   //readjust endTime
        pauseShift+=(pauseFin-pauseStart);
        nextSec+=pauseFin-pauseStart;

        resume.setColorBackground(#4B70FF);
        pause.setColorBackground(#002b5c);
      }
    }

    if (parameter=="user1") {
      userNumber=0;
      getUserSettings(userNumber);
      currentState=State.getInput;
    }
    if (parameter=="user2") {
      userNumber=1;
      getUserSettings(userNumber);
      currentState=State.getInput;
    }
    if (parameter=="user3") {
      userNumber=2;
      getUserSettings(userNumber);
      currentState=State.getInput;
    }
    if (parameter=="user4") {
      userNumber=3;
      getUserSettings(userNumber);
      currentState=State.getInput;
    }

    if (parameter=="Save Settings") {  //retrieves and writes settings to json file
      userSettings.setString("name"+userNumber, userName.getText());
      userSettings.setString("stretchLength"+userNumber, stretchLen.getText());
      userSettings.setString("timeA"+userNumber, TimeA.getText());
      userSettings.setString("timeB"+userNumber, TimeB.getText());
      userSettings.setString("timeC"+userNumber, TimeC.getText());
      userSettings.setString("timeD"+userNumber, TimeD.getText());
      userSettings.setString("hours"+userNumber, Hours.getText());
      userSettings.setString("mins"+userNumber, Minutes.getText());
      userSettings.setString("secs"+userNumber, Seconds.getText());
      if (sinWave==1) {
        userSettings.setString("wavePattern"+userNumber, "sine");
      } else if (squareWave==1) {
        userSettings.setString("wavePattern"+userNumber, "square");
      }
      // stretchLen, TimeA, TimeB, TimeC, TimeD, Hours, Minutes, Seconds, userName;
      saveJSONObject(userSettings, topSketchPath+"/users.json");
    }

    if (parameter=="Load User") {
      loadedUser=true;
      displayedUser=false;
      currentState=State.userProfile;
    }

    if (parameter=="Back") {
      loadedUser=false;
      currentState=State.getInput;
    }

    if (parameter=="Aux") {
      if (firstAux==true&& eStop==1) {
        displayEstopError=1;
      }
      firstAux=true;
      serialPort.write("A");
    }

    if (parameter=="Tare") {
      if (isAux==1) {
        serialPort.write("T");
      } else {
        displayAuxError=1;
      }
    }

    if (parameter=="Ready") {
      if (isTared==1 && isAux==1) {
        serialPort.write("R");
      } else {
        displayTareError=1;
      }
    }

    if (parameter=="eStopAux") {
      if (firstEstopAux==true&& eStop==1) {
        displayEstopError=1;
      }
      firstEstopAux=true;
      serialPort.write("A");
    }
    if (parameter=="eStopResume") {
      if (isAux==1) {
        serialPort.write("R");
        currentState=lastCurrentState;
        eStopAux.setColorBackground(#002b5c);
        eStopAux.setColorForeground(#4B70FF);
        savedLastState=false;
        if (currentState==State.running||currentState==State.returnInitPos) {
          if (isPaused==true) {
            isPaused=false;
            pauseFin=millis();
            endTime=endTime+(pauseFin-pauseStart);   //readjust endTime to account for time stopped
            pauseShift+=(pauseFin-pauseStart);
            nextSec+=pauseFin-pauseStart;
            returnInitPosTime+=pauseFin-pauseStart;
          }
        }
      } else {
        displayAuxError=1;
      }
    }
  }
}
