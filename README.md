# NGINX Load Balancer con Terraform, Packer y Ansible

Este proyecto implementa una infraestructura de alta disponibilidad en Google Cloud Platform (GCP) utilizando NGINX como servidor web. La arquitectura incluye un Load Balancer que distribuye el tráfico entre múltiples instancias, cada una con su propio ID único para demostrar el balanceo de carga.

## 🏗️ Arquitectura

```
                    [Load Balancer]
                           |
                           |
        +----------------+----------------+
        |                |                |
    [Instancia 1]    [Instancia 2]    [Instancia 3]
        |                |                |
    [NGINX + ID]     [NGINX + ID]     [NGINX + ID]
```

## 📋 Prerrequisitos

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [Packer](https://www.packer.io/downloads.html) >= 1.8.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) >= 2.9.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- Cuenta de GCP con facturación habilitada
- Proyecto de GCP creado

## 🔑 Configuración Inicial

1. Clonar el repositorio:
```bash
git clone <url-del-repositorio>
cd <nombre-del-repositorio>
```

2. Configurar las credenciales de GCP:
```bash
gcloud auth application-default login
```

3. Configurar las variables de Packer:
   - Editar `packer/nginx/packer.auto.pkrvars.hcl` con tus valores:
```hcl
project_id          = "tu-proyecto-id"
region              = "europe-west1"
image_name_prefix   = "nginx-image"
```

## 🚀 Despliegue

### 1. Crear la imagen con Packer

```bash
cd packer/nginx
packer build .
```

Este comando:
- Crea una imagen base de Ubuntu 22.04 LTS
- Instala y configura NGINX
- Configura un servicio systemd para generar IDs únicos
- Aplica las configuraciones de seguridad necesarias

### 2. Desplegar la infraestructura con Terraform

```bash
cd terraform/environments/dev  # o prod para producción
terraform init
terraform plan
terraform apply
```

El despliegue creará:
- Un grupo de instancias administrado
- Un Load Balancer
- Reglas de firewall
- Health checks
- Plantillas de instancias

## 🔍 Verificación

1. Obtener la IP del Load Balancer:
```bash
terraform output load_balancer_ip
```

2. Verificar el balanceo de carga:
```bash
# Hacer múltiples peticiones para ver diferentes IDs
for i in {1..10}; do
  curl -s http://<IP-DEL-LOAD-BALANCER>/id
  echo
  sleep 1
done
```

3. Verificar las instancias:
```bash
gcloud compute instance-groups managed list-instances nginx-mig-dev --zone=europe-west1-b
```

## 🧹 Limpieza

Para eliminar toda la infraestructura:

```bash
cd terraform/environments/dev  # o prod
terraform destroy
```

## 📁 Estructura del Proyecto

```
.
├── packer/
│   └── nginx/
│       ├── main.pkr.hcl
│       ├── packer.auto.pkrvars.hcl
│       └── ansible/
│           ├── playbook.yml
│           └── roles/
│               └── webserver/
│                   ├── tasks/
│                   ├── templates/
│                   └── handlers/
└── terraform/
    ├── modules/
    │   └── nginx_instance_group/
    │       ├── main.tf
    │       ├── variables.tf
    │       └── outputs.tf
    └── environments/
        ├── dev/
        │   ├── main.tf
        │   └── terraform.tfvars
        └── prod/
            ├── main.tf
            └── terraform.tfvars
```

## 🔧 Configuración Personalizada

### Modificar el número de instancias

Editar `terraform/environments/dev/terraform.tfvars`:
```hcl
instance_count = 3  # Cambiar al número deseado
```

### Modificar la región

Editar `terraform/environments/dev/terraform.tfvars`:
```hcl
region = "europe-west1"  # Cambiar a la región deseada
```

## 🔐 Seguridad

- Las instancias usan instancias spot para reducir costos
- Los health checks aseguran que solo instancias saludables reciban tráfico
- Las reglas de firewall están configuradas para permitir solo el tráfico necesario
- No se almacenan credenciales en el código

## 💡 Mejores Prácticas Implementadas

- Infraestructura como Código (IaC)
- Separación de ambientes (dev/prod)
- Módulos reutilizables
- Configuración automatizada
- Imágenes preconfiguradas
- Balanceo de carga
- Health checks
- Logging y monitoreo

## 🐛 Troubleshooting

### Problemas comunes:

1. **Error de permisos en GCP**
   - Verificar que la cuenta tiene los permisos necesarios
   - Ejecutar `gcloud auth application-default login`

2. **Error en el health check**
   - Verificar que NGINX está corriendo en las instancias
   - Revisar los logs: `gcloud compute ssh <instancia> --command="sudo journalctl -u nginx"`

3. **Mismo ID en todas las instancias**
   - Verificar que el servicio generate-id está corriendo
   - Revisar los logs: `gcloud compute ssh <instancia> --command="sudo journalctl -u generate-id"`

## 📝 Notas Adicionales

- El proyecto usa Ubuntu 22.04 LTS como sistema operativo base
- Las instancias son tipo e2-micro para optimizar costos
- El Load Balancer está configurado para no usar afinidad de sesión
- Los IDs únicos se generan al arrancar cada instancia

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor, sigue estos pasos:
1. Fork el repositorio
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles. 