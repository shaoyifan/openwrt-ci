#!/bin/sh

board_name=$(cat /tmp/sysinfo/board_name)

configure_wifi() {
    local radio=$1
    local channel=$2
    local htmode=$3
    local txpower=$4
    local ssid=$5
    local key=$6
    local now_encryption=$(uci get wireless.default_radio${radio}.encryption)
    if [ -n "$now_encryption" ] && [ "$now_encryption" != "none" ]; then
        return 0
    fi
    uci -q batch <<EOF
set wireless.radio${radio}.channel="${channel}"
set wireless.radio${radio}.htmode="${htmode}"
set wireless.radio${radio}.txpower="${txpower}"
set wireless.default_radio${radio}.ssid="${ssid}"
set wireless.default_radio${radio}.key="${key}"
EOF
}

jdc_ax1800_pro_wifi_cfg() {
    configure_wifi 0 149 HE80 20 'Jdc_AX1800PRO_5G' '12345678'
    configure_wifi 1 1 HE20 20 'Jdc_AX1800PRO' '12345678'
}

jdc_ax6600_wifi_cfg() {
    configure_wifi 0 149 HE80 18 'AX6600' 'shaoyifan2019'
    configure_wifi 1 1 HE20 17 'IOT' 'shaoyifan2019'
    configure_wifi 2 44 HE160 18 'AX6600_5G' 'shaoyifan2019'
}
 

case "${board_name}" in
jdcloud,ax1800-pro | \
    jdcloud,re-ss-01)
    jdc_ax1800_pro_wifi_cfg
    ;;
jdcloud,ax6600 | \
    jdcloud,re-cs-02)
    jdc_ax6600_wifi_cfg
    ;;
*)
    exit 0
    ;;
esac

uci commit wireless
/etc/init.d/network restart
