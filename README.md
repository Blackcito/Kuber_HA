# 🧱 Kuber_HA

Repositorio para desplegar un clúster de Kubernetes altamente disponible, con balanceo de carga, almacenamiento persistente Longhorn y aprovisionamiento automatizado con Terraform.

---

## 📌 Tabla de contenidos

1. [Introducción](#introducción)  
2. [Infraestructura con Terraform](#infraestructura-con-terraform)  
3. [Alta Disponibilidad del Control Plane](#alta-disponibilidad-del-control-plane)  
4. [Instalación de Kubernetes](#instalación-de-kubernetes)  
5. [Almacenamiento Persistente con Longhorn](#almacenamiento-persistente-con-longhorn)  
6. [Orquestación de Configuración](#orquestación-de-configuración)  
7. [Validación e Integración](#validación-e-integración)  
8. [Componentes Adicionales y Extensibilidad](#componentes-adicionales-y-extensibilidad)  
9. [Documentación y Uso](#documentación-y-uso)  
10. [Referencias y Recursos](#referencias-y-recursos)

---

## 1. Introducción

**Objetivo:**  
Desplegar un entorno de Kubernetes HA (alta disponibilidad) autosuficiente, con balanceadores activos/pasivos (HAProxy + Keepalived), almacenamiento distribuido (Longhorn) y ejecución automatizada con Terraform y Ansible.

**Arquitectura:**  
Incluye 3 nodos control-plane, 2 nodos worker, 2 nodos LB, con una VIP compartida para acceso a API y servicios.
Diagrama:  
![Flowchart](https://github.com/user-attachments/assets/5c799269-db9b-4782-962b-677abe39e468)


---

## 2. Infraestructura con Terraform

Se define y provisiona:

- Proveedor y variables (p.ej. tamaño VM, red).  
- Máquinas:
  - `control-plane` (3 instancias).
  - `workers` (2 instancias).
  - `lb` (2 para HAProxy + Keepalived).

Ejecute:
'''bash
terraform init
terraform apply


En mas detalle la carpeta config, contendra todas las configuraciones sobre red para cada nodo, asi como las configuraciones cloud_init para inciar los OS.
Variables.tf, contendra las variables a usar, siendo en este caso cantidad de workers, control-plane, proxy y las configuraciones de cada uno.
main.tf, contrae toda la configuracion para el despligue de estas maqunas previamente solicitadas en variables. contiene la configuracion de red, espacio, discos, entre otros.

---

## 2. INSTALACION CON ANSIBLE

### Resumen

Previo a cualquier paso ocuapremos el archivo hosts.ini, donde estaran los controladores, workers y proxy, cada uno con sus ips, asi como variables extras para ansible, a partir de este punto todo el uso sera completamente en asnible peusto que las maquinas ya debieron quedar desplegadas.

### Alta disponibilidad

#### HAProxy

* Balancea el tráfico entrante sobre la VIP.
* Health checks a los 3 masters sobre el puerto 6443 (apiserver).

#### Keepalived

* Configura la **VIP** flotante.
* VRRP con prioridad para HA.
  
### Explicacion
Para esta parte de la configuracion se usan las dos maquinas llamas lb, o en hosts.ini como proxy, se instala haproxy y keepalived, y se configurara con una plantilla previa donde en haproxy dejaremos los servidores master (control) y en keepalived usaremos la ip virtual de hosts.ini asi como un despligue del servicio y su vecino para tener un disponibilidad en caso que una maquina falle, para este casos on 2 proxy pero el minimo ideal siempre sera 3.


## ⚘️ 3. Instalación de Kubernetes

### Preparación de los nodos

* Configuración básica de red, kernel y contenedores.
* Instalación de kubeadm, kubelet, container runtime.

####
Se inicializa el cluster, desde el archivo de site.yaml le pasamos como variable la ip flotante para asi inicialice el cluster, extraemos los certificados y las configuraciones para pasarlas a los otros nodos, ya en el comando de union, tomamos la ip flotante, los archivos compartidos por parte del master 1, y hacemos que las maquinas se unan como workers o control, esto dependiendo de que maquina sea.

### Creación del cluster

* Init del master principal (`kubeadm init`) y generación de certificados.
* Union del resto de masters (**stacked etcd**) y workers (`kubeadm join`).

####
Instalamos dependencias finales de kubernetes 

## 🔀 4. Almacenamiento Persistente con Longhorn

####
la instalacion se hace acorde a la documentacion de longhorn para instalacion por medio de kubectl, donde instalamos cona pply -f -url repositorio-, se espera a que este listo longhorn, obtenemos los ndoso y los unimos.

### Deployment

* Instalación mediante apply.
* Namespace: `longhorn-system`.

### Configuración

* Cada worker detecta discos adicionales para almacenamiento persistente.
* Administración de volúmenes y snapshots desde la UI de Longhorn.

### Validación

* Verificación de pods `longhorn-manager`, `longhorn-ui`, `csi-plugin`.
* Creación de PVC y pruebas de lectura/escritura.

## 🔗 5. Orquestación de la Configuración

### Ansible

* Roles separados por componente (**kubernetes**, **longhorn**, **haproxy**, **keepalived**).
* Variables personalizadas por entorno.
* Ejecución secuencial controlada mediante `site.yml`.

## 🔢 6. Validación y Pruebas

Para esta parte se tiene un archivo de ansible llamado longhorn_simple_test.yml, el cual crea un PVC, pod ngninx y service nodeport, esto nos permite tener dentro de nuestro worker y en su almacenamieto de longhorn una "pagina" de ngninx a la cual podemos acceder desde el navegador y con esto comprobar que ocurre en caso de fallar un worker.


## 📚 8. Uso y Mantenimiento

### Requisitos previos

* Terraform, Ansible, acceso SSH a las máquinas.

### Flujo recomendado:

```bash
# Provisión de infraestructura
cd terraform
terraform init && terraform apply

# Configuración del clúster
cd ../ansible
ansible-playbook -i hosts.ini site.yml
```

### Mantenimiento

* Escalado de workers mediante terraform.
* Actualización de Kubernetes mediante kubeadm.
* Actualización de Longhorn mediante Helm.

## 🔎 9. Referencias

* [Documentación oficial de Kubernetes](https://kubernetes.io/docs/)
* [Documentación oficial de Longhorn](https://longhorn.io/docs/)
* [HAProxy Documentation](https://www.haproxy.org/)
* [Keepalived Documentation](https://keepalived.org/)
* [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)

---

### Autor: [Blackcito](https://github.com/Blackcito)

Si deseas aportar mejoras o correcciones, por favor abre un Pull Request o Issue.


