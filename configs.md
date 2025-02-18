# Tableaux config AP4

### **1. Équipements Réseau :**

| **Type d'équipement**    | **Préfixe** | **Exemple de nommage**                       |
| ------------------------ | ----------- | -------------------------------------------- |
| **Routeur**              | RTR         | **RTR68COL02** (Routeur #2, Colmar, 68)      |
| **Routeur Téléphone IP** | VIR         | **VIR68COL01** (Routeur VoIP #1, Colmar, 68) |
| **Firewall**             | FRW         | **FRW68COL01** (Firewall #1, Colmar, 68)     |
| **Switch**               | SWT         | **SWT68COL02** (Switch #2, Colmar, 68)       |
| **Switch Téléphone IP**  | SWV         | **SWV68COL01** (Switch VoIP #1, Colmar, 68)  |

---

### **2. Équipements Informatiques :**

| **Type d'équipement** | **Préfixe** | **Exemple de nommage**                       |
| --------------------- | ----------- | -------------------------------------------- |
| **Laptop**            | LTP         | **LTP68COL05** (Laptop #5, Colmar, 68)       |
| **Tablette**          | TAB         | **TAB68COL03** (Tablette #3, Colmar, 68)     |
| **Ordinateur**        | PDT         | **PDT68COL12** (Ordinateur #12, Colmar, 68)  |
| **Imprimante**        | PRN         | **PRN68COL04** (Imprimante #4, Colmar, 68)   |
| **Télévision**        | TLV         | **TLV68COL02** (Télévision #2, Colmar, 68)   |
| **Téléphone IP**      | TEL         | **TEL68COL08** (Téléphone IP #8, Colmar, 68) |
| **Serveur**           | SRV         | **SRV68COL01** (Serveur #1, Colmar, 68)      |

---

### **3. Machines Virtuelles :**

| **Type d'équipement**                    | **Préfixe** | **Exemple de nommage**                      |
| ---------------------------------------- | ----------- | ------------------------------------------- |
| **Machine Virtuelle (Logiciel)**         | VML         | **VML68COL01** (VM Logiciel #1, Colmar, 68) |
| **Machine Virtuelle (Web)**              | VMW         | **VMW68COL02** (VM Web #2, Colmar, 68)      |
| **Machine Virtuelle (Active Directory)** | VAD         | **VAD68COL01** (VM AD #1, Colmar, 68)       |
| **Machine Virtuelle (MECM)**             | VMC         | **VMC68COL01** (VM MECM #1, Colmar, 68)     |
| **Machine Virtuelle (Mail)**             | VMM         | **VMM68COL01** (VM Mail #1, Colmar, 68)     |
| **Machine Virtuelle (Antivirus)**        | VAV         | **VAV68COL01** (VM AV #1, Colmar, 68)       |

### **Tableau Réseau**

| **Équipement**          | **Nom**      | **Interface** | **Adresse IP** | **VLAN**                   | **Rôle**                  | **Sortie** |
| ----------------------- | ------------ | ------------- | -------------- | -------------------------- | ------------------------- | ---------- |
| **Routeur**             | RTR68COL01   | WAN (0/0)     | 10.126.78.46   | -                          | Connexion Internet FAI1   | -          |
|                         |              | LAN (1/0)     | 172.16.0.254   | -                          | Passerelle principale     | FRW68COL01 |
|                         |              | LAN (1/1)     | 172.16.0.254   | -                          | Passerelle principale     | FRW68COL02 |
|                         |              | LAN (1/2)     | 172.16.50.254  | 50                         | Passerelle VoIP           | SWV68COL01 |
|                         | RTR68COL02   | WAN (0/0)     | 10.54.146.8    | -                          | Connexion Internet FAI2   | -          |
|                         |              | LAN (1/0)     | 172.16.0.253   | -                          | Passerelle de secours     | FRW68COL01 |
|                         |              | LAN (1/1)     | 172.16.0.253   | -                          | Passerelle de secours     | FRW68COL02 |
|                         |              | LAN (1/2)     | 172.16.50.253  | 50                         | Passerelle VoIP secours   | SWV68COL01 |
| **Pare-feu**            | FRW68COL01   | WAN (0/0)     | 172.16.0.11    | -                          | Accès internet principale | -          |
|                         |              | WAN (0/1)     | 172.16.0.13    | -                          | Accès internet secours    | -          |
|                         |              | WAN - VIP     | 172.16.0.10    | -                          | Accès internet principale | -          |
|                         |              | WAN - VIP     | 172.16.0.20    | -                          | Accès internet secours    | -          |
|                         |              | VLAN          | 172.16.10.253  | 10                         | -                         |            |
|                         |              | VLAN - VIP    | 172.16.10.254  | 10                         | -                         | -          |
|                         |              | VLAN          | OpenVPN3       | 15                         | -                         | -          |
|                         |              | VLAN - VIP    | OpenVPN4       | 15                         | -                         | -          |
|                         |              | VLAN          | 172.16.30.253  | 30                         | -                         | -          |
|                         |              | VLAN - VIP    | 172.16.30.254  | 30                         | -                         | -          |
|                         |              | VLAN          | 172.16.60.253  | 60                         | -                         | -          |
|                         |              | VLAN - VIP    | 172.16.60.254  | 60                         | -                         | -          |
|                         |              | VLAN          | 172.16.90.253  | 90                         | -                         | -          |
|                         |              | VLAN - VIP    | 172.16.90.254  | 90                         | -                         | -          |
|                         |              | LAN (1/0)     | 172.16.1.253   | Trunk (10, 15, 30, 60, 90) | Connexion aux switches    | SWT68COL01 |
|                         |              | LAN - VIP     | 172.16.1.254   | Trunk (10, 15, 30, 60, 90) | Connexion aux switches    | SWT68COL01 |
|                         |              | PFSYNC (1/1)  | 10.0.0.1       | -                          | Synchro Firewall          | FRW68COL02 |
|                         |              | DMZ (1/2)     | OpenVPN4       | 15                         | Sécurité DMZ              | SRV68COL01 |
|                         | FRW68COL02   | WAN (0/0)     | 172.16.0.12    | -                          | Accès internet principale | -          |
|                         |              | WAN (0/1)     | 172.16.0.14    | -                          | Accès internet secours    | -          |
|                         |              | WAN - VIP     | 172.16.0.10    | -                          | Accès internet principale | -          |
|                         |              | WAN - VIP     | 172.16.0.20    | -                          | Accès internet secours    | -          |
|                         |              | VLAN          | 172.16.10.252  | 10                         | -                         |            |
|                         |              | VLAN - VIP    | 172.16.10.254  | 10                         | -                         | -          |
|                         |              | VLAN          | OpenVPN2       | 15                         | -                         | -          |
|                         |              | VLAN - VIP    | OpenVPN4       | 15                         | -                         | -          |
|                         |              | VLAN          | 172.16.30.252  | 30                         | -                         | -          |
|                         |              | VLAN - VIP    | 172.16.30.254  | 30                         | -                         | -          |
|                         |              | VLAN          | 172.16.60.252  | 60                         | -                         | -          |
|                         |              | VLAN - VIP    | 172.16.60.254  | 60                         | -                         | -          |
|                         |              | VLAN          | 172.16.90.252  | 90                         | -                         | -          |
|                         |              | VLAN - VIP    | 172.16.90.254  | 90                         | -                         | -          |
|                         |              | LAN (1/0)     | 172.16.1.252   | Trunk (10, 15, 30, 60, 90) | Connexion aux switches    | SWT68COL02 |
|                         |              | LAN - VIP     | 172.16.1.254   | Trunk (10, 15, 30, 60, 90) | Connexion aux switches    | SWT68COL02 |
|                         |              | PFSYNC (1/1)  | 10.0.0.2       | -                          | Synchro Firewall          | FRW68COL01 |
|                         |              | DMZ (1/2)     | OpenVPN4       | 15                         | Sécurité DMZ              | SRV68COL01 |
| **Switch**              | SW68COL01    | UPLINK (0/0)  | 172.16.1.10    | Trunk                      | Switch principal          | -          |
|                         |              | TRUNK (0/1)   | -              | Trunk                      | Connexion inter-switch    | SWT68COL02 |
|                         |              | VLAN 10       | 172.16.10.1    | 10                         | Réseau Serveurs           | -          |
|                         |              | VLAN 30       | 172.16.30.1    | 30                         | Réseau Utilisateurs       | -          |
|                         |              | VLAN 60       | 172.16.60.1    | 60                         | Réseau Affichage TV       | -          |
|                         |              | VLAN 90       | 172.16.90.1    | 90                         | Réseau Imprimantes        | -          |
|                         | SW68COL02    | UPLINK (0/0)  | 172.16.1.20    | Trunk                      | Switch secondaire         | -          |
|                         |              | TRUNK (0/1)   | -              | Trunk                      | Connexion inter-switch    | SWT68COL01 |
|                         |              | VLAN 10       | 172.16.10.2    | 10                         | Réseau Serveurs           | -          |
|                         |              | VLAN 30       | 172.16.30.2    | 30                         | Réseau Utilisateurs       | -          |
|                         |              | VLAN 60       | 172.16.60.2    | 60                         | Réseau Affichage TV       | -          |
|                         |              | VLAN 90       | 172.16.90.2    | 90                         | Réseau Imprimantes        | -          |
| **Serveurs**            | SRV68COL01   | LAN           | 172.16.15.10   | 15                         | Serveur DMZ               | -          |
|                         |              | LAN           | 172.16.15.11   | 15                         | Serveur DMZ               | -          |
|                         | SRV68COL02   | LAN           | 172.16.10.10   | 10                         | Serveur                   | -          |
|                         |              | LAN           | 172.16.10.11   | 10                         | Serveur                   | -          |
| **Machines Virtuelles** | VML68COL01   | -             | 172.16.15.20   | 15                         | VM Ebrigade               | -          |
|                         | VAV68COL01   | -             | 172.16.10.15   | 10                         | VM Elastic Security       | -          |
|                         | VAD68COL01   | -             | 172.16.10.20   | 10                         | VM AD DS/DHCP             | -          |
|                         | VAD68COL02   | -             | 172.16.10.21   | 10                         | VM AD DS/DHCP             | -          |
|                         | VMC68COL01   | -             | 172.16.10.30   | 10                         | VM MECM                   | -          |
|                         | VMM68COL01   | -             | 172.16.10.40   | 10                         | VM Stalwart               | -          |
|                         | VML68COL02   | -             | 172.16.10.50   | 10                         | VM Grafana                | -          |
|                         | VML68COL03   | -             | 172.16.10.60   | 10                         | VM Tvheadend              | -          |
| **Postes de travail**   | VLAN 30 DHCP | -             | 172.16.30.0/24 | 30                         | Réseau Utilisateurs       | -          |
| **Téléphonie IP**       | VLAN 50 DHCP | -             | 172.16.50.0/24 | 50                         | Réseau Téléphones IP      | -          |
| **Télévision**          | VLAN 60 DHCP | -             | 172.16.60.0/24 | 60                         | Réseau Affichage TV       | -          |
| **Imprimantes**         | VLAN 90 DHCP | -             | 172.16.90.0/24 | 90                         | Réseau Imprimantes        | -          |

### Pare-feu

| **Source**      | **Port Source** | **Destination** | **Port Destination** | **Protocole** | **Action** | **Description**                           |
| --------------- | --------------- | --------------- | -------------------- | ------------- | ---------- | ----------------------------------------- |
| WAN             | *               | 172.16.15.20    | TCP/443              | TCP           | Autoriser  | Accès à Ebrigade depuis Internet          |
| WAN             | *               | 172.16.15.20    | TCP/80               | TCP           | Autoriser  | Accès HTTP à Ebrigade (redirection HTTPS) |
| WAN             | *               | OpenVPN         | UDP/1194             | UDP           | Autoriser  | Accès OpenVPN depuis Internet             |
| WAN             | *               | OpenVPN         | TCP/443              | TCP           | Autoriser  | Accès OpenVPN SSL depuis Internet         |
| 172.16.30.0/24  | *               | 172.16.10.20-21 | TCP/53, UDP/53       | TCP, UDP      | Autoriser  | DNS des utilisateurs vers AD              |
| 172.16.30.0/24  | *               | 172.16.10.20-21 | TCP/88               | TCP           | Autoriser  | Kerberos pour les utilisateurs            |
| 172.16.30.0/24  | *               | 172.16.10.20-21 | TCP/389              | TCP           | Autoriser  | LDAP pour les utilisateurs                |
| 172.16.30.0/24  | *               | 172.16.10.20-21 | TCP/636              | TCP           | Autoriser  | LDAPS pour les utilisateurs               |
| 172.16.30.0/24  | *               | 172.16.90.0/24  | TCP/631              | TCP           | Autoriser  | Impression IPP                            |
| 172.16.30.0/24  | *               | 172.16.90.0/24  | TCP/9100             | TCP           | Autoriser  | Impression brute                          |
| 172.16.30.0/24  | *               | 172.16.10.40    | TCP/25,587           | TCP           | Autoriser  | SMTP vers Stalwart                        |
| 172.16.30.0/24  | *               | 172.16.10.40    | TCP/143,993          | TCP           | Autoriser  | IMAP vers Stalwart                        |
| 172.16.60.0/24  | *               | 172.16.10.60    | TCP/9981-9982        | TCP           | Autoriser  | Accès Tvheadend                           |
| 172.16.10.30    | *               | 172.16.30.0/24  | TCP/445              | TCP           | Autoriser  | MECM vers les postes de travail           |
| 172.16.10.15    | *               | 172.16.30.0/24  | TCP/8080             | TCP           | Autoriser  | Surveillance Elastic Security             |
| 172.16.10.50    | *               | Tout Interne    | TCP/9100             | TCP           | Autoriser  | Surveillance Grafana                      |
| 172.16.10.0/24  | *               | 172.16.10.0/24  | *                    | Tout          | Autoriser  | Communication inter-serveurs              |
| 172.16.15.0/24  | *               | 172.16.15.0/24  | *                    | Tout          | Autoriser  | Communication inter-DMZ                   |
| 172.16.15.0/24  | *               | 172.16.10.20-21 | TCP/53, UDP/53       | TCP, UDP      | Autoriser  | DNS de la DMZ vers AD                     |
| 172.16.30.0/24  | *               | 172.16.10.30    | TCP/8530-8531        | TCP           | Autoriser  | Communication client WSUS/MECM            |
| 172.16.10.20-21 | *               | 172.16.30.0/24  | *                    | Tout          | Autoriser  | AD vers les postes de travail             |
| 172.16.30.0/24  | *               | 172.16.10.50    | TCP/3000             | TCP           | Autoriser  | Accès à Grafana                           |
| 172.16.10.0/24  | *               | 172.16.15.0/24  | TCP/443              | TCP           | Autoriser  | Accès serveur aux services DMZ            |
| 172.16.90.0/24  | *               | 172.16.10.20-21 | TCP/53, UDP/53       | TCP, UDP      | Autoriser  | DNS pour les imprimantes                  |
| 172.16.30.0/24  | UDP/68          | 172.16.10.20-21 | UDP/67               | UDP           | Autoriser  | DHCP pour les postes de travail           |
| 172.16.60.0/24  | UDP/68          | 172.16.10.20-21 | UDP/67               | UDP           | Autoriser  | DHCP pour les écrans TV                   |
| 172.16.90.0/24  | UDP/68          | 172.16.10.20-21 | UDP/67               | UDP           | Autoriser  | DHCP pour les imprimantes                 |
| OpenVPN         | *               | 172.16.10.20-21 | TCP/53, UDP/53       | TCP, UDP      | Autoriser  | DNS pour les clients VPN                  |
| OpenVPN         | *               | 172.16.10.20-21 | TCP/88,389,636       | TCP           | Autoriser  | Authentification AD pour les clients VPN  |
| OpenVPN         | *               | Tout Interne    | *                    | Tout          | Autoriser  | Accès passerelle VPN aux réseaux internes |
| 172.16.10.0/24  | *               | WAN             | TCP/80,443           | TCP           | Autoriser  | Mises à jour serveur et services externes |
| 172.16.15.0/24  | *               | WAN             | TCP/80,443           | TCP           | Autoriser  | Mises à jour DMZ et services externes     |
| 172.16.30.0/24  | *               | WAN             | TCP/80,443           | TCP           | Autoriser  | Internet HTTP(S)                          |
| Tout            | *               | Tout            | *                    | Tout          | Refuser    | Refuser tout autre trafic                 |
