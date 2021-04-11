

configuration MehulAppC{}

implementation{
	components MainC, LedsC, MehulC as MehulC;  // here instead of App we can also use _ or another alias

	components new TimerMilliC() as Timer0;
	components new TimerMilliC() as Timer1;
	components new TimerMilliC() as Timer2;

	MainC.Boot <- MehulC.Boot;

	//LedsC are numbered in TinyOS, as different platforms have different color LEDs

	LedsC.Leds <- MehulC.Leds;
	Timer0 <- MehulC.Timer0;
	Timer1 <- MehulC.Timer1;
	Timer2 <- MehulC.Timer2;
	
	components SerialPrintfC;
	
	
	components new SensirionSht11C() as TemperatureSensor;	//For temperature, Please Note Sensor SensirionSht11C :  provides us with both 
	TemperatureSensor.Temperature <- MehulC.ReadingTemperature; //temperature and Humidity Readings
	
	
	components new HamamatsuS10871TsrC() as LightSensor;	//For Light
	LightSensor <- MehulC.ReadingLight ;
	
	
	components new SensirionSht11C() as HumiditySensor;	//For Humidity
	HumiditySensor.Humidity <-MehulC.ReadingHumidity ;		
	
	components ActiveMessageC;
	components new AMSenderC(SIGNAL_RADIO) as Signal_SenderC;
	components new AMReceiverC(SIGNAL_RADIO) as Rev_SenderC;
	
	Signal_SenderC <- MehulC.Packet;
	Signal_SenderC <- MehulC.SignalPacket;
	Signal_SenderC <- MehulC.SignalSend; 				// AMSend sends a radio message
	ActiveMessageC <- MehulC.SplitControl;  			// SplitControl starts and stops the radio
	Rev_SenderC    <- MehulC.Receive;
	
}
