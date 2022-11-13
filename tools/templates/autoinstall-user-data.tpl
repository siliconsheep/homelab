#cloud-config
autoinstall:
  version: 1
  apt:
    disable_components: []
    geoip: true
    preserve_sources_list: false
    primary:
    - arches:
      - amd64
      - i386
      uri: http://se.archive.ubuntu.com/ubuntu
    - arches:
      - default
      uri: http://ports.ubuntu.com/ubuntu-ports
  drivers:
    install: false
  identity:
    hostname: {{ .Hostname }}
    password: {{ .PasswordHash }}
    realname: K3S
    username: {{ .Username }}
  kernel:
    package: linux-generic
  keyboard:
    layout: us
    toggle: null
    variant: ''
  locale: en_US.UTF-8
  network:
    ethernets:
      eno1:
        addresses:
        - {{ .IP }}
        gateway4: {{ .Gateway }}
        nameservers:
          addresses:
          - {{ .DNS }}
          search:
          - {{ .SearchDomain }}
    version: 2
    wifis: {}
  ssh:
    allow-pw: true
    authorized-keys:
    - '{{ .SSHPublicKey }}'
    install-server: true
  storage:
    config:
    - type: disk
      id: ssd-0
      match:
        ssd: yes
        size: smallest
      ptable: gpt
      wipe: superblock
      preserve: false
      name: ''
      grub_device: false 
    - type: partition
      id: partition-0
      device: ssd-0
      size: 1GB
      wipe: superblock
      flag: boot
      number: 1
      preserve: false
      grub_device: true
    - type: format
      id: format-0
      fstype: fat32
      volume: partition-0
      preserve: false
    - type: partition
      id: partition-1
      device: ssd-0
      size: 2GB
      wipe: superblock
      flag: ''
      number: 2
      preserve: false
      grub_device: false
    - type: format
      id: format-1
      fstype: ext4
      volume: partition-1
      preserve: false
    - type: partition
      id: partition-2
      device: ssd-0
      # size: 252783362048
      size: -1
      wipe: superblock
      flag: ''
      number: 3
      preserve: false
      grub_device: false
    - type: lvm_volgroup
      id: lvm_volgroup-0
      name: ubuntu-vg
      devices:
      - partition-2
      preserve: false
    - type: lvm_partition
      volgroup: lvm_volgroup-0
      id: lvm_partition-0
      name: lv-varlog
      size: 30GB
      wipe: superblock
      preserve: false
    - type: lvm_partition
      id: lvm_partition-1
      name: lv-root
      volgroup: lvm_volgroup-0
      #size: 220570058752B
      size: -1
      wipe: superblock
      preserve: false
    - type: format
      id: format-4
      volume: lvm_partition-0
      fstype: ext4    
      preserve: false
    - type: format
      id: format-5
      fstype: ext4
      volume: lvm_partition-1
      preserve: false
    - type: mount
      id: mount-1
      device: format-1
      path: /boot
    - type: mount
      id: mount-0
      device: format-0
      path: /boot/efi
    - type: mount
      id: mount-5
      device: format-5
      path: /
    - type: mount
      id: mount-4
      path: /var/log
      device: format-4
    - type: disk
      id: ssd-1
      match:
        ssd: yes
        size: largest
      ptable: gpt
      wipe: superblock
      preserve: false
      name: ''
      grub_device: false
    - type: partition
      id: partition-data
      device: ssd-1
      size: -1
      wipe: superblock
      number: 1
      preserve: false
      grub_device: false
    - type: format
      id: format-data
      volume: partition-data
      fstype: ext4
    - type: mount
      id: mount-data
      device: format-data
      path: /data
  updates: security
