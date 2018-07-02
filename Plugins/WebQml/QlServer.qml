import QtQuick 2.11
import QlServer 1.0
import QlFiles 1.0

Item {
    enabled: cfg_WebActive

    property int port: cfg_WebPort
	property string filesDir: ''
	property var callback:    function(req,resp){}
	
	property bool kvEnabled:  false
    property var  kv:        ({})
	
	QlServer { id:server_ }
	QlFiles  { id:file_ }

	// request methods
	property var methods: [ 'OPTIONS', 'GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'TRACE', 'CONNECT' ];

	// response codes
	property var codes: {
		100:'Continue', 101:'Switching Protocols', 200:'OK', 201:'Created', 202:'Accepted', 203:'Non-Authoritative Information',
		204:'No Content', 205:'Reset Content', 206:'Partial Content', 300:'Multiple Choices', 301:'Moved Permanently',
		302:'Found', 303:'See Other', 304:'Not Modified', 305:'Use Proxy', 307:'Temporary Redirect', 400:'Bad Request',
		401:'Unauthorized', 402:'Payment Required', 403:'Forbidden', 404:'Not Found', 405:'Method Not Allowed',
		406:'Not Acceptable', 407:'Proxy Authentication Required', 408:'Request Time-out', 409:'Conflict', 410:'Gone',
		411:'Length Required', 412:'Precondition Failed', 413:'Request Entity Too Large', 414:'Request-URI Too Large',
		415:'Unsupported Media Type', 416:'Requested range not satisfiable', 417:'Expectation Failed',
		500:'Internal Server Error', 501:'Not Implemented', 502:'Bad Gateway', 503:'Service Unavailable',
		504:'Gateway Time-out', 505:'HTTP Version not supported',
	};

	// content MIMEs
	property var types: {
		'txt':'text/plain; charset="utf-8"', 'bin':'application/octet-stream',
		'html':'text/html; charset="utf-8"', 'js':'application/javascript; charset="utf-8"',
		'json':'application/json; charset="utf-8"', 'jsonp':'application/javascript; charset="utf-8"',
		'css':'text/css; charset="utf-8"',
		'png':'image/png', 'jpg':'image/jpg', 'gif':'image/gif', 'bmp':'image/bmp',
		'pdf':'application/pdf',
	};

	// file type aliases
	property var typeAlias: {
		'txt':'txt', 'text':'txt', 'lst':'txt',
		'html':'html', 'htm':'html', 'css':'css',
		'js':'js', 'javascript':'js', 'jsonp':'js', 'json':'json',
		'png':'png', 'jpg':'jpg', 'jpeg':'jpg', 'gif':'gif', 'bmp':'bmp',
		'pdf':'pdf',
	};

	// string to bytes
	function stob(s){
		var b = [];
		for (var i=0; i<s.length; i++) b.push(s.charCodeAt(i) & 0xFF);
		return b;
	}

	// bytes to string
	function btos(b,start,end){
		var s = [];
		if (start === undefined) start = 0;
		if (end   === undefined) end = b.length-1;
		while (start < end) s.push(String.fromCharCode(b[start++] & 0xFF));
		return s.join('');
	}

	// get file extension
	function fext(s){
		var ss = s.split('.');
		return ss.length > 1 ? ss.pop().toLowerCase() : '';
	}

	// parse HTTP request
	function parseRequest(request){
		if (request instanceof Array) request = btos(request);
		var lines = request.split('\r\n');
	
		request = {error:true, lines:lines, headers:{}, cookies:{}, postQuery:'', postQueries:{},};
	
		if (lines.length > 2){
			request.request = lines[0];
		
			// parse 1st line (method/URI/version)
			var m = /^([A-Z]+) (.*) HTTP\/([0-9])\.([0-9])$/.exec(lines[0]);
			if (m){
				request.method=m[1]; request.uri=m[2];
				request.verh=m[3]; request.verl=m[4];
				request.ver = m[3] + '.' + m[4];
			
				// get URL query/hash from full URI
				var u = request.uri.split('?');
				request.url = u[0];                          // URL
				request.query = (u.length > 1) ? u[1] : '';  // query
				u = request.query.split('#');
				request.query = u[0];
				request.hash = (u.length > 1) ? u[1] : '';   // hash
			
				// split query to params
				request.queries = {};
				u = request.query.split('&');
				for (var i=0; i<u.length; i++){
					var uu = u[i].split('=');
                    if (uu.length === 2) request.queries[uu[0]] = uu[1];
				}
			
				// get headers
                i = 1;
				while ((i < lines.length) && (lines[i].length > 0)){
                    m = /^([A-Za-z\\-]+): (.*)$/.exec(lines[i]);
					if (m) request.headers[m[1]] = m[2];
					i++;
				}
				i++;
				
				// get cookies
				if ('Cookie' in request.headers){
					var cookies = request.headers['Cookie'].split(';');
                    for (i=0; i<cookies.length; i++){
						var cookie = cookies[i].split('=');
						if (cookie.length === 2) request.cookies[cookie[0].trim()] = cookie[1].trim();
					}
				}
				
				// get rest of content
				request.contentLines = lines.slice(i);
                request.content = request.contentLines.join('\r\n');
				request.error = false;
				
                // parse POST parameters
				if ((request.method === 'POST')&&(request.contentLines.length > 0)){
                    if  (request.content.indexOf("}") <0 )   {
                        request.content +=  "}" ;
                    }
                }
			}
		}
		return request;
	}


	Component.onCompleted: {
		// start serving at port
		server_.listenPort(port);
	
		// connect callback
		server_.requestHandler.connect(function(s,dir,callback){
			return function(request){
                 request = parseRequest(request);

				if (!request.error){
                    //console.log('QlServer serving',request.method,request.uri);

					// response object
					var response = {
						served:  false,       // 'content was served' flag
						ver:     request.ver, // protocol version
						code:    200,         // response code
						content: '',          // text/html content
						blob:    [],          // binary content
						headers: { 'Content-Type':types.html },
						cookies: request.cookies,
					}

					// serve Key-Value requests
					if (kvEnabled && (request.method === 'POST') && (request.url === '/kv.json')){
						
					}
					
					// call user callback function
                    if (callback) callback(request,response);

					// serve static file
					if ((!response.served) && (dir !== '') && (request.method === 'GET')){
						var f = dir + request.url;
						// check if file exists
						if (file_.isFile(f)){
							var ext = typeAlias[fext(f)]; // get extension alias
							// serve text content
                            if (['txt','html','js','css'].indexOf(ext) != -1){
								response.content = file_.readString(f,'utf8');
								response.headers['Content-Type'] = types[ext];
								response.served = true;
							}
							// serve image/document
							else if (['png','jpg','gif','bmp','pdf'].indexOf(ext) != -1){
								response.blob = file_.readBytes(f);
								response.headers['Content-Type']   = types[ext];
								response.headers['Content-Length'] = response.blob.length;
								response.served = true;
							}
							// serve other binary content
							else {
								response.blob = file_.readBytes(f);
								response.headers['Content-Type']   = types['bin'];
								response.headers['Content-Length'] = response.blob.length;
								response.served = true;
							}
							if (response.served) console.log('QlServer served file',f);
						}
					}

                    // call user callback function
                    /*
                    if (!response.served) {
                        if (callback) callback(request,response);
                    }
                    */


                    // not served - error
					if (!response.served) response = {served:true, ver:request.ver, code:404, content:'', blob:[], headers:{}, cookies:{}};
				
					// serve response packet
					if (response.served){
						var resp = ['HTTP/' + response.ver + ' ' + response.code + ' ' + codes[response.code]];
						// set headers
						for (var k in response.headers) resp.push(k + ': ' + response.headers[k]);
						// set cookies
                        for ( k in response.cookies) resp.push('Set-Cookie: ' + k + '=' + response.cookies[k]);
						// set body/content/blob
						resp.push('');
						if (response.code === 200){
							resp.push(response.content);
							s.blob(response.blob);
						}
						s.respond(resp.join('\r\n'));
					}
				}
			}
		}(server_,filesDir,callback));
	}
	
	Component.onDestruction: {
		server_.close();
	}
}

