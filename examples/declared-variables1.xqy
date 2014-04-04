xquery version "1.0-ml";

declare function local:slow($i as xs:int) {
	xdmp:spawn-function(
		function() {
			xdmp:sleep($i * 1000), $i
		},
		<options xmlns="xdmp:eval">
			<result>{fn:true()}</result>
		</options>
	)
};

declare variable $a := local:slow(5);
declare variable $b := local:slow(4);
declare variable $c := local:slow(3);
declare variable $d := local:slow(2);
declare variable $e := local:slow(1);

xdmp:elapsed-time()