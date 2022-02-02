#!/bin/sh
# Script that configure and start LDAP

# Ensure certificates exist
if [ "$LDAPS" = true ]; then

  RETRY=0
  MAX_RETRIES=3
  until [ -f "$KEY_FILE" ] && [ -f "$CERT_FILE" ] && [ -f "$CA_FILE" ] || [ "$RETRY" -eq "$MAX_RETRIES" ]; do
    RETRY=$((RETRY+1))
    echo "Cannot find certificates. Retry ($RETRY/$MAX_RETRIES) ..."
    sleep 1
  done

  # exit if no certificates were found after maximum retries
  if [ "$RETRY" -eq "$MAX_RETRIES" ]; then
    echo "Cannot start ldap, the following certificates do not exist"
    echo " CA_FILE:   $CA_FILE"
    echo " KEY_FILE:  $KEY_FILE"
    echo " CERT_FILE: $CERT_FILE"
    exit 1
  fi

fi

# This section replaces variables in slap.cnf
# Add more if you needed
SLAPD_CONF="/etc/openldap/slapd.conf"

if [ "$LDAPS" = true ]; then
  sed -i "s~%CA_FILE%~$CA_FILE~g" "$SLAPD_CONF"
  sed -i "s~%KEY_FILE%~$KEY_FILE~g" "$SLAPD_CONF"
  sed -i "s~%CERT_FILE%~$CERT_FILE~g" "$SLAPD_CONF"
  if [ -n "$TLS_VERIFY_CLIENT" ]; then
    sed -i "/TLSVerifyClient/ s/demand/$TLS_VERIFY_CLIENT/" "$SLAPD_CONF"
  fi
else
  # comment out TLS configuration
  sed -i "s~TLSCACertificateFile~#&~" "$SLAPD_CONF"
  sed -i "s~TLSCertificateKeyFile~#&~" "$SLAPD_CONF"
  sed -i "s~TLSCertificateFile~#&~" "$SLAPD_CONF"
  sed -i "s~TLSVerifyClient~#&~" "$SLAPD_CONF"
fi

sed -i "s~%ROOT_USER%~$ROOT_USER~g" "$SLAPD_CONF"
sed -i "s~%SUFFIX%~$SUFFIX~g" "$SLAPD_CONF"
sed -i "s~%ACCESS_CONTROL%~$ACCESS_CONTROL~g" "$SLAPD_CONF"

ROOT_PW=$(slappasswd -s "$ROOT_PW")
sed -i "s~%ROOT_PW%~$ROOT_PW~g" "$SLAPD_CONF"


# This sections allows you to import your own data
# Include any *.ldif script located in /lidif/ folder
for l in /ldif/*; do
  case "$l" in
    *.ldif)  echo "ENTRYPOINT: adding $l";
            slapadd -l $l
            ;;
    *)      echo "ENTRYPOINT: ignoring $l" ;;
  esac
done

if [ "$LDAPS" = true ]; then
  echo "Starting LDAPS"
  slapd -d "$LOG_LEVEL" -h "ldaps:///"
else
  echo "Starting LDAP"
  slapd -d "$LOG_LEVEL" -h "ldap:///"
fi

# run command passed to docker run
exec "$@"