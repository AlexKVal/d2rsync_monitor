# d2rsync monitor

It checks if rsync has been really done on all backup nodes

It's complementary to `d2rsync / d2rsync_node` utilities

### Usage

- fill in the `config.yml` with servers IPs
```yml
---
branches:
  name1: 10.0.0.2
  name2: 10.0.1.2
  name3: 10.0.3.2
```

- put `id_rsa` to the project root folder

- and run `get-state.cmd`
