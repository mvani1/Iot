#ifndef Transmiter_Header
#define Transmiter_Header

typedef nx_struct Transmit{

	nx_uint16_t 	NetworkId; 		// NodeID
 	nx_uint8_t 	Data; 			// contains Data
	nx_uint16_t 	Flag; 			//If different packets are used for each sensor data then we will need a flag otherwise there will be 							//no need of the flag because a single pac1ket recive and send data at a time
	
}Message;

enum{	
	SIGNAL_RADIO = 6; 
};

#endif
