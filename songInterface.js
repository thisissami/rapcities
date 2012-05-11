var fs = require('fs');
var mongodb = require('mongodb'),
  mongoserver = new mongodb.Server('localhost', 26374),
  dbConnector = new mongodb.Db('uenergy', mongoserver);
dbConnector.open(function(err, DB){
    if(err){
      console.log('oh shit! connector.open error!');
      console.log(err.message);
    }
    else{
      db = DB;
      console.log('opened successfully');
    db.createCollection('songs', function(err, song){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
        console.log('songs created');
        songs = song;
        db.createCollection('rbDE', function(err, rb){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
        console.log('rb created');
        rbDE = rb;
        db.createCollection('hiphopDE', function(err, hiphop){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
        console.log('hiphop created');
        hiphopDE = hiphop;
        db.createCollection('skaDE', function(err, ska){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
        console.log('ska created');
        skaDE = ska;
        db.createCollection('latinDE', function(err, latin){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
        console.log('latin created');
        latinDE = latin;
        db.createCollection('countryDE', function(err, country){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
        console.log('country created');
        countryDE = country;
        db.createCollection('bluesDE', function(err, blues){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
        console.log('blues created');
        bluesDE = blues;
        db.createCollection('electroDE', function(err, electro){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
        console.log('electro created');
        electroDE = electro;
        db.createCollection('rockDE', function(err, rock){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
        console.log('rock created');
        rockDE = rock;
        db.createCollection('popDE', function(err, pop){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
        console.log('pop created');
        popDE = pop;
        
    db.createCollection('jazzDE', function(err, jazz){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
        console.log('jazz created');
        jazzDE = jazz;
        
    db.createCollection('moodDE', function(err, mood){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
        console.log('moods created');
        moodDE = mood;
    });});});});});});});});});});});});
  }
  });

function getSongs(response, query){
  var minX = parseFloat(query.minX);
  var minY = parseFloat(query.minY);
  var maxX = parseFloat(query.maxX);
  var maxY = parseFloat(query.maxY);
  var maxL = Math.min(maxX-minX,maxY-minY)/6;
  sort = query.sort;
  genre = query.genre;
  if(minX < 0 || maxX > 1 || minY < 0 || maxY > 1){
            console.log('getSongs attempt with inappropriate bounds');
            return;
          }
  if(genre){
      var geo;
      switch(parseInt(genre)){
        case 0: geo = bluesDE; genre = 'Blues'; break;
        case 1: geo = countryDE; genre = 'Country/Folk'; break;
        case 2: geo = electroDE; genre = 'Electronic'; break;
        case 3: geo = hiphopDE; genre = 'Hip Hop'; break;
        case 4: geo = jazzDE; genre = 'Jazz'; break;
        case 5: geo = latinDE; genre = 'Latin American'; break;
        case 6: geo = popDE; genre = 'Pop'; break;
        case 7: geo = rbDE; genre = 'R&B'; break;
        case 8: geo = rockDE; genre = 'Rock'; break;
        case 9: geo = skaDE; genre = 'Ska'; break;
        default: return;
      }
      getResults(geo);
  }
  else{
      getResults(moodDE);
  }//else


function getResults(geo){
          var results = new Array();
          var mnx, mxx, mxy, mny; //current min and max x and ys
          var px, py; //current x/y pos
          var count = 36;
          for(var i = 0; i<6; i++){
            if(i == 0)
              mnx = minX;
            else
              mnx = mxx;
            mxx = lerp(minX, maxX, (i+1)/6);
            for(var j = 0; j<6; j++){
              if(j == 0)
                mny = minY;
              else
                mny = mxy;
              mxy = lerp(minY, maxY, (j+1)/6);
              
              var pos = {}
              if(!sort){// && maxL > 0.025){
                //console.log('mnx '+mnx+' mxx '+mxx+' mny '+mny+' mxy '+mxy);
                px = map(parseFloat(Math.random()),0,1,mnx,mxx);
                py = map(parseFloat(Math.random()),0,1,mny,mxy);
                //console.log('px: ' + px + '  py: '+py+'\n');
                pos['$near'] = [px,py]; 
                pos['$maxDistance'] = maxL;//0.02;
              }
                //console.log(JSON.stringify(pos));
              else{
                var within = {}
                within['$box'] = [[mnx,mny],[mxx,mxy]];
                pos['$within'] = within;
              }
              
              var doc = {'pos':pos};
              //doc['pos'] = pos;
              if(sort==1){geo.find(doc, {'sort':[['hottness','desc']],'limit':1},postFind);}
              else if(sort==2){geo.find(doc, {'sort':[['hottness','asc']],'limit':1},postFind);}
              else{geo.findOne(doc, postFind);}
              
function postFind(err, returned){
  if(err){
    console.log('oh shit! error using geo.find!');
    console.log(err.message);
      count--;
      if(count == 0)
        sendData(results, response);
    }
    else if(sort){returned.nextObject(songFunc);}
    else{songFunc(err,returned);}
    
}

function songFunc(err, song){
  if(err){
    console.log('oh shit! error using returned.nextObject!');
    console.log(err);
    count--;
    if(count == 0)
      sendData(results, response);
  }
    else if(song != null){
      songs.findOne({'_id':song._id}, function(err, input){
        if(err){
        console.log('songs.findOne error.');
        console.log(err.message);
        count--;
        if(count == 0)
          sendData(results, response);
        }
        else{
        if(genre)
          input.song.genre = genre;
        results.push(input);
        count--;
        if(count == 0){
          sendData(results, response);
        }
      }
    });
  }
  else{
    count--;
    if(count == 0){
      sendData(results, response);
    }
  }
}             
              
              
            }
          }
  }

function sendData(results, response){
  var data = {}
  data['results'] = results;
  response.writeHead(200, {'Content-Type': 'application/json'});
  response.end(JSON.stringify(results));
}

function map(num, minold, maxold, minnew, maxnew){
  return ((num-minold)/(maxold - minold))*(maxnew - minnew) + minnew;
}

function lerp(min, max, i){
  return min+((max-min)*i);
}

}

exports.getSongs = getSongs;
