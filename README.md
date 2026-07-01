```
docker login -u daverc31                                  # authentification Docker Hub
docker run --privileged --rm tonistiigi/binfmt --install all   # QEMU, UNIQUEMENT si tu construis arm64 par émulation ici
bash ./publish.sh amd64      # build natif amd64 -> pousse :1.6.0-amd64
bash ./publish.sh arm64      # build arm64      -> pousse :1.6.0-arm64
bash ./combine-manifest.sh   # assemble les deux -> :latest / :1.6.0 / :1.6.0-trixie multi-arch
```
