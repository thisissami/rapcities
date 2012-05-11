var sys = require('sys');

function Style(style, genre){
  this.style = style;
  this.genre = genre;
}

var genres = new Array();
genres.push(new Style("Techno","Electronic"));
  genres.push(new Style("Trance","Electronic"));
  genres.push(new Style("Dubstep","Electronic"));
  //genres.push(new Style("Jungle","Electronic"));
  genres.push(new Style("Drum and Bass","Electronic"));
  genres.push(new Style("House","Electronic"));
  genres.push(new Style("Ambient","Electronic"));
  genres.push(new Style("Trip-Hop","Electronic"));
  genres.push(new Style("Downtempo","Electronic"));
  genres.push(new Style("IDM","Electronic"));
  //pop
  genres.push(new Style("Dance Pop","Pop"));
  genres.push(new Style("Pop Rock", "Pop"));
  genres.push(new Style("Electropop","Pop"));
  genres.push(new Style("Indie Pop", "Pop"));
  genres.push(new Style("Teen Pop", "Pop"));
  genres.push(new Style("Europop", "Pop"));
  genres.push(new Style("Power Pop", "Pop"));
  genres.push(new Style("Country Pop","Pop"));
  genres.push(new Style("Pop Rap", "Pop"));
  //rock
  genres.push(new Style("Indie Rock", "Rock"));
  genres.push(new Style("Punk Rock", "Rock"));
  genres.push(new Style("Alternative Rock", "Rock"));
  genres.push(new Style("Progressive Rock", "Rock"));
  genres.push(new Style("Psychedelic Rock", "Rock"));
  genres.push(new Style("Heavy Metal", "Rock"));
  genres.push(new Style("Classic Rock", "Rock"));
  genres.push(new Style("Hard Rock", "Rock"));
  genres.push(new Style("Rap Rock", "Rock"));
  //hip hop
  genres.push(new Style("Gangsta Rap", "Hip Hop"));
  genres.push(new Style("G-Funk", "Hip Hop"));
  genres.push(new Style("East Coast Hip Hop", "Hip Hop"));
  genres.push(new Style("West Coast Hip Hop", "Hip Hop"));
  genres.push(new Style("Alternative Hip Hop", "Hip Hop"));
  genres.push(new Style("Southern Rap", "Hip Hop"));
  genres.push(new Style("Turntablism", "Hip Hop"));
  //jazz
  genres.push(new Style("Free Jazz", "Jazz"));
  genres.push(new Style("Acid Jazz", "Jazz"));
  genres.push(new Style("Cool Jazz", "Jazz"));
  genres.push(new Style("Smooth Jazz", "Jazz"));
  genres.push(new Style("Soul Jazz", "Jazz"));
  genres.push(new Style("Avant-Garde Jazz", "Jazz"));
  genres.push(new Style("Big Band", "Jazz"));
  genres.push(new Style("Bebop", "Jazz"));
  genres.push(new Style("Swing", "Jazz"));
  //r&b
  genres.push(new Style("Contemporary R&B", "R&B"));
  genres.push(new Style("New Jack Swing", "R&B"));
  genres.push(new Style("Doo-wop", "R&B"));
  genres.push(new Style("Funk","R&B"));
  genres.push(new Style("Disco","R&B"));
  genres.push(new Style("Soul","R&B"));
  genres.push(new Style("P-Funk","R&B"));
  //country/folk
  genres.push(new Style("Bluegrass", "Country/Folk"));
  genres.push(new Style("Rockabilly","Country/Folk"));
  genres.push(new Style("Americana","Country/Folk"));
  genres.push(new Style("Western","Country/Folk"));
  genres.push(new Style("Country Rock","Country/Folk"));
  genres.push(new Style("Neofolk","Country/Folk"));
  genres.push(new Style("Indie Folk", "Country/Folk"));
  genres.push(new Style("Progressive Folk", "Country/Folk"));
  genres.push(new Style("Folk Rock", "Country/Folk"));
  //Ska
  genres.push(new Style("Lovers Rock", "Ska"));
  genres.push(new Style("2 Tone", "Ska"));
  genres.push(new Style("Dub", "Ska"));
  genres.push(new Style("Dancehall", "Ska"));
  genres.push(new Style("Reggae Fusion", "Ska"));
  genres.push(new Style("Reggae", "Ska"));
  genres.push(new Style("Rocksteady", "Ska"));
  //blues
  genres.push(new Style("Boogie-Woogie","Blues"));
  genres.push(new Style("Country Blues", "Blues"));
  genres.push(new Style("Delta Blues","Blues"));
  genres.push(new Style("Electric Blues", "Blues"));
  genres.push(new Style("Jump Blues", "Blues"));
  genres.push(new Style("Piano Blues", "Blues"));
  //Latin
  genres.push(new Style("Bossa Nova", "Latin American"));
  genres.push(new Style("Salsa", "Latin American"));
  genres.push(new Style("Samba", "Latin American"));
  genres.push(new Style("Reggaeton", "Latin American"));
  genres.push(new Style("Mambo", "Latin American"));
  genres.push(new Style("Merengue", "Latin American"));
  genres.push(new Style("Tejano", "Latin American"));
  genres.push(new Style("Nueva Cancion", "Latin American"));
  genres.push(new Style("Tango", "Latin American"));
var moods = new Array();
moods.push('Happy');
moods.push('Sad');
moods.push('Angry');
moods.push('Trippy');
moods.push('Dark');
moods.push('Epic');
moods.push('Sweet');
moods.push('Sexy');
moods.push('Funky');
moods.push('Relaxed');

var spawn = require('child_process').spawn, gscript;
var pos = 0; 
var length = genres.length;
console.log('total length: ' + length);

gartist();
//gogenre();
function gogenre(){
  if(pos < length){
    gscript = spawn('node', ['populate.js', 'genre',genres[pos].genre, genres[pos].style]);
    gscript.stdout.on('data', function(data){
      sys.puts(data);
      //console.log(data);
    });
    gscript.on('exit',function(code){
      if(code != 0)
        console.log('SOME KIND OF ERROR');
      pos++;
      gogenre();
    });
  }
  else{
    console.log('done with genre. onto moods!');
    length = moods.length;
    pos = 0;
    gomood();
  }
}

function gomood(){
    if(pos < length){
      gscript = spawn('node',['populate.js','mood',moods[pos]]);
      gscript.stdout.on('data', function(data){
        sys.puts(data);
        //console.log(data);
      });
      gscript.on('exit',function(code){
        if(code != 0)
          console.log('SOME KIND OF ERROR');
        pos++;
        gomood();
      });
    }
    else{
      console.log('done with mood. onto the next thing!');
      process.exit();
      pos = 0;
      gartist();
    }
}

function gartist(){
  if(pos < 3){
    console.log('getting facebook info, attempt numba ' + pos);
    gscript = spawn('node',['artist.js']);
    gscript.stdout.on('data', function(data){
      sys.puts(data);
    });
    gscript.on('exit',function(code){
      if(code != 0)
        console.log('SOME KIND OF ARTIST ERROR');
      pos++;
      gartist();
    });
  }
  else{
    console.log('doing da facebook!');
    gscript = spawn('node',['facebook.js']);//facebook info!
    gscript.stdout.on('data', function(data){
      sys.puts(data);
    });
    gscript.on('exit',function(code){
      console.log('facebook done!');
      geo();
    });
  }
}

function geo(){
  gscript = spawn('node',['geo.js']);
  gscript.stdout.on('data', function(data){
    sys.puts(data);
  });
  gscript.on('exit',function(code){
    console.log('FINISHED WITH IT ALL!');
    process.exit();
  });
}
  
process.on("SIGTERM", function() {
   console.log("Parent SIGTERM detected");
   // exit cleanly
   process.exit();
});

process.on("exit", function() {
  console.log('exiting');
});
