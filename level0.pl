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

use Cmd ;

use Actions ;

# Variables globales, etc

my $server="http://rt.rediris.es" ;
my $username ;
my $password ;

# Funciones locales
sub input {
	my $txt=$_[0] ;
	print "$txt" ;
	my $lin = <STDIN> ;
	if (($lin eq "\n")  && (defined $_[1] ) ) {
			$lin=$_[1] ; }
	else {  chomp $lin ; }
	return $lin ;
}

## Inicio del código

my $cmd_parser=Cmd->new() ;

my $prompt =" Command ?> " ;
my $term = Term::ReadLine->new('Level 0 for Incident Response') ;
my $linea ;

$server= input ("Servidor RT (defaults to $server )",$server) ;

$username= input ( "introduce el usuario: " ) ;
$password=  read_password (' password : ') ;

Actions::load_rules() ;

Actions::login($server,$username,$password) ;




$main::fin=0 ;

while ( $main::fin ==0  ) { 
#	 $linea = $term->readline ($prompt ) ;
#	$cmd_parser->YYData->{DATA} = $linea ;
#	$cmd_parser->YYParse(yylex=> \&lex) ;
#	$cmd_parser->YYData->{DATA} = <STDIN> ;
	$linea= $term->readline ($prompt) ;
	$cmd_parser->YYData->{DATA} = $linea ;
#	$cmd_parser->YYParse(yydebug => 0x1F, YYlex => \&Cmd::cmdlex) ;
	$cmd_parser->YYParse( YYlex => \&Cmd::cmdlex) ;

}	
