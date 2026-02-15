# Shadowrocket 节点配置

**协议**: VLESS + Reality  
**适用客户端**: Shadowrocket (iOS)

---

## 节点链接

### 1. Cloudflare 443
```
vless://cbf3b4be-b3a8-4f70-bd28-988e72f7d46d@172.245.19.104:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.cloudflare.com&fp=chrome&pbk=vQHFkbVqbMIHkMSIAKiaHK5PwIiIlJmKZPbWTtZqBX8&sid=590b3501&type=tcp&headerType=none#SR-Cloudflare-443
```

### 2. Microsoft 8443
```
vless://cbf3b4be-b3a8-4f70-bd28-988e72f7d46d@172.245.19.104:8443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.microsoft.com&fp=chrome&pbk=vQHFkbVqbMIHkMSIAKiaHK5PwIiIlJmKZPbWTtZqBX8&sid=590b3501&type=tcp&headerType=none#SR-Microsoft-8443
```

### 3. Google 2053
```
vless://cbf3b4be-b3a8-4f70-bd28-988e72f7d46d@172.245.19.104:2053?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.google.com&fp=chrome&pbk=vQHFkbVqbMIHkMSIAKiaHK5PwIiIlJmKZPbWTtZqBX8&sid=590b3501&type=tcp&headerType=none#SR-Google-2053
```

### 4. Apple 2086
```
vless://cbf3b4be-b3a8-4f70-bd28-988e72f7d46d@172.245.19.104:2086?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.apple.com&fp=safari&pbk=vQHFkbVqbMIHkMSIAKiaHK5PwIiIlJmKZPbWTtZqBX8&sid=590b3501&type=tcp&headerType=none#SR-Apple-2086
```

---

## 配置参数说明

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

---

## 添加方法

1. 打开 Shadowrocket
2. 点击右上角 "+"
3. 选择 "类型" → "VLESS"
4. 复制上述链接粘贴到 "URL" 栏
5. 点击完成

---

## 注意事项

- Reality 协议需要有效的 SNI 和公钥配置
- 不同端口对应不同的目标网站 SNI
- flow: xtls-rprx-vision 提供更强的流量混淆
