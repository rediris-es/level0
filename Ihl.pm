####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package Ihl;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
#Included Parse/Yapp/Driver.pm file----------------------------------------
{
#
# Module Parse::Yapp::Driver
#
# This module is part of the Parse::Yapp package available on your
# nearest CPAN
#
# Any use of this module in a standalone parser make the included
# text under the same copyright as the Parse::Yapp module itself.
#
# This notice should remain unchanged.
#
# (c) Copyright 1998-2001 Francois Desarmenien, all rights reserved.
# (see the pod text in Parse::Yapp module for use and distribution rights)
#

package Parse::Yapp::Driver;

require 5.004;

use strict;

use vars qw ( $VERSION $COMPATIBLE $FILENAME );

$VERSION = '1.05';
$COMPATIBLE = '0.07';
$FILENAME=__FILE__;

use Carp;

#Known parameters, all starting with YY (leading YY will be discarded)
my(%params)=(YYLEX => 'CODE', 'YYERROR' => 'CODE', YYVERSION => '',
			 YYRULES => 'ARRAY', YYSTATES => 'ARRAY', YYDEBUG => '');
#Mandatory parameters
my(@params)=('LEX','RULES','STATES');

sub new {
    my($class)=shift;
	my($errst,$nberr,$token,$value,$check,$dotpos);
    my($self)={ ERROR => \&_Error,
				ERRST => \$errst,
                NBERR => \$nberr,
				TOKEN => \$token,
				VALUE => \$value,
				DOTPOS => \$dotpos,
				STACK => [],
				DEBUG => 0,
				CHECK => \$check };

	_CheckParams( [], \%params, \@_, $self );

		exists($$self{VERSION})
	and	$$self{VERSION} < $COMPATIBLE
	and	croak "Yapp driver version $VERSION ".
			  "incompatible with version $$self{VERSION}:\n".
			  "Please recompile parser module.";

        ref($class)
    and $class=ref($class);

    bless($self,$class);
}

sub YYParse {
    my($self)=shift;
    my($retval);

	_CheckParams( \@params, \%params, \@_, $self );

	if($$self{DEBUG}) {
		_DBLoad();
		$retval = eval '$self->_DBParse()';#Do not create stab entry on compile
        $@ and die $@;
	}
	else {
		$retval = $self->_Parse();
	}
    $retval
}

sub YYData {
	my($self)=shift;

		exists($$self{USER})
	or	$$self{USER}={};

	$$self{USER};
	
}

sub YYErrok {
	my($self)=shift;

	${$$self{ERRST}}=0;
    undef;
}

sub YYNberr {
	my($self)=shift;

	${$$self{NBERR}};
}

sub YYRecovering {
	my($self)=shift;

	${$$self{ERRST}} != 0;
}

sub YYAbort {
	my($self)=shift;

	${$$self{CHECK}}='ABORT';
    undef;
}

sub YYAccept {
	my($self)=shift;

	${$$self{CHECK}}='ACCEPT';
    undef;
}

sub YYError {
	my($self)=shift;

	${$$self{CHECK}}='ERROR';
    undef;
}

sub YYSemval {
	my($self)=shift;
	my($index)= $_[0] - ${$$self{DOTPOS}} - 1;

		$index < 0
	and	-$index <= @{$$self{STACK}}
	and	return $$self{STACK}[$index][1];

	undef;	#Invalid index
}

sub YYCurtok {
	my($self)=shift;

        @_
    and ${$$self{TOKEN}}=$_[0];
    ${$$self{TOKEN}};
}

sub YYCurval {
	my($self)=shift;

        @_
    and ${$$self{VALUE}}=$_[0];
    ${$$self{VALUE}};
}

sub YYExpect {
    my($self)=shift;

    keys %{$self->{STATES}[$self->{STACK}[-1][0]]{ACTIONS}}
}

sub YYLexer {
    my($self)=shift;

	$$self{LEX};
}


#################
# Private stuff #
#################


sub _CheckParams {
	my($mandatory,$checklist,$inarray,$outhash)=@_;
	my($prm,$value);
	my($prmlst)={};

	while(($prm,$value)=splice(@$inarray,0,2)) {
        $prm=uc($prm);
			exists($$checklist{$prm})
		or	croak("Unknow parameter '$prm'");
			ref($value) eq $$checklist{$prm}
		or	croak("Invalid value for parameter '$prm'");
        $prm=unpack('@2A*',$prm);
		$$outhash{$prm}=$value;
	}
	for (@$mandatory) {
			exists($$outhash{$_})
		or	croak("Missing mandatory parameter '".lc($_)."'");
	}
}

sub _Error {
	print "Parse error.\n";
}

sub _DBLoad {
	{
		no strict 'refs';

			exists(${__PACKAGE__.'::'}{_DBParse})#Already loaded ?
		and	return;
	}
	my($fname)=__FILE__;
	my(@drv);
	open(DRV,"<$fname") or die "Report this as a BUG: Cannot open $fname";
	while(<DRV>) {
                	/^\s*sub\s+_Parse\s*{\s*$/ .. /^\s*}\s*#\s*_Parse\s*$/
        	and     do {
                	s/^#DBG>//;
                	push(@drv,$_);
        	}
	}
	close(DRV);

	$drv[0]=~s/_P/_DBP/;
	eval join('',@drv);
}

#Note that for loading debugging version of the driver,
#this file will be parsed from 'sub _Parse' up to '}#_Parse' inclusive.
#So, DO NOT remove comment at end of sub !!!
sub _Parse {
    my($self)=shift;

	my($rules,$states,$lex,$error)
     = @$self{ 'RULES', 'STATES', 'LEX', 'ERROR' };
	my($errstatus,$nberror,$token,$value,$stack,$check,$dotpos)
     = @$self{ 'ERRST', 'NBERR', 'TOKEN', 'VALUE', 'STACK', 'CHECK', 'DOTPOS' };

#DBG>	my($debug)=$$self{DEBUG};
#DBG>	my($dbgerror)=0;

#DBG>	my($ShowCurToken) = sub {
#DBG>		my($tok)='>';
#DBG>		for (split('',$$token)) {
#DBG>			$tok.=		(ord($_) < 32 or ord($_) > 126)
#DBG>					?	sprintf('<%02X>',ord($_))
#DBG>					:	$_;
#DBG>		}
#DBG>		$tok.='<';
#DBG>	};

	$$errstatus=0;
	$$nberror=0;
	($$token,$$value)=(undef,undef);
	@$stack=( [ 0, undef ] );
	$$check='';

    while(1) {
        my($actions,$act,$stateno);

        $stateno=$$stack[-1][0];
        $actions=$$states[$stateno];

#DBG>	print STDERR ('-' x 40),"\n";
#DBG>		$debug & 0x2
#DBG>	and	print STDERR "In state $stateno:\n";
#DBG>		$debug & 0x08
#DBG>	and	print STDERR "Stack:[".
#DBG>					 join(',',map { $$_[0] } @$stack).
#DBG>					 "]\n";


        if  (exists($$actions{ACTIONS})) {

				defined($$token)
            or	do {
				($$token,$$value)=&$lex($self);
#DBG>				$debug & 0x01
#DBG>			and	print STDERR "Need token. Got ".&$ShowCurToken."\n";
			};

            $act=   exists($$actions{ACTIONS}{$$token})
                    ?   $$actions{ACTIONS}{$$token}
                    :   exists($$actions{DEFAULT})
                        ?   $$actions{DEFAULT}
                        :   undef;
        }
        else {
            $act=$$actions{DEFAULT};
#DBG>			$debug & 0x01
#DBG>		and	print STDERR "Don't need token.\n";
        }

            defined($act)
        and do {

                $act > 0
            and do {        #shift

#DBG>				$debug & 0x04
#DBG>			and	print STDERR "Shift and go to state $act.\n";

					$$errstatus
				and	do {
					--$$errstatus;

#DBG>					$debug & 0x10
#DBG>				and	$dbgerror
#DBG>				and	$$errstatus == 0
#DBG>				and	do {
#DBG>					print STDERR "**End of Error recovery.\n";
#DBG>					$dbgerror=0;
#DBG>				};
				};


                push(@$stack,[ $act, $$value ]);

					$$token ne ''	#Don't eat the eof
				and	$$token=$$value=undef;
                next;
            };

            #reduce
            my($lhs,$len,$code,@sempar,$semval);
            ($lhs,$len,$code)=@{$$rules[-$act]};

#DBG>			$debug & 0x04
#DBG>		and	$act
#DBG>		and	print STDERR "Reduce using rule ".-$act." ($lhs,$len): ";

                $act
            or  $self->YYAccept();

            $$dotpos=$len;

                unpack('A1',$lhs) eq '@'    #In line rule
            and do {
                    $lhs =~ /^\@[0-9]+\-([0-9]+)$/
                or  die "In line rule name '$lhs' ill formed: ".
                        "report it as a BUG.\n";
                $$dotpos = $1;
            };

            @sempar =       $$dotpos
                        ?   map { $$_[1] } @$stack[ -$$dotpos .. -1 ]
                        :   ();

            $semval = $code ? &$code( $self, @sempar )
                            : @sempar ? $sempar[0] : undef;

            splice(@$stack,-$len,$len);

                $$check eq 'ACCEPT'
            and do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Accept.\n";

				return($semval);
			};

                $$check eq 'ABORT'
            and	do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Abort.\n";

				return(undef);

			};

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Back to state $$stack[-1][0], then ";

                $$check eq 'ERROR'
            or  do {
#DBG>				$debug & 0x04
#DBG>			and	print STDERR 
#DBG>				    "go to state $$states[$$stack[-1][0]]{GOTOS}{$lhs}.\n";

#DBG>				$debug & 0x10
#DBG>			and	$dbgerror
#DBG>			and	$$errstatus == 0
#DBG>			and	do {
#DBG>				print STDERR "**End of Error recovery.\n";
#DBG>				$dbgerror=0;
#DBG>			};

			    push(@$stack,
                     [ $$states[$$stack[-1][0]]{GOTOS}{$lhs}, $semval ]);
                $$check='';
                next;
            };

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Forced Error recovery.\n";

            $$check='';

        };

        #Error
            $$errstatus
        or   do {

            $$errstatus = 1;
            &$error($self);
                $$errstatus # if 0, then YYErrok has been called
            or  next;       # so continue parsing

#DBG>			$debug & 0x10
#DBG>		and	do {
#DBG>			print STDERR "**Entering Error recovery.\n";
#DBG>			++$dbgerror;
#DBG>		};

            ++$$nberror;

        };

			$$errstatus == 3	#The next token is not valid: discard it
		and	do {
				$$token eq ''	# End of input: no hope
			and	do {
#DBG>				$debug & 0x10
#DBG>			and	print STDERR "**At eof: aborting.\n";
				return(undef);
			};

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Dicard invalid token ".&$ShowCurToken.".\n";

			$$token=$$value=undef;
		};

        $$errstatus=3;

		while(	  @$stack
			  and (		not exists($$states[$$stack[-1][0]]{ACTIONS})
			        or  not exists($$states[$$stack[-1][0]]{ACTIONS}{error})
					or	$$states[$$stack[-1][0]]{ACTIONS}{error} <= 0)) {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Pop state $$stack[-1][0].\n";

			pop(@$stack);
		}

			@$stack
		or	do {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**No state left on stack: aborting.\n";

			return(undef);
		};

		#shift the error token

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Shift \$error token and go to state ".
#DBG>						 $$states[$$stack[-1][0]]{ACTIONS}{error}.
#DBG>						 ".\n";

		push(@$stack, [ $$states[$$stack[-1][0]]{ACTIONS}{error}, undef ]);

    }

    #never reached
	croak("Error in driver logic. Please, report it as a BUG");

}#_Parse
#DO NOT remove comment

1;

}
#End of include--------------------------------------------------


#line 1 "Ihl.yp"



use Rtactions ;
use Ihlc ;
use strict ;
use 5.012; 

my %varspace;

$varspace{'end_status'} =0 ;

my @stackarg ;
my @stackexp ;

$varspace{'debug'} = 0 ;

sub dbg {
	if($varspace{'debug'} == 1)  { 
	 print "DEBUG IHL :" ;
	for (my $i =0 ; $i!= @_ ; $i++) { print "$_[$i] " ; }
	print "\n" ;
	return 1 ;
	}
}

sub setvar{
	my $var=$_[1] ;
	my $value=$_[2] ;
	$varspace{$var}= $value ;
	dbg( "llamada a setvar, variable $var , valor $value") ;
	}

sub getvar{
	my $var=$_[1] ;
	dbg ("get var de $var, return value is $varspace{$var}") ;
	return ($varspace{$var}) ;
	}



sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			'NAME' => 2,
			'VAR' => 8,
			'IF' => 7
		},
		GOTOS => {
			'statement_list' => 1,
			'asignation' => 6,
			'statement' => 5,
			'procedure_call' => 3,
			'root' => 9,
			'conditional' => 4
		}
	},
	{#State 1
		ACTIONS => {
			'NAME' => 2,
			'IF' => 7,
			'VAR' => 8
		},
		DEFAULT => -1,
		GOTOS => {
			'statement' => 10,
			'asignation' => 6,
			'procedure_call' => 3,
			'conditional' => 4
		}
	},
	{#State 2
		ACTIONS => {
			'OPENPAR' => 11
		},
		DEFAULT => -18
	},
	{#State 3
		DEFAULT => -4
	},
	{#State 4
		DEFAULT => -6
	},
	{#State 5
		ACTIONS => {
			'PERIOD' => 12
		}
	},
	{#State 6
		DEFAULT => -5
	},
	{#State 7
		ACTIONS => {
			'OPENPAR' => 13
		},
		GOTOS => {
			'condition' => 14
		}
	},
	{#State 8
		ACTIONS => {
			'ASSIGN' => 15
		}
	},
	{#State 9
		ACTIONS => {
			'' => 16
		}
	},
	{#State 10
		ACTIONS => {
			'PERIOD' => 17
		}
	},
	{#State 11
		ACTIONS => {
			'NAME' => 18,
			'VAR' => 24,
			'NUMBER' => 25,
			'OPENPAR' => 22,
			'STRING' => 21
		},
		GOTOS => {
			'value_list' => 20,
			'function' => 19,
			'expression' => 23
		}
	},
	{#State 12
		DEFAULT => -2
	},
	{#State 13
		ACTIONS => {
			'NAME' => 18,
			'VAR' => 24,
			'NUMBER' => 25,
			'OPENPAR' => 22,
			'STRING' => 21
		},
		GOTOS => {
			'function' => 19,
			'expression' => 26
		}
	},
	{#State 14
		ACTIONS => {
			'THEN' => 27
		}
	},
	{#State 15
		ACTIONS => {
			'NAME' => 18,
			'VAR' => 24,
			'NUMBER' => 25,
			'OPENPAR' => 22,
			'STRING' => 21
		},
		GOTOS => {
			'function' => 19,
			'expression' => 28
		}
	},
	{#State 16
		DEFAULT => 0
	},
	{#State 17
		DEFAULT => -3
	},
	{#State 18
		ACTIONS => {
			'OPENPAR' => 29
		}
	},
	{#State 19
		DEFAULT => -14
	},
	{#State 20
		ACTIONS => {
			'CLOSEPAR' => 30
		}
	},
	{#State 21
		DEFAULT => -13
	},
	{#State 22
		ACTIONS => {
			'NAME' => 18,
			'VAR' => 24,
			'NUMBER' => 25,
			'OPENPAR' => 22,
			'STRING' => 21
		},
		GOTOS => {
			'function' => 19,
			'expression' => 31
		}
	},
	{#State 23
		ACTIONS => {
			'COMMA' => 32
		},
		DEFAULT => -16
	},
	{#State 24
		DEFAULT => -12
	},
	{#State 25
		DEFAULT => -10
	},
	{#State 26
		ACTIONS => {
			'NOTEQ' => 33,
			'EQUAL' => 34
		}
	},
	{#State 27
		ACTIONS => {
			'BK_BEGIN' => 35
		}
	},
	{#State 28
		DEFAULT => -9
	},
	{#State 29
		ACTIONS => {
			'NAME' => 18,
			'VAR' => 24,
			'NUMBER' => 25,
			'OPENPAR' => 22,
			'STRING' => 21
		},
		GOTOS => {
			'value_list' => 36,
			'function' => 19,
			'expression' => 23
		}
	},
	{#State 30
		DEFAULT => -19
	},
	{#State 31
		ACTIONS => {
			'CLOSEPAR' => 37
		}
	},
	{#State 32
		ACTIONS => {
			'NAME' => 18,
			'VAR' => 24,
			'NUMBER' => 25,
			'OPENPAR' => 22,
			'STRING' => 21
		},
		GOTOS => {
			'value_list' => 38,
			'function' => 19,
			'expression' => 23
		}
	},
	{#State 33
		ACTIONS => {
			'NAME' => 18,
			'VAR' => 24,
			'NUMBER' => 25,
			'OPENPAR' => 22,
			'STRING' => 21
		},
		GOTOS => {
			'function' => 19,
			'expression' => 39
		}
	},
	{#State 34
		ACTIONS => {
			'NAME' => 18,
			'VAR' => 24,
			'NUMBER' => 25,
			'OPENPAR' => 22,
			'STRING' => 21
		},
		GOTOS => {
			'function' => 19,
			'expression' => 40
		}
	},
	{#State 35
		ACTIONS => {
			'NAME' => 2,
			'IF' => 7,
			'VAR' => 8
		},
		GOTOS => {
			'statement_list' => 41,
			'statement' => 5,
			'asignation' => 6,
			'procedure_call' => 3,
			'conditional' => 4
		}
	},
	{#State 36
		ACTIONS => {
			'CLOSEPAR' => 42
		}
	},
	{#State 37
		DEFAULT => -11
	},
	{#State 38
		DEFAULT => -17
	},
	{#State 39
		ACTIONS => {
			'CLOSEPAR' => 43
		}
	},
	{#State 40
		ACTIONS => {
			'CLOSEPAR' => 44
		}
	},
	{#State 41
		ACTIONS => {
			'NAME' => 2,
			'IF' => 7,
			'VAR' => 8,
			'BK_END' => 45
		},
		GOTOS => {
			'statement' => 10,
			'asignation' => 6,
			'procedure_call' => 3,
			'conditional' => 4
		}
	},
	{#State 42
		DEFAULT => -15
	},
	{#State 43
		DEFAULT => -21
	},
	{#State 44
		DEFAULT => -20
	},
	{#State 45
		ACTIONS => {
			'ELSE' => 46
		},
		DEFAULT => -8
	},
	{#State 46
		ACTIONS => {
			'BK_BEGIN' => 47
		}
	},
	{#State 47
		ACTIONS => {
			'NAME' => 2,
			'IF' => 7,
			'VAR' => 8
		},
		GOTOS => {
			'statement_list' => 48,
			'statement' => 5,
			'asignation' => 6,
			'procedure_call' => 3,
			'conditional' => 4
		}
	},
	{#State 48
		ACTIONS => {
			'NAME' => 2,
			'IF' => 7,
			'VAR' => 8,
			'BK_END' => 49
		},
		GOTOS => {
			'statement' => 10,
			'asignation' => 6,
			'procedure_call' => 3,
			'conditional' => 4
		}
	},
	{#State 49
		DEFAULT => -7
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'root', 1,
sub
#line 77 "Ihl.yp"
{dbg ("Semantic Tree build !!" ) ;  execute ($_[1] )  ; }
	],
	[#Rule 2
		 'statement_list', 2,
sub
#line 80 "Ihl.yp"
{ dbg("Ejecución de linea simple: $_[1]") ; 
				return ( $_[1]  ) ; 
					 }
	],
	[#Rule 3
		 'statement_list', 3,
sub
#line 83 "Ihl.yp"
{ dbg("ejecución de linea compuesta: $_[1]") ; 
        			return (['STATEMENT_LIST' , $_[1] , $_[2] ] ) ; 
				}
	],
	[#Rule 4
		 'statement', 1,
sub
#line 90 "Ihl.yp"
{ return ($_[1]  ) ; }
	],
	[#Rule 5
		 'statement', 1,
sub
#line 91 "Ihl.yp"
{ return ( $_[1] ) ; }
	],
	[#Rule 6
		 'statement', 1,
sub
#line 92 "Ihl.yp"
{ return ( $_[1] ) ; }
	],
	[#Rule 7
		 'conditional', 10,
sub
#line 96 "Ihl.yp"
{
			dbg ("Se llega a evaluar correctamente el arbol de una condicional!!!") ; 
			return ( ['FULL_CONDITION', $_[2] , $_[5] , $_[9] ] ) ; }
	],
	[#Rule 8
		 'conditional', 6,
sub
#line 99 "Ihl.yp"
{
			return (['SINGLE_CONDITION' , $_[2], $_[5] ] ) ; }
	],
	[#Rule 9
		 'asignation', 3,
sub
#line 103 "Ihl.yp"
{ dbg("Asignacion $_[1] = $_[3]") ; return (['ASSIGN', $_[1] , $_[3] ] ) ;  }
	],
	[#Rule 10
		 'expression', 1,
sub
#line 106 "Ihl.yp"
{ return  (['NUMBER', $_[1] ] ) ; }
	],
	[#Rule 11
		 'expression', 3,
sub
#line 107 "Ihl.yp"
{ return ( ['EXPRESSION' , $_[2] ] ) ; }
	],
	[#Rule 12
		 'expression', 1,
sub
#line 108 "Ihl.yp"
{   return (['VAR' , $_[1] ] ) ;  }
	],
	[#Rule 13
		 'expression', 1,
sub
#line 109 "Ihl.yp"
{ return (['STRING' , $_[1] ]) ; }
	],
	[#Rule 14
		 'expression', 1,
sub
#line 110 "Ihl.yp"
{ return (['FUNCTION_CALL', $_[1] ] ) ; }
	],
	[#Rule 15
		 'function', 4,
sub
#line 113 "Ihl.yp"
{	return (['FUNCTION', $_[1] , $_[3] ] )}
	],
	[#Rule 16
		 'value_list', 1,
sub
#line 116 "Ihl.yp"
{ dbg("expresión de value list simple/ultima valor:$_[1]") ; return (['VALUE_LIST_SIMPLE', $_[1] ]); }
	],
	[#Rule 17
		 'value_list', 3,
sub
#line 117 "Ihl.yp"
{ return (['VALUE_LIST_COMPUESTA', $_[1], $_[3]] ) ; }
	],
	[#Rule 18
		 'procedure_call', 1,
sub
#line 121 "Ihl.yp"
{  return (['PROCEDURE_SIMPLE', $_[1]] ) ; }
	],
	[#Rule 19
		 'procedure_call', 4,
sub
#line 122 "Ihl.yp"
{ return (['PROCEDURE_WITH_ARGS',$_[1], $_[3] ] ) ; }
	],
	[#Rule 20
		 'condition', 5,
sub
#line 126 "Ihl.yp"
{ return (['CONDITION_EQ', $_[2] , $_[4] ] ) ; }
	],
	[#Rule 21
		 'condition', 5,
sub
#line 127 "Ihl.yp"
{ return (['CONDITION_NE', $_[2] , $_[4] ] ) ; }
	]
],
                                  @_);
    bless($self,$class);
}

#line 130 "Ihl.yp"


## Analizador lexico

sub ihllex {

        $_[0]->YYData->{DATA} =~ s/^ +//;
	
#       print "dolar cero vale $_[0]->YYData->{DATA}\n" ;
        return ('',undef) unless (length $_[0]->YYData->{DATA}) ;

#	$_[0]->YYData->{DATA} =~ s/(^\s*take\s*)// and return ("TAKE",'TAKE' ) ;
#	$_[0]->YYData->{DATA} =~ s/^\s*untake\s*// and return ("UNTAKE",'UNTAKE') ;
#	$_[0]->YYData->{DATA} =~ s/^\s*reject\s*// and return ("REJECT",'REJECT') ;
#	$_[0]->YYData->{DATA} =~ s/^\s*end_actions\s*// and return ("END_ACTIONS",'END_ACTIONS') ;
#	$_[0]->YYData->{DATA} =~ s/^\s*next_action\s*// and return ("NEXT_ACTION",'NEXT_ACTION') ;
#	
	$_[0]->YYData->{DATA} =~ s/^\s*==\s*// and return ("EQUAL",'') ;
	$_[0]->YYData->{DATA} =~ s/^\s*\!=\s*// and return ("NOTEQ",'') ;

	$_[0]->YYData->{DATA} =~ s/^\s*=\s*// and return ("ASSIGN",'') ;
	$_[0]->YYData->{DATA} =~ s/^\s*\(\s*// and return ("OPENPAR",'') ;
	$_[0]->YYData->{DATA} =~ s/^\s*\)\s*// and return ("CLOSEPAR",'') ;
	$_[0]->YYData->{DATA} =~ s/^\s*,\s*//	and return ("COMMA",'') ;
	$_[0]->YYData->{DATA} =~ s/^\s*;\s*// and return ("PERIOD",'') ;

	$_[0]->YYData->{DATA} =~ s/^\s*if\s*// and return ("IF",'') ;
	$_[0]->YYData->{DATA} =~ s/^\s*then\s*// and return("THEN",'') ;
	$_[0]->YYData->{DATA} =~ s/^\s*else\s*// and return("ELSE",'') ;
	$_[0]->YYData->{DATA} =~ s/^\s*\{\s*//	and return("BK_BEGIN",'') ;
	$_[0]->YYData->{DATA} =~ s/^\s*\}\s*//	and return("BK_END",'') ;

	
#	$_[0]->YYData->{DATA} =~ s/^\s*\$(\w+)//  and dbg( "LEX : VAR $1" )  and return ("VAR", $1);
#	$_[0]->YYData->{DATA} =~ s/^\s*(\d+)\s*// and dbg("LEX:  NUMBER $1") and return('NUMBER',$1) ; 
#       $_[0]->YYData->{DATA} =~ s/^\s*(\w+)\s*//    and dbg("LEX NAME  $1") and return ("NAME",$1);
#	$_[0]->YYData->{DATA} =~ s/^\s*"(.*?)"\s*// and dbg( "LEX STRING $1") and return ("STRING", $1) ; 


	$_[0]->YYData->{DATA} =~ s/^\s*\$(\w+)//  and return ("VAR", $1);
	$_[0]->YYData->{DATA} =~ s/^\s*(\d+)\s*// and return('NUMBER',$1) ; 
        $_[0]->YYData->{DATA} =~ s/^\s*(\w+)\s*//  and return ("NAME",$1);
	$_[0]->YYData->{DATA} =~ s/^\s*"(.*?)"\s*//  and return ("STRING", $1) ; 


}


### Main Function execute 
## This is the Syntax tree "parser" and execution

sub execute {
	my $ra = $_[0] ;

	my $token = $$ra[0]  ;
#	print "Token es $token\n" ; 

	given ($token) {

	when ('STATEMENT_LIST') { execute ($$ra[1] ) ;  execute ($$ra[2]) ;  } 
	when ('STATEMENT') { execute ($$ra[1] ) ; }
	when ('ASSIGN')  { 
			my $var=$$ra[1] ;
			my $ret= evaluate ($$ra[2] ) ; 
			# Codigo de asignacion
#			print "Asignacion de $var valor $ret\n" ;
			$varspace{$var} = $ret ;
			}

	when ('PROCEDURE_WITH_ARGS') {
			my $proc=$$ra[1] ;
			my $cmd ;
#			print "Seria la ejecucion del procedure $proc\n" ;
			if (($cmd = Ihlc::lookup_proc($proc)) !=0 ) {
#                        dbg("a ejecutar comando $proc con argumentos") ;
			my @args = make_params ($$ra[2] ) ;
		#	print "Dump de parametros !!\n" ;
		#	for (my $i=0 ; $i!= @args ; $i ++) { print "array $i valor $args[$i]\n" ; }	
                         $cmd->(\%varspace, @args) ; }
                else { dbg("procedure $cmd no existe") ; }
			 }
	when ('FULL_CONDITION') {
#			print "Ejecucion de la condicion \n" ;
			if (evaluate_cond ($$ra[1] )) {  execute ($$ra[2]) ; } 
			else { execute ($$ra[3])  ; }
			}
	when ('SINGLE_CONDITION') {
			if (evaluate_cond ($$ra[1] )) { execute ($$ra[2] ) ; } }
	when ('PROCEDURE_SIMPLE') {
			my $proc= $$ra[1] ; 
#			print "Ejecucion del procedure $proc simple \n" ; 
			my $cmd ;
			if (($cmd = Ihlc::lookup_proc($proc)) !=0 ) {
                        dbg("a ejecutar comando $proc con argumentos") ;
                         $cmd->(\%varspace) ; }
			   else { dbg("procedure $cmd no existe") ; }
			}
	}
}

sub make_params {
	my $ra =$_[0] ;
	given ($$ra[0] ) {
	when ('VALUE_LIST_SIMPLE') {   return evaluate ($$ra[1] ) ; } 
	when ('VALUE_LIST_COMPUESTA') {
			return ( evaluate ($$ra[1]), make_params ($$ra[2])  ) ; 
					}
	}
}

sub evaluate_function {
	my $name= $_[0] ;
	my $ra= $_[1] ; 

	my $proc ; my $ret =0 ;
        if (($proc = Ihlc::lookup_func($name)) !=0 ) {
                                dbg("Existe la función $name  valor $proc argumentos " . @stackexp) ;
                                dbg ("current ticket is $varspace{'current'} ") ;
                                 $ret= $proc->(\%varspace, @stackexp) ; @stackexp=() ; }
                        else { dbg ("No existe la función $_[1]") ; }
	}

sub evaluate {
	my $ra= $_[0] ; 
	given ($$ra[0] ){
	when ('NUMBER') { return $$ra[1] ; } 
	when ('VAR') 	{ return ( $varspace{$$ra[1]}) ; }
	when ('STRING')	{ return ( $$ra[1] ) ; } 
	when ('FUNCION_CALL') { return (evaluate_function ($$ra[1] , $$ra[2]) );  } 
	}
}

sub evaluate_cond {
	my $ra= $_[0] ;
	my ($left , $right) ;
	given ($$ra[0] ) {
	when ('CONDITION_EQ' ) {
		$left= evaluate ($$ra[1] ) ; 
		$right= evaluate ($$ra[2] ) ;
		if ($left == $right ) {  return 1 ; } else { return (0) ; }
		}
	when ('CONDITION_NE' ) {
		$left= evaluate ($$ra[1] ) ;
		$right=evaluate ($$ra[2] ) ;
		if ($left != $right) { return 1 ; } else { return (0) ; }
			}
	}
		
		
}




1;
