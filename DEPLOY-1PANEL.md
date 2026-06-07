# 使用 1Panel 部署

本部署方式会把用户前台、管理后台和 Go API 构建进同一个应用容器，并启动一个仅供应用使用的 Redis。SQLite 数据库、上传文件、日志和 Redis 数据均保存在仓库目录下的 `data/` 中。

## 部署前先处理仓库中的数据库

当前仓库已经追踪了 `dujiao-next/db/` 内的 SQLite 数据库文件。若 GitHub 仓库是公开的，这些文件可能泄露用户、订单或配置数据。

在本地确认不再需要通过 Git 保存这些文件后，停止追踪并推送一次：

```bash
git rm --cached dujiao-next/db/dujiao.db dujiao-next/db/dujiao.db-shm dujiao-next/db/dujiao.db-wal
git add .gitignore
git commit -m "chore: stop tracking runtime database"
git push
```

这不会删除本地数据库，但无法清除 Git 历史中已经上传的旧版本。若里面有真实数据，应将仓库改为私有，轮换已泄露的密钥，并进一步清理 Git 历史。

## 1. 准备 VPS

在 1Panel 的应用商店安装：

- OpenResty
- Docker（若安装 1Panel 时已经安装，可跳过）

将域名解析到 VPS 公网 IP，并确认安全组或防火墙已开放 `80` 和 `443`。不要对公网开放 `18080` 或 `6379`。

## 2. 拉取仓库

在 1Panel 的终端中执行：

```bash
cd /opt
git clone https://github.com/disowning/dujiao-next.git
cd dujiao-next
cp .env.example .env
```

若仓库是私有仓库，需要使用 GitHub Deploy Key 或 Personal Access Token 拉取。

## 3. 设置密钥和管理员

执行三次下面的命令，每次复制不同的输出作为三个密钥：

```bash
openssl rand -hex 32
```

再执行一次生成初始管理员密码：

```bash
openssl rand -hex 16
```

然后在 1Panel 文件管理中编辑 `/opt/dujiao-next/.env`：

```dotenv
APP_SECRET_KEY=第一条随机值
JWT_SECRET=第二条随机值
USER_JWT_SECRET=第三条随机值
WEB_ADMIN_PATH=/一段不易猜到的后台路径
DJ_DEFAULT_ADMIN_USERNAME=admin
DJ_DEFAULT_ADMIN_PASSWORD=一个强管理员密码
```

`APP_SECRET_KEY` 一旦开始使用就不要更换，否则数据库内已加密的敏感配置可能无法解密。

## 4. 启动容器

可以在 1Panel 的「容器」->「编排」中创建编排，路径选择 `/opt/dujiao-next/compose.yaml`；也可以在终端执行：

```bash
cd /opt/dujiao-next
docker compose up -d --build
docker compose ps
docker compose logs --tail=100 app
```

健康检查：

```bash
curl http://127.0.0.1:18080/health
```

正常响应应包含 `"status":"ok"`。

## 5. 配置域名和 HTTPS

在 1Panel 的「网站」中创建反向代理网站：

- 主域名：你的商城域名，例如 `shop.example.com`
- 代理地址：`http://dujiao-next:8080`

然后在该网站的 HTTPS 设置中申请 Let's Encrypt 证书，并开启强制 HTTPS。

应用容器已加入 1Panel 自带的 `1panel-network`，因此 OpenResty 可以通过容器名访问它。不要删除该网络。`127.0.0.1:18080` 仅用于在 VPS 终端执行健康检查，不对公网开放。

访问地址：

- 商城前台：`https://shop.example.com/`
- 管理后台：`https://shop.example.com` 加上 `.env` 中的 `WEB_ADMIN_PATH`

首次登录后立即确认管理员账号可用，并妥善保存 `.env`。

## 更新和备份

更新：

```bash
cd /opt/dujiao-next
git pull
docker compose up -d --build
```

备份时至少保存：

- `/opt/dujiao-next/.env`
- `/opt/dujiao-next/data/`

可先停止服务再复制 SQLite 数据，以获得一致性最好的备份：

```bash
docker compose stop app
tar -czf /opt/dujiao-next-backup-$(date +%F).tar.gz .env data
docker compose start app
```
