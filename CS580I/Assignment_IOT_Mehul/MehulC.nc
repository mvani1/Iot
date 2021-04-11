#include <Timer.h>		// Bidirectional1 imcro  Generic interface.
#include <stdio.h>
#include <string.h>
#include "Transmitter_Header.h"

module MehulC
{	// all the interfaces that are going to be used in the program
	
	uses{	 
		interface Boot;							// Boot Interface
		interface Leds;							// Leds Interface

		interface Timer<TMilli> as Timer0;
		interface Timer<TMilli> as Timer1;				//Timer interfaces
		interface Timer<TMilli> as Timer2;
		
		interface Read<uint16_t> as ReadingTemperature;
		interface Read<uint16_t> as ReadingLight;			// Sensors interface
		interface Read<uint16_t> as ReadingHumidity;
		
		interface Packet;
		interface AMPacket as SignalPacket;
		interface AMSend as SignalSend;					// Radio interfaces
		interface SplitControl;
		interface Receive;
	
}
}

implementation{

	bool signalBusy = FALSE;		// A flag declared so that asyncronous operation could be done and no preemption occurs

	// There could be multiple packets or a single packet for this program as a flag is used to distinguish.
		// 1. Single packets
		// 2. Multiple apcket - > //message_t packet0,packet1,packet2;

	message_t packet;					

	 			

	// Timers are required so that they can be collect the data from the sensors and send that data
	// hence three timers are required for two sensors.(as one of the sensor collects temp. and humidity both)

	event void Boot.booted(){
		call Timer0.startPeriodic(1000);			// this function calls the Timer0.fired()
		call Timer1.startPeriodic(2000);			// this function calls the Timer1.fired()
		call Timer2.startPeriodic(4000);			// this function calls the Timer2.fired()
		call SplitControl.start();
	}

	
	event void Timer0.fired(){
		call ReadingTemperature.read();		// Sensing the data from the Temperature sensor every 1 second	
	}

		
	event void Timer1.fired(){
		call ReadingLight.read();		// Sensing the data from the Light sensor every 2 second
	}

	
	event void Timer2.fired(){
		call ReadingHumidity.read();		// Sensing the data from the Humidity sensor every 4 second
	}

	
// The below 3 function  generates a 16-bit value provides Read<uint16_t>. If the provider of Read return SUCCESS to a call to read, then it will signal readDone in the future , passing the Read's result back as the val parameter to the event handler.
 
	event void ReadingTemperature.readDone(error_t result, uint16_t val){
		
		if(signalBusy == FALSE){
			Message* message = call Packet.getPayload(& packet, sizeof(Message));     
			message -> NetworkId = TOS_NODE_ID;
			message -> Data = val;
			message -> Flag = 1;

			// sending Temperature Packet

			if(message -> NetworkId == 1){
				if(call SignalSend.send(AM_BROADCAST_ADDR,& packet, sizeof(Message)) == SUCCESS){
					call Leds.led0Toggle();		//Led0 toggles for the temperature data
					signalBusy = TRUE;
				
				}
			}
			
		}
	
	}

	event void ReadingLight.readDone(error_t result, uint16_t val){
		if(signalBusy == FALSE){
			Message* message = call Packet.getPayload(& packet, sizeof(Message));
			message -> NetworkId = TOS_NODE_ID;
			message -> Data = val;
			message -> Flag = 2;

			// sending Light Packet

			if(message -> NetworkId== 1){
				if(call SignalSend.send(AM_BROADCAST_ADDR,& packet, sizeof(Message)) == SUCCESS){
					
					
					call Leds.led1Toggle();	//LED toggles when getting the data of light sensor
					signalBusy = TRUE;	
				
				}
			}
			
		}
	}

	event void ReadingHumidity.readDone(error_t result, uint16_t val){
		if(signalBusy == FALSE){
			Message* message = call Packet.getPayload(& packet, sizeof(Message));
			message -> NetworkId = TOS_NODE_ID;
			message -> Data = val;
			message -> Flag = 3;

			// sending Humidity Packet

			if(message -> NetworkId == 1){
				if(call SignalSend.send(AM_BROADCAST_ADDR,& packet, sizeof(Message)) == SUCCESS){
					call Leds.led2Toggle();	//LED toggles for humidity
					signalBusy = TRUE;
				}
			}
			
		}

	}
	

	event void SplitControl.startDone(error_t error){ }
	
	event void SignalSend.sendDone(message_t* msg, error_t error){
		signalBusy = FALSE;						// Provider pass the pointer back to the user after the a Success
	}
	
	// A Receive handle can always copy needed data out of the packet and just returns the passed buffer

	event message_t * Receive.receive(message_t* msg, void *payload, uint8_t len){

		if(len == sizeof(Message)){
			 Message* incoming = (Message*)payload;
			 uint16_t data = incoming -> Data;
			 uint8_t sensors = incoming -> Flag;
			 
			 switch(sensors){
			 case 1: 
				printf("Temp: %d \r\n", data);
				call Leds.led0Toggle();
				break;
			 case 2: 
				printf("Light: %d \r\n", data);
				call Leds.led1Toggle();
				break;
			 case 3: 
				printf("Humidity: %d \r\n", data);
				call Leds.led2Toggle();
				break;
			} 				
		}
	return msg;				
	}
	
	event void SplitControl.stopDone(error_t error){}	
	

}
