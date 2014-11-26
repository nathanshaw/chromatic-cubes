 //Tester function for the Chronome
me.dir() + "/instruments.ck" => string oscInstrument;
Machine.add(oscInstrument) => int instrument;

me.dir() + "/cubes_0_1_player_places.ck" => string oscCommunication;
Machine.add(oscCommunication) => int communication;

1::week => now;

Machine.remove(instrument);
Machine.remove(communication);

