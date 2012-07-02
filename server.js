var cluster = require('cluster'),
    numCPUs = require('os').cpus().length;

    
if(cluster.isMaster){
  console.log(numCPUs + ' cores on this machine.');
  for(var i = 0; i < numCPUs; i++)
    cluster.fork();
    
  cluster.on('death', function(worker){
    console.log('worker ' + worker.pid + ' died.');
    cluster.fork();
  });
  process.on("SIGTERM", process.exit);
  process.on("SIGINT", process.exit);
  process.on("SIGKILL", process.exit);
  /*process.on("SIGTERM", websiteDown);
  process.on('exit',websiteDown);
  process.on('SIGINT', websiteDown);*/
}
else{
  connect = require('connect'),
  url = require('url'),
  path = require('path'),
  fs = require('fs');
  uploader = require('./uploadArtist'),
  digital7 = require('./7Dconnect'),
  artistInfo = require('./artistInfo');
  users = require('./user');
  http = require('http');
  //everyauth = require('everyauth');
  passport = require('passport');
  fpass = require('passport-facebook').Strategy;
  redistore = require('connect-redis')(connect);

passport.serializeUser(function(userid,done){
	console.log('serializing!');
	done(null, userid);
});
passport.deserializeUser(function(userid,done){
	console.log('deserializing!');
	done(null,userid);
});

passport.use(new fpass({
		//clientID:'300271166724919',
		//clientSecret:'b4ba0065d5002941b871610d00afd80b',
		clientID:'134659439991720', //rapcities proper
		clientSecret:'43c2b1a5bc972868418383d74a51bfa4',
		callbackURL:'http://localhost:8888/auth/facebook/callback'
	},
	function(accessToken, refreshToken, fbUserData, done){
		var toUpload = {
			'name':fbUserData._json.name,
			'birthday':fbUserData._json.birthday,
			'location':fbUserData._json.location,
			'email':fbUserData._json.email,
			'gender':fbUserData._json.gender,
			'fbid':fbUserData._json.id,
			'accessToken':accessToken
		}
		users.fbCreate(toUpload, function (err, id) {
		      if (err) { return done(err); }
		      done(null, id);
		});
	}
));

  function onRequest(req, res, next) {
    var parsed = url.parse(req.url,true);
    var pathname = parsed.pathname;
    var ext = path.extname(pathname);
    
    switch(pathname){
      case '/addArtist': console.log('OH SHIT SOME SUCCESS!'); uploader.uploadLoc(res, parsed.query); break;
	  case '/getArtists': console.log('GETTING ZE ARTISTS!!!!'); uploader.getLocs(res, parsed.query); break;
	  case '/addEvent': console.log('OH SHIT ADDING AN EVENT!!!!'); uploader.uploadEvent(res, parsed.query); break;
      case '/getEvents': console.log('OH SHIT GETTING AN EVENT!!!!'); uploader.getEvents(res, parsed.query); break;
	  case '/getArtistInfo': console.log('getting artist info'); artistInfo.get(res, parsed.query); break;
	  case '/getBio': artistInfo.getBio(res, parsed.query); break;
	  case '/getTrack': console.log('getting track'); digital7.getTrack(res, parsed.query); break;
      case '/seeSongs': users.seeSongs(req, res, next); break;
      case '/addSong': users.addSong(req, res, next); break;
      case '/removeSong': users.removeSong(req, res, next); break;
      case '/countSongs': users.countSongs(req, res, next); break;
      case '/isFav': users.isFav(req, res, next); break;
      default: return;
    }
  }

	function checkWWW(req, res, next){
		if(req.headers.host.match(/^www/)){
			console.log('www');
			res.writeHead(301, {'location':'http://'+req.headers.host.replace(/^www\./,'')+req.url});
			res.end();
		} else	next();
	}
	
	function checkLoggedIn(req, res, next){
		console.log("req.user: " + req.user);
		if(req.user){
			if(req.url == '/logout'){
				req.logOut();
				res.writeHead(302, {'location':'http://localhost:8888/login'});
				res.end();
			}
			else
				next();
		}
		else{
			console.log('\nNot LOGGED IN\n');
			if(req.socket.remoteAddress || req.socket.socket.remoteAddress == '127.0.0.1'){
		      	var folder,contentType;
				console.log('req url = '+req.url);
	  		   	if(req.url == '/landing.png'){
					folder = __dirname+'/files/landing.png';
					contentType = 'image/png';
				}
				else if(req.url == '/facebookLanding.png'){
					folder = __dirname+'/files/facebookLanding.png';
					contentType = 'image/png';
				}
				else if(req.url == '/auth/facebook'){
					passport.authenticate('facebook', {scope: ['email','user_location','user_birthday']})(req,res,next);
					return;
				}
				else if(req.url.split('?')[0] == '/auth/facebook/callback'){
					passport.authenticate('facebook', {failureRedirect: '/failbook', 'successRedirect':'http://localhost:8888/'})(req, res, next);
					return;
				}
				else if(req.url.split('?')[0] == '/failbook'){
					console.log('failed log in');
					res.writeHead(401);
					res.end('Your login attempt with Facebook failed. If this is an error, please try logging in again or get in touch with Facebook.');
					return;
				}
				else{
		        	folder = __dirname + '/files/landing.html';
		        	contentType = 'text/html; charset=utf-8';
			    }
				if(folder){
					console.log('got to folder part\n\n');
			        fs.readFile(folder, function(error, content){
			          if(error){
			            res.writeHead(500);
			            res.end();
			          }
			          else{
			            res.writeHead(200, {'Content-Type': contentType});
			            res.end(content);
			          }
			        });
			      }
					else{ res.writeHead(500); res.end();}
			}
			else {res.writeHead(500); res.end();}
		}
	}
    
  connect.createServer(
	checkWWW,
	connect.logger(),
	connect.cookieParser(),
	connect.bodyParser(),
	connect.session({store: new redistore, secret:'jibblym87543dxj'}),
	connect.query(),
	passport.initialize(),
	passport.session(),
	checkLoggedIn,
    require('./fileServer')(),
    connect.compress({memLevel:9}),
    onRequest).listen(80);
	//onRequest).listen(8888);
  console.log('Server has started.');
}

