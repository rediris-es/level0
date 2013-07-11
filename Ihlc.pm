
package Ihlc ;

use Rtactions ;

use 5.012; 

my $dbg = 0 ;

sub dbg {
	if($dbg == 1)  { 
	 print "DEBUG IHLCommands :" ;
	for (my $i =0 ; $i!= @_ ; $i++) { print "$_[$i] " ; }
	print "\n" ;
	}
}

## declaracion 


sub ipfromstring  {
	my $ref= $_[0] ; 
	my $string=$_[1] ;
#	print "hay que buscar dir IP en  $string\n" ;
	my $ip= "0.0.0.0" ;
	if ($string =~ m/([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})/) {
		$ip= "$1\.$2\.$3\.$4" ;
		}
#	print "Return de func_ip_from es $ip \n" ;
	return $ip ;
}
	
sub getfromticket {
	my $ref=$_[0] ;
	my $code=$_[1] ;
	dbg("Ejecución función getfrom ticket argumento $code, current ticket = $ref->{'current'}") ;
	# this should be optimized if get from ticket is going to be call more than 1 time
	my %hash= Rtactions::RT_ticket_content ($ref->{'current'}) ;
	dbg("El resultado de getfromticket($code ) en el ticket $ref->{'current'} es $hash{$code}") ;
	return $hash{$code} ;
	}

sub take {
	my $ref= $_[0] ;
	my $id = $$ref{'current'} ;

	dbg("Ejecución de acción take argumento  $id") ;
	Rtactions::RT_take ($id) ;

	}

sub untake{
	my $ref= $_[0] ;
	my $id= $$ref{'current'} ;
	dbg("ejcueción de acción untake argumento $id") ;
	Rtactions::RT_untake ($id) ;
	}

sub reject {
	my $ref=$_[0] ;
	my $id= $$ref{'current'} ;
	Rtactions::RT_reject($id) ;
	dbg ("ejecución de acción reject argumento $id") ;

	}

sub ticket_add {
	my $ref=$_[0] ;
	my $id= $_[1] ;
	my $field= $_[2] ;
	my $mode=$_[3] ;
	my $value = $_[4] ;
	dbg ( "Ejecución de ticked add id=$id , campo =$field  mode=$mode valor =$value") ;
	Rtactions::RT_store($id,$field,$mode,$value) ;
}
sub print {
	dbg "SE llama al comando print ..." ;
	for (my $i=1; $i!= @_ ; $i++  )  { print $_[$i] ; }
	print "\n" ;
	}

sub end_actions {
	my $ref=$_[0] ;
	$$ref{'ENDSTATUS'} = 1 ;
	dbg("Fin de acciones!!") ;
	}

sub next_action {
	my $ref=$_[0] ;
	$$ref{'ENDSTATUS'} = 0 ;
	dbg ("Sigiente acción") ; }

my %commands = (
	'take' => \&take,
	'untake' =>\&untake,
	'reject' =>\&reject,
	'end_actions' =>\&end_actions,
	'next_action' =>\&next_action,
	'ticket_add' => \&ticket_add,
	'print' => \&print,
	) ;

my %functions= (
	'getfromticket' => \&getfromticket,
	'ipfromstring' => \&ipfromstring,
 	) ;



sub lookup_proc {
	my $proc=$_[0] ;
	my $ret=-1 ;
	if (exists $commands{$proc} ) {
			dbg ("LOOKUP EXISTE el procedeure $proc");
			 $ret=$commands{$proc} ; } ;
	return $ret ; 
	}

sub lookup_func{
	my $func=$_[0] ;
	my $ret=-1;
	if (exists $functions{$func} ) {
			dbg ("LOOKUP EXISTE la función $func valor $functions{$func}");
			$ret=$functions{$func} ; } ; 
	return($ret) ;
	}
	
#required at end 
1;

