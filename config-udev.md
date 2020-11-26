# Configuracion reglas udev

## Identificar dispositivo
Lo primero es conectar el dispositivo y ver en que direccion fue montado (esto se puede ver en /var/log/message). En este caso la direccion fue /dev/sda1, luego utilizando el siguiente comando
`udevadm info -a -p $(udevadm info -q path -n /dev/sda1` 

Esto entregara la informacion de la forma mostrada más abajo.  Estas caracteristicas son las que serviran para identificar dispositivos.
```
  looking at device '//devices/platform/soc/3f980000.usb/usb1/1-1/1-1.3/1-1.3:1.                                                                                             0/host0/target0:0:0/0:0:0:0/block/sda/sda1':
    KERNEL=="sda1"
    SUBSYSTEM=="block"
    DRIVER==""
    ATTR{alignment_offset}=="0"
    ATTR{partition}=="1"
    ATTR{discard_alignment}=="0"
    ATTR{size}=="15669216"
    ATTR{start}=="32"
    ATTR{ro}=="0"
    ATTR{inflight}=="       0        0"

  looking at parent device '//devices/platform/soc/3f980000.usb/usb1/1-1/1-1.3/1                                                                                             -1.3:1.0/host0/target0:0:0/0:0:0:0/block/sda':
    KERNELS=="sda"
    SUBSYSTEMS=="block"
    DRIVERS==""
    ATTRS{events_poll_msecs}=="-1"
    ATTRS{events_async}==""

    ATTRS{removable}=="1"
    ATTRS{capability}=="51"
    ATTRS{alignment_offset}=="0"
    ATTRS{ext_range}=="256"
    ATTRS{range}=="16"
    ATTRS{hidden}=="0"
    ATTRS{events}=="media_change"
    ATTRS{discard_alignment}=="0"
    ATTRS{size}=="15669248"
    ATTRS{ro}=="0"
    ATTRS{inflight}=="       0        0"

  looking at parent device '//devices/platform/soc/3f980000.usb/usb1/1-1/1-1.3/1                                                                                             -1.3:1.0/host0/target0:0:0/0:0:0:0':
    KERNELS=="0:0:0:0"
    SUBSYSTEMS=="scsi"
    DRIVERS=="sd"
    ATTRS{blacklist}==""
    ATTRS{device_busy}=="0"
    ATTRS{evt_capacity_change_reported}=="0"
    ATTRS{evt_media_change}=="0"
    ATTRS{rev}=="1.0 "
    ATTRS{iocounterbits}=="32"
    ATTRS{state}=="running"
    ATTRS{vendor}=="General "
    ATTRS{eh_timeout}=="10"
    ATTRS{evt_soft_threshold_reached}=="0"
    ATTRS{queue_type}=="none"
    ATTRS{evt_inquiry_change_reported}=="0"
    ATTRS{queue_depth}=="1"
    ATTRS{type}=="0"
    ATTRS{inquiry}==""
    ATTRS{ioerr_cnt}=="0x1"
    ATTRS{scsi_level}=="3"
    ATTRS{evt_lun_change_reported}=="0"
    ATTRS{timeout}=="30"
    ATTRS{iodone_cnt}=="0xfa"
    ATTRS{iorequest_cnt}=="0xfa"
    ATTRS{device_blocked}=="0"
    ATTRS{max_sectors}=="240"
    ATTRS{model}=="USB Flash Disk  "
    ATTRS{evt_mode_parameter_change_reported}=="0"

```
## Escribir regla

El archivo que contiene la regla debe tener el formato xx-name.rules.d donde xx es un numero entre 0 y 99. Este numero indicara la prioridad de las reglas, una regla que comience por 20 sera ejectuda antes que la que comienza por un numero mayor. Para este caso el archivo sera llamado 50-backup.rules
Al momento de escribir el contenido de la regla es importante asegurarse de que estamos utilizando un atributo de los mostrados en el primer bloque, ya que esto asegura que el enlace simbolico sea un dispositivo montable (Idealmente KERNEL o SUBSYSTEM).  
> Solo se puede utilizar un atributo de cada bloque de lo contrario la regla dara un error.

Con lo anterior los atributos de la regla seran 
```
SUBSYSTEM=="block"
KERNEL=="sd*" /*Cualquier dispoistivo que el atributo kernel empieze por sd*/
DRIVERS=="usb-storage"
ACTION=="add"
```

Ademas se agrega 
```
SYMLINK+="avm_link"
RUN+="/bin/systemctl --no-block start backup_avm.service"
```
que permiten crear el enalce simbolico e iniciar un servicio cuando se cumplan las 4 reglas anteriores.
