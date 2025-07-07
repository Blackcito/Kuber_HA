# Para habilitar las redes

virsh net-define  manage.xml
virsh net-start     manage

virsh net-define netstack.xml 
virsh net-start netstack

