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
@description The purpose of this module is to provide non mutating map objects.
When a property is updated in the map instead of changing the orginal map it returns a copy of the map with the desired property(s) changed.
@requires MarkLogic 7+.

:)

module namespace obj = "http://www.xquerycoder.com/libs/object-functions";

(:
	Helpful when doing a recursive descent and want to pass along variables.
	Using these functions allows you to pass along multiple values within one parameter.
	The map never mutates so it doesn't cause side affects like xdmp:set or map:put would.

	In this example when it processes a <child> node it addds it's @id to the object.
	Then when it processes a <title> node it adds the @id from the object.

	Notice the title within the other node gets an @id="DEFAULT"
	If you switch line 54 with 53 you will now see it gets a @id="1" because the map mutated when it processed the first child node.

	declare function local:continue($node as node(), $obj as map:map) as item()* {
		for $z in $node/node()
		return (
			local:process($z, $obj)
		)
	};

	declare function local:process($node as node(), $obj as map:map) as item()* {
		typeswitch ($node)
		case text() return ($node)
		case comment() return ($node)
		case document-node() return local:continue($node, $obj)
		case element(root) return local:continue($node, $obj)
		case element(child) return (
			let $obj := obj:set($obj, 'id', $node/@id)
			(: let $put := map:put($obj, 'id', $node/@id) :)
			return (
				element { fn:node-name($node) } {
					$node/@*,
					local:continue($node, $obj)
				}
			)
		)
		case element(title) return (
			element { fn:node-name($node) } {
				$node/@* except $node/@id,
				obj:get($obj, 'id'),
				local:continue($node, $obj)
			}
		)
		default return (
			element { fn:node-name($node) } {
				$node/@*,
				local:continue($node, $obj)
			}
		)
	};

	let $obj :=
		obj:new(
			obj:prop("id", attribute id { "DEFAULT" })
		)
	let $xml :=
		<root>
			<child id="1">
				<title>Title 1</title>
				<body>Body 2</body>
			</child>
			<other>
				<title>Title 1</title>
				<body>Body 2</body>
			</other>
			<child id="2">
				<title>Title 2</title>
				<body>Body 2</body>
			</child>
		</root>

	return (
		local:process($xml, $obj)
	)
:)

(: Generic Object creation: just a wrapper around map:new :)
declare function obj:new($props as map:map*) as map:map {
	map:new($props)
};

(: Creates a property :)
declare function obj:prop($key as xs:string, $value as item()*) as map:map {
	map:entry($key, $value)
};

(: Gets the property from the object: just a wrapper around map:get :)
declare function obj:get($obj as map:map, $key) as item()* {
	map:get($obj, $key)
};

(: Returns a copy of the object with property updated: Not mutating the original map :)
declare function obj:set($obj as map:map, $key as xs:string, $value as item()*) as map:map {
	map:new((
		$obj,
		map:entry($key, $value)
	))
};

(: Returns a copy of the object with the properties updated: Not mutating the original map :)
declare function obj:set($obj as map:map, $props as map:map*) as map:map {
	map:new((
		$obj,
		$props
	))
};
