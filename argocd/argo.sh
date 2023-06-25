#!/bin/bash
set -o errexit -o nounset -o pipefail
HOST_NAME=$(gum input --placeholder "What is the fully qualified domain name  you would like to expose this cluster on?")
export HOST_NAME=$HOST_NAME
SSL_EMAIL=$(gum input --placeholder "Which email would you like to use for Let's Encrypt (SSL)")
export SSL_EMAIL=$SSL_EMAIL

for file in *.tmpl; do envsubst < "$file" > "${file%.tmpl}"; done
export HOST_NAME
export SSL_EMAIL
