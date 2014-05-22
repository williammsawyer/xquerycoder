xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";
import module namespace diff = "http://wwww.xquerycoder.com/libs/xml-diff" at "/libs/xml-diff.xqy";

declare variable $left :=
<bookstore xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="BookStore.xsd">
    <book price="730.54" ISBN="string" publicationdate="2016-02-27">
        <title>string</title>
        <author>
            <first-name>string</first-name>
            <middle-name>string</middle-name>
            <last-name>string</last-name>
        </author>
        <genre>string</genre>
    </book>
    <book price="6738.774" ISBN="string">
        <title>string</title>
        <author>
            <first-name>string</first-name>
            <last-name>string</last-name>
        </author>
    </book>
</bookstore>;

declare variable $right :=
<bookstore xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="BookStore.xsd">
    <book price="730.55" ISBN="string" publicationdate="2016-02-27" return-date="2016-02-28">
        <title>string</title>
        <author>
            <first-name>string</first-name>
            <last-name>string-diff</last-name>
        </author>
        <genre>string</genre>
    </book>
    <book price="6738.774" ISBN="string">
        <author>
            <first-name>string</first-name>
            <last-name>string</last-name>
        </author>
        <help>string</help>
    </book>
    <book price="1289.12" ISBN="string">
        <author>
            <first-name>string</first-name>
            <last-name>string</last-name>
        </author>
    </book>
</bookstore>;

declare %test:case function diff-nodes-test() {
	let $nodes := diff:nodes($left, $right)
	return (
		assert:equal(fn:count($nodes), 14),
		(: Left :)
		assert:true($nodes is $left/book[1]/@price),
		assert:true($nodes is $left/book[1]/author/middle-name),
		assert:true($nodes is $left/book[1]/author/last-name),
		assert:true($nodes is $left/book[2]/title),
		assert:false($nodes is $left/book[1]),
		assert:false($nodes is $left/book[2]),

		(: Right :)
		assert:true($nodes is $right/book[1]/@price),
		assert:true($nodes is $right/book[1]/author/last-name),
		assert:true($nodes is $right/book[2]/help),
		assert:false($nodes is $right/book[1]),
		assert:false($nodes is $right/book[2]),
		assert:true($nodes is $right/book[3]),
		assert:true($nodes is $right/book[3]//(@* | *))
	)
};