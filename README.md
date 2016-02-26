# d2rsync monitor

WIP: it will check if rsync has been really done on all nodes

#### algo

- repeat for every server
- read via `ssh admin@server c:\d2rsync\config.yml nodes_up: []`

```
rsynced: e:\rsynced
nodes_up:
- User@10.0.31.231:/cygdrive/c/rsynced
```

then connect to each node and read the date of the latest link
and compare the link date with the current date.
