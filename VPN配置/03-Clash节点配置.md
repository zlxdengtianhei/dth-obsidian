# Clash 节点配置

**协议**: VLESS + TLS / VMess + WebSocket  
**适用客户端**: Clash Verge (macOS/Windows), Clash for Android

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
  sni: google.com
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
  sni: cloudflare.com
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
  sni: microsoft.com
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
  sni: apple.com
  client-fingerprint: safari
  skip-cert-verify: true
  alpn:
    - h2
    - http/1.1
```

### 5. WS-VMess-10000

```yaml
- name: "WS-VMess-10000"
  type: vmess
  server: 172.245.19.104
  port: 10000
  uuid: cbf3b4be-b3a8-4f70-bd28-988e72f7d46d
  alterId: 0
  cipher: auto
  network: ws
  ws-path: /v2ray
  skip-cert-verify: true
```

---

## 配置参数说明

### TLS 节点参数

| 参数 | 说明 |
|------|------|
| tls | 启用 TLS 加密 |
| servername/sni | TLS 握手时的服务器名称 |
| client-fingerprint | 客户端 TLS 指纹 (chrome/safari) |
| skip-cert-verify | 跳过证书验证 (自签名证书需要) |
| alpn | ALPN 协议列表 |

### WebSocket 节点参数

| 参数 | 说明 |
|------|------|
| network: ws | 使用 WebSocket 传输 |
| ws-path | WebSocket 路径 |
| cipher | 加密方式 (auto) |
| alterId | VMess 备用 ID (建议设为 0) |

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

## 已知问题

### cipher missing 错误

如果在测试配置时出现 "key 'cipher' missing" 错误:
- 确保 WebSocket 节点包含 `cipher: auto` 字段
- 删除订阅缓存后重新添加

### Microsoft 端口不通

如果 TLS-2096 端口不通:
- 可能是被防火墙阻断
- 尝试使用其他端口 (2053, 10443, 12086)
