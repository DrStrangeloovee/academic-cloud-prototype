# Proxmox Host Setup

Initial setup steps before the first `tofu apply`.

---

## 1. Create API token

In the Proxmox Web-UI:

| Field | Value |
|---|---|
| User | `acp@pve` (see next step) |
| Token ID | `acp-token` |
| Privilege Separation | Checked |

### Create user

On the Proxmox host via SSH:

```
pveum user add acp@pve --comment "acp"
pveum role add ACPRole --privs \
  "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk \
   VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options \
   VM.Audit VM.PowerMgmt VM.GuestAgent.Audit Sys.Audit Datastore.AllocateSpace Datastore.Audit \
   SDN.Use VM.GuestAgent.Audit"
pveum aclmod / -user acp@pve -role ACPRole
pveum user token add acp@pve acp-token
pveum aclmod -token 'acp@pve!acp-token' -role ACPRole
```

Copy the token (`acp@pve!acp-token=xxxxxxxx-...`) into `terraform/terraform.tfvars`.

---

## 2. Create Cloud-Init template (VM-ID 9000)

Create VM template on the host:

```bash
# Image herunterladen
wget -O /var/lib/vz/images/debian-13-generic-amd64.qcow2 \
  https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2

# Customizing for
qm create 9000 \
  --name debian-13-cloudinit \
  --memory 1024 \
  --net0 virtio,bridge=vmbr0 \
  --scsihw virtio-scsi-single

# Disk importieren 
qm importdisk 9000 /var/lib/vz/images/debian-13-generic-amd64.qcow2 local-lvm

# Disk als scsi0 mounten
qm set 9000 \
  --scsi0 local-lvm:vm-9000-disk-0,discard=on,iothread=1 \
  --boot c \
  --bootdisk scsi0

# Cloud-Init-Drive hinzufügen
qm set 9000 --ide2 local-lvm:cloudinit

# Serial-Konsole für noVNC Debugging
qm set 9000 --serial0 socket --vga serial0

# QEMU Guest Agent aktivieren
qm set 9000 --agent enabled=1,type=virtio

# Start VM, install qemu-guest-agent and set temporary credentials
qm set 9000 --ciuser root --cipassword changeme
qm start 9000

# Wait for cloud-init process to finish
qm wait 9000

# Remove temporary credentials
qm set 9000 --delete ciuser --delete cipassword

# Create template
qm template 9000
```

### Wichtig
- Das Debian Generic Cloud Image enthält `qemu-guest-agent` **nicht** –
  der manuelle Installationsschritt oben ist daher zwingend erforderlich.
- Alternativ: Proxmox bietet `virt-customize` (aus `libguestfs-tools`), damit
  lässt sich der Agent ohne VM-Start direkt ins qcow2-Image installieren:
  ```bash
  apt-get install -y libguestfs-tools
  virt-customize -a /var/lib/vz/images/debian-12-generic-amd64.qcow2 \
    --install qemu-guest-agent \
    --run-command 'systemctl enable qemu-guest-agent'
  # Danach erst qm importdisk ausführen
  ```
- Die VM-ID `9000` muss mit `template_vm_id` in `terraform.tfvars` übereinstimmen.

---

## 3. Netzwerk-Voraussetzung

Die Spike-VM bekommt via DHCP eine IP auf `vmbr0`. Stelle sicher, dass der
DHCP-Server in deinem Heimnetz Adressen auf diesem Bridge-Interface verteilt
(Standardfall wenn `vmbr0` mit dem LAN-Port verbunden ist).

---

## 4. Bridge `vmbr1` (Lab-Netz, ohne Uplink)

Für das Phase-2-Pentest-Lab wird eine **zweite Linux-Bridge** auf dem Proxmox-Host
benötigt, die keinen Uplink ins LAN hat. Ihre Aufgabe: ein Layer-2-Pfad zwischen
Attacker- und Target-VM bereitstellen, ohne dass das Target Außenkontakt bekommt.

**Begründung gegen VLAN auf `vmbr0`:** Isolation per Konstruktion (kein
physikalischer Pfad nach außen) ist stärker als Isolation per Konfiguration
(VLAN-Tagging müsste auf jedem Hop korrekt sein, VLAN-Hopping ist im
Pentest-Kontext ein realer Angriffsvektor). Zusätzlich reproduzierbar auf jeder
Proxmox-Installation, unabhängig von der Switch-Hardware.

### Bridge anlegen

Auf dem Proxmox-Host als root:

```bash
cat >> /etc/network/interfaces <<'EOF'

auto vmbr1
iface vmbr1 inet manual
    bridge-ports none
    bridge-stp off
    bridge-fd 0
#  Lab-Netz fuer Phase 2 (Pentest-Lab). Bewusst kein Uplink.
EOF

ifreload -a
```

`ifreload -a` ist Teil von `ifupdown2` (auf Proxmox vorinstalliert) und lädt die
Netzwerkkonfiguration neu, ohne den Hypervisor durchzustarten.

### Verifizieren der Bridge

```bash
ip link show vmbr1
# Erwartung: state UP, NO-CARRIER (Bridge hat keinen Uplink, das ist gewollt)

bridge link show
# Erwartung: vmbr1 ohne angeschlossene Ports
```

### Hinweise

- Die Bridge wird **bewusst nicht** von OpenTofu verwaltet, sondern persistent in
  `/etc/network/interfaces` definiert. Sie überlebt `tofu destroy` und steht
  beim nächsten `tofu apply` ohne Neuanlage zur Verfügung. Wäre die Bridge
  Tofu-managed, würde jeder Lab-Down sie löschen.
- IP-Routing/NAT zwischen `vmbr0` und `vmbr1` darf hier **nicht** konfiguriert
  werden — das würde der Isolation widersprechen.
- Sollte die Web-UI unter „System → Netzwerk" auf `vmbr1` einen „Pending"-Status
  zeigen, weil sie zur Laufzeit via `ifreload -a` aktiviert wurde, synchronisiert
  ein erneuter Klick auf „Apply Configuration" oder ein Host-Reboot den UI-State.

---

## 5. Verifizieren

```bash
# Auf dem Proxmox-Host:
pvesh get /nodes/<nodename>/qemu/9000/status/current
# Sollte type=template zurückgeben
```
