# $Id: cli.rb,v 1.43 2010/06/07 08:51:25 chabannf Exp $

# 
# CONTACT     : zonecheck@nic.fr
# AUTHOR      : Stephane D'Alu <sdalu@nic.fr>
#
# CREATED     : 2002/08/02 13:58:17
# REVISION    : $Revision: 1.43 $ 
# DATE        : $Date: 2010/06/07 08:51:25 $
#
# CONTRIBUTORS: (see also CREDITS file)
#
#
# LICENSE     : GPL v3
# COPYRIGHT   : AFNIC (c) 2003
#
# This file is part of ZoneCheck.
#
# ZoneCheck is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# ZoneCheck is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ZoneCheck; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

require 'getoptlong'
require 'param'

##
## Processing parameters from CLI (Command Line Interface)
##
## WARN: don't forget to update locale/cli.*
##
## ----------------------------------------------------------------------
##
## usage: PROGNAME: [-hqV] [-voet opt] [-46] [-n ns...] [-c conf] domainname
##         --lang          Select another language (en, fr, ...)
##     -d, --debug         Select debugging messages to print
##     -h, --help          Show this message
##     -V, --version       Display version and exit
##     -B, --batch         Depreciated option
##     -c, --config        Specify location of the configuration file
##         --testdir       Location of the directory holding tests
##     -P, --profile       Force uses of a particular profile
##     -C, --category      Only perform test for the specified category
##     -T, --test          Name of the test to perform
##         --testlist      List all the available tests
##         --testdesc      Give a description of the test
##                            (values: name, failure, success, explanation)
##     -r, --resolver      Resolver to use for guessing 'ns' information
##     -n, --ns            List of nameservers for the domain
##                            (ex: ns1;ns2=ip1,ip2;ns3=ip3)
##     -q, --quiet         Don't display extra titles
##     -1, --one           Only display the most relevant message
##     -g, --tagonly       Display only tag (suitable for scripting)
##     -v, --verbose       Display extra information (see verbose)
##     -o, --output        Output (see output)
##     -e, --error         Behaviour in case of error (see error)
##     -t, --transp        Transport/routing layer (see transp)
##     -4, --ipv4          Only check the zone with IPv4 connectivity
##     -6, --ipv6          Only check the zone with IPv6 connectivity
##         --preset        Use a preset configuration
##         --option        Set extra options (-,-opt,opt,opt=foo)
## 
##   verbose:              [intro/testname/explain/details]
##                         [reportok|fatalonly] [testdesc|counter]
##                         can be prefix by '-' or '!' to remove the effect
##     intro          [i]  Print summary for domain and associated nameservers
##     testname       [n]  Print the test name
##     explain        [x]  Print an explanation for failed tests
##     details        [d]  Print a detailed description of the failure
##     reportok       [o]  Still report passed test
##     fatalonly      [f]  Print fatal errors only
##     testdesc       [t]  Print the test description before running it
##     counter        [c]  Print a test counter
## 
##   output:               [byseverity|byhost] [text|html]
##     byseverity    *[bs] Output is sorted/merged by severity
##     byhost         [bh] Output is sorted/merged by host
##     text          *[t]  Output plain text
##     html           [h]  Output HTML
## 
##   error:                [allfatal|allwarning|dfltseverity] [stop|nostop]
##     allfatal       [af] All error are considered fatal
##     allwarning     [aw] All error are considered warning
##     dfltseverity  *[ds] Use the severity associated with the test
##     stop          *[s]  Stop on the first fatal error
##     nostop         [ns] Never stop (even on fatal error)
## 
##   transp:               [ipv4/ipv6] [udp|tcp|std]
##     ipv4          *[4]  Use IPv4 routing protocol
##     ipv6          *[6]  Use IPv6 routing protocol
##     udp            [u]  Use UDP transport layer
##     tcp            [t]  Use TCP transport layer
##     std           *[s]  Use UDP with fallback to TCP for truncated messages
##
module Input
    class CLI
	with_msgcat "cli.%s"

	def allow_preset ; true ; end

	def initialize
	    init
	end

	def restart
	    init
	end

	def parse(p)
	    begin
		opts_analyse(p)
		args_analyse(p) unless p.test.list || p.test.desctype
	    rescue GetoptLong::Error
		return false
	    end
	    true
	end

	def interact(p, c, tm, io=$console.stdout)
	    true
	end

	def usage(errcode, io=$console.stderr)
	    io.print $mc.get('input:cli:usage').gsub('PROGNAME', PROGNAME)
	    exit errcode unless errcode.nil?
	end

	def error(str, errcode=nil, io=$console.stderr)
	    l10n_error = $mc.get('word:error').upcase
	    io.puts "#{l10n_error}: #{str}"
	    exit errcode unless errcode.nil?
	end


	#-- PRIVATE -------------------------------------------------
	private
	def init
	    @opts = GetoptLong.new(* opts_definition)
	    @opts.quiet = true
	end

	def opts_definition
	    [   [ '--help',	'-h',	GetoptLong::NO_ARGUMENT       ],
		[ '--version',	'-V',	GetoptLong::NO_ARGUMENT       ],
		[ '--quiet',	'-q',	GetoptLong::NO_ARGUMENT       ],
		[ '--lang',		GetoptLong::REQUIRED_ARGUMENT ],
		[ '--debug',	'-d',   GetoptLong::REQUIRED_ARGUMENT ],
		[ '--batch',	'-B',   GetoptLong::OPTIONAL_ARGUMENT ],
		[ '--config',	'-c',   GetoptLong::REQUIRED_ARGUMENT ],
		[ '--testdir',	        GetoptLong::REQUIRED_ARGUMENT ],
		[ '--category', '-C',   GetoptLong::REQUIRED_ARGUMENT ],
		[ '--profile',  '-P',   GetoptLong::REQUIRED_ARGUMENT ],
		[ '--test',     '-T',   GetoptLong::REQUIRED_ARGUMENT ],
		[ '--testlist',         GetoptLong::NO_ARGUMENT       ],
		[ '--testdesc',         GetoptLong::REQUIRED_ARGUMENT ],
		[ '--resolver',	'-r',   GetoptLong::REQUIRED_ARGUMENT ],
		[ '--ns',	'-n',   GetoptLong::REQUIRED_ARGUMENT ],
		[ '--ipv4',	'-4',	GetoptLong::NO_ARGUMENT       ],
		[ '--ipv6',	'-6',	GetoptLong::NO_ARGUMENT       ],
		[ '--one',	'-1',	GetoptLong::NO_ARGUMENT       ],
		[ '--tagonly',	'-g',   GetoptLong::NO_ARGUMENT       ],
		[ '--verbose',	'-v',   GetoptLong::OPTIONAL_ARGUMENT ],
		[ '--output',	'-o',   GetoptLong::REQUIRED_ARGUMENT ],
		[ '--error',	'-e',	GetoptLong::REQUIRED_ARGUMENT ],
		[ '--transp',	'-t',	GetoptLong::REQUIRED_ARGUMENT ],
		[ '--preset',           GetoptLong::REQUIRED_ARGUMENT ],
		[ '--option',           GetoptLong::REQUIRED_ARGUMENT ],
    [ '--edns',           GetoptLong::REQUIRED_ARGUMENT  ],
    [ '--securedelegation',   '-s', GetoptLong::OPTIONAL_ARGUMENT  ],
		#
		# Let's have some fun
		[ '--makecoffee',       GetoptLong::NO_ARGUMENT       ],
		[ '--coffee',           GetoptLong::NO_ARGUMENT       ] ]
        end

	def opts_analyse(p)
	    @opts.each do |opt, arg|
		case opt
		when '--help'      then usage(EXIT_USAGE, $console.stdout)
		when '--version'
		    l10n_version = $mc.get('input:version') % $zc_version
		    l10n_version.gsub!(/PROGNAME/, PROGNAME)
		    $console.stdout.puts l10n_version
		    exit EXIT_OK
		when '--quiet'     then p.rflag.quiet		= true
		when '--debug'     then $dbg.level		= arg
		when '--lang'      then $locale.lang		= arg
		when '--config'    then p.preconf.cfgfile = arg.dup.untaint
		when '--testdir'   then p.preconf.testdir = arg.dup.untaint
		when '--profile'   then p.preconf.profile	= arg
		when '--category'  then p.test.categories	= arg
		when '--test'      then p.test.tests		= arg
		when '--testlist'  then p.test.list		= true
		when '--testdesc'  then p.test.desctype		= arg
		when '--resolver'  then p.resolver.local	= arg
		when '--ns'        then p.domain.ns		= arg
		when '--ipv6'      then p.network.ipv6		= true
		when '--ipv4'      then p.network.ipv4		= true
		when '--one'       then p.rflag.one		= true
		when '--tagonly'   then p.rflag.tagonly		= true
		when '--error'     then p.error			= arg
		when '--transp'    then p.transp		= arg
		when '--verbose'   then p.verbose		= arg
		when '--output'    then p.output		= arg
		when '--preset'    then p.preconf.preset	= arg
		when '--option'    then p.option	       << arg
    when '--edns'      then p.edns = arg
		when '--securedelegation'        then p.securedelegation = arg
    when '--batch'
      $console.stdout.puts $mc.get('input:cli:deprecated_option') % "batch"
      exit EXIT_OK
		#
		# Let's have some fun
		when '--makecoffee'
		    $console.stdout.print <<EOT
#{PROGNAME}: I'm not currently designed for that task.
\tBut if you really want this option added in future release, 
\tyou should see with the maintainer: \"#{ZC_MAINTAINER}\".
EOT
		    exit EXIT_OK
		when '--coffee'
		    $console.stdout.puts "#{PROGNAME}: No thank you, I prefer tea."
		    exit EXIT_OK
		end
	    end
	end
	
	def args_analyse(p)
		if !(ARGV.length == 1)
		    raise Param::ParamError, 
			$mc.get('xcp_param_domain_expected') 
		end
	    setdomain(p, ARGV[0])
	end

	def setdomain(p, arg)
	    p.domain.name = arg
	end
    end
end
