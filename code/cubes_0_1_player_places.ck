//OSC

"/monome" => string prefix; 

//initial send and receive
OscSend xmit;
xmit.setHost("localhost", 12002);

OscRecv recv;
8000 => recv.port;
recv.listen ();

//request devices
xmit.startMsg("/serialosc/list", "si");
"localhost" => xmit.addString;
8000 => xmit.addInt;

//wait for response
recv.event("/serialosc/device", "ssi") @=> OscEvent discover;
discover => now;

string serial; string devicetype; int port;

oscInstruments oscInstrument;//the file that holds all the sound

2 => int settings;//the amound of different settings allowed for

2 => int mode;//0 is color select 1 is gameboard 2 is "reset/boot"

while(discover.nextMsg() != 0){
    discover.getString() => serial;
    discover.getString() => devicetype;
    discover.getInt() => port;
    <<<serial, " ", devicetype, " ", port, " ">>>;
}

//set host to device port
<<<"using device on port: ", port>>>;
xmit.setHost("localhost", port);

//connect to device 
xmit.startMsg("/sys/info", "si");
"localhost" => xmit.addString;	
8000 => xmit.addInt;

//set prefix
xmit.startMsg("/sys/prefix", "s");
prefix => xmit.addString;
<<<"setting prefix to ", prefix>>>;
//Arrays for storing color data
int RED[8][8];
int GREEN[8][8];
int BLUE[8][8];
int BOARD[8][8];

int currentColor;
35 => float refreshRate;
1.0 => float level;

for (0 => int bx; bx < 8; bx++){
    for (0 => int by; by < 8; by++){
        10 => BOARD[bx][by];
    }
}

fun void printBOARD(){
    for (0 => int bx; bx < 8; bx++){
        for (0 => int by; by < 8; by++){
            <<<BOARD[bx][by]>>>;
        }
    }
}

fun void testBlinkAll(int repeats, int speed, string prefix_){//flashes all leds at given rate//used at begenning/end of game

for(0 => int i; i < repeats; i++){
    if (speed < 9){//to ensure it runs smoothly
        10 => speed;   
    }
    xmit.startMsg(prefix_ +"/grid/led/all", "i");
    xmit.addInt(1);
    speed::ms => now;
    xmit.startMsg(prefix_ + "/grid/led/all", "i");
    xmit.addInt(0);
    speed::ms => now;
    spork ~oscInstrument.oscS(Math.random2(2,8),Math.random2(2,8), 1);  
}
}


fun void randomTest(int length, int onNum, int offNum, int speed, string prefix_){
    /*
    This function acts as a tester for the drum samples and the LEDS
    --------------------
    
    length : determines the number of times you want cycle through loop
    
    onNum : the number of lights randomly turned off
    
    offNum : the number of lights randomly turned off (function does not automatically turn off LEDS that just turned on
    
    speed : the delay time between each loop
    
    prefix_ : the chronome's prefix 
    -----------------
    
    */
    for(0 => int i; i < length; i++){//overall loop for entire function
        for (0 => int t; t< onNum; t++){//loop for turning on random LED to random color
            Math.random2(0,7) => int x;
            Math.random2(0,7) => int y;
            sendRGB(x,y,Math.random2(0, 127), Math.random2(0,127),Math.random2(0, 127), 1, prefix_);
            speed::ms => now;
            spork ~oscInstrument.blow(x,y,1);
            for (0 => int r; r < offNum; r++){//loop for turning off random lights
                sendWhite(Math.random2(0,7), Math.random2(0,7), 0, prefix_);
            }
        }
    }
}
///variables for testIndividual()
0 => int counter;
0 => int ora;
.75 => float equal;
2.5 => float lCut;
6 => float fRange;


//sweeps through grid and recolors all LED's
fun void testIndividual(int repeats, int speed, string prefix_){
    
    if (speed < 8){
        8 => speed;   
    }
    if(counter%2 == 0){
        Math.random2(4,7) => ora;
    }
    else{
        Math.random2(0,3) => ora;
    }
    if (ora == 0){
        for(0 => int i; i < repeats; i++){
            Math.random2(60,127) => int red;
            Math.random2(60,127) => int green;
            Math.random2(60,127) => int blue;
            for (7 => int by; by >= 0; by--){
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorR;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorG;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorB;
                if(factorR == 0){1 => factorR;};
                if(factorG == 0){1 => factorG;};
                if(factorB == 0){1 => factorB;};   
                for (0 => int bx; bx < 8; bx++){
                    assignButtonColor(bx, by, red, green, blue, factorR, factorG, factorB, equal, lCut, fRange);
                    speed::ms => now;
                }
            }
        }
    }
    else if (ora == 1){
        for(0 => int i; i < repeats; i++){
            Math.random2(70,127) => int red;
            Math.random2(70,127) => int green;
            Math.random2(70,127) => int blue;
            
            for (7 => int by; by >= 0; by--){
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorR;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorG;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorB;
                if(factorR == 0){1 => factorR;};
                if(factorG == 0){1 => factorG;};
                if(factorB == 0){1 => factorB;};
                for (7 => int bx; bx >= 0; bx--){
                    assignButtonColor(bx, by, red, green, blue, factorR, factorG, factorB, equal, lCut, fRange);
                    speed::ms => now;              
                }
            }
        }
    }
    else if (ora == 2){
        for(0 => int i; i < repeats; i++){
            Math.random2(70,127) => int red;
            Math.random2(70,127) => int green;
            Math.random2(70,127) => int blue;
            
            for (0 => int by; by < 8; by++){
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorR;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorG;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorB;
                if(factorR == 0){1 => factorR;};
                if(factorG == 0){1 => factorG;};
                if(factorB == 0){1 => factorB;};                for (7 => int bx; bx >= 0 ; bx--){
                    assignButtonColor(bx, by, red, green, blue, factorR, factorG, factorB, equal, lCut, fRange);  
                    speed::ms => now;         
                }
            }
        }
    }
    else if (ora == 3){
        for(0 => int i; i < repeats; i++){
            Math.random2(70,127) => int red;
            Math.random2(70,127) => int green;
            Math.random2(70,127) => int blue;
            
            for (0 => int by; by < 8; by++){
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorR;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorG;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorB;
                if(factorR == 0){1 => factorR;};
                if(factorG == 0){1 => factorG;};
                if(factorB == 0){1 => factorB;};
                for (0 => int bx; bx < 8; bx++){
                    assignButtonColor(bx, by, red, green, blue, factorR, factorG, factorB, equal, lCut, fRange);  
                    speed::ms => now;        
                }
            }
        }
    }
    else if (ora == 4){
        for(0 => int i; i < repeats; i++){
            Math.random2(70,127) => int red;
            Math.random2(70,127) => int green;
            Math.random2(70,127) => int blue;
            
            for (7 => int bx; bx >= 0; bx--){
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorR;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorG;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorB;
                if(factorR == 0){1 => factorR;};
                if(factorG == 0){1 => factorG;};
                if(factorB == 0){1 => factorB;};
                for (0 => int by; by < 8; by++){
                    assignButtonColor(bx, by, red, green, blue, factorR, factorG, factorB, equal, lCut, fRange);   
                    speed::ms => now;     
                }
            }
        }
    }
    else if (ora == 5){
        for(0 => int i; i < repeats; i++){
            Math.random2(70,127) => int red;
            Math.random2(70,127) => int green;
            Math.random2(70,127) => int blue;
            
            for (7 => int bx; bx >= 0; bx--){
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorR;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorG;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorB;
                if(factorR == 0){1 => factorR;};
                if(factorG == 0){1 => factorG;};
                if(factorB == 0){1 => factorB;};
                for (7 => int by; by >= 0; by--){
                    assignButtonColor(bx, by, red, green, blue, factorR, factorG, factorB, equal, lCut, fRange);   
                    speed::ms => now;  
                }
            }
        }
    }
    else if (ora == 6){
        for(0 => int i; i < repeats; i++){
            Math.random2(70,127) => int red;
            Math.random2(70,127) => int green;
            Math.random2(70,127) => int blue;
            
            for (0 => int bx; bx < 8; bx++){
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorR;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorG;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorB;
                if(factorR == 0){1 => factorR;};
                if(factorG == 0){1 => factorG;};
                if(factorB == 0){1 => factorB;};
                for (7 => int by; by >= 0 ; by--){
                    assignButtonColor(bx, by, red, green, blue, factorR, factorG, factorB, equal, lCut, fRange);  
                    speed::ms => now;  
                }
            }
        }
    }
    else  {
        for(0 => int i; i < repeats; i++){
            Math.random2(70,127) => int red;
            Math.random2(70,127) => int green;
            Math.random2(70,127) => int blue;
            
            for (0 => int bx; bx < 8; bx++){
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorR;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorG;
                (Math.random2f(-fRange,fRange)*level/2) $ int => int factorB;
                if(factorR == 0){1 => factorR;};
                if(factorG == 0){1 => factorG;};
                if(factorB == 0){1 => factorB;};                
                for (0 => int by; by < 8; by++){
                    assignButtonColor(bx, by, red, green, blue, factorR, factorG, factorB, equal, lCut, fRange);   
                    speed::ms => now;
                }
            }
        }
    }   
    counter++;//what do i count?
}

//overly complicated function that semi-randomly assigns a new color an LED
fun void assignButtonColor(int dx, int dy, int red, int green, int blue, int factorR, int factorG, int factorB, float equal, float lCut, float fRange){
    .75 => float equal;
    2.5 => float lCut;
    6 => float fRange;
    if (red + factorR > 127 || red + factorR < factorR){
        -1 *=> factorR;  
        
    }
    
    if (green + factorG > 127 || green + factorG < factorG){
        -1 *=> factorG;
    }
    if (blue + factorB > 127 || blue + factorB < factorB){
        -1 *=> factorB;
    }       
    ///
    if (blue < red && blue < green){
        0 => blue;
        Math.abs(factorB) => factorB;
    }
    if (red < blue && red < green){
        0 => red;   
        Math.abs(factorR) => factorR;
    }
    if (green < red && green < blue){
        0 => green;   
        Math.abs(factorG) => factorG;       
    }
    if (level < lCut){
        if (green > red && green > blue){
            //127 => green;
            (red  * equal $ int) => red;
            (blue  * equal $ int) => blue;
        }
        if (red > green && red > blue){
            //127 => red;
            (green  * equal $ int) => green;
            (blue  * equal $ int) => blue;
        }
        if (blue > red && blue > green){
            //127 => blue;
            (red  * equal $ int) => red;
            (green * equal $ int) => green;
        }
    }
    //
    factorR +=> red;
    factorB +=> blue;
    factorG +=> green;
    //
    if (red < 0){
        127 => red;
    }
    if (green < 0){
        127 => green;   
    }
    if (blue < 0){
        127 => blue;   
    }
    if (red > 127){
        0 => red;
    }
    if (green > 127){
        0 => green;   
    }
    if (blue > 127){
        0 => blue;   
    }                    
    red => RED[dx][dy];
    green => GREEN[dx][dy];
    blue => BLUE[dx][dy];
    
    if (mode == 0){
        sendRGB(dx, dy, red, green , blue,  1, prefix);
        spork ~oscInstrument.blow(dx,dy,1);
    }
}

fun void buttonPress(string prefix_){
    recv.event( prefix_ + "/grid/key", "iii") @=> OscEvent oe;
    int x;
    int y;
    int state;
    
    while(true){	
        oe => now;
        
        // read all msgs in the current OSC buffer
        while(oe.nextMsg() != 0){
            oe.getInt() => x;
            oe.getInt() => y;
            oe.getInt() => state;
        }
        
        if (mode == 0 && state == 1){
            getColor(x,y) => currentColor;
            clearBoard(60);
            playingBoard();
            1 => mode;
            0 => state;
        }
        if (mode == 1 && state == 1){//if the mode is in the playing board then place colors.
            int levelF;//scales down the 'master' level to something usable in cube genration
            ((level*0.09) $ int) => levelF;
            for ((Math.random2(-2,-1) - levelF) => int cx; cx < (Math.random2(0,3) + levelF); cx++){
                if((cx + x) < 8 && cx + x >= 0){
                    for ((Math.random2(-2,-1) - levelF) => int cy; cy < (Math.random2(0,3) + levelF); cy++){
                        if((cy + y) < 8 && cy + y >= 0){
                            sendWhite((cx + x),(cy + y),0, prefix_);
                            75::ms => now;
                            if (currentColor == 0){
                                sendRGB((x+cx),(y+cy), 127, 0, 0, 1, prefix_);
                                sendRGB(x,y, 127, 0, 0, 1, prefix_);         
                            }
                            else if(currentColor == 1){
                                sendRGB((x+cx),(y+cy), 0, 127, 0, 1, prefix_); 
                                sendRGB(x,y, 0, 127, 0, 1, prefix_);                            
                            }
                            else if (currentColor == 2){
                                sendRGB((x+cx),(y+cy), 0, 0, 127, 1, prefix_);
                                sendRGB(x,y, 0, 0, 127, 1, prefix_);
                            }
                            else if (currentColor == 3){
                                sendRGB((x+cx),(y+cy), 110, 127, 0, 1, prefix_);
                                sendRGB(x,y, 110, 127, 0, 1, prefix_);
                            }
                            else{
                                <<<"Error current color = ", currentColor, "It needs to be 0-3">>>;   
                            }
                            currentColor => BOARD[x+cx][y+cy];
                            spork ~oscInstrument.blow(x+cx,y+cy,1);
                        }
                        currentColor => BOARD[x][y];
                    }
                }
            }
            850::ms => now;//allow players to see board for a period of time before it gpes back to color select mode.
            0 => mode; //change back to color select mode
            0.937 *=> refreshRate;//make the color select scream refresh faster
            0.18 +=> level;//make the game harder
            <<<"New Level is :", level>>>;
        }  
    }
}

fun void clearBoard(int length)
{
    /*
    basically just a function that flashes the lights on the board
    */
    xmit.startMsg(prefix + "/grid/led/all", "i");
    xmit.addInt(1);
    length::ms => now;
    xmit.startMsg(prefix +"/grid/led/all", "i");
    xmit.addInt(0);
    200::ms => now;
}

fun int getColor(int x, int y){
    /*
    //function gets color data from LED and determines what band has the greatest value (red green or blue)
    //it then send back an int which determines which color
    //  
    ------------------------
    Returns :
    ------------------------
    color  : an int that shows which color is most dominant in the chosen LED
    
    0  :  Red
    1  :  Green 
    2  :  Blue
    3  :  yellow
    
    --------------------------
    */
    RED[x][y] => int red;
    GREEN[x][y] => int green;
    BLUE[x][y] => int blue;
    if (red > green && red > blue){
        return 0;
    }
    else if(green > red && green > blue){
        return 1;
    }
    else if(blue > red && blue > green){
        return 2;
    }
    else{
        return 3;  
    }
}

fun void sendWhite(int x, int y, int state, string prefix_){
    xmit.startMsg(prefix_ + "/grid/led/set", "iii");
    x => xmit.addInt;
    y => xmit.addInt;
    state => xmit.addInt;
}

fun void sendRGB(int x, int y, int r, int g, int b, int send, string prefix_){
    //<<<"x = ", x, " : y = ", y, " : r = ", r, " : g =", g, " : b =", b>>>;   
    xmit.startMsg(prefix_ + "/grid/led/color", "iiiii");//set color
    x => xmit.addInt;
    y => xmit.addInt;
    r => xmit.addInt;
    g => xmit.addInt;
    b => xmit.addInt;
    //turn it on
    sendWhite(x,y,send,prefix_);   
}

fun void playingBoard(){
    //<<<"Entered the PlayingBoard">>>;
    
    for (0 => int cx; cx < 8; cx++){
        for (0 => int cy; cy < 8; cy++){
            if (BOARD[cx][cy] == 0){
                sendRGB(cx,cy, 127, 0, 0, 1, prefix);       
            }
            else if(BOARD[cx][cy] == 1){
                sendRGB(cx,cy, 0, 127, 0, 1, prefix);                            
            }
            else if (BOARD[cx][cy] == 2){
                sendRGB(cx,cy, 0, 0, 127, 1, prefix);
            }
            else if (BOARD[cx][cy] == 3){
                sendRGB(cx,cy, 110, 127, 0, 1, prefix);
            }
            else if (BOARD[cx][cy] > 3){
                sendRGB(cx,cy, 0, 0, 0, 0, prefix);
            }
            else{
                sendWhite(cx,cy,0, prefix);
                //<<<"Error current color = ", currentColor, "It needs to be 0-3">>>;   
            }
            //<<<"Setting Board Position : ",cx, cy , ": to prefix :", BOARD[cx][cy]>>>;
        }
    }
}
//checks board to see if the win conditions have been met
fun int checkWin(){
    
    0 => int R;
    0 => int G;
    0 => int B;
    0 => int C;
    0 => int counter;
    
    for (0 => int cx; cx < 8; cx++){
        for (0 => int cy; cy < 8; cy++){
            if (BOARD[cx][cy] < 4)//if square is assigned a color
            {
                counter++; //count up
            }
        }
    }
    if (counter > 63){//if all cubes are assigned a color...
        0 => int value;
        playingBoard();
        1::second => now;
        <<<"-------------------------">>>;
        <<<"Game Over">>>;
        <<<"-------------------------">>>;
        <<<"Game Level : ",level>>>;
        for (0 => int bx; bx < 8; bx++){
            for (0 => int by; by < 8; by++){
                BOARD[bx][by] => value;
                if (value < 1){
                    R++;
                }
                else if (value < 2){
                    G++;
                }
                else if (value < 3){
                    B++;    
                }
                else{
                    C++;   
                }
            }
        }
        <<<"-------------------------------------">>>;
        <<<"Red Count = ", R, " Green Count = ", G, " Blue Count =", B, "Computer Count :", C >>>;
        <<<"-------------------------------------">>>;
        1.3::second => now;
        2 => mode;//set to 'intro' mode
        <<<"Board is reset, you may play again">>>;
        return 2;//someone won
    }
    return 1;//no one won
}

//sets all cubes to blank within the game board
fun void resetBoard(){
    for (0 => int bx; bx < 8; bx++){
        for (0 => int by; by < 8; by++){
            10 => BOARD[bx][by];    
        }
    }
}

//loop for running random test
spork ~buttonPress(prefix);

while (true){   
    20::ms => now;
    if (mode == 0){//mode 0 is the 'color select' screen
        testIndividual(1, (refreshRate $ int), prefix);
    }
    else if( mode == 1){//mode 1 is the playing board
        
        playingBoard();  
        if (checkWin() == 2){
            resetBoard();
        } 
        200::ms => now;
    }
    else if(mode ==2){
        //<<<"Mode is not 0 or 1">>>;
        for (20 => int i; i < 120; 5 +=> i){
            testBlinkAll(i/10,i/5, prefix);
        }
        35 => refreshRate;//reset refresh rate
        1.0 => level;//reset level
        1::second => now;
        0 => mode;//back to game
    }
}
