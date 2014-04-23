xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";
import module namespace seq = "http://www.xquerycoder.com/libs/sequence-functions" at "/libs/sequence-functions.xqy";

declare variable $sequence-full as item()* := (1, 2, 3, 4 ,5 , 6, 7, 8, 9 , 10);
declare variable $sequence-half as item()* := ( 3, 4, 5, 6, 7, 8 );
declare variable $sequence-one as item()* := ( 1 );
declare variable $sequence-empty as item()* := ();


declare %test:case function last() {
	let $last-last := seq:last($sequence-full)
	let $last-half := seq:last($sequence-half)
	let $last-one := seq:last($sequence-one)
	let $last-empty := seq:last($sequence-empty)
	return (
		assert:equal( 10, $last-last),
		assert:equal( 8, $last-half),
		assert:equal(1, $last-one),
		assert:empty( $last-empty )
	)
};

declare %test:case function first() {
	let $first-last := seq:first($sequence-full)
	let $first-half := seq:first($sequence-half)
	let $first-one := seq:first($sequence-one)
	let $first-empty := seq:first($sequence-empty)
	return (
		assert:equal(1, $first-last),
		assert:equal(3, $first-half),
		assert:equal(1, $first-one),
		assert:empty($first-empty)
	)
};

declare %test:case function tail() {
	let $tail-last := seq:tail($sequence-full)
	let $tail-half := seq:tail($sequence-half)
	let $tail-one := seq:tail($sequence-one)
	let $tail-empty := seq:tail($sequence-empty)
	return (
		assert:equal( (2, 3, 4, 5, 6, 7, 8, 9, 10), $tail-last),
		assert:equal( (4, 5, 6, 7, 8), $tail-half),
		assert:empty($tail-one),
		assert:empty($tail-empty)
	)
};

declare %test:case function pop() {
	let $pop-last := seq:pop($sequence-full)
	let $pop-half := seq:pop($sequence-half)
	let $pop-one := seq:pop($sequence-one)
	let $pop-empty := seq:pop($sequence-empty)
	return (
		assert:equal((1, 2, 3, 4, 5, 6, 7, 8, 9), $pop-last),
		assert:equal((3, 4, 5, 6, 7), $pop-half),
		assert:empty($pop-one),
		assert:empty($pop-empty)
	)
};

declare %test:case function get-index() {
	let $index-last := seq:get($sequence-full, 5)
	let $index-half := seq:get($sequence-half, 5)
	let $index-one := seq:get($sequence-one, 5)
	let $index-empty := seq:get($sequence-empty, 5)
	return (
		assert:equal(5, $index-last),
		assert:equal(7, $index-half),
		assert:empty($index-one),
		assert:empty($index-empty)
	)
};

declare %test:case function get-range() {
	let $range-last := seq:get($sequence-full, 3, 5)
	let $range-half := seq:get($sequence-half, 3, 5)
	let $range-one := seq:get($sequence-one, 3, 5)
	let $range-empty := seq:get($sequence-empty, 3, 5)
	return (
		assert:equal( (3, 4, 5), $range-last),
		assert:equal( (5, 6, 7), $range-half),
		assert:empty($range-one),
		assert:empty($range-empty)
	)
};