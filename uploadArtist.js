var mongodb = require('mongodb'),
  mongoserver = new mongodb.Server('10.112.0.110', 26374),
  //mongoserver = new mongodb.Server('localhost', 26374),
  dbConnector = new mongodb.Db('uenergy', mongoserver);
dbConnector.open(function(err, DB){
    if(err){
      console.log('oh shit! connector.open error!');
      console.log(err.message);
    }
    else{
      db = DB;
      console.log('opened successfully');
      db.createCollection('artistLocations2', function(err, artlocs){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
	console.log('artist locations created');
	locs = artlocs;
});
}
});

function uploadLoc(response, query){
	console.log(query);
	locs.insert(query, {safe:true}, function(err, doc){
		if(err){console.log('ruh-roh! scooby dooby scawedy booby! (AKA artist upload failed)')}
		else{
			response.writeHead(200, {'Content-Type': 'application/json'});
			var returned = {'name':query.name};
			response.end(JSON.stringify(returned));
		}
	});
}

function getLocs(response, query){
    if(query.minX){
        var minX = parseFloat(query.minX);
        var minY = parseFloat(query.minY);
        var maxX = parseFloat(query.maxX);
        var maxY = parseFloat(query.maxY);
        var maxL = Math.min(maxX-minX,maxY-minY)/6.0;
        sort = query.sort;
        if(minX < 0 || maxX > 1 || minY < 0 || maxY > 1){
                console.log('getSongs attempt with inappropriate bounds');
                return;
              }
			  
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
              if(sort==1){locs.find(doc, {'sort':[['hottness','desc']],'limit':1},postFind);}
              else if(sort==2){locs.find(doc, {'sort':[['hottness','asc']],'limit':1},postFind);}
              else{locs.findOne(doc, postFind);}
              
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

function songFunc(err, artist){
  if(err){
    console.log('oh shit! error using returned.nextObject!');
    console.log(err);
    count--;
    if(count == 0)
      sendData(results, response);
  }
    else if(artist != null){
        results.push(artist);
        count--;
        if(count == 0){
          sendData(results, response);
        }
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
    else{ //if no query variables
        locs.find({}/*,{'_id':true,'topTracks':true,'7id':true,'x':true,'y':true}*/).toArray(function(err, results){
            if(!err){
                //var data = {}
                //data['results'] = results;
                response.writeHead(200, {'Content-Type': 'application/json'});
                response.end(JSON.stringify(results));
            }
        });
    }
}

exports.uploadLoc = uploadLoc;
exports.getLocs = getLocs;