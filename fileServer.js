
var fs = require('fs'),
  utils = require(__dirname + '/node_modules/connect/lib/utils'),
  zlib = require('zlib'),
  gzip = zlib.createGzip(),
  files = {};

/**
 *   - `maxAge`  cache-control max-age directive, defaulting to 1 day
 *
 */

module.exports = function fileServer(maxage){
  var maxAge = maxage || 86400000;

  return function fileServer(req, res, next){
    if(req.socket.remoteAddress || req.socket.socket.remoteAddress == '127.0.0.1'){
      var folder,contentType;
      if(req.url == '/indexold.html'){
        folder = __dirname + '/pde/indexold.html';
        contentType = 'text/html';
      }
	  else if(req.url == '/uploader'){
        folder = __dirname + '/pde/artistupload.html';
        contentType = 'text/html';
      }
	  else if(req.url == '/tester'){
        folder = __dirname + '/pde/artisttester.html';
        contentType = 'text/html';
      }
      else if(req.url == '/vyuzik.pde'){
        folder = __dirname + '/pde/vyuzik.pde';
        contentType = 'text/processing';
      } 
	  else if(req.url == '/svg.pde'){
		folder = __dirname + '/pde/SVG/applet_js/svg.pde';
        contentType = 'text/processing';
      }  
	  else if(req.url == '/svgtester.pde'){
		folder = __dirname + '/pde/SVG/applet_js/svgtester.pde';
        contentType = 'text/processing';
      }
	  else if(req.url == '/processing.js'){
		folder = __dirname + '/pde/SVG/applet_js/processing.js';
        contentType = 'text/javascript';
      } 
	  else if(req.url == '/NYCMapOutlines2_simple.svg'){
		folder = __dirname + '/pde/SVG/applet_js/NYCMapOutlines2_simple.svg';
        contentType = 'image/svg+xml';
      }
	  else if(req.url == '/NYC.svg'){
		folder = __dirname + '/pde/SVG/applet_js/NYCfinal.svg';
        contentType = 'image/svg+xml';
      }
	  else if(req.url == '/bot.svg'){
		folder = __dirname + '/pde/SVG/applet_js/rappericon.svg';
        contentType = 'image/svg+xml';
      }	  else if(req.url == '/frame.svg'){
		folder = __dirname + '/pde/SVG/applet_js/frame.svg';
        contentType = 'image/svg+xml';
      }	  
 
      if(folder){
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
    }
    switch(req.url){
      case('/favicon.ico'):
        if (files.icon) {
          res.writeHead(200, files.icon.headers);
          res.end(files.icon.body);
        } else readfile('/files/favicon.ico','image/x-icon','icon',false)
        break;
      case('/robots.txt'):
        res.writeHead(404);
        res.end();
        break;
      case('/areyouateapot'):
        res.writeHead(418);
        res.end('check the header!');
        break;
      case('/'):
        if (files.index) sendfile('index')
        else readfile('/pde/indexold.html','text/html','index',true)
        break;
      case('/processing-1.3.6.min.js'):
        if (files.processing) sendfile('processing')
        else readfile('/files/processing-1.3.6.min.js','text/javascript','processing',true)
        break;
      case('/soundmanager2.js'):
        if (files.sm2) sendfile('sm2')
        else readfile('/files/soundmanager2-nodebug-jsmin.js','text/javascript','sm2',true)
        break;
      case('/soundmanager2.swf'):
        if (files.sm2f){
          res.writeHead(200, files.sm2f.headers);
          res.end(files.sm2f.body);
        }
        else readfile('/files/soundmanager2.swf','application/x-shockwave-flash','sm2f',false)
        break;
      /*case('/soundmanager2_flash9.swf'):
        if (files.sm2f9) {
          res.writeHead(200, files.sm2f9.headers);
          res.end(files.sm2f9.body);
        } else readfile('/files/soundmanager2_flash9.swf','application/x-shockwave-flash','sm2f9',false)
        break;*/
      case('/youtube'):
        if (files.ytube) {
          res.writeHead(200, files.ytube.headers);
          res.end(files.ytube.body);
        } else readfile('/files/web_youtube2.png','image/png','ytube',false)
        break;
      case('/facebook'):
        if (files.fbook) {
          res.writeHead(200, files.fbook.headers);
          res.end(files.fbook.body);
        } else readfile('/files/facebook.gif','image/gif','fbook',false)
        break;
      case('/info.svg'):
        if (files.info) {
          res.writeHead(200, files.info.headers);
          res.end(files.info.body);
        } else readfile('/files/info.svg','image/svg+xml','info',false)
        break;
      default: next();
    } 
 //icon, index, sm2, sm2f, sm2f9, processing, info, fbook, ytube;   
    function sendfile(file){
      var acceptEncoding = req.headers['accept-encoding'];
      if (!acceptEncoding) {
        acceptEncoding = '';
      }
      if (acceptEncoding.trim() == '*' || acceptEncoding.match(/\bgzip\b/)) {
        res.writeHead(200, files[file].gzip.headers);
        res.end(files[file].gzip.body);
      }
      else if (acceptEncoding.match(/\bdeflate\b/)) {
        res.writeHead(200, files[file].deflate.headers);
        res.end(files[file].deflate.body);
      }
      else{ 
        res.writeHead(200, files[file].headers);
        res.end(files[file].body);
      }
    }
    //if compress, then create gzip and deflate as well, otherwise, just a regular copy
    function readfile(path,contentType,file,compress){
      fs.readFile(__dirname + path, function(err, buf){
        if (err) return next(err);
        files[file] = {
          headers: {
             'Content-Type': contentType,
             'Content-Length': buf.length,
             'ETag': '"' + utils.md5(buf) + '"',
             'Cache-Control': 'public, max-age=' + (maxAge / 1000)
          }, body: buf
        };
        if(compress){
          zlibBuffer(zlib.createGzip({level:zlib.Z_BEST_COMPRESSION,memLevel:zlib.Z_MAX_MEMLEVEL}),buf,function(err,gzip){
            files[file].gzip = {
              headers: {
                 'Content-Type': contentType,
                 'Content-Encoding':'gzip',
                 'Content-Length': gzip.length,
                 'ETag': '"' + utils.md5(gzip) + '"',
                 'Cache-Control': 'public, max-age=' + (maxAge / 1000)
              }, body: gzip
            };
          });
          zlibBuffer(zlib.createDeflate({level:zlib.Z_BEST_COMPRESSION,memLevel:zlib.Z_MAX_MEMLEVEL}),buf,function(err,deflate){
            files[file].deflate = {
              headers: {
                 'Content-Type': contentType,
                 'Content-Encoding':'deflate',
                 'Content-Length': deflate.length,
                 'ETag': '"' + utils.md5(deflate) + '"',
                 'Cache-Control': 'public, max-age=' + (maxAge / 1000)
              }, body: deflate
            };
          });
        }
        res.writeHead(200, files[file].headers);
        res.end(buf);
      });
    }
    //zippify!
    function zlibBuffer(engine, buffer, callback) {
      var buffers = [];
      var nread = 0;

      engine.on('error', function(err) {
        engine.removeListener('end');
        engine.removeListener('error');
        callback(err);
      });

      engine.on('data', function(chunk) {
        buffers.push(chunk);
        nread += chunk.length;
      });

      engine.on('end', function() {
        var buffer;
        switch(buffers.length) {
          case 0:
            buffer = new Buffer(0);
            break;
          case 1:
            buffer = buffers[0];
            break;
          default:
            buffer = new Buffer(nread);
            var n = 0;
            buffers.forEach(function(b) {
              var l = b.length;
              b.copy(buffer, n, 0, l);
              n += l;
            });
            break;
        }
        callback(null, buffer);
      });

      engine.write(buffer);
      engine.end();
    }
  };
};
