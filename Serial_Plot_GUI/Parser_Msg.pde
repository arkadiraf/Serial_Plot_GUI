// Parse Message class

////Setup serial objects
//void setup_Serial() {
//  // check if serial ports are defined
//  if (Serial.list().length<myPorts.length) {
//    cp5.getController("b_serial").setColorBackground(b_serial_color_off);
//    if (DEBUG_MODE) {
//      println("Not enough serial ports ", Serial.list().length, myPorts.length);
//    }
    
//  // not supported 2 serial ports for now 
//  //} else if (Serial.list().length>=2) {
//  //  // if serial ports aren't defined, set default ports:
//  //  if ((myPorts[0]==null)||(myPorts[1]==null)) {
//  //    serial_port_open(0, 0);// port num - the serial port to define ,  port_def the defined serial port
//  //    serial_port_open(1, 1);
//  //    cp5.get(ScrollableList.class, "serial_data").setValue(0); // update dropdown serial_data
//  //    cp5.get(ScrollableList.class, "serial_TTL").setValue(1); // update dropdown serial_data
//  //  }
  
//    if (DEBUG_MODE) {
//      printArray(Serial.list());
//      printArray(myPorts);
//      printArray(myPortsNames);
//    }
//  }
//}

// open port
void serial_port_open(int _port_num, int _port_def) { // port num - the serial port to define ,  port_def the defined serial port
  int port_num=_port_num;
  int port_def=_port_def;
  // stop previous defined port
  if (myPorts[port_def]!=null) {
    myPorts[port_def].stop(); 
    myPorts[port_def] = null;
    myPortsNames[port_def]="";
  }
  // check if port isn`t defined yet
  String serial_port_temp=Serial.list()[port_num];
  if (!myPortsNames[(port_def+1)%2].equals(serial_port_temp)) {
    // define port
    try {
      myPorts[port_def] = new Serial(this, Serial.list()[port_num], serial_baudrate);
      myPorts[port_def].bufferUntil(10); // lf = 10 = /n
      myPortsNames[port_def]=Serial.list()[port_num]; // update names
    }
    catch(Exception e) {
      System.err.println("Error opening serial port " + myPorts[_port_def]);
      println(e.getMessage());
      e.printStackTrace();
    }
  }
}
// Parse message from both ports
void parse_msg_IMU(String _incoming_str) {
  String incoming_str=_incoming_str;
  // add data integrity test to reduce crash events
  if (incoming_str==null) { // verify data available
    println("no Data available "+incoming_str);
  } else {
    String[] msg_split=split(incoming_str, ':');
    // verify split successful and data available:
    if (msg_split.length==2) {
        if (msg_split[0].equals("MSG")) {
        float[] data_values = float(split(msg_split[1], ','));
        if (data_values.length==8){
          if (DEBUG_MODE) {
            println("data "+data_values);
          }
        // update data points
        //data_points_update[0]=data_values[2]; // first value seconds
        data_points_update[0]=(data_values[0]/1000)%1; // first value seconds
        data_points_update[1]=data_values[2]; // Acc X
        data_points_update[2]=data_values[3]; // Acc Y
        data_points_update[3]=data_values[4]; // Acc Z
        // Update chart data:
        update_chart_data();
        //println("data not valid "+data_values);
        }else{
          println("data not valid "+data_points_update[0]);
        }
      }
    }else{
      println("data not valid "+msg_split);
    }
  }
}

// Parse message from both ports
void parse_msg_MIC(String _incoming_str) {
  String incoming_str=_incoming_str;
  // add data integrity test to reduce crash events
  if (incoming_str==null) { // verify data available
    println("no Data available "+incoming_str);
  } else {
    float[] data_values = float(split(incoming_str, ','));
    data_points_update[0]=data_values[0]; 
    update_chart_data();
    // print recieved data
    // println(data_values[0]);
  }
}
