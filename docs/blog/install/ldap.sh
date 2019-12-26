#!/bin/bash

option=$1
name=$2

function help() {
    info=$(cat << EOF
********************************************
sh ldap.sh [option] [name]
option: adduser addgrp deluser delgrp modpwd
name: username
********************************************
EOF
    )
    echo "$info"
}

if [[ -z "$option" ]] || [[ -z "$name" ]]; then
    help
    exit
fi

user_password=$(openssl rand -base64 8)

add_user_template=$(cat << EOF
dn: uid=ldapuser1,ou=ldapgroup1,dc=my-domain,dc=com
uid: ldapuser1
cn: ldapuser1
sn: ldapuser1
mail: ldapuser1@my-domain.com
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
objectClass: posixAccount
userPassword: 123456
EOF
)
add_group_template=$(cat << EOF
123
123
123
EOF
)
delete_user_template=$(cat << EOF
123
123
123
EOF
)
delete_group_template=$(cat << EOF
123
123
123
EOF
)

change_user_password_template=$(cat << EOF
123
123
123
EOF
)

if [ 'adduser' = "$option" ]; then
    echo "$add_user_template"
    ldapadd -x -D "cn=admin,dc=qtrade,dc=com,dc=cn" -w "XelNaga"
elif [ 'addgrp' = "$option" ]; then
    echo addgrp
elif [ 'deluser' = "$option" ]; then
    echo deluser
elif [ 'delgrp' = "$option" ]; then
    echo delgrp
elif [ 'modpwd' = "$option" ]; then
    echo modgrp
else
    echo option is illegal
    help
    exit
fi


result=$(echo "'{USER_NAME}' 123" | sed "s/{USER_NAME}/$user_name/g")

echo $result
