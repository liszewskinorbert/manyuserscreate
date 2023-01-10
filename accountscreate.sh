#!/bin/bash

filename=./empty.txt
count=0
password_length=6
password_letters="0123456789abcdefghijklmnoprstuwxyz,./@#$%^&"
declare -a myAccounts
declare -a myPasswords
declare -a Names
declare -a Surnames
security_user=("admin1" "admin2")
counts=0



create_file_to_raport() {
d=`date +%Y-%m-%d.%H:%M:%S`
file=raport_$d
touch $file
}

set_file() {
	echo "np ./mylist.txt"
        read filetoread
        if [ -e "$filetoread" ] ; then
                echo "File $filetoread exist" | tee -a $file
                #counts=(`wc -l "$filetoread"|cut -d " " -f 1`)
		myAccounts=(`cat "$filetoread" |cut -d " " -f 1|tr '[:upper:]' '[:lower:]' `)
                counts="${#myAccounts[*]}";
		Names=(`cat "$filetoread" |cut -d " " -f 2`)
		Surnames=(`cat "$filetoread" |cut -d " " -f 3`)
		echo "File have $counts records" |tee -a $file
		sleep 3s
		clear
        else
                echo "File $filetoread not exist" |tee -a $file
		sleep 3s
		clear
        fi
}
set_length() {
	echo "Length for password is set to 6, enter new value or write 6" |tee -a $file
	read length
	password_length=$length
	echo "Now length is set $password_length" |tee -a $file
	slepp 3s
	clear
}


show_users_to_add() {
for (( i = 0, a = 1 ; i < $counts ; i++, a++))
do
echo "Account nr [$a]: ${myAccounts[$i]} ${Names[$i]} ${Surnames[$i]}"
done
sleep 3s
clear
}


show_config() {
	echo "Ener to show config settings" >> $file
        echo "File to read data $filetoread"
        echo "Create accounts $counts"
        echo "Length passwords is $password_length"
	echo "Characters to passwords $password_letters"
	sleep 6s
	clear
}

make_password() {
echo "$d Passwords for geting accounts" >> $file
myPasswords=(`egrep -aio -m $counts "[$password_letters]{$password_length}" /dev/urandom`)
for (( i = 0,  j = 1 ; i < $counts ; i++, j++))
do
echo "Password nr [$j]: ${myPasswords[$i]}" |tee -a $file
done
sleep 3s
clear
}

create_accounts() {
echo "$d Creating accounts is running" >>$file
for (( i = 0 ; i < $counts ; i++ ))
do
	account_in_etc=(`cat /etc/passwd | grep ${myAccounts[$i]} | cut -d ":" -f 1`)
	if [[ ${myAccounts[$i]} == $accounts_in_etc ]]
		then
		echo "Uer ${myAccounts[$i]} is exist in system" |tee -a $file
		else
		echo "User ${myAccounts[$i]} is not exist in system"|tee -a $file
		fullname=(${Names[$i]}_${Surnames[$i]})
		useradd -d /home/${myAccounts[$i]} -m -G groupname -c $fullname -s /bin/bash ${myAccounts[$i]}
		echo -e "User ${myAccounts[$i]} was add to system" |tee -a $file
		#echo -e "${myAccounts[$i]}:${myPasswords[$i]}" |chpasswd
		echo -e "${myPasswords[$i]}" |passwd ${myAccounts[$i]} --stdin
		echo -e "Password for user ${myAccounts[$i]} is set." | tee -a $file
		passwd -e ${myAccounts[$i]}
		#chage --lastday 0 ${myAccounts[$i]}
		echo "User ${myAccounts[$i]} must change password on first login" | tee -a $file
	fi
done
sleep 5s
clear
}


delete_account() {
echo "$d Delete account" >> $file
echo "Enter username to delete:" |tee -a $file

read account_to_delete
if [[ $account_to_delete == "root" ]]
	then
	echo "This is root, you cant do that !!!" |tee -a $file
elif
	[[ " ${security_user[*]} " =~ " ${account_to_delete} " ]]
then
	echo "This is admin user, you cant do that" |tee -a $file
elif
	[[ $account_to_delete == `cat /etc/passwd |grep ${account_to_delete} |cut -d ":" -f 1` ]]
	then
	echo "User $account_to_delete was delete" |tee -a $file
	userdel -r $account_to_delete
else
	echo "This user not exist in system" |tee - a $file
fi
sleep 3s
clear
}

reset_password() {
echo "$d Reset password" >> $file
echo "Enter username to reset password" |tee -a $file
 
read account_to_reset_password
if [[ $account_to_reset_password == "root" ]]
        then
        echo "This is root, you cat do that !!!!" |tee -a $file
elif
        [[ " ${security_user[*]} " =~ " ${account_to_reset_password} " ]]
then
        echo "This is admin user, you cant do that" |tee -a $file
elif
        [[ $account_to_reset_password == `cat /etc/passwd |grep ${account_to_reset_password} |cut -d ":" -f 1` ]]
        then
        echo "User $account_to_reset_password was reset password" |tee -a $file
        new_password=(`egrep -aio -m 1 "[$password_letters]{$password_length}" /dev/urandom`)
	echo "Password for user $account_to_reset_password is $new_password " |tee -a $file
	echo -e "$account_to_reset_password:$new_password"|chpasswd|tee -a $file
	passwd -e $account_to_reset_password
	echo "User must change password on first login" |tee -a $file
else
        echo "User is not exist in system" |tee - a $file
fi
sleep 5s
clear
}


create_raport_login_pass() {
echo "$d Raport from making changes is save as: " >> $file
for (( i = 0, j = 1 ; i<$counts ; i++, j++))
do
echo -e "$j. ${myAccounts[$i]} ${Names[$i]} ${Surnames[$i]} ${myPasswords[$i]}" |tee -a $file
done
sleep 5s
clear
}



create_file_to_raport
choose="Choise number from [1-8] or 9 to exit program  : "
while [ 1 -eq 1 ] ; do
	echo -e "What you have to do ?"
	echo -e "\e[92m1) Set file to read data"
	echo -e "\e[92m2) Set longth password (default 6)"
	echo -e "\e[92m3) Show settings"
	echo -e "\e[92m4) Make random passwords for adding accounts"
	echo -e "\e[92m5) Make raport from make changes in system"
	echo -e "\e[91m6) Create loaded accounts to system"
	echo -e "\e[91m7) Delete account"
	echo -e "\e[91m8) Reset password for account"
	echo -e "\e[37m9) Exit from program"
	echo -e $choose
	read answer
	case "${answer^^}" in
		"1") echo "Set file to read data" 
		set_file
		show_users_to_add;;
		"2") echo "Set longth password" 
		set_length;;
		"3") echo "Show settings"
		show_config;;
		"4") echo "Create random passswords for account from file"
		make_password;;
		"5") echo "Make raport"
		create_raport_login_pass;;
		"6") echo "Create loaded accounts to system"
		create_accounts;;
		"7") echo "Delete account"
		delete_account;;
		"8") echo "Reset password for account"
		reset_password;;
		"9") echo "Good bye"
		echo "Raport from making changes in system was save to file $file"
		echo "$d Working with scrypt was end" >> $file
		sleep 1s
		exit ;;
		*) echo "Only digits from 1 to 9" 
		sleep 2s
		clear;;
	esac
done

