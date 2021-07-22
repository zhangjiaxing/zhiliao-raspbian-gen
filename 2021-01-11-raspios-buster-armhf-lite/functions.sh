
readconfig(){
    if [[ -f "$SERVER_CONFIG_FILE" ]]; then
        jq --raw-output ".$1" $SERVER_CONFIG_FILE

    elif [[ -f "/data/xluf-config.json" ]]; then
        jq --raw-output ".$1" "/data/xluf-config.json"

    elif [[ -f "/etc/xluf-config.json" ]]; then
        jq --raw-output ".$1" "/etc/xluf-config.json"    
    
    else
        echo "Unknown: Can't find the configuration file" >&2
        echo "debug: SERVER_CONFIG_FILE = $SERVER_CONFIG_FILE" >&2
	return 2
    fi
}

errecho(){
    echo -e "\033[1;31m${1}\033[0m"
}

errinfo(){
    echo -en "\033[1;31m[ 错误 ]\033[0m"
    echo ${1}
}

okinfo(){
    echo -en "\033[1;32m[ 成功 ]\033[0m"
    echo ${1}
}



check_deb(){
    # 如果安装输出1, 否则不输出
    deb_name="$1"
    state=`dpkg-query -W -f '${db:Status-Abbrev}' "$deb_name"`
    if [[ "$state" == "ii " ]]; then
        echo "1"
    fi
}

export -f okinfo
export -f errinfo
export -f check_deb
export -f errecho
export -f readconfig

