# shellcheck shell=bash

alias dig='dig +noall +answer'

digg() { # substitute for "ANY"
  local x
  for x in A AAAA AFSDB APL CAA CDNSKEY CDS CERT CNAME CSYNC DHCID DLV DNAME \
           DNSKEY DS EUI48 EUI64 HINFO HIP HTTPS IPSECKEY KEY KX LOC MX NAPTR \
           NS NSEC NSEC3 NSEC3PARAM OPENPGPKEY PTR RP SIG SMIMEA SOA SPF SRV \
           SRV SSHFP SVCB TA TKEY TSLA TSIG TXT URI ZONEMD; do
    dig "$@" "$x"
  done | distinct # Only show CNAME once (defined in ~/.bashrc)
}
