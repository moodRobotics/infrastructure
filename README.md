# Mood Robotics & Grupo Hereda - Infrastructure as Code (IaC)

Repositorio centralizado y única fuente de verdad declarativa para todos los entornos de infraestructura y despliegues gestionados mediante Docker Swarm, Docker Standalone y Portainer GitOps Workflows.

**Repositorio remoto:** `https://github.com/moodrobotics/infrastructure.git`

---

## 📁 Estructura del Repositorio

```plaintext
infrastructure/
├── clusters/
│   ├── maria/             # Cluster Swarm (maria001-003) - Grupo Hereda
│   │   ├── nginx-proxy/   # Ingress proxy y certificados
│   │   ├── mongodb/       # Bases de datos de producción
│   │   └── hereda-apps/   # Stacks de gestión
│   └── quimera/           # Cluster Swarm (mood001, mood003, mood999) - Mood Robotics
│       ├── core-services/ # Apps Node.js (1-tool.com, paypirus.com, cvic.uk)
│       ├── databases/     # Instancias MongoDB
│       └── dsh/           # DeepSeek Harness (ghcr.io/moodrobotics/dsh:release)
├── standalone/
│   ├── dragon/            # Servidor mood100 (HP DL580 Gen9 + RTX 5060 Ti)
│   │   └── gpu-workloads/ # Stacks con runtime nvidia para IA/Inferencia
│   └── shadow/            # MiniPC Mercedes (10.90.0.21)
│       └── home-services/  # Servicios locales / Backups
├── proxy/
│   └── smith/             # Raspberry Pi 3B+ (192.168.40.31)
│       └── 4g-proxy/      # Configuración de proxies salientes 4G
└── shared/
    ├── registry/          # Docker Registry privado autoalojado
    └── cloudflare/        # Configuración de tunnels y reglas de DNS
```

---

## 🌐 Detalle de Entornos y Componentes

### 1. `clusters/maria/` (Grupo Hereda)
* **Topología:** Cluster Docker Swarm formado por nodos `maria001`, `maria002` y `maria003`.
* **Configuración:** Ficheros Compose preparados para Swarm (`deploy.mode: replicated`).
* **Subdirectorios:**
  * `nginx-proxy/`: Ingress reverse proxy y gestión de certificados SSL automáticos.
  * `mongodb/`: Servidores de bases de datos MongoDB de producción para Grupo Hereda con volúmenes persistentes y redes dedicadas.
  * `hereda-apps/`: Stacks de servicios internos y aplicaciones de gestión de Hereda.

### 2. `clusters/quimera/` (Mood Robotics)
* **Topología:** Cluster Docker Swarm formado por nodos `mood001`, `mood003` y `mood999`.
* **Configuración:** Stacks de producción Node.js expuestos mediante Nginx Proxy Web hacia Cloudflare y DonDominio.
* **Subdirectorios:**
  * `core-services/`: Despliegue de aplicaciones y microservicios:
    * `1-tool.com`
    * `paypirus.com`
    * `cvic.uk`
    * `moodrobotics.com`
  * `databases/`: Instancias de MongoDB en Swarm con alta disponibilidad y persistencia.

### 3. `standalone/dragon/` (Servidor `mood100`)
* **Hardware:** HP ProLiant DL580 Gen9 + NVIDIA GeForce RTX 5060 Ti.
* **Software/Drivers:** Drivers NVIDIA 595.71.05 / CUDA 13.2 con NVIDIA Container Toolkit.
* **Modo:** Docker Compose Standalone.
* **Subdirectorios:**
  * `gpu-workloads/`: Stacks con runtime NVIDIA (`deploy.resources.reservations.devices`) para inferencia, LLMs (vLLM / Ollama) y aceleración por GPU.

### 4. `standalone/shadow/` (MiniPC Mercedes)
* **Red:** IP estática `10.90.0.21`, comunicada con la oficina mediante ruta estática Mikrotik (`10.90.0.0/24 via 192.168.40.1`).
* **Modo:** Docker Compose Standalone.
* **Subdirectorios:**
  * `home-services/`: Servicios locales de la sede, agentes de sincronización y tareas de backup.

### 5. `proxy/smith/` (Raspberry Pi 3B+)
* **Red:** IP `192.168.40.31`.
* **Hardware:** Raspberry Pi 3B+ con módem USB 4G Orange.
* **Subdirectorios:**
  * `4g-proxy/`: Contenedores proxy (Squid / Privoxy) y scripts para balancear y enrutar peticiones salientes a través de la interfaz 4G.

### 6. `shared/registry/`
* **Función:** Docker Registry privado v2 autoalojado.
* **Flujo CI/CD:** El pipeline de CI compila y sube las imágenes a este registro antes de que Portainer las despliegue en los clusters.

### 7. `shared/cloudflare/`
* **Función:** Túneles de Cloudflare (`cloudflared`) y mapeo de dominios/DNS para exposición segura sin apertura de puertos entrantes innecesarios.

---

## 🚀 Despliegue con Portainer GitOps

Para desplegar o actualizar cualquier stack desde Portainer:

1. Ve a **Stacks** > **Add stack** (o edita un stack existente).
2. Selecciona **Build method: Repository**.
3. Configura:
   * **Repository URL:** `https://github.com/moodrobotics/infrastructure.git`
   * **Repository reference:** `refs/heads/main`
   * **Compose path:** Ruta relativa al stack deseado. Por ejemplo:
     * Quimera Core Services: `clusters/quimera/core-services/docker-compose.yml`
     * Maria Ingress: `clusters/maria/nginx-proxy/docker-compose.yml`
     * Dragon GPU: `standalone/dragon/gpu-workloads/docker-compose.yml`
4. Habilita **Automatic updates** (Git polling o Webhook) según sea necesario.
