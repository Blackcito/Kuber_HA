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
![Diagrama general](link-al-diagrama-en-tu-repositorio)

---

## 2. Infraestructura con Terraform

Define y provisiona:

- Proveedor y variables (p.ej. tamaño VM, red).  
- Máquinas:
  - `control-plane` (3 instancias).
  - `workers` (2 instancias).
  - `lb` (2 para HAProxy + Keepalived).

Ejecute:
```bash
terraform init
terraform apply
