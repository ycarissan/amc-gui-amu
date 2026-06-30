#!/usr/bin/env bash
#
# combine-manifest.sh — assemble les images PAR ARCHITECTURE deja publiees
# (:VERSION-amd64 et/ou :VERSION-arm64) en un manifeste multi-arch sous les tags
# mobiles :latest, :VERSION et :VERSION-trixie.
#
# A lancer :
#   - apres ./publish.sh sur la 1re machine  -> les tags mobiles pointent vers
#     la (les) arch(s) disponible(s) a cet instant ;
#   - de nouveau apres avoir publie l'autre arch (Mac) -> les tags mobiles
#     deviennent multi-arch (amd64 + arm64). Aucune reconstruction.
#
# Pre-requis : etre connecte a Docker Hub -> `docker login -u daverc31`
set -euo pipefail

IMAGE="${IMAGE:-daverc31/amc-amu-vnc}"
AMC_VERSION="${AMC_VERSION:-1.6.0}"

# Tags mobiles a (re)composer
MOVING=( "${IMAGE}:latest" "${IMAGE}:${AMC_VERSION}" "${IMAGE}:${AMC_VERSION}-trixie" )

# Detection des images par-architecture reellement presentes sur le registre
SOURCES=()
for ARCH in amd64 arm64; do
    SRC="${IMAGE}:${AMC_VERSION}-${ARCH}"
    if docker buildx imagetools inspect "${SRC}" >/dev/null 2>&1; then
        echo ">> Trouve  : ${SRC}"
        SOURCES+=( "${SRC}" )
    else
        echo ">> Absent  : ${SRC} (ignore)"
    fi
done

if [ "${#SOURCES[@]}" -eq 0 ]; then
    echo "Aucune image par-architecture trouvee. Lancez d'abord ./publish.sh." >&2
    exit 1
fi

# Arguments -t pour chaque tag mobile
TAGARGS=()
for t in "${MOVING[@]}"; do TAGARGS+=( -t "${t}" ); done

echo ">> Assemblage du manifeste a partir de : ${SOURCES[*]}"
docker buildx imagetools create "${TAGARGS[@]}" "${SOURCES[@]}"

echo ">> Verification du manifeste :latest :"
docker buildx imagetools inspect "${IMAGE}:latest"

if [ "${#SOURCES[@]}" -lt 2 ]; then
    echo ""
    echo "NB : une seule architecture est publiee pour l'instant."
    echo "    Les utilisateurs de l'autre architecture n'auront pas d'image"
    echo "    tant que vous n'aurez pas lance ./publish.sh sur la machine"
    echo "    correspondante, puis relance ./combine-manifest.sh."
fi
