#!/bin/bash
# 병의원 AI 데스크 서비스소개서 → GitHub Pages 게시 스크립트
# 사용: ./publish.sh <owner/repo>
set -u
REPO="${1:-bigyes13-beep/hospital-ai-desk}"
cd "$(dirname "$0")" || exit 1

echo "== 1. 리포 접근 확인: $REPO"
gh api "repos/$REPO" --jq '.full_name, .private, .default_branch, .has_pages' 2>&1

echo "== 2. 푸시"
git remote remove origin 2>/dev/null
git remote add origin "https://github.com/$REPO.git"
if git push -u origin main 2>&1; then
  echo "PUSH_OK"
else
  echo "PUSH_FAILED"
  exit 1
fi

echo "== 3. Pages 활성화 시도"
gh api -X POST "repos/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" 2>&1 | head -20
echo "== 4. Pages 상태"
gh api "repos/$REPO/pages" --jq '{status,html_url,build_type}' 2>&1 | head -20
