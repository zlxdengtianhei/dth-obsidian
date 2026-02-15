# Clash 节点配置

**协议**: VLESS + TLS / VLESS + WS + TLS  
**适用客户端**: Clash Verge (macOS/Windows), Clash for Android  
**最后更新**: 2026-02-15

---

## 订阅地址

```
http://172.245.19.104:8888/clash.yaml
```

---

## 节点配置详情

### 1. TLS-2053-Google

```yaml
- name: "TLS-2053-Google"
  type: vless
  server: 172.245.19.104
  port: 2053
  uuid: cbf3b4be-b3a8-4f70-bd28-988e72f7d46d
  network: tcp
  tls: true
  servername: google.com
  client-fingerprint: chrome
  skip-cert-verify: true
  alpn:
    - h2
    - http/1.1
```

### 2. TLS-10443-Cloudflare

```yaml
- name: "TLS-10443-Cloudflare"
  type: vless
  server: 172.245.19.104
  port: 10443
  uuid: cbf3b4be-b3a8-4f70-bd28-988e72f7d46d
  network: tcp
  tls: true
  servername: cloudflare.com
  client-fingerprint: chrome
  skip-cert-verify: true
  alpn:
    - h2
    - http/1.1
```

### 3. TLS-2096-Microsoft

```yaml
- name: "TLS-2096-Microsoft"
  type: vless
  server: 172.245.19.104
  port: 2096
  uuid: cbf3b4be-b3a8-4f70-bd28-988e72f7d46d
  network: tcp
  tls: true
  servername: microsoft.com
  client-fingerprint: chrome
  skip-cert-verify: true
  alpn:
    - h2
    - http/1.1
```

### 4. TLS-12086-Apple

```yaml
- name: "TLS-12086-Apple"
  type: vless
  server: 172.245.19.104
  port: 12086
  uuid: cbf3b4be-b3a8-4f70-bd28-988e72f7d46d
  network: tcp
  tls: true
  servername: apple.com
  client-fingerprint: safari
  skip-cert-verify: true
  alpn:
    - h2
    - http/1.1
```

### 5. WS-TLS-12000

```yaml
- name: "WS-TLS-12000"
  type: vless
  server: 172.245.19.104
  port: 12000
  uuid: cbf3b4be-b3a8-4f70-bd28-988e72f7d46d
  network: ws
  tls: true
  servername: cloudflare.com
  client-fingerprint: chrome
  skip-cert-verify: true
  alpn:
    - http/1.1
  ws-opts:
    path: /clash-ws
```

---

## 配置参数说明

### TLS 节点参数

| 参数 | 说明 |
|------|------|
| tls | 启用 TLS 加密 |
| servername | TLS 握手时的服务器名称 |
| client-fingerprint | 客户端 TLS 指纹 (chrome/safari) |
| skip-cert-verify | 跳过证书验证 (自签名证书需要) |
| alpn | ALPN 协议列表 |

### WebSocket + TLS 节点参数

| 参数 | 说明 |
|------|------|
| network: ws | 使用 WebSocket 传输 |
| ws-opts.path | WebSocket 路径 (/clash-ws) |
| tls: true | WebSocket 运行在 TLS 之上 |

---

## 添加方法

### Clash Verge (macOS/Windows)

1. 打开 Clash Verge
2. 进入 "配置" 页面
3. 点击 "添加"
4. 选择 "订阅 URL"
5. 输入: `http://172.245.19.104:8888/clash.yaml`
6. 点击确定

### 强制刷新订阅

如果配置未更新:
1. 删除现有订阅配置
2. 重新添加订阅 URL

---

## 注意事项

- 所有节点出站流量经 Cloudflare WARP 转发
- 出口 IP 为 Cloudflare (104.28.209.x, AS13335)，非 RackNerd 数据中心 IP
- WS+TLS 节点使用 VLESS 协议 (非旧版 VMess)，更安全更高效
- 旧的 VMess WS 节点 (端口 10000) 已移除
