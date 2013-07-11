#!/usr/bin/perl


use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

use Error qw(:try);
use RT::Client::REST;
use RT::Client::REST::Ticket;

use Term::ReadKey;   
use Term::ReadPassword;
use Term::ReadLine ;

use Net::IP ;

use Ihl ;

use actions ;

# Variables globales, etc


## Inicio del código

my $codigo=<<FIN;
take ;
\$variable = 10 ;
\$subject=getfromticket("subject") ;
\$ip = ipfromstring(\$subject)  ;
ticket_add(\$current,"ip","append",\$ip) ;
next_action ;
FIN

$codigo=<<FIN2;
		\$uno= 1 ;
		print ("uno--->", \$uno );
		if  ( \$uno == 1 ) then { print ("uno") ; } else { print ("dos") ; } ;
		end_actions ;
FIN2

	print "Codigo a ejecutar:\n$codigo\n" ;

	my $ihl_parser=Ihl->new() ;

	$ihl_parser->setvar("current",12345) ;
	$ihl_parser->setvar("ENDSTATUS",-1) ;

	$ihl_parser->setvar("debug",1) ;

	$codigo=~ s/\n/ /g ;
	$codigo=~ s/\t//g ;
	
	print "Codigo a ejecutar:\n$codigo\n" ;

	$ihl_parser->YYData->{DATA} = $codigo ;
#	$ihl_parser->YYParse(yydebug => 0x1F, YYlex => \&Ihl::ihllex) ;
	$ihl_parser->YYParse( YYlex => \&Ihl::ihllex) ;
	my $res= $ihl_parser->getvar("ENDSTATUS") ;
	print "Resultado de la ejecución del codigo es $res\n" ;

#$fin = do_actions ($k, $rules[$k]->{'actions'} , $id  ) ;
# Action , programa, ticketid

