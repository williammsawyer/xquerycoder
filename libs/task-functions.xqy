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
@description Run set number of tasks in sequence.
@requires MarkLogic 7+.

:)

module namespace task = "http://www.xquerycoder.com/libs/task-functions";

declare namespace eval = "xdmp:eval";

declare variable $trace-key := "TaskList";

(:
	The purpose of this library is to be able to perform tasks sequentially or in other words one after another.
	Perfroming tasks sequentially allows each task to build upon each other or act on the results of the previous task.
	Once a task list has started it will coninute util: it reaches the end of the list; a task returns false; a task errors; or server restart.

	Example:

	task:start((
        task:function('first', function(){ let $s := xdmp:sleep(1000) return xdmp:log('first')}, ()),
        task:function('second', function(){ let $s := xdmp:sleep(1000) return xdmp:log('second')}, ()),
        task:function('third', function(){ let $s := xdmp:sleep(1000) return xdmp:log('third')}, ()),
        task:function('forth', function(){ let $s := xdmp:sleep(1000) return xdmp:log('forth')}, ()),
        task:function('fifth', function(){ let $s := xdmp:sleep(1000) return xdmp:log('fifth')}, ())
    ))

	Log Result
        2014-05-30 22:05:28.223 Info: [Event:id=TaskList] Starting: first
        2014-05-30 22:05:29.223 Info: TaskServer: first
        2014-05-30 22:05:29.223 Info: [Event:id=TaskList] Finished: first
        2014-05-30 22:05:29.223 Info: [Event:id=TaskList] Starting: second
        2014-05-30 22:05:30.223 Info: TaskServer: second
        2014-05-30 22:05:30.223 Info: [Event:id=TaskList] Finished: second
        2014-05-30 22:05:30.223 Info: [Event:id=TaskList] Starting: third
        2014-05-30 22:05:31.223 Info: TaskServer: third
        2014-05-30 22:05:31.223 Info: [Event:id=TaskList] Finished: third
        2014-05-30 22:05:31.223 Info: [Event:id=TaskList] Starting: forth
        2014-05-30 22:05:32.223 Info: TaskServer: forth
        2014-05-30 22:05:32.223 Info: [Event:id=TaskList] Finished: forth
        2014-05-30 22:05:32.223 Info: [Event:id=TaskList] Starting: fifth
        2014-05-30 22:05:33.223 Info: TaskServer: fifth
        2014-05-30 22:05:33.223 Info: [Event:id=TaskList] Finished: fifth
        2014-05-30 22:05:33.223 Info: [Event:id=TaskList] Tasks complete
:)

(:
   Builds a task to invoke a function with the given invoke options.
   If your function needs to be invoked in a update transaction make sure you call xdmp:commit() at the end of the function.
   Referer to xdmp:invoke-function documentation for valid $options.
   http://docs.marklogic.com/xdmp:invoke-function
:)
declare function task:function($name as xs:string, $fn as xdmp:function, $options as element(eval:options)?) {
	map:new((
		map:entry("name", $name),
		map:entry("type", "function"),
		map:entry("fn", $fn),
		map:entry("options", $options)
	))
};

(:
	Builds a task to invoke a file with the given invoke options/params
	Referer to xdmp:invoke documentation for valid $options and $params.
	http://docs.marklogic.com/xdmp:invoke
:)
declare function task:file($name as xs:string, $path as xs:string, $options as element(eval:options)?, $params as item()*) {
	map:new((
		map:entry("name", $name),
		map:entry("type", "file"),
		map:entry("path", $path),
		map:entry("options", $options),
		map:entry("params", $params)
	))
};

(: Start executing the tasks :)
declare function task:start($tasks as map:map+) {
	xdmp:spawn-function(
		function() {
			task:invoke($tasks)
		}
	)
};

(: Invokes the first task and then spawns the next one :)
declare function task:invoke($tasks as map:map*) {
	let $task as map:map? := $tasks[1]
	let $tail as map:map* := fn:tail($tasks)
	return (
		if ( fn:exists($task) ) then (
			let $name as xs:string := map:get($task, 'name')
			let $report := xdmp:trace($trace-key, "Starting: " || $name)
			let $run as item()* :=
				switch ( map:get($task, 'type') )
				case "function" return (
					xdmp:invoke-function(
						map:get($task, 'fn'),
						map:get($task, 'options')
					)
				)
				case "file" return (
					xdmp:invoke(
						map:get($task, 'path'),
						map:get($task, 'params'),
						map:get($task, 'options')
					)
				)
				default return ()
			return (
				if ( fn:not($run = fn:false()) ) then (
					let $report := xdmp:trace($trace-key, "Finished: " || $name)
					let $start-next := if ( fn:exists($tail)) then ( task:start($tail) ) else ( xdmp:trace($trace-key, "Tasks complete"))
					return (
						$run
					)
				) else (
                    xdmp:trace($trace-key, "Tasks terminated after: " || $name)
                )
			)
		) else ()
	)
};