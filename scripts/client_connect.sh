#!/bin/bash
# AUTOR: João Maurício Nunes Carneiro
# DATA: 21/03/2024
# PROPÓSITO: Realizar a verificação do MAC e do certificado do client OpenVPN de forma a impedir acessos não autorizados
# VERSÃO: 1.0 
#################################################################################################################################################

################# Variables Definition Start #################
USER_CONNECT_TIME=$time_ascii
USER_CERTIFICATE_NAME=$common_name
USER_MAC_ADDRESS=$IV_HWADDR
USER_PLATFORM=$UV_PLAT_REL
ALLOW_LIST="/etc/openvpn/scripts/allow-list.csv"
LOG_FILE="/var/log/openvpn/connections.log"
################# Variables Definition End ###################

################# Functions Definition Start #################
# The Script's main logic
main(){
	touch $LOG_FILE
	checkAllowListExists >> $LOG_FILE
	printSeparator >> $LOG_FILE
	addAuthLogEntry >> $LOG_FILE
	checkUserMacAddress >> $LOG_FILE
}

printSeparator(){
	echo "#########################################################################"
}

checkAllowListExists(){
	# Check if allow list file exists
	if [[ ! -f "$ALLOW_LIST" ]]; then
		echo "Error: Allow list file '$ALLOW_LIST' not found."
		exit 1
	fi
}

checkUserMacAddress(){
	# Loop through each line in the allow list file
	while IFS=, read -r certificate_name mac_address; do
	# Check for exact match of certificate name and mac address (case-sensitive)
	if [[ "$certificate_name" == "$USER_CERTIFICATE_NAME" && "$mac_address" == "$USER_MAC_ADDRESS" ]]; then
		echo ""
		echo "Certificate "$USER_CERTIFICATE_NAME" matches "$USER_MAC_ADDRESS", connecting user."
		printSeparator
		exit 0
	fi
	done < "$ALLOW_LIST"
}

addAuthLogEntry(){
	echo "Client certificate: $USER_CERTIFICATE_NAME"
	echo "Connection time: $USER_CONNECT_TIME"
	echo "MAC Address: $USER_MAC_ADDRESS"
	echo "Platform: $USER_PLATFORM"
}

################# Functions Definition End ###################

main $@ # Calls our main function passing all available arguments