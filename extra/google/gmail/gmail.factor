! Copyright (C) 2016 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays json.reader kernel namespaces oauth2 sequences ;
IN: google.gmail

CONSTANT: api-base "https://www.googleapis.com/gmail/v1/users"

CONSTANT: auth-uri "https://accounts.google.com/o/oauth2/auth"
CONSTANT: token-uri "https://www.googleapis.com/oauth2/v4/token"
CONSTANT: redirect-uri "urn:ietf:wg:oauth:2.0:oob"
CONSTANT: gmail-scope-ro "https://www.googleapis.com/auth/gmail.readonly"

SYMBOL: access-token

: configure-oauth2 ( client-id client-secret -- )
    [ auth-uri token-uri redirect-uri ] 2dip gmail-scope-ro { }
    oauth2 boa \ oauth2 set ;

: ensure-token ( -- )
    access-token [
        [ \ oauth2 get console-flow ] unless*
    ] change ;

: api-call ( method get-params -- result )
    ensure-token
    [ api-base prepend ] dip string+params>url
    access-token get oauth-http-get nip
    json> ;

: list-drafts ( -- seq )
    "/me/drafts" { } api-call ;

: list-labels ( -- seq )
    "/me/labels" { } api-call ;

: list-messages-by-label ( label -- seq )
    [ "/me/messages" ] dip "labelIds" swap 2array 1array api-call ;

: get-messages ( id format -- seq )
    [ "/me/messages/" prepend ] dip "format" swap 2array 1array api-call ;