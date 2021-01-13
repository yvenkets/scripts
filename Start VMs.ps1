workflow start-VMS

{

    Sequence

        {
        start-VM -Name DC01
        start-VM -Name SQL01
        start-VM -Name TFS01
        start-VM -Name IIS01
        start-VM -Name SP_Deploy_1
        start-VM -Name SP_Deploy_2
        start-VM -Name SP_Production
        start-VM -Name BMS-SVR-018
        start-VM -Name BMS-VM-001

         }

}

start-VMS