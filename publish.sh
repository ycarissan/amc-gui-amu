#!/usr/bin/env bash
#
# publish.sh — build NATIF d'UNE architecture, puis push vers Docker Hub sous un
# tag suffixe par l'architecture (ex. :1.6.0-amd64). A lancer sur chaque machine :
#   - sur ce PC (Linux/amd64)        : ./publish.sh        (ou ./publish.sh amd64)
#   - plus tard sur le Mac (arm64)   : ./publish.sh        (ou ./publish.sh arm64)
# Puis assembler le manifeste multi-arch avec ./combine-manifest.sh
#
# Build NATIF = pas d'emulation QEMU => rapide. (L'ancienne approche multi-arch
# en une seule commande emulait l'arm64, d'ou la lenteur.)
#
# Pre-requis : etre connecte a Docker Hub -> `docker login -u daverc31`
set -euo pipefail

IMAGE="${IMAGE:-daverc31/amc-gui-amu}"
AMC_VERSION="${AMC_VERSION:-1.6.0}"
BUILDER="${BUILDER:-amcbuilder}"

# --- Architecture cible : argument explicite, sinon detectee depuis l'hote --
ARCH="${1:-$(uname -m)}"
case "${ARCH}" in
    x86_64|amd64)  ARCH="amd64"; PLATFORM="linux/amd64" ;;
    aarch64|arm64) ARCH="arm64"; PLATFORM="linux/arm64" ;;
    *) echo "Architecture non supportee : ${ARCH} (attendu amd64 ou arm64)" >&2; exit 1 ;;
esac

BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
VCS_REF="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
TAG="${IMAGE}:${AMC_VERSION}-${ARCH}"

echo ">> Build NATIF ${PLATFORM}"
echo ">> Tag publie : ${TAG}"

# --- Builder buildx (driver docker-container, requis pour --push) -----------
if ! docker buildx inspect "${BUILDER}" >/dev/null 2>&1; then
    echo ">> Creation du builder buildx '${BUILDER}' ..."
    docker buildx create --name "${BUILDER}" --use --bootstrap
else
    echo ">> Reutilisation du builder buildx '${BUILDER}' ..."
    docker buildx use "${BUILDER}"
fi

# --provenance=false : manifeste propre (1 seule entree d'arch), facilite
# l'assemblage ulterieur par combine-manifest.sh.
docker buildx build \
    --platform "${PLATFORM}" \
    -t "${TAG}" \
    --build-arg AMC_VERSION="${AMC_VERSION}" \
    --build-arg BUILD_DATE="${BUILD_DATE}" \
    --build-arg VCS_REF="${VCS_REF}" \
    --provenance=false \
    --push \
    .

echo ">> Publie : ${TAG}"
echo ">> Etape suivante : ./combine-manifest.sh (assemble les arches disponibles"
echo "   dans les tags :latest, :${AMC_VERSION}, :${AMC_VERSION}-trixie)"
