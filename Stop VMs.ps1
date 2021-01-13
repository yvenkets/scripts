workflow stop-VMS

{

    Sequence

        {
        stop-VM -Name DC01
        stop-VM -Name SQL01
        stop-VM -Name TFS01
        stop-VM -Name IIS01
        stop-VM -Name SP_Deploy_1
        stop-VM -Name SP_Deploy_2
        stop-VM -Name SP_Production
        stop-VM -Name BMS-SVR-018
        stop-VM -Name BMS-VM-001

         }

}

stop-VMS