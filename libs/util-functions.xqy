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
@description Place for random helpful functions
@requires MarkLogic 5+.

:)

module namespace util = "http://www.xquerycoder.com/libs/util";

(: fn:string-join but for items :)
declare function util:item-join($items as item()*, $seperator as item()*) as item()* {
	let $count := fn:count($items)
	return (
		for $item in fn:subsequence($items, 1, $count - 1)
		return ($item, $seperator),
		fn:subsequence($items, $count)
	)
};