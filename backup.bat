7z a "%DATE%:~0,2%.%TIME:~3,2%_Backup.7z" c:\apache\htdocs\
7z a -t7z "c:\Downloads\%DATE:~7,2%-%DATE:~4,2%-%DATE:~10,4%.7z" "c:\Downloads \backup" -mx5
