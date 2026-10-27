# DeepKey 用户说明（GitHub Pages）

- `docs/index.html`：安装说明
- `docs/setup.html`：配网页（与 deepkey-relay/deepkey-setup.html 相同，已预填服务器 43.129.168.123:9331）
- `docs/.nojekyll`：让 Pages 原样发布，不经过 Jekyll

发布：仓库 Settings → Pages → Source 选 `Deploy from a branch`，分支 `main`，目录 `/docs`。

给用户的链接：
- 说明：`https://<用户名>.github.io/<仓库名>/`
- 配网（预填绑定码）：`https://<用户名>.github.io/<仓库名>/setup.html?bind=<绑定码>`

更新配网页：改完 deepkey-relay/deepkey-setup.html 后复制过来，并把 PRESET.host 改成服务器 IP。
