var http = require('http');
var api = require('7digital-api'),
	artistes = new api.Artists();
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
	  db.createCollection('artists', function(err, artlocsupload){
	  if(err){
	  console.log('creation error'); console.log(err); return;
	  }
	  arts = artlocsupload;
	console.log('artist locations created');
	locs = artlocs;
	
	db.createCollection('sponsorEvents', function(err, even){
		if(err){ console.log('creationevent error'); console.log(err); return;}
		events = even;
	});
});});
}
});

function uploadLoc(responses, query){
	var base = '/api/v4/artist/search?api_key=AOGW6OBBGGYABOKGX&limit=true&bucket=id:7digital-US&results=1&format=json';
	var request = {
	  'host' : 'developer.echonest.com',
	  'port' : 80
	}
	
	console.log(query);
	locs.insert(query, {safe:true}, function(err, artistt){
		if(err){console.log('ruh-roh! scooby dooby scawedy booby! (AKA artist upload failed)'); console.log(err); returnError(responses,err.message);}
		else{
			var artist = artistt[0];
			//get from echonest the information for this artist ID
		      request['path'] = base + '&name=' + (((artist.name).replace(/ /g, '%20')).replace(/&/g, '%26'));
		      console.log('Getting info from artist: ' + artist.name);

		      http.get(request, function(response) {
		        var body = '';
		        response.on('data', function(data) {
		          body += data;
		        });

		        response.on('end', function() {
		          var results = JSON.parse(body);
		          if(results.response.status.code == 0) {
		            echo_artist = results.response.artists[0];
					if(echo_artist && echo_artist.id){
		console.log(JSON.stringify(echo_artist));
					var id7 = echo_artist.foreign_ids[0].foreign_id.split(':')[2];
					artistes.getTopTracks({artistId:id7}, function(err,data){
						if(err){
							console.log("7digital top tracks error:");
							console.log(err);
							returnError(responses,'7digital error: '+err.message);
						}
						else{
							var i;
							var top = new Array();
							for(i = 0; i < data.tracks.track.length; i++){
								var cur = {
									'title': data.tracks.track[i].title,
									'id': data.tracks.track[i].id,
									'duration': data.tracks.track[i].duration,
									'explicit': data.tracks.track[i].explicitContent
								}
								top.push(cur);
							}
							var trackCount = 0; var trackTotal = top.length;
							for(i = 0; i < trackTotal; i++){
								(function(cur){
									var request2 = {
										'host': 'gdata.youtube.com',
										'port': 80,
										'path': "/feeds/api/videos?q="+top[cur].title.replace(/ /g,'+')+"+"+artist.name.replace(/ /g, '+')+"&v=2&alt=jsonc&max-results=1&format=5"
									}
									http.get(request2, function(respons){
										var bod = '';
									    respons.on('data', function(data){
									      bod += data;
									    });
									    respons.on('end', function(){
											//console.log(body);
									      	var results = JSON.parse(bod);
											//console.log(results);					
											trackCount++;
											if(results.data.items){
										        var video_id = results.data.items[0].id;
												top[cur].video_id = video_id;
										    }
											if(trackCount == trackTotal){
												var k;
												var flag = false; 
												for(k = 0; k < trackTotal; k++){
													var id = top[k].video_id;
													var j; 
													for(j = k+1; j < trackTotal; j++){
														if(top[j].video_id == id){
															top[j].flag = true;
															flag = true;
														}	
													}
												}
												if(flag){
													for(k = trackTotal-1; k>=0; k--){
														if(top[k].flag)
															top.splice(k,1);
													}
												}
					locs.findAndModify({'_id':artist._id}, [['_id','asc']],
					{$set : {
						'echoID': echo_artist.id,
							'7id': echo_artist.foreign_ids[0].foreign_id,
							'topTracks' : top
					}},function(err){if(err)console.log(err);
						else{
							request['path'] = '/api/v4/artist/profile?api_key=AOGW6OBBGGYABOKGX&bucket=id:facebook&id='+echo_artist.id;
							http.get(request, function(response2){
						        var body2 = '';
						        response2.on('data', function(data){
						          body2 += data;
						        });
						        response2.on('end', function(){
						          var results = JSON.parse(body2);
						          if(results.response.status.code == 0){
									if(results.response.artist != undefined && results.response.artist.foreign_ids != undefined && results.response.artist.foreign_ids[0].foreign_id != undefined){
										var facebook = 'http://facebook.com/pages/';
										var fbookarr = results.response.artist.foreign_ids[0].foreign_id.split(':');
						                  facebook += fbookarr[1]+'/'+fbookarr[2];
						            	locs.findAndModify({'_id':artist._id}, [['_id','asc']],
										{$set : {
											'facebook': facebook
										}},function(err,toBeReturned){if(err)console.log(err)
										else{
											request['path'] = '/api/v4/artist/profile?api_key=AOGW6OBBGGYABOKGX&bucket=news&bucket=biographies&bucket=blogs&bucket=images&bucket=video&id='+echo_artist.id;
											http.get(request, function(response3){
										        var body3 = '';
										        response3.on('data', function(data) {
										          body3 += data;
										        });

										        response3.on('end', function() {
										          var results = JSON.parse(body3);
										          if(results.response.status.code == 0) {
										            curartist = results.response.artist;
													console.log(curartist);
													var artistinfo = {
														'_id' : echo_artist.id,
														'7id':echo_artist.foreign_ids[0].foreign_id,
														'name':echo_artist.name,
														'biographies' : curartist.biographies,
										                'blogs' : curartist.blogs,
										                'images' : curartist.images,
										                'news' : curartist.news,
										                'videos': curartist.video
													}
										            arts.insert(artistinfo, {safe: true}, function(err) {
										              if(err) {
										                console.log(err.message);
														returnError(responses,err.message);
										              }
														else{
															console.log("\n\n\n"+JSON.stringify(toBeReturned)+"\n\n\n");
															responses.writeHead(200, {'Content-Type': 'application/json'});
															toBeReturned['success']=true;
															responses.end(JSON.stringify(toBeReturned));
														}
										              
										            });
										          } else {
										            console.log('response error for artist ' + echo_artist.id + ": " + JSON.stringify(results.response));
													returnError(responses,'response error for artist ' + echo_artist.id + ": " + JSON.stringify(results.response));
										          }
										        });
										      }).on('error', function(e) {
										        console.log('request error');
										        console.log(e.message);
												returnError(responses,e.message);
										      });
										}
						            });
						         }}});
						      }).on('error',function(e){
						          console.log('request error');
						          console.log(e.message);
									returnError(responses,e.message);
						      });
						}});
						}
					});
				});
			})(i);}
						}});
		          }else{console.log('\n\nskipping this guy \n\n');}} else {
		            console.log('response error for artist ' + artist.name + ": " + JSON.stringify(results.response));
					returnError(responses,'response error for artist ' + artist.name + ": " + JSON.stringify(results.response));
		          }
		        });
		      }).on('error', function(e) {
		        console.log('request error');
		        console.log(e.message);
				returnError(responses,e.message);
		      });
		}
	});
}

function returnError(response, message){
	console.log("\n\n\nERRROOOOORRR!!!  "+message+"\n\n\n");
	responses.writeHead(200, {'Content-Type': 'application/json'});
	var returned = {'success':false,'error':message+" (Please email Sami about this)"};
	responses.end(JSON.stringify(returned));
}
function uploadEvent(response, query){
	query.sponsor = query.sponsor.toLowerCase();
	events.insert(query, {safe:true}, function(err,doc){
		if(err){console.log('ruh-h! event upload failed!'); console.log(err); }
		else{
			response.writeHead(200, {'Content-Type': 'application/json'});
			response.end(JSON.stringify(doc[0]));
		}
	});
}

function getEvents(response, query){
	var sponsor = query.sponsor.toLowerCase();
	var query = {}
	if(sponsor != "all")
		query['sponsor'] = sponsor;
	events.find(query).toArray(function(err, results){
        if(!err){
            response.writeHead(200, {'Content-Type': 'application/json'});
            response.end(JSON.stringify(results));
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
    else if(query.all){
	 	locs.find(/*,{'_id':true,'topTracks':true,'7id':true,'x':true,'y':true}*/).toArray(function(err, results){
            if(!err){
                //var data = {}
                //data['results'] = results;
                response.writeHead(200, {'Content-Type': 'application/json'});
                response.end(JSON.stringify(results));
            }
        });
    }//if no query variables
    else{
	    locs.find({'RID':{'$exists':true}}/*,{'_id':true,'topTracks':true,'7id':true,'x':true,'y':true}*/).toArray(function(err, results){
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
exports.uploadEvent = uploadEvent;
exports.getEvents = getEvents;
