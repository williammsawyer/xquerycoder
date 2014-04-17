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
@description This module is a placeholder for the most performant ways to get items from a sequences.
@requires MarkLogic 7+.

:)

(:
  Using this library may lessen performance slightly because of the extra little overhead of calling a function.
  That is why I see this more of a reference library you can copy from but not actually call.
  With that said there is nothing wrong with using it. During testing, looping 10,000 times I found it only added 0.02 seconds to the results.
:)

module namespace seq = "http://xquerycoder.blogspot.com/libs/sequence-functions";

declare function seq:last($sequence as item()*) as item()? {
	fn:subsequence($sequence, fn:count($sequence))
};

declare function seq:first($sequence as item()*) as item()? {
	$sequence[1]
};

declare function seq:tail($sequence as item()*) as item()* {
	fn:tail($sequence)
};

declare function seq:pop($sequence as item()*) as item()* {
	fn:subsequence($sequence, 1, fn:count($sequence) - 1)
};

declare function seq:get($sequence as item()*, $index as xs:int) as item()? {
	$sequence[$index]
};

declare function seq:get($sequence as item()*, $start as xs:int, $end as xs:int) as item()* {
	$sequence[$start to $end]
};







