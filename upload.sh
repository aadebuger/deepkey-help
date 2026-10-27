#!/usr/bin/env bash
# 把 docs/ 发布到 GitHub Pages(第一次自动建仓库、开 Pages; 以后再运行就是更新)
#
#   ./upload.sh                 # 默认仓库名 deepkey-help, 提交说明 "更新说明"
#   ./upload.sh "改了常见问题"   # 自定义提交说明
#   REPO=deepkey-docs ./upload.sh
#
# 需要: git, gh(brew install gh; gh auth login)
set -euo pipefail

REPO="${REPO:-deepkey-help}"
MSG="${1:-更新说明}"
cd "$(dirname "$0")"

die() { echo "× $*" >&2; exit 1; }

command -v git >/dev/null || die "没装 git"
command -v gh  >/dev/null || die "没装 gh: brew install gh 然后 gh auth login"
gh auth status >/dev/null 2>&1 || die "gh 还没登录: gh auth login"
[ -f docs/index.html ] || die "当前目录下没有 docs/index.html, 请在 deepkey-pages 目录里运行"

OWNER="$(gh api user --jq .login)"
FULL="$OWNER/$REPO"
echo "▶ 仓库: $FULL"

# 1. 本地 git 仓库
if [ ! -d .git ]; then
  git init -q -b main
  echo "  已初始化本地仓库"
fi
git add -A
if git diff --cached --quiet; then
  echo "  没有新的改动"
else
  git commit -q -m "$MSG"
  echo "  已提交: $MSG"
fi

# 2. 远程仓库: 没有就建(必须 public, 免费账号的私有仓库不能开 Pages), 有就推送
if gh repo view "$FULL" >/dev/null 2>&1; then
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$FULL.git"
  git push -q -u origin main
  echo "  已推送"
else
  gh repo create "$REPO" --public --source . --remote origin --push >/dev/null
  echo "  已创建仓库并推送"
fi

# 3. Pages: 没开就开(main 分支 /docs 目录)
if gh api "repos/$FULL/pages" >/dev/null 2>&1; then
  echo "  Pages 已开启"
else
  gh api -X POST "repos/$FULL/pages" -f "source[branch]=main" -f "source[path]=/docs" >/dev/null
  echo "  已开启 Pages(main /docs)"
fi

# 4. 等发布完成(最多约 3 分钟)
printf "  等待发布"
for _ in $(seq 1 36); do
  st="$(gh api "repos/$FULL/pages" --jq .status 2>/dev/null || true)"
  [ "$st" = "built" ] && break
  [ "$st" = "errored" ] && { echo; die "发布失败, 到 https://github.com/$FULL/actions 看原因"; }
  printf "."; sleep 5
done
echo

URL="$(gh api "repos/$FULL/pages" --jq .html_url 2>/dev/null || echo "https://$OWNER.github.io/$REPO/")"
echo "✓ 安装说明: $URL"
echo "✓ 配网页:   ${URL%/}/setup.html?bind=<绑定码>"
[ "${st:-}" = "built" ] || echo "  (还在发布中, 一两分钟后刷新即可)"
