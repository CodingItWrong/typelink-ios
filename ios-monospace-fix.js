/**
 * Fixes iOS monospace issues. For the given node, iterates through
 * all child nodes. Whenever a text node is found, each character is
 * wrapped with a <span> tag, which somehow fixes spacing on iOS.
 * The one exception is a space: it needs to be replaced with an invisible
 */ 
function iOSMonospaceFix( root ) {
	var node, text, textNodes, span, char, container;
	
	// for each child node..
	for( var i = 0; i < root.childNodes.length; i++ ) {
		node = root.childNodes[i];
		
		// if it's an element, recursively go into it
		if( 1 == node.nodeType ) {
			iOSMonospaceFix( node );
			
			// if it's a text node...
		} else if( 3 == node.nodeType ) {
			text = node.data;
			container = document.createElement("span");
			
			// for each character...
			for( var j = 0; j < text.length; j++ ) {
				// wrap it in a span
				char = text.charAt(j);
				span = document.createElement("span");
				
				// apply extra fixes for spaces
				if( char == " " ) {
					span.className = "sp";
					//char = "_\u200B";
					span.innerHTML = "-&#8203;";
				} else {
					span.appendChild( document.createTextNode( char ) );
				}
				
				// insert it into the dom tree
				//span.appendChild( document.createTextNode( char ) );
				container.appendChild(span);
			}
			
			// remove text node that's been replaced by spans
			node.parentNode.insertBefore(container,node);
			node.parentNode.removeChild(node);
		}
	}
}
