var mongodb = require('mongodb'),
  mongoserver = new mongodb.Server('localhost', 26374),
  dbConnector = new mongodb.Db('uenergy', mongoserver),
  http = require('http');

var base = '/api/v4/song/search?api_key=AOGW6OBBGGYABOKGX&sort=song_hotttnesss' +
    '-desc&bucket=id:7digital-US&limit=true&bucket=audio_summary&bucket=tracks&result' +
    's=20&bucket=artist_familiarity&bucket=artist_hotttnesss&bucket=artist_location' +
    '&bucket=song_hotttnesss';
    
var request = {}
request['host'] = 'developer.echonest.com';
request['port'] = 80;
      
var done = false; 
var MINX = MINY = 0,
    MAXX = MAXY = stepSize = 0.2;

dbConnector.open(function(err, db){
  if(err){
    console.log('oh shit! connector.open error!');
    console.log(err.message);
  }
  else{
    console.log('opened successfully');
    db.createCollection('artists', function(err, artists){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err.message);
        return;
      }
      console.log('artists created');
      db.createCollection('songs', function(err,songs){
        if(err){
          console.log('db.create songs error');
          console.log(err);
          return;
        }
        intervalID = setInterval(doNext, 600, artists, songs);
      });
    });
  }
});
var mode = process.argv[2];
if(mode == 'genre'){//if style/genre
  genre = process.argv[3];
  style = process.argv[4];
  styleweb = style.replace(/ /g, '%20');
  styleweb = styleweb.replace(/&/g, '%26');
  console.log(style+ ' but actually ' +styleweb);
}
else{//if mood
  mood = process.argv[3];
  console.log(mood);
}
var done = false;
var count = 0;
var total = 0;
var newtotal= 0;
/*var inscount = 0;
var intcount = 0;
var errcount = 0; */

function doNext(artists, songs){
  var suffix = '&min_danceability=' + MINX + '&max_danceability=' + MAXX +
      '&min_energy=' + MINY + '&max_energy=' + MAXY + '&start=0';
  if(mode == 'genre')
    suffix += '&style=' + styleweb;
  else
    suffix += '&mood=' + mood;
  request['path'] = base+suffix;
  if(MAXY != 1){
    MINY = MAXY;
    MAXY = parseFloat(Number(MAXY + stepSize).toFixed(3));
  }
  else if(MAXX != 1){
    console.log('Currently at: ' +MINX+'-'+MAXX+' X and '+MINY+'-'+MAXY+' Y\n');
    MINX = MAXX;
    MAXX = parseFloat(Number(MAXX + stepSize).toFixed(3));
    MINY = 0;
    MAXY = stepSize;
  }
  else{
    console.log('\nFIN (almost)');
    if(mode == 'genre'){
      console.log('genre: ' + genre);
      console.log('style: ' + style);
    }
    else
      console.log('mood: ' + mood);
    clearInterval(intervalID);
    done = true;
  }
  count++;
  http.get(request, function(response){
    var body = '';
    response.on('data', function(data){
      body += data;
    });
    response.on('end', function(){
      var results = JSON.parse(body);
      if(results.response.status.code == 0){
        var length = results.response.songs.length;
        total+=length;
        for(var i = 0; i < length; i++){
          var returnedSong = results.response.songs[i];
          var artID = returnedSong['artist_id'];
          if(returnedSong['artist_name'] == undefined){continue;}//no-name artists not allowed!
          (function(song, artid){
            songs.findOne({'_id':song.id}, function(err,obj){
              if(err){
                console.log('find one err: ' + err);
              }
              else if(obj != null && mode == 'genre' && obj.song.genre == genre){
                /*var len = obj.song.genre.length;
                var found = false;
                for(var j = 0; j < len; j++){
                  if(obj.song.genre[j] == genre){found=true;}
                }
                //~ if(!found){obj.song.genre.push(genre);} */  // CODE FOR MULTIPLE GENRES
                
                // NOTE THE ORDER NEEDS TO BE GENRE -> MODE FOR THIS TO WORK PROPERLY
                obj.song.style.push(style);
                songs.findAndModify({'_id':obj.song.id},[['_id','asc']],obj,{},function(err){
                  if(err){console.log('find and modify error: '+err);}
                });
              }
              else if(obj != null){
                /*obj.song.mood.push(mood);
                songs.findAndModify({'_id':obj.song.id},[['_id','asc']],obj,{},function(err){
                  if(err){console.log('find and modify error: '+err);}
                });*/
              }
              else{
                newtotal++;
                var input = {}
                input['_id'] = song.id;
                if(mode == 'genre'){
                  //~ song['genre'] = new Array(genre); // CODE FOR MULTIPLE GENRES
                  song['genre'] = genre;
                  song['style'] = new Array(style);
                  artists.insert({'_id':artid,'genre':genre});
                }
                else{
                  song['mood'] = mood;
                  artists.insert({'_id':artid,'mood':mood});
                }
                input['song'] = song;
                //inscount++;
                songs.insert(input);//,{safe:true},function(err,obj2){if(err){console.log(err.message);errcount++;inscount--;}
                //else{inscount--; intcount++;}})
              }
            });
          })(returnedSong,artID);
        }
        if(count == 25){lexit();}
          //console.log('internal: '+intcount);console.log('errors: '+errcount);console.log('insert count: '+inscount);}
      }
      else if(count == 25){lesadexit1(request,results);}else{console.log(results);}
    });
  }).on('error',function(e){ if(count == 25){lesadexit2(e);}else{console.log('request error');
    console.log('without stringification: ' + e);
}
    });
    }

function lexit(){
  console.log('done');console.log('total: '+total);console.log('new: '+newtotal); setTimeout(process.exit,2000,[0]);
}

function lesadexit1(request, results){
  console.log(results);setTimeout(process.exit,2000,[1]);
}
