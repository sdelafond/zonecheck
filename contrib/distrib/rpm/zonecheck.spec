Summary: Perform consistency checks on DNS zones
Name: zonecheck
Version: 3.0.5
Release: 1
License: GPL
Group: Applications/Internet
URL: http://www.zonecheck.fr/

Packager: The ZoneCheck Team <zonecheck@nic.fr>
Vendor: The ZoneCheck Team

Source: http://savannah.nongnu.org/download/zonecheck/%{name}-%{version}.tgz
BuildRoot: %{_tmppath}/root-%{name}-%{version}
BuildArch: noarch

BuildRequires: ruby >= 1.8, ruby-libs
Requires: ruby >= 1.8, ruby-libs, rubygems-dnsruby >= 1.47

%description
ZoneCheck is intended to help solve DNS misconfigurations or
inconsistencies that are usually revealed by an increase in
the latency of the application. The DNS is a critical resource
for every network application, so it is quite important to
ensure that a zone or domain name is correctly configured in
the DNS.

%package cgi
Summary: Web service interface for ZoneCheck
Group: Applications/Internet
Requires: %{name} = %{version}

%description cgi
Provide a web service interface for ZoneCheck.
(ZoneCheck is intended to help solve DNS misconfigurations)

%prep
%setup -n %{name}

%build
%{__rm} -rf %{buildroot}

%install
ruby ./installer.rb common cli cgi \
    -DPREFIX="%{_prefix}"          \
    -DETCDIR="%{_sysconfdir}"      \
    -DLIBEXEC="%{_libexecdir}"     \
    -DMANDIR="%{_mandir}"          \
    -DETCDIST=""                   \
    -DCHROOT="%{buildroot}"        \
    -DRUBY=/usr/bin/ruby

case `uname` in
    OSF1)
ruby -p -i \
    -e "\$_.gsub"\!"(/(<const\s+name\s*=\s*\"ping4\"\s+value\s*=\s*\")[^\"]*(\"\s*\/>)/, '\1/sbin/ping -n -q -t 5 -c 5 %s > /dev/null\2')" \
    -e "\$_.gsub"\!"(/(<const\s+name\s*=\s*\"ping6\"\s+value\s*=\s*\")[^\"]*(\"\s*\/>)/, '\1/sbin/ping -n -q -t 5 -c 5 %s > /dev/null\2')" \
    %{buildroot}%{_sysconfdir}/zonecheck/zc.conf
    ;;

    *)
ruby -p -i \
    -e "\$_.gsub"\!"(/(<const\s+name\s*=\s*\"ping4\"\s+value\s*=\s*\")[^\"]*(\"\s*\/>)/, '\1/bin/ping -n -q -w 5 -c 5 %s > /dev/null\2')" \
    -e "\$_.gsub"\!"(/(<const\s+name\s*=\s*\"ping6\"\s+value\s*=\s*\")[^\"]*(\"\s*\/>)/, '\1/usr/sbin/ping6 -n -q -w 5 -c 5 %s > /dev/null\2')" \
    %{buildroot}%{_sysconfdir}/zonecheck/zc.conf
    ;;
esac

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
%doc BUGS ChangeLog COPYING CREDITS GPL HISTORY README TODO
%doc doc/html
%dir %{_sysconfdir}/zonecheck
%config %{_sysconfdir}/zonecheck/rootservers
%config %{_sysconfdir}/zonecheck/*.profile
%verify(not size,not md5) %config(noreplace) %{_sysconfdir}/zonecheck/zc.conf
%{_bindir}/*
%dir %{_libexecdir}/zonecheck
%{_libexecdir}/zonecheck/zc
%{_libexecdir}/zonecheck/lib
%{_libexecdir}/zonecheck/locale
%{_libexecdir}/zonecheck/test
%{_mandir}/man1/*

%files cgi
%defattr(-, root, root, 0755)
%{_libexecdir}/zonecheck/www
%{_libexecdir}/zonecheck/cgi-bin

%changelog
* Wed Oct 29 2008 Eric Redon <redon@nic.fr> - 2.0.8
- Updated AFNIC Configuration profile.

* Mon Nov 13 2003 Stephane D'Alu <sdalu@nic.fr> - 2.0.0b10
- Updated for new zone configuration profile.

* Fri Oct 24 2003 Jean-Philippe Pick <zonecheck@nic.fr> - 2.0.0b9
- Reworked packaging to meet new installation process.

* Tue Sep 02 2003 Dag Wieers <dag@wieers.com> - 2.0.0-0.b7
- Initial package. (using DAR)

