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
@description This module diffs two xml documents.
@requires MarkLogic 7+. map-sets.xqy, pretty-print.xqy
:)

module namespace diff = "http://www.xquerycoder.com/libs/xml-diff";

import module namespace set = "http://www.xquerycoder.com/libs/map-set" at "./map-set.xqy";
import module namespace pretty = "http://www.xquerycoder.com/libs/pretty-print" at "./pretty-print.xqy";

(: Pretty side by side comparison :)
declare function diff:pretty($leftXml as node(), $rightXml as node()) as element(div)* {
	let $nodes as node()* := diff:nodes($leftXml, $rightXml)
	return (
		<div class="xml-diff">
			<div class="left">{pretty:print($leftXml, $nodes)}</div>
			<div class="right">{pretty:print($rightXml, $nodes)}</div>
		</div>
	)
};

(: Get the diff nodes from the difference map :)
declare function diff:nodes($leftXml as node(), $rightXml as node()) as node()* {
	let $difference as map:map := diff:difference-map($leftXml, $rightXml)
	for $key in map:keys($difference)
	let $nodes as node()* := map:get($difference, $key)
	return (
		typeswitch ($nodes[1])
			case element() return (
                (: Node exist in both left and right, but are different in some way :)
				if ( fn:exists($nodes[2])) then (
					(: prevent child descendant differences from causing parents to be marked as different
                       only if direct child text() nodes are different do we keep the nodes :)
					if ( fn:not(fn:deep-equal($nodes[1]/text(), $nodes[2]/text()))) then (
						$nodes
					) else ()
				) else (
					$nodes
				)
			)
			default return $nodes
	)
};

(: Build difference map :)
declare function diff:difference-map($leftXml as node(), $rightXml as node()) as map:map {
	let $leftPathMap as map:map := diff:path-map($leftXml)
	let $rightPathMap as map:map := diff:path-map($rightXml)
	let $difference as map:map := set:outer($leftPathMap, $rightPathMap)
	return (
		$difference
	)
};

(: Maps all xdmp:paths to nodes :)
declare function diff:path-map($xml as item()) as map:map {
	let $map as map:map := map:map()
	let $mapping as empty-sequence() :=
		(: Map every thing except text() nodes :)
		for $node as item() in $xml//(@* | * | comment())
		(: strip the root off the path and make sure every node has a positional predicate
		   Need consistent paths syntax for the map operators to work correctly :)
		let $path as xs:string := fn:replace(fn:replace(xdmp:path($node), '/[^/]+/(.*)', '$1'), '([^\]])$', '$1[1]')
		return ( map:put($map, $path, $node) )
	return $map
};

(: Default css styling for displaying diff:pretty :)
declare function diff:styles() as element(style) {
	<style type="text/css">
		{
			(: Pull in default styles from xml pretty print :)
			pretty:styles()/text()
		}
		.xml-diff .left {{ float: left; }}
		.xml-diff .right {{ float: left; }}
	</style>
};