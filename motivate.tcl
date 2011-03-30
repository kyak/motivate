#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

#data file containing the tree of questions in xml format
set datafile "motivate.xml"

#for text output
proc output {text} {
	regsub -all {[\t\n]} $text {} value
	if {$value == ""} {
		exit
	} else {
		puts $value
	}
}

#read the data file
if {[catch {set fd [open $datafile r]}]} {puts "No data file, exiting..."; exit}
set data [read $fd]
close $fd

#use tDOM package to parse XML into DOM tree
package require tdom
dom parse $data doc
$doc documentElement root

#output the top node
set node [$root firstChild]
output [[$node firstChild] nodeValue]

#traverse the DOM tree
while {1} {
	puts "y/n?"
	gets stdin answer
	#select child nodes "node"
	set nodes [$node selectNodes node]
	#the number of child nodes
	set nodesnum [llength $nodes]
	if {$answer == "y"} {
		if {$nodesnum < 1} {
			#answered YES, but the number of child nodes < 1,
			#therefore it's empty (shouldn't really ever get here)
			exit
		}
		#the first "node" node is YES
		set node [lindex $nodes 0]
	} else {
		if {$nodesnum < 2} {
			#the same check as above, but this time we can get here
			#cause the NO node may be omitted (to save some space)
			exit
		}
		#the seconds "node" node is NO
		set node [lindex $nodes 1]
	}
	#if this is the last node, it has no children
	#and the text is directly retrieved by nodeValue
	if {[$node hasChildNodes]} {
		output [[$node firstChild] nodeValue]
	} else {
		output [$node nodeValue]
	}
	#nowhere to go from this node, let's exit
	if {[llength [$node selectNodes node]] == 0} {exit}
}
