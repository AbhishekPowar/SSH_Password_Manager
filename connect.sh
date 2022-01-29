pathConnect=`dirname $(realpath $0)`
cd "$pathConnect"
delimiter=":"
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
bold=$(tput bold)
normal=$(tput sgr0)
timeoutDuration=0.5
function addNewConfig(){

	requests="nickname password username ipaddress"
	declare -A configs
	configLine=""
	for key in `echo ${requests}`
	do
		echo -e "Enter $key : \c" 
		read inputVar
		configs[$key]=$inputVar
		configLine+=":$inputVar"
	done
	configLine=`echo $configLine|cut -c 2-`
	echo $configLine
	echo -e "Do you want save (y/n) \c"
	read inputVar
	if [[ "$inputVar" == 'y' ]]
	then 
		echo "Saving configuration.."
		echo $configLine >> configs
		echo "Configuration saved successfully"
		echo "Password :${configs['password']}"
		ssh ${configs['username']}@${configs['ipaddress']}
	else
		echo "Exiting process"	
	fi
}
function pingIp(){
	ip=$1
	timeout $timeoutDuration ping -c1 $ip > /dev/null 2> /dev/null
	result=$?	
	machineStatus="${red}DOWN${reset}"
	if [[ $result -eq 0 ]]
	then 
		machineStatus="${green}UP${reset}"
	fi
	echo $machineStatus
}

function parse() {
	sentence=$1
	OLDIFS=$IFS
	IFS=':'
	creds=($sentence)
	IFS=$OLDIFS
	echo ${creds[@]}
}

function getDefPass() {
	password=`cat config |grep default|awk -F: '{print $2}'`
	echo $password
}

function getDefUsername() {
	password=`cat config |grep default|awk -F: '{print $3}'`
	echo $password
}

function showAll() {
	timeoutDuration=0.2
	key=":"
	if [[ $# -eq 1 ]]
	then 
		key=$1
	fi
	echo -e "Staring process"
	output="nickname -> username@ipAddr machineStatus\n"
	for configLine in `cat $configFilePath`
	do 
		if [[ ! -z "`echo $configLine|grep $key`" ]]
		then
			echo -e "#\c"
			creds=(`parse $configLine`)
			nickname=${creds[0]}
			password=${creds[1]}
			username=${creds[2]}
			ipAddr=${creds[3]}
			machineStatus=`pingIp $ipAddr`
			output+="$nickname -> $username@$ipAddr $machineStatus\n"
		fi
	done
	echo -e "\n"
	if [[ `echo -e "$output"|wc -l` -gt 2 ]]
	then
		echo -e $output |column -t
	else
		echo "No matches"
	fi
}

function connectUsingSSH() {
	password=$1
	usernameIP=$2
	ipAddr=${usernameIP/*@/}
	machineStatus=`pingIp $ipAddr`
	if [[ "$machineStatus" == *"UP"* ]]
	then
		echo "Trying to Connecting to $usernameIP ..."
		echo "sshpass -p $password ssh $usernameIP"
		sshpass -p $password ssh $usernameIP
	else
		#echo "sshpass -p $password ssh $usernameIP"
		echo "Server $ipAddr is $machineStatus"
	fi
	
}

function isSubexUser(){
	unique=`echo $1|cut -c 2-`
	ipAddr="172.31.16.${unique}"
	password=`getDefPass`
	username=`getDefUsername`
	connectUsingSSH $password $username@$ipAddr
}

function useSamePassword(){
	password=`getDefPass`
	if [[ $# -eq 2 ]]
	then
		connectUsingSSH $password $2
	elif [[ $# -eq 3 ]]
	then
		connectUsingSSH $password $2@$3
	else
		echo "Usage : cn -u username@ip | cn -u username ip"
	fi
}

function useSameUsername(){
	password=`getDefPass`
	username=`getDefUsername`
	ipAddr=$1
	connectUsingSSH $password "$username@$ipAddr"   
}

function showIfMultipleMatches() {
	echo "Multiple Machine Matches"
	showAll $1
}

function connect() {
	if [[ $# -ne 1 ]]
	then 
		echo "Send nickname"
		exit 0
	fi

	configLine=$(cat $configFilePath | grep $1 )
	matches=$(cat $configFilePath | grep "^.*$1.*:"|wc -l)

	if [ $matches -eq 1 ]
	then 
		creds=(`parse $configLine`)
		nickname=${creds[0]}
		password=${creds[1]}
		username=${creds[2]}
		ipAddr=${creds[3]}
		connectUsingSSH $password $username@$ipAddr

	elif [[ $matches -eq 0 ]]
	then
		echo "No matches found"
	else
		showIfMultipleMatches $1
	fi

}

function help() {
	cat README.md | less
}

function main() {
	case $1 in 
		-a|--add) addNewConfig ;;
		-h|--help) help ;;
		-p|-sp|--useSamePassword) useSamePassword $@;; 
		-pu|-su|--useSameUser) useSameUsername $2;; 
		-s|--show) showAll;; 
		-s=*|--show=*) showAll ${1#*=};; 
		/*) isSubexUser $1;;
		*) connect $1;;
	esac
}
configFilePath="config"
main $@
