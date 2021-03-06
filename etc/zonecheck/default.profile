<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE config PUBLIC "-//ZoneCheck//DTD Config V1.0//EN" "config.dtd">
<config>
<!-- $Id: default.profile,v 1.7 2010/06/29 13:12:22 chabannf Exp $ -->

  <profile name="default"
           longdesc="default profile for checking delegations">
    <const name="registry" value="default"/>

    <rules class="generic">
      <!-- Domain name check -->
      <check name="dn_sntx"     severity="f" category="dns:sntx"/>
      <check name="dn_orp_hyph" severity="f" category="dns:sntx"/>
      <check name="dn_dbl_hyph" severity="w" category="dns:sntx"/>
      <check name="one_ns"      severity="f" category="dns">
        <check name="several_ns"  severity="f" category="dns"/>
      </check>

      <!-- IP address check -->
      <check name="ip_distinct"     severity="f" category="ip"/>
      <check name="ip_all_same_net" severity="w" category="ip"/>
      <check name="all_same_asn"    severity="w" category="ip"/>

      <!-- Interop -->
      <check name="delegation_udp512" severity="f" category="dns:interop"/>
      <check name="delegation_udp512_additional" severity="w" category="dns:interop"/>
    </rules>

    <rules class="nameserver">
      <!-- IP address check -->
      <check name="ip_private" severity="w" category="ip"/>
      <check name="ip_bogon"   severity="w" category="ip"/>
    </rules>


    <rules class="address">
      <!-- Connectivity -->
      <check name="icmp" severity="w" category="connectivity:l3"/>
      <check name="udp"  severity="f" category="connectivity:l4"/>
      <check name="tcp"  severity="f" category="connectivity:l4"/>

      <!-- Interoperability -->
      <check name="aaaa"                severity="f" category="dns:interop"/>

      <!-- SOA -->
      <check name="soa"                 severity="f" category="dns">
        <check name="soa_auth"            severity="f" category="dns"/>
        <check name="given_nsprim_vs_soa" severity="f" category="dns"/>
        <check name="soa_master_fq"       severity="w" category="dns:soa"/>
        <check name="soa_master_sntx"     severity="f" category="dns:soa"/>
        <check name="soa_contact_sntx_at" severity="f" category="dns:soa"/>
        <check name="soa_contact_sntx"    severity="f" category="dns:soa"/>
        <check name="soa_serial_fmt_YYYYMMDDnn" severity="w" category="dns:soa"/>
        <check name="soa_expire"          severity="f" category="dns:soa"/>
        <check name="soa_minimum"         severity="w" category="dns:soa"/>
        <check name="soa_refresh"         severity="w" category="dns:soa"/>
        <check name="soa_retry"           severity="w" category="dns:soa"/>
        <check name="soa_retry_refresh"   severity="f" category="dns:soa"/>
        <check name="soa_expire_7refresh" severity="f" category="dns:soa"/>
        <check name="soa_ns_cname"        severity="w" category="dns:soa"/>
        <check name="soa_vs_any"          severity="f"      category="dns:soa"/>
        <check name="soa_drift_serial"    severity="w" category="dns:soa"/>
        <check name="soa_coherence_serial" severity="f" category="dns:soa"/>
        <check name="soa_coherence_contact" severity="f" category="dns:soa"/>
        <check name="soa_coherence_master" severity="w" category="dns:soa"/>
        <check name="soa_coherence"       severity="w" category="dns:soa"/>
      </check>

      <!-- NS -->
      <check name="ns"             severity="f" category="dns:ns">
	    <check name="ns_auth"        severity="f" category="dns:ns"/>
	    <check name="given_ns_vs_ns" severity="f" category="dns"/>
	    <check name="ns_sntx"        severity="f" category="dns:ns"/>
	    <check name="ns_cname"       severity="f" category="dns:ns"/>
	    <check name="ns_vs_any"      severity="f" category="dns:ns"/>
	    <check name="ns_ip"          severity="f" category="dns:ns"/>
	    <check name="ns_reverse"     severity="w" category="dns:ns"/>
	    <check name="ns_matching_reverse" severity="w" category="dns:ns"/>
      </check>

      <case test="mail_by_mx_or_a">
        <when value="MX">
          <check name="mx"             severity="f" category="dns:mx">
            <check name="mx_auth"        severity="f" category="dns:mx"/>
            <check name="mx_sntx"        severity="f" category="dns:mx"/>
            <check name="mx_cname"                  severity="f" category="dns:mx"/>
            <check name="mx_no_wildcard"            severity="i" category="dns:mx"/>
            <check name="mx_ip"                     severity="f" category="dns:mx"/>
            <check name="mx_vs_any"                 severity="f" category="dns:mx"/>
          </check>
        </when>
      </case>

      <check name="correct_recursive_flag"    severity="f" category="dns"/>

      <case test="recursive_server">
        <when value="true">
          <!-- Loopback -->
          <check name="loopback_delegation"       severity="w" category="dns:loopback"/>
          <check name="loopback_host"             severity="f" category="dns:loopback"/>

          <!-- Root servers -->
          <check name="root_servers"              severity="f" category="dns:root">
            <check name="root_servers_ns_vs_icann"  severity="f" category="dns:root"/>
            <check name="root_servers_ip_vs_icann"  severity="w" category="dns:root"/>
          </check>
        </when>
      </case>
    </rules>
    
   
    <rules class="extra">
    <!-- Mail -->
      <check name="mail_mx_or_addr" severity="w" category="mail"/>
      <case test="mail_delivery">
        <when value="nodelivery"/>
        <else>
          <check name="mail_openrelay_domain"     severity="w" category="mail:openrelay"/>
          <check name="mail_delivery_postmaster"  severity="w" category="mail:delivery"/>
        </else>
      </case>
      <check name="mail_hostmaster_mx_cname"     severity="f" category="mail"/>
      <check name="mail_openrelay_hostmaster"    severity="w" category="mail:openrelay"/>
      <check name="mail_delivery_hostmaster"     severity="f" category="mail:delivery"/>
    </rules>
    
    <rules class="dnssec">
      <case test="dnssec_policy">
      <when value="full">
        <case test="a_ds_or_dnskey_is_given">
        <when value="true">
          <check name="ds_and_dnskey_coherence" severity="f" category="dns:dnssec"/>
        </when>
        </case>
        <check name="edns" severity="f" category="dns:dnssec">
          <check name="one_dnskey"         severity="f" category="dns:dnssec">
            <check name="several_dnskey"         severity="w" category="dns:dnssec"/>
          </check>
          <check name="has_soa_rrsig"      severity="f" category="dns:dnssec">
            <check name="zsk_and_ksk"            severity="w" category="dns:dnssec"/>
            <check name="key_length"             severity="w" category="dns:dnssec"/>
            <check name="soa_rrsig_expiration"   severity="w" category="dns:dnssec"/>
            <check name="soa_rrsig_validity_period" severity="w" category="dns:dnssec"/>
            <check name="algorithm"              severity="w" category="dns:dnssec">
              <check name="verify_soa_rrsig"       severity="f" category="dns:dnssec"/>
            </check>
          </check>
        </check>
      </when>
      <when value="lax">
        <check name="edns" severity="w" category="dns:dnssec">
          <check name="one_dnskey"         severity="w" category="dns:dnssec">
            <check name="several_dnskey"         severity="w" category="dns:dnssec"/>
          </check>
          <check name="has_soa_rrsig"      severity="w" category="dns:dnssec">
            <check name="zsk_and_ksk"            severity="w" category="dns:dnssec"/>
            <check name="key_length"             severity="w" category="dns:dnssec"/>
            <check name="soa_rrsig_expiration"   severity="w" category="dns:dnssec"/>
            <check name="soa_rrsig_validity_period" severity="w" category="dns:dnssec"/>
            <check name="algorithm"              severity="w" category="dns:dnssec">
              <check name="verify_soa_rrsig"       severity="w" category="dns:dnssec"/>
            </check>
          </check>
  	    </check>
      </when>
	  </case>
    </rules>
    
  </profile>

  <!-- Local Variables: -->
  <!-- mode: xml        -->
  <!-- End:             -->
</config>
