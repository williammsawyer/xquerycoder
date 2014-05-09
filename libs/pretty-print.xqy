xquery version "1.0-ml";

(:~
Copyright (c) 2014 William Sawyer

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

@author William Sawyer (wilby.sawyer@gmail.com)
@version 0.1
@description This module pretty prints xml using html and css.
@requires MarkLogic 7+.

:)

module namespace pretty = "http://www.xquerycoder.com/libs/pretty-print";

(:
Example: Pretty print xml with the title node highlighted

let $xml :=
	<document id="1234" xmlns="http://my.ns">
		<title>Title</title>
		<body>My body</body>
	</document>
return (
	pretty:print($xml, $xml/title)
)
:)

declare function pretty:styles() {
	<style type="text/css">
		.eBlock {{ display:block; color: black; font-family: monospace;}}
        .eBlock .eBlock {{ margin-left: 10px; }}
		.eName {{ display:inline-block; color: #000096;}}
		.aBlock {{ display:inline-block; margin-left: 5px; color: #993300; }}
		.aName {{ display:inline; color: #F5844C; }}
		.aName.ns {{ color: #0099CC }}
		.comment {{ display:block; margin-left: 10px; color: darkgreen; }}
		.highlight {{ background-color: #FFFBCC; }}
	</style>
};

declare function pretty:simple-print($node as node()){
    <pre>{
        xdmp:quote(
            $node,
            <options xmlns="xdmp:quote">
                <indent>yes</indent>
                <indent-untyped>yes</indent-untyped>
                <method>html</method>
            </options>
    )}</pre>
};

declare function pretty:print($node as node()) as item() {
	pretty:print($node, (), ())
};

declare function pretty:print($node as node(), $highlight as node()*) as item() {
	pretty:print($node, $highlight, ())
};

declare function pretty:print($node as node(), $highlight as node()*, $namespaces as item()*) as item() {
	typeswitch ($node)
		case text() return $node
		case comment() return pretty:comment($node, $highlight, $namespaces)
		case attribute() return pretty:attribute($node, $highlight, $namespaces)
		case element() return pretty:element($node, $highlight, $namespaces)
		case document-node() return pretty:print($node/*, $highlight, $namespaces)
		default return (
			if ( xdmp:node-kind($node) = "namespace") then (
				pretty:namespace($node)
			) else ()
		)

};

declare function pretty:namespace($node) as node() {
	let $name := fn:local-name($node)
	let $aName := if ($name = "") then ( "xmlns") else ( "xmlns:" || $name)
	where fn:not($name = "xml")
	return (
		<span class="aBlock">
			<span class="aName ns">{$aName || '='}</span>
			{'"' || fn:string($node) || '"'}
		</span>
	)

};

declare function pretty:comment($node as node(), $highlight as node()*, $namespaces as item()*) as node() {
	<div class="comment{pretty:highlight($node, $highlight)}">{xdmp:quote($node)}</div>
};

declare function pretty:attribute($node as node(), $highlight as node()*, $namespaces as item()*) as node() {
	<span class="aBlock{pretty:highlight($node, $highlight)}">
		<span class="aName">{" " || fn:node-name($node) || '='}</span>
		{'"' || fn:string($node) || '"'}
	</span>
};

declare function pretty:element($node as node(), $highlight as node()*, $namespaces as item()*) as node() {
	let $new-ns :=
		for $ns in $node/namespace::*
		where fn:not($ns is $namespaces)
		return $ns
    let $self-closing := fn:empty($node/node())
	return
		<div class="eBlock{pretty:highlight($node, $highlight)}">
			<span class="eName">{"&lt;" || fn:node-name($node)}{pretty:print($node/@*, $highlight, ())}{pretty:print($new-ns, $highlight, ())}{
                if ( $self-closing ) then ("/&gt;") else ("&gt;")
            }</span>{
                if ( $self-closing) then () else (
                    pretty:print($node/node(), $highlight, ($namespaces, $new-ns)),
                    <span class="eName"> {"&lt;/"  || fn:node-name($node) || "&gt;"} </span>
                )
            }

		</div>
};

declare function pretty:highlight($node as node(), $highlight as node()*) as xs:string? {
	if ($node is $highlight) then (' highlight') else ()
};