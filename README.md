# Docker Linux RDP

This is a custom docker image based on Debian, with `xrdp` and `ssh` server setup.

In a container is created custom user abc:abc, but you can change its password by following command

```sh
docker exec -it container_name passwd abc
```
