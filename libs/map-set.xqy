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
@description helper functions for map operations
@requires MarkLogic 7+.
Help References: http://docs.marklogic.com/guide/app-dev/hashtable#id_97970
:)

module namespace set = "http://www.xquerycoder.com/libs/map-set";

(:
	Creates a map from the sequence of items
:)
 declare function set:map($items as item()*) as map:map {
	let $map := map:map()
	let $puts :=
		for $item in $items
		return map:put($map, xs:string($item), $item)
	return $map
};

(:
	Creates a map from the sequence of items
	with the key being the return of the $keyFn
:)
declare function set:map($items as item()*, $keyFn as xdmp:function) as map:map {
	let $map := map:map()
	let $puts :=
		for $item in $items
		return map:put($map, $keyFn($item), $item)
	return $map
};

(:
	Creates a map from the sequence of items
	with the key being the return of the $keyFn
	with the value being the return of the $valueFn
:)
declare function set:map($items as item()*, $keyFn as xdmp:function, $valueFn as xdmp:function) as map:map {
	let $map := map:map()
	let $puts :=
		for $item in $items
		return map:put($map, $keyFn($item), $valueFn($item))
	return $map
};

(:
	Map inner join or intersection
:)
declare function set:inner($left as map:map, $right as map:map) as map:map {
	$left * $right
};

(:
	left join or what is unique to the left map
:)
declare function set:left($left as map:map, $right as map:map) as map:map {
	$left - $right
};

(:
	right join or what is unique to the right map
:)
declare function set:right($left as map:map, $right as map:map) as map:map {
	$right - $left
};

(:
	left and right joins unioned together
:)
declare function set:outer($left as map:map, $right as map:map) as map:map {
	(: set:union(set:left($left, $right), set:right($left, $right)) :)
	($left - $right) + ($right - $left)
};

declare function set:union($left as map:map, $right as map:map) as map:map {
	$left + $right
};

(:
	Slightly different than union.  Keys that exists in multiple maps are overwriten instead of merged. Last map wins
:)
declare function set:extend($maps as map:map*) as map:map {
	map:new((
		$maps
	))
};

(:
	Reverse the keys and values in the map
:)
declare function set:reverse($map as map:map) as map:map {
	-$map
};

(:
	The inference that a value from a map matches the key of another map. The result is the keys from the first map (Map A), and values from the second map (Map B), where the value in Map A is equal to key in Map B
:)
declare function set:inference($left as map:map, $right as map:map) as map:map {
	$left div $right
};

(:
	The combination of the reverse and inference between maps. The result is the reversal of the keys in the first map (Map A) and the values in Map B, where a value in Map A matches a key in Map B
:)
declare function set:reverse-inference($left as map:map, $right as map:map) as map:map {
	$left mod $right
};

declare function set:values($map as map:map) as item()* {
	for $key in map:keys($map)
	return ( map:get($map, $key) )
};
