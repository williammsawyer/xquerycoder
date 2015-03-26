xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";
import module namespace util = "http://www.xquerycoder.com/libs/util" at "/libs/util-functions.xqy";

declare namespace stripTest = "StripTest";

declare %test:case function dequote-test() {
	let $string := '"test"'
	return (
		assert:equal(util:dequote($string), "test")
	)
};

declare %test:case function item-join-test() {
	let $items := (
        <div>1</div>,
        <div>2</div>,
        <div>3</div>,
        <div>4</div>
    )
    let $join := xdmp:quote( <list>{ util:item-join($items, <br/>) }</list> )
    let $expected := "<list><div>1</div><br/><div>2</div><br/><div>3</div><br/><div>4</div></list>"
	return (
		assert:equal($join, $expected)
	)
};

declare %test:case function pad-right-test() {
    let $string := "test"
    let $test1 := util:pad-right($string, "0", 5)
    let $expected1 := "test0"
    let $test2 := util:pad-right($string, "0", 6)
    let $expected2 := "test00"
    let $test3 := util:pad-right($string, "0", 4)
    let $expected3 := "test"
    return (
        assert:equal($test1, $expected1),
        assert:equal($test2, $expected2),
        assert:equal($test3, $expected3)
    )
};

declare %test:case function pad-left-test() {
    let $string := "test"
    let $test1 := util:pad-left($string, "0", 5)
    let $expected1 := "0test"
    let $test2 := util:pad-left($string, "0", 6)
    let $expected2 := "00test"
    let $test3 := util:pad-left($string, "0", 4)
    let $expected3 := "test"
    return (
        assert:equal($test1, $expected1),
        assert:equal($test2, $expected2),
        assert:equal($test3, $expected3)
    )
};

declare %test:case function root-test() {
    let $doc :=
        document {
            <root>
                <child></child>
            </root>
        }

    let $test1 := util:root($doc)
    let $expected1 := $doc/root

    let $test2 := util:root($doc/root)
    let $expected2 := $doc/root

    let $test3 := util:root($doc/root/child)
    let $expected3 := $doc/root
    return (
        assert:equal($test1, $expected1),
        assert:equal($test2, $expected2),
        assert:equal($test3, $expected3)
    )
};

declare %test:case function strip-namespaces-test() {
    let $doc :=
        document {
            <stripTest:root>
                <stripTest:child></stripTest:child>
            </stripTest:root>
        }
    let $doc2 :=
        document {
            <root>
                <child></child>
            </root>
        }

    let $test1 := util:strip-namespaces($doc)
    let $expected1 := $doc2
    let $nodes := $test1/stripTest:*
    return (
        assert:equal($test1, $expected1),
        assert:empty($nodes)
    )
};

declare %test:case function trim-test() {
    let $string := "     test    test        "
    let $test1 := util:trim($string)
    let $expected1 := "test    test"
    return (
        assert:equal($test1, $expected1)
    )
};

declare %test:case function unquote-test() {
    let $string := "<test>unquote</test>"
    let $test1 := util:unquote($string)
    let $expected1 := <test>unquote</test>
    return (
        assert:equal($test1, $expected1)
    )
};

declare %test:case function unquote-repair-test() {
    let $string := "<test>unquote<br></test>"
    let $test1 := util:unquote-repair($string)
    let $expected1 := <test>unquote<br/></test>
    return (
        assert:equal($test1, $expected1)
    )
};

declare %test:case function xml-to-binary() {
    let $xml := <test>test</test>
    let $test1 := util:xml-to-binary($xml, ())
    let $expected1 as xs:string := <text>&lt;?xml version="1.0" encoding="UTF-8" standalone="yes"?&gt;&#13;&#10;&lt;test&gt;test&lt;/test&gt;</text>
    return (
        assert:equal(xdmp:binary-decode($test1, "UTF-8"), $expected1)
    )
};

(:
declare function util:unquote($string as xs:string) as node()* {
    xdmp:unquote( fn:concat("<quoted>", $string, "</quoted>"), "", ("format-xml", "repair-none"))/quoted/node()
};


declare function util:unquote-repair($string as xs:string) as node()* {
    xdmp:unquote( fn:concat("<quoted>", $string, "</quoted>"), "", ("format-xml", "repair-full"))/quoted/node()
}

:)