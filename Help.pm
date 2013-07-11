
package Help ;

use strict ;

# Implementation of the "help command", separated from the actions.pm for better customization , translations, and text editing

my %text = (

	'default' => '

help command will provide a detailed command help

other commands with help page:

take : take a ticket
untake : untake a ticket
reject: reject a ticket
info: information about a ticket
quit : end the program
list: list the incident report queue

ihl: Introduction to the "Incident Handling Language"

',

	'TAKE' => '

Take a ticket , arguments can be:
	- a ticket code 
	- the word "all" to mean all the incident report queue ticket owned by nobody
	- a list of ticket codes, separated by space
	- a ticket range code_start - code_end

it will only take the unassigned tickets
',


	'UNTAKE' => '
Untake a ticket arguments can be:
	- a ticket code 
	- the word "all" to mean all the incident report queue ticket owned by the user in the IR queue and not linked to an incident
	- a list of ticket codes, separated by space
	- a ticket range code_start - code_end
it will only untake the tickets owned by the user
',

	'LIST' => '
Produce a listing of the tickets in the Incident Report Queue , whose state is new or open and are not linked to an incident
' ,
	'INFO' => '
Provide information about a ticket ID  , normal mode presents the basic information about the incident, with "details" it dump
the full list information of the tickets
',
	'PROCESS' => '
More important command and still not fully implemented, it will process the ticket using the "rules" file in order to know  what to do
with each ticket, as usual the argument can be:
	- a ticket code 
	- the word "all" to mean all the incident report queue ticket owned by nobody
	- a list of ticket codes, separated by space
	- a ticket range code_start - code_end

',
	'REJECT' => '
Reject a ticket, as usual it can have different, as usual it can accept:
	- a ticket code 
	- the word "all" to mean all the incident report queue ticket owned by nobody
	- a list of ticket codes, separated by space
	- a ticket range code_start - code_end

',
	'IHL' => '
Incident Handling Language.
	

Little language to express what to do with a ticket, see the file "language.txt" for more info
'

);

sub help {
	my $arg=$_[0] ;
	if  (defined ($text{$arg} )) { print $text{$arg} ; }
	else { print $text{'default'}  ; }
}

### Required at end

