#!/usr/bin/env bash

LOGIN="$1"
PASSWORD="$2"
ID=$(cat /proc/sys/kernel/random/uuid)

PASSWORD_HASH=$(echo -n "$PASSWORD" | md5sum | awk '{print $1}')

redis-cli set "user_id_${LOGIN}" "${ID}"
redis-cli set "user_password_${LOGIN}" "${PASSWORD_HASH}"
redis-cli sadd "users" "${LOGIN}"
