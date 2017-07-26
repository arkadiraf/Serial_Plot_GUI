/////////////////////////////////////////////////////////////
// Serial GUI - Arkadi & Alon 8/1/2017 - arkadiraf@gmail.com //
/////////////////////////////////////////////////////////////
// Ver 1.7 - finishes//
///////////////////////////////////////////

///////////////////////////////////////////
// To fix /////////////////////////////////
///////////////////////////////////////////
/*

 */

/*
Future features:
 - connect button, add option to press disconnect in order to reset connection.
 */

// Debug mode.
boolean DEBUG_MODE=false;

// interface mode
boolean FMRI_MODE=false;
boolean MOUSE_MODE=true;
boolean DATA_MODE=false;
////////////////
// libraries: //
////////////////
import controlP5.*;
import java.awt.Font;
import processing.serial.*;

// Import Java libraries (file handling)
import java.util.stream.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.LineNumberReader;

// buffered file handler
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.IOException;


/////////////
// Object  //
/////////////
//declare cp5 main object
ControlP5 cp5;
// add drop down
ScrollableList serialPortsList_1, serialPortsList_2;

// add serial objects
Serial[] myPorts;
String[] myPortsNames;
int serial_baudrate;
boolean serial_connect_flag=false;

// declare graphs array
Chart_Frame[] chart_array;

// declare text objects cp5
Textlabel serial_port_label, file_label;

///////////////////
// GUI variables //
///////////////////

// windows dimention
//int win_height = 720;
//int win_width = 1280;
int win_height = 900;
int win_width = 1600;

// declare GUI variables
int number_of_charts; // max 10
int chart_width;
int chart_height;
int button_height;
int slide_height;
int slide_width;
float  graph_off_x, graph_off_y, graph_off_w;
String[] chart_lable_string;
// buttons
int button_width;
boolean b_start_state = false;

//////////////////////////////////
// data variables
//////////////////////////////////
// live mode status
boolean LIVE_MODE=true;

// Data variables
int glob_datapoints=1000;
float[] data_points_update;
//setting data range
float[] data_min_range, data_max_range;

// file zoom buffer variables
int max_zoom_buffer;
int current_zoom_buffer;

// data integrity test variable
long sample_counter_record=0;

//////////////////////////////////
// Output file variables
//////////////////////////////////

// define path for file selector
File output_folder;
File output_file;
String output_file_name = "";
String output_file_path;
boolean output_file_status = false;
// buffered file manager
BufferedWriter writer = null;

//////////////////////////////////
// Input file variables
//////////////////////////////////

// Define input file variables
String input_file_name = "";
String input_file_path;
boolean input_file_status = false;
File input_file;
// define buffered reader
BufferedReader reader = null;

// Define input string data variables
String[] input_string_buffer;

// number of lines in file
long line_count = 0;


//////////////////////////////
// parameter initialization //
//////////////////////////////
void settings() {

  // set window size
  size(win_width, win_height);

  //init FMRI variables
  if (FMRI_MODE) { 
    Init_FMRI_Variables();
  } else if (MOUSE_MODE) {
    Init_Mouse_Demo_Variables();
  } else { 
    Init_Variables();
  };
  //Init_Mouse_Demo_Variables();
}
/////////////// 
// GUI setup //
///////////////

void setup() {
  // set GUI screen 
  surface.setTitle("Serial_GUI");
  surface.setResizable(true);
  background(255, 255, 255);
  setup_GUI();
  //frameRate(60);
}

///////////////
// Main loop //
///////////////
void draw() {
  // set gui backround
  background(win_bg_color);

  // update data based on mouse data
  if ((MOUSE_MODE)&&(LIVE_MODE)) {
    //mouse_draw();
    for (int ii=0; ii<1; ii++) { // performance test
      mouse_draw();
    }
  } else if ((DATA_MODE)&&(LIVE_MODE)) { // data integrity mode
    //mouse_draw();
    for (int ii=0; ii<100; ii++) { // performance test
      data_draw_test();
    }
  }// end live mode

  // chek for windows resize
  resize_check();
  // update GUI
  draw_GUI();
  if (DEBUG_MODE) {
    println(frameRate);
  }
}

///////////////
// Functions //
///////////////
// check resize window
void resize_check() {
  // dumb method to detect window resize:
  if ((win_height!=height)||(win_width!=width)) {
    win_height=height;
    win_width=width;
    //surface.setSize(win_width, win_height);
    cp5.setGraphics(this, 0, 0); // fixes resize out of bondary issue
    if (DEBUG_MODE) {
      println(millis(), win_height, win_width);
    }
    //delay(100);
    resize_GUI();
  }
}

// update data based on mouse data:
void mouse_draw() {
  // update data points
  data_points_update[0]=mouseY;
  data_points_update[1]=mouseX;
  data_points_update[2]=mouseY-mouseX;
  data_points_update[3]=(mouseY+mouseX)/2;

  // Update chart data:
  update_chart_data();
}

// update data based on data test
void data_draw_test() {
  sample_counter_record++;
  long temp=sample_counter_record;
  // update data points
  data_points_update[0]=temp%1000;
  temp=temp/1000;
  data_points_update[1]=temp%10;
  temp=temp/10;
  data_points_update[2]=temp%10;
  temp=temp/10;
  data_points_update[3]=temp%10;
  temp=temp/10;
  data_points_update[4]=temp%10;
  // Update chart data:
  update_chart_data();
}

////////////////////////
// update charts data //
////////////////////////
void update_chart_data() {
  // move data buffer by one
  for (int jj=0; jj< chart_array.length; jj++) {
    for (int i = 1; i < chart_array[jj].chart_data.length; i++) {
      chart_array[jj].chart_data[i-1]=chart_array[jj].chart_data[i];
    }
  }
  ///////////////////
  // update charts //
  ///////////////////
  for (int jj=0; jj< chart_array.length; jj++) {  
    chart_array[jj].chart_data[chart_array[jj].chart_data.length-1]=data_points_update[jj]; // update buffer value
    chart_array[jj].myChart.push("incoming", chart_array[jj].chart_data[chart_array[jj].chart_data.length-1]);

    // example additional charts
    //chart_array[jj].myChart.push("layer_1", chart_array[jj].chart_data[chart_array[jj].chart_data.length-1]+200*cos(0.001*millis()*TWO_PI));
    //chart_array[jj].myChart.push("layer_2", chart_array[jj].chart_data[chart_array[jj].chart_data.length-1]+500*sin(0.001*millis()*TWO_PI));
  }

  /////////////////
  // record data //
  /////////////////
  String buffer_record="REC: ";
  buffer_record+=millis()+"\t";
  for (int jj=0; jj< chart_array.length; jj++) {  
    buffer_record+=chart_array[jj].chart_data[chart_array[jj].chart_data.length-1]+"\t";
  }
  record_line(buffer_record);
}

////////////
// Events //
////////////

// Serial event
void serialEvent(Serial p) {
  // get new data line
  String incoming_msg_temp=p.readString();
  // verify data available  
  if (incoming_msg_temp==null) {
    //if (DEBUG_MODE) {
    println("no Data available "+incoming_msg_temp);
    //}
  } else {
    if (DEBUG_MODE) {
      println(incoming_msg_temp);
    }
    // parse incoming data
    if ((FMRI_MODE)&&(LIVE_MODE)) parse_msg_FMRI(incoming_msg_temp);
  }
} // end serial event