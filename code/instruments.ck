//simple program to play an OSC
public class oscInstruments{
    
    fun void awaiting(int speed, int freq){
        SinOsc s1 => JCRev reverb => dac;
        ((Math.random2f(0.98,1.02)*freq $ int) + 261 ) => s1.freq;
        Math.random2f(0.38,0.42) => float gain;
        
        for (0 => float i; i < 0.3; 0.02 +=> i)
        {
            i => s1.gain;
            5::ms => now;   
        }  
         
        gain => s1.gain;
        speed::ms => now;
        /*   
        while (gain > 0.01){
            0.95 => gain;
            (speed*0.1 $ int)::ms => now;   
        }
        */
        0 => s1.gain;
    }
    
    fun void oscS(int x, int y, int state){
        SqrOsc s => dac;
        Std.mtof(x + (y*7) + 48) => s.freq;
        0.3 => s.gain;
        200::ms => now;
        0 => s.gain;           
    }
    TriOsc t => JCRev reverb => dac;
    0 => t.gain;
    
    fun void oscP(int x, int y, int pressure){
        //<<<"Incomming Pressure :", pressure>>>;
        Std.mtof(x + (y*7) + 48) => float baseFreq;
        ((pressure $ float)/800)*baseFreq => t.freq;
        (pressure $ float)/1000 => float np;
        np * np * np => np;
        //<<<"np is ",np>>>;
        if (np > 0.35){
            np => t.gain;   
        }
        else{
            0 => t.gain;   
        }
        30::ms => now;
    }
    Gain master => JCRev reverb2 => dac;
    
    fun void blow(int x,int y,int z)
    {
        //<<<"Flute Called">>>;
        BlowHole flute => master;
        0.6 => master.gain; 
        Math.random2f(0.2,0.35) => flute.reed;
        (x+1)*(y+1) + 42 => float fluteTone;
        Math.random2f(-1.4,1.4) => flute.rate;
        Std.mtof(fluteTone) => flute.freq;
        1 => flute.noteOn;
        200::ms => now;
        Math.random2f(0.45,0.55) => flute.pressure;
        200::ms => now;
        1 => flute.noteOff;
        1 => flute.vent;
    }
}
