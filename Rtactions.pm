
package Rtactions ;

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

use Error qw(:try);
use RT::Client::REST;
use RT::Client::REST::Ticket;


## Variables del modulo

my $rt ;  # Internal variable for the RT instance
my $server ; # internal variable for the RTIR server, assigned at login
my $username ; # Internal variable for the RTIR user, assigned at login
my $password ; # internal variable for the RTIR user passwor,d, assigned at login

#
# Currently implemented commands
# take / untake
# info / list
# Quit (main code)
#
# 

# Funciones 

sub RT_login{
	$server=$_[0] ;
	$username=$_[1] ;
	$password=$_[2] ;

	
	$rt = RT::Client::REST->new(
   	server  => $server ,
	);
	$rt->login(
    username => $username, 
    password => $password,
) || die "Login error !!\n" ;
	return "0" ;
}


sub RT_list {

my @ids = $rt->search(
               type => 'ticket',
               query => "Status = 'new' and Queue = 'Incident Reports' ",
             );
my $count=0 ;
             for my $id (@ids) {
              my ($ticket) = $rt->show(type => 'ticket', id => $id);
	      foreach my $k  (keys ( %$ticket)) {
		#	print "$k tipo ", ref ($ticket->{$k}) , " valor $ticket->{$k} \n" ;
		}
		$count++ ;
              print "ID ", $id,  " ; Owner : ", $ticket->{'Owner'} , " Subject: ", $ticket->{'Subject'}, "\n";
             }
		print "\nTotal Incomming reports: $count\n" ;

}

sub RT_get_tickets {
	my @ids = $rt->search(
           type => 'ticket',
             query => "Status = 'new' and Queue = 'Incident Reports' ",
         );
	return @ids ;
	}

sub RT_ticket_content {
	my $id=$_[0] ;
	my ($ticket) = $rt->show(type => 'ticket', id => $id);
	my %ret ;
	 foreach my $k  (keys ( %$ticket)) { $ret{$k} = $ticket->{$k}  ; }
	return %ret ;
}
sub RT_info {
	my $id= $_[0] ;
	my $detail=$_[1] ;

	my ($ticket) = $rt->show(type => 'ticket', id => $id);
	if  ($detail ne '' ) {
		print "Full information for ticket $id\n" ;
	         foreach my $k  (keys ( %$ticket)) { print "$k  ==  $ticket->{$k} \n" ; }
	}
	else {
		print "ticket $id information \n" ;
		print  "id : ", $ticket->{'id'} , "; Owner : ", $ticket->{'Owner'}, "  State: ", $ticket->{'Status'} ," \n" ;
		print "From: ", $ticket->{'Requestors'} , "Subject: " , $ticket->{'Subject'}, "\n" ;
		print "IP addresses  : ", $ticket->{'CF.{IP}'}, "\n" ;
	
	}

}


sub  RT_take {
	my $id= $_[0] ;
 
	my $ret =0 ; 		
		
try {
    RT::Client::REST::Ticket->new(
        rt  => $rt,
        id  => $id,
    )->take;
} catch Exception::Class::Base with {
    my $e = shift;
#    die ref($e), ": ", $e->message || $e->description, "\n";
	print "$id ERROR:" , ref($e) , ":" , $e->message || $e->description, "\n";
	$ret=-1 ; 
};

}

##

sub  RT_untake {
	my $id= $_[0] ;
 
	my $ret =0 ; 		
		
try {
    RT::Client::REST::Ticket->new(
        rt  => $rt,
        id  => $id,
    )->untake;
} catch Exception::Class::Base with {
    my $e = shift;
#    die ref($e), ": ", $e->message || $e->description, "\n";
	print "ERROR:" , ref($e) , ":" , $e->message || $e->description, "\n";
	$ret=-1 ; 
};

}

##

sub RT_reject {
	my $id = $_[0] ;
	# Reject es dos cosas, el custom field y el Status se hace en dos transacciones
	# pillamos el ticket
	
#	print "Reject of ticket $id\n" ;
	my $ticket = RT::Client::REST::Ticket->new(
    	rt  => $rt,
 	id  => $id, );
	
	# el normal
	$ticket->status('rejected') ;   
	#  Custom field 
	$ticket->cf('{State}', 'rejected') ;
	
	try {
    $ticket->store;
	} catch Exception::Class::Base with {
    my $e = shift;
     print "ERROR:",  ref($e), ": ", $e->message || $e->description, "\n";
	 };
	
    }




## 

sub RT_store {
	my $id= $_[0] ;
	my $field =$_[1] ;
	my $mode=$_[2] ;
	my $value=$_[3] ;

	my %values ;
	my $oldval ;
	my $newval ;
	my $sep="" ;
	# Syntax check of IP address
	if ($field eq "ip") { 	
			unless ( (my $addr= new Net::IP ($value) )) {
					print "Error !$value! is not an IP address!!\n" ;
					return (-1) ;
				}
			}
	$newval=$value ;
 
	if ($mode eq "append") {
				 %values = RT_ticket_content($id) ; 
				# Special RedIRIS case with IP addresses
				$oldval=$values{$field} if (defined ($values{$field}))  ;
	
				if ($field eq "ip") { 
					  $oldval= $values{'CF.{IP}'} ; 
					  $sep="," ;
					  if ($oldval ne "") { $oldval.= $sep ; }
					}
				$newval= $oldval .  $value ;
				}
				
	my $ticket = RT::Client::REST::Ticket->new(rt=>$rt, id=> $id) ;
	
	#  special case of IP address
#	print "campo a añadir $newval\n" ;
	if ($field eq "ip") {
		
		$ticket->cf('ip',$newval) ;
		try {
    		$ticket->store;
		} catch Exception::Class::Base with {
  		my $e = shift;
    		print "ERROR: ",  ref($e), ": ", $e->message || $e->description, "\n";
	 	};
	}
	else{ 
		print "Sorry, demo mode still not implemented !!\n" ;}	

}
	
 
## Required at end
1;
 
