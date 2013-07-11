
package Actions ;

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

use Error qw(:try);

use Rtactions ;

use Ihl ; # The Incident Handling Language Parser ...

## Variables del modulo
## Mostly this is "wrapper" for using RTactions in both the 
my $server ; # internal variable for the RTIR server, assigned at login
my $username ; # Internal variable for the RTIR user, assigned at login
my $password ; # internal variable for the RTIR user passwor,d, assigned at login


my $pathdisplay="/RTIR/Display.html?id=" ;

my $dbg =0 ;

sub dbg {
	if($dbg == 1)  { 
	 print "DEBUG ACTIONS :" ;
	for (my $i =0 ; $i!= @_ ; $i++) { print "$_[$i] " ; }
	print "\n" ;
	}
}



#
# Currently implemented commands
# take / untake
# info / list
# Quit (main code)
#
# 
# Rules translation

my %rules_t= (
	 "allways" , "(1 == 1 )" ,
	 "never "  , "(0 == 0 )" ,
	 "#SUBJECT" , "\$ticket{'Subject'}",
	 "#FROM" ,    "\$ticket{'Requestors'}"
	 
	 ); 
           

my @rules ; # wil contain the rules

my $rulesfile="ihl-rules.xml" ;

# Funciones sobre las RULES

sub xml2hash {
         my $xml = $_[0] ;
         my %h=  () ;
        my $i ;
        my @temp =  qw (name description condition actions) ;
        foreach  $i (@temp)
                {
                 $xml =~/.*<$i>(.*)<\/$i>.*/s ;
                $h{$i} =$1 ;
                chomp $h{$i} ;
                }
        return  \%h ;
}

sub rulessplit  {
        my $cad =$_[0] ;
         $cad =~ /.*<rules>(.*)<\/rules>.*/msi ;
        my @alertas= split /<\/rule>/s , $1 ;
        pop @alertas ;
        for (my $i=0; $i!=@alertas ; $i++)  { $alertas[$i] .= "</rule>\n"  ; }
        return @alertas ;
        }
       
sub load_rules {
		open FILE, $rulesfile;
		my $txt =  join "" , <FILE> ;
		close FILE ;
#		dbg("leido : $txt") ;
		my @tmp = rulessplit ($txt) ;
#		print "Hay @tmp rules\n" ;
		foreach my $r  (@tmp ) {
			#print "processing $r en load_rules\n" ;
			my $rh =   xml2hash ($r) ;
			push @rules , $rh ;
		#	$rules{$$rh{'name'}} = $rh ; 
			
		}
}

sub print_rules {
		print "Current Rules\n" ;
		my $r ;
		for ($r =0 ; $r!=@rules ; $r++) {
			print "[$r] $rules[$r]->{'name'} , $rules[$r]->{'description'} \n" ;
		}
}

sub show_rule {
	my $r=$_[0] ;
	print "Name: $rules[$r]->{'name'}\nDescription: $rules[$r]->{'description'}\n" ;
	print "Condition:\n$rules[$r]->{'condition'}\n" ;
	print "Actiones:\n$rules[$r]->{'actions'}\n" ;
	}


sub rules_translate {
		my $linea = $_[0] ;
		$linea =~ tr/\n//d ;
		
		foreach my $k (keys %rules_t ) {
				if ($linea=~ /$k/) {
							$linea =~ s/$k/$rules_t{$k}/e ;
				}
		}
		return $linea ;
}
	



# Funciones 



sub login{
	$server=$_[0] ;
	$username=$_[1] ;
	$password=$_[2] ;

	Rtactions::RT_login  ($server,$username,$password) ;
}

sub list {
	Rtactions::RT_list ;
	}


sub get_tickets {
	return Rtactions::RT_get_tickets() ;
	}


sub info {
	my $id= $_[0] ;
	my $detail=$_[1] ;
	Rtactions::RT_info($id,$detail) ;
	}

sub take {
	my $type=shift (@_ ) ;
	my ($start, $end );
	my @list ;
	if  ($type eq "range" ) {
			$start=shift (@_ ) ; ;
			$end=shift  (@_) ;
			for (my $i=$start ; $i!=$end +1 ; $i++) { push @list, $i ;} 
			}
	elsif ($type eq "list") { 
		@list= split /\s+/,shift (@_) ; 
		@list= reverse (@list) ;
		pop @list ; # required last value in $list is not a ticket
		}
	elsif ($type eq "all") {
		@list= get_tickets() ; }
	foreach my $k (@list) { Rtactions::RT_take  $k  ; }
}

sub untake {
	my $type=shift (@_ ) ;
	my ($start, $end );
	my @list ;
	if  ($type eq "range" ) {
			$start=shift (@_ ) ; ;
			$end=shift  (@_) ;
			for (my $i=$start ; $i!=$end +1 ; $i++) { push @list, $i ;} 
			}
	elsif ($type eq "list") { 
		@list= split /\s+/,shift (@_) ; 
		@list= reverse (@list) ;
		pop @list ; # required last value in $list is not a ticket
		}
	elsif ($type eq "all") {
		@list= get_tickets() ; }
	foreach my $k (@list) { Rtactions::RT_untake $k  ; }
}

sub reject {
	my $type=shift (@_ ) ;
	my ($start, $end );
	my @list ;
	if  ($type eq "range" ) {
			$start=shift (@_ ) ; ;
			$end=shift  (@_) ;
			for (my $i=$start ; $i!=$end +1 ; $i++) { push @list, $i ;} 
			}
	elsif ($type eq "list") { 
		@list= split /\s+/,shift (@_) ; 
		@list= reverse (@list) ;
		pop @list ; # required last value in $list is not a ticket
		}
	elsif ($type eq "all") {
		@list= get_tickets() ; }
	foreach my $k (@list) { Rtactions::RT_reject $k  ; }
}


sub url  {
	my $type=shift (@_ ) ;
	my ($start, $end );
	my @list ;
	if  ($type eq "range" ) {
			$start=shift (@_ ) ; ;
			$end=shift  (@_) ;
			for (my $i=$start ; $i!=$end +1 ; $i++) { push @list, $i ;} 
			}
	elsif ($type eq "list") { 
		@list= split /\s+/,shift (@_) ; 
		@list= reverse (@list) ;
		pop @list ; # required last value in $list is not a ticket
		}
	elsif ($type eq "all") {
		@list= get_tickets() ; }
	foreach my $k (@list) { 	print "Ticket URL: " . $server . $pathdisplay . $k . "\n" ; }
}


sub do_actions {
	my  $regla=$_[0] ;
	my $codigo= $_[1] ;
	my $ticket = $_[2] ;
	
	my $ihl_parser=Ihl->new() ;

	$ihl_parser->setvar("current",$ticket) ;
	$ihl_parser->setvar("ENDSTATUS",-1) ;

	$codigo=~ s/\n/ /g ;
	$codigo=~ s/\t+/ / ;
#	print "Codigo limpio:\n$codigo\n" ;
	$ihl_parser->YYData->{DATA} = $codigo ;
#	$ihl_parser->YYParse(yydebug => 0x1F, YYlex => \&Ihl::ihllex) ;
	$ihl_parser->YYParse( YYlex => \&Ihl::ihllex) ;
	
	my $res= $ihl_parser->getvar("ENDSTATUS") ;
	
	if ($res == -1 ) { print "RULE $regla has a error evaluation return $res on ticket $ticket \n" ;  $res=0 ; }
	return $res ;
}	

sub do_process {
		
		my $id = $_[0];
#		my $ticket = $rt->show(type => 'ticket', id => $id); 
		my %ticket= Rtactions::RT_ticket_content($id) ;
		my $mode ="test" ;
		my $fin =0 ; 
		my %localvars = () ; 
		for (my $k=0 ;  ($k!=@rules && $fin != 1)  ; $k++) {
			my $cond = rules_translate ($rules[$k]->{'condition'} ) ;
#			dbg ("condition a evluar es $cond-x-") ;
			#print "from = $ticket->{'Requestors'} subject $ticket->{'Subject'}\n" ; 
			if (eval  ($cond)) {
				dbg ("$cond evalua a true !!"); 
				dbg ("Regla $k concuerda. En ticket $id hay que ejecutar  $rules[$k]->{'actions'}") ;

				$fin= do_actions ($k, $rules[$k]->{'actions'},$id) ;

#			print "Rule $k match\n: execute $rules->[$k]->{'actions'} , ticket $id\n" ;

			#		$fin = do_actions ($k, $rules[$k]->{'actions'} , $id  ) ;

		}
					
		}
}




sub process {
	my $type=shift (@_ ) ;
	my ($start, $end );
	my @list ;
	if  ($type eq "range" ) {
			$start=shift (@_ ) ; ;
			$end=shift  (@_) ;
			for (my $i=$start ; $i!=$end +1 ; $i++) { push @list, $i ;} 
			}
	elsif ($type eq "list") { 
		@list= split /\s+/,shift (@_) ; 
		@list= reverse (@list) ;
		pop @list ; # required last value in $list is not a ticket
		}
	elsif ($type eq "all") {
		@list= get_tickets() ; }
	foreach my $k (@list) { do_process $k  ; }
}

	
 
## Required at end
1;
 
