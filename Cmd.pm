####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package Cmd;
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


#line 2 "Cmd.yp"
 my %symtab; #line 29 "Cmd.yp"


use Actions ;
use Help ;

my $argument;
my $start ; 
my $end ;
my $stype ;



sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			'URL' => 15,
			'REJECT' => 2,
			'SET' => 1,
			'SEARCH' => 3,
			'RULES' => 17,
			'QUIT' => 19,
			'UNTAKE' => 8,
			'TAKE' => 9,
			'INFO' => 20,
			'HELP' => 10,
			'PROCESS' => 11,
			'LIST' => 24
		},
		GOTOS => {
			'set_command' => 16,
			'comand' => 5,
			'quit_command' => 4,
			'help_command' => 7,
			'url_command' => 6,
			'rules_command' => 18,
			'list_command' => 21,
			'untake_command' => 12,
			'reject_command' => 22,
			'process_command' => 23,
			'search_command' => 13,
			'info_command' => 25,
			'take_command' => 14
		}
	},
	{#State 1
		ACTIONS => {
			'WHITE' => 26
		}
	},
	{#State 2
		ACTIONS => {
			'ALL' => 30,
			'CODIGO' => 27
		},
		GOTOS => {
			'rango' => 28,
			'lista' => 29
		}
	},
	{#State 3
		ACTIONS => {
			'STYPE' => 31
		}
	},
	{#State 4
		DEFAULT => -2
	},
	{#State 5
		ACTIONS => {
			'' => 32
		}
	},
	{#State 6
		DEFAULT => -10
	},
	{#State 7
		DEFAULT => -9
	},
	{#State 8
		ACTIONS => {
			'ALL' => 35,
			'CODIGO' => 27
		},
		GOTOS => {
			'rango' => 33,
			'lista' => 34
		}
	},
	{#State 9
		ACTIONS => {
			'ALL' => 38,
			'CODIGO' => 27
		},
		GOTOS => {
			'rango' => 36,
			'lista' => 37
		}
	},
	{#State 10
		ACTIONS => {
			'URL' => 44,
			'REJECT' => 39,
			'UNTAKE' => 40,
			'TAKE' => 41,
			'IHL' => 45,
			'INFO' => 46,
			'PROCESS' => 42,
			'LIST' => 47
		},
		DEFAULT => -27,
		GOTOS => {
			'token' => 43
		}
	},
	{#State 11
		ACTIONS => {
			'ALL' => 51,
			'range' => 49,
			'CODIGO' => 48
		},
		GOTOS => {
			'lista' => 50
		}
	},
	{#State 12
		DEFAULT => -7
	},
	{#State 13
		DEFAULT => -11
	},
	{#State 14
		DEFAULT => -1
	},
	{#State 15
		ACTIONS => {
			'ALL' => 54,
			'CODIGO' => 27
		},
		GOTOS => {
			'rango' => 52,
			'lista' => 53
		}
	},
	{#State 16
		DEFAULT => -6
	},
	{#State 17
		ACTIONS => {
			'SHOW' => 55,
			'LOAD' => 57,
			'LIST' => 56
		}
	},
	{#State 18
		DEFAULT => -12
	},
	{#State 19
		DEFAULT => -26
	},
	{#State 20
		ACTIONS => {
			'CODIGO' => 58
		}
	},
	{#State 21
		DEFAULT => -5
	},
	{#State 22
		DEFAULT => -8
	},
	{#State 23
		DEFAULT => -3
	},
	{#State 24
		DEFAULT => -34
	},
	{#State 25
		DEFAULT => -4
	},
	{#State 26
		ACTIONS => {
			'VAR' => 59
		}
	},
	{#State 27
		ACTIONS => {
			'MINUS' => 60,
			'CODIGO' => 48
		},
		DEFAULT => -40,
		GOTOS => {
			'lista' => 61
		}
	},
	{#State 28
		DEFAULT => -20
	},
	{#State 29
		DEFAULT => -19
	},
	{#State 30
		DEFAULT => -21
	},
	{#State 31
		ACTIONS => {
			'VALUE' => 62
		}
	},
	{#State 32
		DEFAULT => 0
	},
	{#State 33
		DEFAULT => -17
	},
	{#State 34
		DEFAULT => -16
	},
	{#State 35
		DEFAULT => -18
	},
	{#State 36
		DEFAULT => -14
	},
	{#State 37
		DEFAULT => -13
	},
	{#State 38
		DEFAULT => -15
	},
	{#State 39
		DEFAULT => -47
	},
	{#State 40
		DEFAULT => -43
	},
	{#State 41
		DEFAULT => -42
	},
	{#State 42
		DEFAULT => -45
	},
	{#State 43
		DEFAULT => -28
	},
	{#State 44
		DEFAULT => -48
	},
	{#State 45
		DEFAULT => -49
	},
	{#State 46
		DEFAULT => -46
	},
	{#State 47
		DEFAULT => -44
	},
	{#State 48
		ACTIONS => {
			'CODIGO' => 48
		},
		DEFAULT => -40,
		GOTOS => {
			'lista' => 61
		}
	},
	{#State 49
		DEFAULT => -30
	},
	{#State 50
		DEFAULT => -29
	},
	{#State 51
		DEFAULT => -31
	},
	{#State 52
		DEFAULT => -23
	},
	{#State 53
		DEFAULT => -22
	},
	{#State 54
		DEFAULT => -24
	},
	{#State 55
		ACTIONS => {
			'CODIGO' => 63
		}
	},
	{#State 56
		DEFAULT => -36
	},
	{#State 57
		DEFAULT => -35
	},
	{#State 58
		ACTIONS => {
			'DETAIL' => 64
		},
		DEFAULT => -32
	},
	{#State 59
		ACTIONS => {
			'WHITE' => 65
		}
	},
	{#State 60
		ACTIONS => {
			'CODIGO' => 66
		}
	},
	{#State 61
		DEFAULT => -41
	},
	{#State 62
		DEFAULT => -25
	},
	{#State 63
		DEFAULT => -37
	},
	{#State 64
		DEFAULT => -33
	},
	{#State 65
		ACTIONS => {
			'ASSIGN' => 67
		}
	},
	{#State 66
		DEFAULT => -39
	},
	{#State 67
		ACTIONS => {
			'WHITE' => 68
		}
	},
	{#State 68
		ACTIONS => {
			'VALUE' => 69
		}
	},
	{#State 69
		DEFAULT => -38
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'comand', 1, undef
	],
	[#Rule 2
		 'comand', 1, undef
	],
	[#Rule 3
		 'comand', 1, undef
	],
	[#Rule 4
		 'comand', 1, undef
	],
	[#Rule 5
		 'comand', 1, undef
	],
	[#Rule 6
		 'comand', 1, undef
	],
	[#Rule 7
		 'comand', 1, undef
	],
	[#Rule 8
		 'comand', 1, undef
	],
	[#Rule 9
		 'comand', 1, undef
	],
	[#Rule 10
		 'comand', 1, undef
	],
	[#Rule 11
		 'comand', 1, undef
	],
	[#Rule 12
		 'comand', 1, undef
	],
	[#Rule 13
		 'take_command', 2,
sub
#line 58 "Cmd.yp"
{  Actions::take ('list',$argument) ;  $argument="" ; }
	],
	[#Rule 14
		 'take_command', 2,
sub
#line 59 "Cmd.yp"
{ Actions::take ('range',$start,$end) ; }
	],
	[#Rule 15
		 'take_command', 2,
sub
#line 60 "Cmd.yp"
{ Actions::take ('all'); }
	],
	[#Rule 16
		 'untake_command', 2,
sub
#line 63 "Cmd.yp"
{ Actions::untake ('list',$argument) ; $argument="" ; }
	],
	[#Rule 17
		 'untake_command', 2,
sub
#line 64 "Cmd.yp"
{ Actions::untake ('range',$start,$end) ; }
	],
	[#Rule 18
		 'untake_command', 2,
sub
#line 65 "Cmd.yp"
{ Actions::untake ('all') ; }
	],
	[#Rule 19
		 'reject_command', 2,
sub
#line 67 "Cmd.yp"
{ Actions::reject ('list',$argument) ; $argument="" ; }
	],
	[#Rule 20
		 'reject_command', 2,
sub
#line 68 "Cmd.yp"
{ Actions::reject ('range',$start,$end) ; }
	],
	[#Rule 21
		 'reject_command', 2,
sub
#line 69 "Cmd.yp"
{ Actions::reject ('all') ; }
	],
	[#Rule 22
		 'url_command', 2,
sub
#line 72 "Cmd.yp"
{ Actions::url ('list',$argument) ; $argument="" ; }
	],
	[#Rule 23
		 'url_command', 2,
sub
#line 73 "Cmd.yp"
{ Actions::url ('range',$start,$end) ; }
	],
	[#Rule 24
		 'url_command', 2,
sub
#line 74 "Cmd.yp"
{ Actions::url ('all') ; }
	],
	[#Rule 25
		 'search_command', 3,
sub
#line 76 "Cmd.yp"
{ Actions::search($stype, $_[3]) ; $stype="" ; }
	],
	[#Rule 26
		 'quit_command', 1,
sub
#line 79 "Cmd.yp"
{  $::fin=1 ; }
	],
	[#Rule 27
		 'help_command', 1,
sub
#line 81 "Cmd.yp"
{ Help::help(''); }
	],
	[#Rule 28
		 'help_command', 2,
sub
#line 82 "Cmd.yp"
{ Help::help($_[2]) ; }
	],
	[#Rule 29
		 'process_command', 2,
sub
#line 84 "Cmd.yp"
{ Actions::process ('list',$argument) ; $argument ="" ; }
	],
	[#Rule 30
		 'process_command', 2,
sub
#line 85 "Cmd.yp"
{ Actions::process ('range',$start,$end) ; }
	],
	[#Rule 31
		 'process_command', 2,
sub
#line 86 "Cmd.yp"
{ Actions::process ('all') ; }
	],
	[#Rule 32
		 'info_command', 2,
sub
#line 89 "Cmd.yp"
{  Actions::info($_[2] , '') ; }
	],
	[#Rule 33
		 'info_command', 3,
sub
#line 90 "Cmd.yp"
{  Actions::info($_[2], 'detail') ;}
	],
	[#Rule 34
		 'list_command', 1,
sub
#line 93 "Cmd.yp"
{ Actions::list ; }
	],
	[#Rule 35
		 'rules_command', 2,
sub
#line 97 "Cmd.yp"
{ Actions::load_rules ; }
	],
	[#Rule 36
		 'rules_command', 2,
sub
#line 98 "Cmd.yp"
{ Actions::print_rules ; }
	],
	[#Rule 37
		 'rules_command', 3,
sub
#line 99 "Cmd.yp"
{ print "codigo vale $_[3]\n" ; Actions::show_rule $_[3] ; }
	],
	[#Rule 38
		 'set_command', 7,
sub
#line 102 "Cmd.yp"
{ print "set \n" ;}
	],
	[#Rule 39
		 'rango', 3,
sub
#line 106 "Cmd.yp"
{ $start=$_[1] ; $end=$_[3] ;}
	],
	[#Rule 40
		 'lista', 1,
sub
#line 109 "Cmd.yp"
{  $argument .=" $_[1] " ; }
	],
	[#Rule 41
		 'lista', 2,
sub
#line 110 "Cmd.yp"
{  $argument .=" $_[1] " ;}
	],
	[#Rule 42
		 'token', 1, undef
	],
	[#Rule 43
		 'token', 1, undef
	],
	[#Rule 44
		 'token', 1, undef
	],
	[#Rule 45
		 'token', 1, undef
	],
	[#Rule 46
		 'token', 1, undef
	],
	[#Rule 47
		 'token', 1, undef
	],
	[#Rule 48
		 'token', 1, undef
	],
	[#Rule 49
		 'token', 1, undef
	]
],
                                  @_);
    bless($self,$class);
}

#line 115 "Cmd.yp"


sub cmdlex {

#        $_[0]->YYData->{DATA} =~ s/^ +//;
#	print "dolar cero vale $_[0]->YYData->{DATA}\n" ;	
        return ('',undef) unless (length $_[0]->YYData->{DATA}) ;


	$_[0]->YYData->{DATA} =~ s/(^\s*take\s*)// and return ("TAKE",'TAKE' ) ;
	$_[0]->YYData->{DATA} =~ s/^\s*untake\s*// and return ("UNTAKE",'UNTAKE') ;
	$_[0]->YYData->{DATA} =~ s/^\s*reject\s*// and return ("REJECT",'REJECT') ;
	$_[0]->YYData->{DATA} =~ s/^\s*url\s*//    and return ("URL","URL") ;

	$_[0]->YYData->{DATA} =~ s/(^\s*all\s*)//  and return ("ALL",'') ;
	$_[0]->YYData->{DATA} =~ s/^(\s*-\s*)//    and return ("MINUS",'') ;
	$_[0]->YYData->{DATA} =~ s/^(\s*process\s*)// and  return ("PROCESS",'') ;
	$_[0]->YYData->{DATA} =~ s/^quit\s*// and  return ("QUIT", '') ; 
	$_[0]->YYData->{DATA} =~ s/^list\s*//  and return ("LIST",'LIST') ;
	$_[0]->YYData->{DATA} =~ s/^(\s*info\s*)// and return ("INFO",'INFO') ;
	$_[0]->YYData->{DATA} =~ s/^(\s*detail\s*)//  and return ("DETAIL",'') ;
	$_[0]->YYData->{DATA} =~ s/^(\s*rules\s*)// and return ('RULES','') ;
	$_[0]->YYData->{DATA} =~ s/^(\s*load\s*)//  and return ('LOAD','') ;
	$_[0]->YYData->{DATA} =~ s/^(\s*show\s*)//  and return ('SHOW','') ;
	$_[0]->YYData->{DATA} =~ s/^(\s*ihl\s*)//  and return ('IHL','') ;


	$_[0]->YYData->{DATA} =~ s/set// and return ("SET", $1) ;
	$_[0]->YYData->{DATA} =~ s/ASSIGN// and return ("ASSIGN", $1);
	# Mierda de parser
	$_[0]->YYData->{DATA} =~ s/^\s*(\d+)\s*// and return ("CODIGO", $1);
#	$_[0]->YYData->{DATA} =~ s/\n// and return ($1,$1) ;	
	$_[0]->YYData->{DATA} =~ s/^\s*help\s*// and return ("HELP",'') ;

        $_[0]->YYData->{DATA} =~ s/^\$(\w+)//  and print "found var $1\n"   and return ("VAR", $1);
	$_[0]->YYData->{DATA} =~ s/^(\w+)//    and print "Found VALUE $1\n" and return ("VALUE",$1);
	$_[0]->YYData->{DATA} =~ s/^\s++// and  return ("WHITE", '') ;

        die "Unknown token (".$_[0]->YYData->{DATA}.")\n";
    }


1;
