xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";
import module namespace set = "http://www.xquerycoder.com/libs/map-set" at "/libs/map-set.xqy";

declare variable $left :=
	map:new((
		map:entry("1", "1"),
		map:entry("3", "3"),
		map:entry("4", "4"),
		map:entry("7", "7"),
		map:entry("9", "9")
	));

declare variable $right :=
	map:new((
		map:entry("2", "2"),
		map:entry("3", "3"),
		map:entry("4", "4"),
		map:entry("5", "5"),
		map:entry("6", "6"),
		map:entry("8", "8"),
		map:entry("9", "9"),
		map:entry("10", "10")
	));

declare %test:case function map-one-param() {
	let $nums := 1 to 10
	let $map := set:map($nums)
	return (
		assert:equal(map:count($map), 10),
		for $key in map:keys($map)
		return (
			assert:true($key = ("1", "2", "3", "4", "5", "6", "7", "8", "9", "10"))
		),
		for $value in set:values($map)
		return (
			assert:true($value = $nums)
		)
	)
};

declare %test:case function map-keyFn() {
	let $nums := 1 to 10
	let $map := set:map($nums, function($value){ xs:string($value) || "TEST"})
	return (
		assert:equal(map:count($map), 10),
		for $key in map:keys($map)
		return (
			assert:true($key = ("1TEST", "2TEST", "3TEST", "4TEST", "5TEST", "6TEST", "7TEST", "8TEST", "9TEST", "10TEST"))
		),
		for $value in set:values($map)
		return (
			assert:true($value = $nums)
		)
	)
};

declare %test:case function map-keyFn-and-valueFn() {
	let $nums := 1 to 10
	let $map := set:map($nums, function($value){xs:string($value) || "TEST"}, function($value){ $value * 2})
	return (
		assert:equal(map:count($map), 10),
		for $key in map:keys($map)
		return (
			assert:true($key = ("1TEST", "2TEST", "3TEST", "4TEST", "5TEST", "6TEST", "7TEST", "8TEST", "9TEST", "10TEST"))
		),
		for $value in set:values($map)
		return (
			assert:true($value = (2, 4, 6, 8, 10, 12, 14, 16, 18, 20))
		)
	)
};

declare %test:case function inner-test() {
	let $inner := set:inner($left, $right)
	let $keys := map:keys($inner)
	return (
		assert:equal(map:count($inner), 3),
		for $key in $keys
		return (
			assert:true($key = ("3", "4", "9"))
		)
	)
};

declare %test:case function left-test() {
	let $left := set:left($left, $right)
	let $keys := map:keys($left)
	return (
		assert:equal(map:count($left), 2),
		for $key in $keys
		return (
			assert:true($key = ("1", "7")),
			assert:false($key = ("2", "5", "6", "8", "10"))
		)
	)
};

declare %test:case function right-test() {
	let $right := set:right($left, $right)
	let $keys := map:keys($right)
	return (
		assert:equal(map:count($right), 5),
		for $key in $keys
		return (
			assert:true($key = ("2", "5", "6", "8", "10")),
			assert:false($key = ("1", "7"))
		)
	)
};

declare %test:case function outer-test() {
	let $outer := set:outer($left, $right)
	let $keys := map:keys($outer)
	return (
		assert:equal(map:count($outer), 7),
		for $key in $keys
		return (
			assert:true($key = ("1", "7", "2", "5", "6", "8", "10")),
			assert:false($key = ("3", "4", "9"))
		)
	)
};

declare %test:case function union-test() {
	let $union := set:union($left, $right)
	let $keys := map:keys($union)
	return (
		assert:equal(map:count($union), 10),
		for $key in $keys
		return (
			assert:true($key = ("1", "7", "2", "5", "6", "8", "10", "3", "4", "9"))
		)
	)
};

declare %test:case function extend-test() {
	let $extend := set:extend(($left, $right))
	let $keys := map:keys($extend)
	return (
		assert:equal(map:count($extend), 10),
		for $key in $keys
		return (
			assert:true($key = ("1", "7", "2", "5", "6", "8", "10", "3", "4", "9"))
		)
	)
};