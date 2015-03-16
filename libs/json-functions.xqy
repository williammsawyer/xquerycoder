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
@description This module allows for easy json contructing and converting from xml to json or vice versa
@requires MarkLogic 6+.

:)

module namespace js = "http://www.xquerycoder.com/libs/json-functions";

import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

declare namespace basic = "http://marklogic.com/xdmp/json/basic";

(:
EXAMPLE

js:to-json(
  js:object((
    js:keyValue("123", 123, "number"),
    js:keyValue("testtest", "testing", "string"),
    js:keyValue("boolean", fn:true(), "boolean"),
    js:keyArray("array",(
      js:object((
        js:keyValue("testing", "inner", "string")
      )),
      js:array((
        js:item(1, "number"), js:item(2,"number"), js:item("test","string")
      ))
    ))
  ))
)
returns
{"id":123, "testtest":"string", "bool":true, "array":[{"testing":"inner"},[1,2,"test"]]}

js:to-xml('{"id":123, "testtest":"string", "bool":true, "array":[{"testing":"inner"},[1,2,"test"]]}')
returns
<json type="object" xmlns="http://marklogic.com/xdmp/json/basic">
  <id type="number">123</id>
  <testtest type="string">string</testtest>
  <bool type="boolean">true</bool>
  <array type="array">
    <json type="object">
      <testing type="string">inner</testing>
    </json>
    <json type="array">
      <item type="number">1</item>
      <item type="number">2</item>
      <item type="string">test</item>
    </json>
  </array>
</json>

:)

declare function js:to-json($xml as element()) as xs:string {
    json:transform-to-json($xml, json:config("basic"))
};

declare function js:to-xml($json as xs:string) as element() {
    json:transform-from-json($json, json:config("basic"))
};

declare function js:object( $children as element()* ) as element(basic:json) {
    <json xmlns="http://marklogic.com/xdmp/json/basic" type="object">{
        $children
    }</json>
};

declare function js:array( $children as element()* ) as element(basic:array) {
    <array xmlns="http://marklogic.com/xdmp/json/basic" type="array">{
        $children
    }</array>
};

declare function js:keyValue( $key as xs:string, $value as item()*, $type as xs:string) as element() {
    element { fn:QName("http://marklogic.com/xdmp/json/basic", xdmp:encode-for-NCName($key) )} {
        attribute type { $type },
        switch ( $type )
        case "quote" return xdmp:quote($value)
        case "string" return fn:string($value)
        case "number" return fn:number($value)
        case "boolean" return xs:boolean($value)
        default return  $value
    }
};

declare function js:keyObject($key as xs:string, $items as item()*) as element() {
    element { fn:QName("http://marklogic.com/xdmp/json/basic", xdmp:encode-for-NCName($key) )} {
        attribute type { "object" },
        $items
    }
};

declare function js:keyArray($key as xs:string, $items as item()*) as element() {
    element { fn:QName("http://marklogic.com/xdmp/json/basic", xdmp:encode-for-NCName($key) )} {
        attribute type { "array" },
        $items
    }
};

declare function js:item($value as item()*, $type as xs:string) as element(basic:item) {
    <item xmlns="http://marklogic.com/xdmp/json/basic" type="{ $type }">{
        switch ( $type )
        case "quote" return xdmp:quote($value)
        case "string" return fn:string($value)
        case "number" return fn:number($value)
        case "boolean" return xs:boolean($value)
        default return  $value
    }</item>
};

(: Removes any nodes that are not in the json namespace :)
declare function js:clean($node as item()*) {
	for $n in $node
		return (
		typeswitch($n)
		case element() return ( if ( $n/namespace::* = "http://marklogic.com/xdmp/json/basic") then ( $n ) else () )
		default return ()
	)
};