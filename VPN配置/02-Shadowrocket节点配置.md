# Shadowrocket 节点配置

**协议**: VLESS + Reality / VLESS + WS + TLS  
**适用客户端**: Shadowrocket (iOS)  
**最后更新**: 2026-02-15

---

## Reality 节点链接 (4个)

### 1. SR-Cloudflare-443
```
vless://cbf3b4be-b3a8-4f70-bd28-988e72f7d46d@172.245.19.104:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.cloudflare.com&fp=chrome&pbk=vQHFkbVqbMIHkMSIAKiaHK5PwIiIlJmKZPbWTtZqBX8&sid=590b3501&type=tcp&headerType=none#SR-Cloudflare-443
```

### 2. SR-Microsoft-8443
```
vless://cbf3b4be-b3a8-4f70-bd28-988e72f7d46d@172.245.19.104:8443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.microsoft.com&fp=chrome&pbk=vQHFkbVqbMIHkMSIAKiaHK5PwIiIlJmKZPbWTtZqBX8&sid=590b3501&type=tcp&headerType=none#SR-Microsoft-8443
```

### 3. SR-Google-2083
```
vless://cbf3b4be-b3a8-4f70-bd28-988e72f7d46d@172.245.19.104:2083?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.google.com&fp=chrome&pbk=vQHFkbVqbMIHkMSIAKiaHK5PwIiIlJmKZPbWTtZqBX8&sid=590b3501&type=tcp&headerType=none#SR-Google-2083
```

### 4. SR-Apple-2087
```
vless://cbf3b4be-b3a8-4f70-bd28-988e72f7d46d@172.245.19.104:2087?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.apple.com&fp=safari&pbk=vQHFkbVqbMIHkMSIAKiaHK5PwIiIlJmKZPbWTtZqBX8&sid=590b3501&type=tcp&headerType=none#SR-Apple-2087
```

---

## WebSocket + TLS 节点链接 (1个)

### 5. SR-WS-TLS-11000
```
vless://cbf3b4be-b3a8-4f70-bd28-988e72f7d46d@172.245.19.104:11000?encryption=none&security=tls&sni=cloudflare.com&fp=chrome&type=ws&path=/sr-ws&allowInsecure=1#SR-WS-TLS-11000
```

---

## 配置参数说明

### Reality 节点参数

| 参数 | 值 | 说明 |
|------|-----|------|
| encryption | none | 加密方式 |
| flow | xtls-rprx-vision | VLESS Vision 流量混淆 |
| security | reality | 使用 Reality 协议 |
| sni | 目标网站域名 | Server Name Indication |
| fp | chrome/safari | 客户端指纹 |
| pbk | vQHFkbVqbMIHkMSIAKiaHK5PwIiIlJmKZPbWTtZqBX8 | Reality 公钥 |
| sid | 590b3501 | Short ID |
| type | tcp | 传输类型 |

### WebSocket + TLS 节点参数

| 参数 | 值 | 说明 |
|------|-----|------|
| security | tls | 使用 TLS 加密 |
| type | ws | WebSocket 传输 |
| path | /sr-ws | WebSocket 路径 |
| allowInsecure | 1 | 跳过证书验证 (自签名证书) |

---

## 添加方法

1. 打开 Shadowrocket
2. 点击右上角 "+"
3. 选择 "类型" → "VLESS"
4. 复制上述链接粘贴到 "URL" 栏
5. 点击完成

---

## 微信分流建议

如果使用 Reality 节点时微信提示"网络环境不佳"：

1. 全局路由设为 **"配置"** 模式
2. 在规则中添加：
   - `GEOIP,CN,DIRECT`
   - `USER-AGENT,WeChat*,DIRECT`
   - `USER-AGENT,MicroMessenger*,DIRECT`
3. 这样微信走直连，其余流量走代理

---

## 注意事项

- Reality 协议需要有效的 SNI 和公钥配置
- 不同端口对应不同的目标网站 SNI
- flow: xtls-rprx-vision 提供更强的流量混淆
- 所有出站流量经 WARP 转发，出口 IP 为 Cloudflare (非 RackNerd)
