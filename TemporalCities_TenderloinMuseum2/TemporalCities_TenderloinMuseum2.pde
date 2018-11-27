/*Basic rotary phone recorder and playback machine. For use with Arduino and a phone.
*--------------------------
*This code reads strings from Arduino and then uses the Minim player to record and playback a series of audio files
*/

import processing.serial.*; 
import ddf.minim.*;
import java.io.*;


 
Minim minim;
AudioInput in;
AudioRecorder recorder; 
AudioPlayer player;
AudioPlayer player2; 
AudioPlayer player3;
AudioPlayer player4;



Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port 
int recordingCount = 0;
int current = 0;
String recordingPrefix = "recording";

int operatorCount = 0;
int currento = 0;
String operatorPrefix = "operator";


void setup() {
  minim = new Minim(this);
  
  in = minim.getLineIn();
  
  
  
  player3 = minim.loadFile("dialtone_mixdown.wav"); //load the dial tone track
  player4 = minim.loadFile("phonebeep.wav"); // load the answering machine tone
  
  File folder = new File("/Users/lizzy/Documents/Processing/TemporalCities_TenderloinMuseum2");
  File[] listOfFiles = folder.listFiles();

    for (int i = 0; i < listOfFiles.length; i++) {
      if (listOfFiles[i].isFile() && listOfFiles[i].getName().startsWith(recordingPrefix)) {
        println("File " + listOfFiles[i].getName());
        recordingCount++;
      }
    }
    recorder = minim.createRecorder(in, recordingPrefix + (recordingCount - 1) +".wav"); //record audio to the file myrecording.wav in the sketch root folder
    current = (int)(Math.random() * recordingCount);
    player2 = minim.loadFile(recordingPrefix + current + ".wav"); //load the recorded file for playback (this file should exist in the folder before you open the sketch for the first time. It will be written over each time) 
  
     println("Found " + recordingCount + " recordings, using " + current + " as initial recording");
   
/*   for (int i = 0; i < listOfFiles.length; i++) {
      if (listOfFiles[i].isFile() && listOfFiles[i].getName().startsWith(operatorPrefix)) {
        println("File " + listOfFiles[i].getName());
        operatorCount++;
      }
    }
   
   currento = (int)(Math.random() * operatorCount); */
   player = minim.loadFile("operator.mp3"); // load the operator track
//   println ("Found " + operatorCount + " operators, using " + currento + " as initial operator");
   
   
    String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600); 
 
}

void draw()
{

background(0);
 
readSerial(); //read the data coming from arduino

if (val.equals("play operator")){  //if you get the string for operator, play that file
   //   currento = (int)(Math.random() * operatorCount);
  //    println("Attempting to load file " + operatorPrefix + currento + ".wav");
  //    player = minim.loadFile(operatorPrefix + currento + ".wav");
      player.play();
      println("playing operator");
  
}

if (val.equals("play dialtone")){  //if you get the string for operator, play that file
      player3.play();
      println("playing dial tone");
  
}
  
 if (val.equals("stop operator")){ //if you got the sign to shut up, do so:
 
    player.pause(); //silence the operator 
    player.rewind(); //go back to the beginning of the song
    player2.pause(); // silence the recorded file
    player2.rewind(); // rewind the recorded file
    player3.pause(); // silence the dial tone
    player3.rewind(); // rewind the dial tone file
    player4.pause(); // silence the answering machine tone (even though it's already over)
    player4.rewind();// rewind the record after the tone file
    
   if ( recorder.isRecording() ) // if the recorder is still going, close it and save the file
    {
      recorder.endRecord();
      recorder.save();
    }
    println("shhhh");
 }
  
  if (val.equals("play response")){ //if you get the sign to play the recorded file, do so
    current = (int)(Math.random() * recordingCount);
    println("Attempting to load file " + recordingPrefix + current + ".wav");
    player2 = minim.loadFile(recordingPrefix + current + ".wav"); 
    player2.play();
    println("playing recorded message " + recordingPrefix + current + ".wav");
  }
  
  if (val.equals("record")){  //if you get the sign to record, do so
  player4.play();
  recordingCount++;
  String newFileName = recordingPrefix + (recordingCount - 1) + ".wav";
  File newRecording = new File(newFileName);
  if (!newRecording.exists()) {
    try {
      newRecording.createNewFile();
      println("Created file " + recordingCount);
      current = recordingCount;
    } catch (java.io.IOException e) {
      println("Could not create file " + newFileName);
    }
  } else {
    println("File already existed!");
  }
  
    recorder = minim.createRecorder(in, newFileName, true);
    println("recording message");
    recorder.beginRecord();
    
  }
  


}
void readSerial(){
     do{
    val = myPort.readStringUntil('\n');         // read incoming data and store it in val 
    } while (val == null);
  val=trim(val);
    
  }
