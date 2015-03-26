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

(: Removes surrounding quotes from a string :)
declare function util:dequote($str as xs:string) as xs:string {
    fn:replace($str, "[&quot;'](.*)[&quot;']$", '$1')
};

(: fn:string-join but for items :)
declare function util:item-join($items as item()*, $seperator as item()*) as item()* {
	let $count := fn:count($items)
	return (
		for $item in fn:subsequence($items, 1, $count - 1)
		return ($item, $seperator),
		fn:subsequence($items, $count)
	)
};

(: Pad the right side of the string :)
declare function util:pad-right($stringToPad as xs:string?, $padChar as xs:string, $length as xs:integer) as xs:string {
    let $strl as xs:integer := fn:string-length($stringToPad)
    return (
        fn:string-join((
            $stringToPad,
            for $i in (1 to $length - $strl) return $padChar
        ), '')
    )
};

(: Pad the left side of the string :)
declare function util:pad-left($stringToPad as xs:string?, $padChar as xs:string, $length as xs:integer) as xs:string {
    let $strl as xs:integer := fn:string-length($stringToPad)
    return (
        fn:string-join((
            for $i in (1 to $length - $strl) return $padChar,
            $stringToPad
        ), '')
    )
};

(: When you always want the root element and not the document-node :)
declare function util:root($node as node()){
    let $root := fn:root($node)
    return (
        typeswitch ($root)
            case document-node() return $root/*
            default return $root
    )
};

(: Strips all namespaces from element names :)
declare function util:strip-namespaces($node as node()*) as node()* {
    for $n as item() in $node
    return (
        typeswitch ($n)
        case text() return $n
        case document-node() return (
            document { util:strip-namespaces($n/node()) }
        )
        case element() return (
            element {fn:local-name($n)} {$n/@*, util:strip-namespaces($n/node())}
        )
        default return $n
    )
};

(: Simaliar to fn:normalize-space() but it only removes leading and trailing spaces :)
declare function util:trim($str as xs:string) as xs:string {
    replace($str, '(^\s+)|(\s+$)', '')
};

(: Wrapper arround xdmp:unquote :)
declare function util:unquote($string as xs:string) as node()* {
    xdmp:unquote( fn:concat("<quoted>", $string, "</quoted>"), "", ("format-xml", "repair-none"))/quoted/node()
};

(: Wrapper arround xdmp:unquote with repair option :)
declare function util:unquote-repair($string as xs:string) as node()* {
    xdmp:unquote( fn:concat("<quoted>", $string, "</quoted>"), "", ("format-xml", "repair-full"))/quoted/node()
};

(: When you need to return xml with a xml declaration :)
declare function util:xml-to-binary($xml as element(), $xml-declaration as xs:string?) {
    let $declaration as xs:string :=
        if ( fn:empty($xml-declaration) or $xml-declaration = "") then (
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        ) else ( $xml-declaration )
    return (
        binary {
            xs:hexBinary(
                xs:base64Binary(
                    xdmp:base64-encode(
                        fn:concat($declaration, "&#13;&#10;", xdmp:quote($xml))
                    )
                )
            )
        }
    )
};