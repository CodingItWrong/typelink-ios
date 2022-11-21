function iPad() { return null != navigator.userAgent.match(/(iPad)/i); }
function iPhone() { return null != navigator.userAgent.match(/(iPhone)/i); }

function log(str) {
	window.location = "log://"+str
}

function getSel(){
	var w=window,d=document,gS='getSelection';
	return (''+(w[gS]?w[gS]():d[gS]?d[gS]():d.selection.createRange().text)).replace(/(^\\s+|\\s+$)/g,'');
}

var lastTouchX = null
var lastTouchY = null
var lastTouchTime = null

function handleTouch(event) {
	
	// get current time and place
	var touchTime = new Date().getTime()
	var x = event.touches[0].pageX
	var y = event.touches[0].pageY
	
	// if these constitute a double tap, send event to Cocoa
	if( null != lastTouchTime
	   && null != lastTouchX
	   && null != lastTouchY
       && 100 < (touchTime-lastTouchTime) // no faster than 1/10 sec: if so, probably dif fingers
	   && 500 > (touchTime-lastTouchTime) // no slower than 1/2 sec in between
	   && 20 > Math.abs( x - lastTouchX )
	   && 20 > Math.abs( y - lastTouchY ) )
	{
		window.location="typelink://doubleTap"
	}
	
	// save time and place
	lastTouchTime = touchTime
	lastTouchX = x
	lastTouchY = y
}

function youtubeUrlsToPlayers() {
	var links = document.getElementsByTagName('a')
	for( var i = 0; i < links.length; i++ ) {
		var match = links[i].href.match(/http:\/\/www\.youtube\.com\/watch\?v=([-\w]+)/)
		if( null != match ) {
			var id = match[1]
			var w, h
			if( iPhone() ) {
				w = 290
				h = 174
			} else {
				w = 640
				h = 385
			}
			var container = document.createElement("div")
			var iframe = document.createElement("iframe")
			iframe.setAttribute("type","text/html")
			iframe.setAttribute("width",w)
			iframe.setAttribute("height",h)
			iframe.setAttribute("src","http://www.youtube.com/embed/"+id)
			iframe.setAttribute("frameborder",0)
			container.appendChild(iframe)
			links[i].parentNode.insertBefore( container, links[i] )
		}
	}
}

window.onload = function() {
	document.addEventListener('touchstart', handleTouch )
	youtubeUrlsToPlayers()
	if( "function" == typeof iOSMonospaceFix ) {
		iOSMonospaceFix(document.body)
	}
}
