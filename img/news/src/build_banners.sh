#!/bin/bash
#SBATCH --job-name=banners
#SBATCH --partition=cpu
#SBATCH --account=longitudalllm_umass
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:15:00
#SBATCH --output=/home/sasifimran_umass/logs/banners_%j.out
export PATH=/home/sasifimran_umass/envs/texbuild/bin:$PATH
export TECTONIC_CACHE_DIR=/home/sasifimran_umass/.tectonic_cache
cd /home/sasifimran_umass/repos/bashlab.github.io/img/news/src || exit 1
RC=0
for f in cinc2026 jolt; do
  tectonic -X compile $f.tex --keep-logs 2>&1 | grep -iE "^error|undefined|warning" | head -10
  [ ${PIPESTATUS[0]} -ne 0 ] && RC=1
  [ -f $f.pdf ] || RC=1
done
for f in cinc2026 jolt; do
  [ -f $f.pdf ] && pdfinfo $f.pdf | grep -E 'Pages|Page size'
  # 1080x540 PNG: two device pixels per CSS pixel in the 270x140 card slot.
  pdftocairo -png -singlefile -scale-to-x 1080 -scale-to-y 540 $f.pdf ../$f || RC=1
done
exit $RC
