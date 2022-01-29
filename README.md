Connect | cn

NAME
       cn - connect

SYNOPSIS
       cn [OPTION] machineName

DESCRIPTION
       	-a, --all
		Usage: cn -a
              	Show all Machine name with their IP Address

	-a=searchTerm
		Usage: cn -a=aws
              	Show all Machine name matching the searchTerm with their IP Address

	-p, --useSamePassword
		Usage: cn -p username@IP | connect -p username IP 
		Use default password

	-pu, --useSameUser
		Usage: cn -pu IPaddress
		Use default username and password to connect

	-h , --help
		Usage: cn --help
		Shows help page

	/*
		Usage: cn /number
		Subex specific command

AUTHOR
       Abhishek Powar (mailabhipowar@gmail.com)

