#!/bin/bash

# Destruye la infraestructura definida por Terraform
terraform destroy -auto-approve

# Limpia archivos y carpetas de Terraform
rm -rf .terraform*
rm -f terraform.tfstate*

# Elimina los discos cloud-init ISO si existen (ajusta el path según tu configuración)
rm -f /home/jose/vmstore/pool/*commoninit.iso

