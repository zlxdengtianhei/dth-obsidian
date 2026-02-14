# Troupe 语言网络功能指南

## 网络标识

Troupe 运行时连接到分布式 P2P 系统，每个运行时实例与一个具有唯一网络标识符的网络节点关联。

### 启动网络节点

```bash
# 使用指定的身份文件启动
$TROUPE/rt/troupe out.js --id=<path_to_id_file>

# 如果不提供参数，运行时会在启动时生成新的标识符
```

## 进程注册与查找

### 注册进程

使用 `register` 原语将进程绑定到一个名称：

```
let val _ = register("echo", self(), authority)
    fun loop() =
        let val _ = receive [
            hn ("ECHO", x, sender) => send(sender, ("REPLY", x)),
            hn _ => ()
        ]
        in loop()
        end
in loop()
end
```

注意：进程注册是系统级操作，需要顶级权威。

### 查找进程

使用 `whereis` 原语查找已注册的进程：

```
let val echo = 
    whereis("qmNRwNZACPciLS14cZFApwrCcAdbRAXYgztea9m5XwRe4z", "echo")
    val _ = send(echo, ("ECHO", "Hello", self()))
in receive [hn x => print x]
end
```

## 别名机制

别名允许避免在源代码中硬编码节点标识符：

```bash
# 启动时提供别名文件
$TROUPE/rt/troupe out.js --aliases=<path_to_aliases_file>
```

在程序中，别名字符串必须以 `@` 字符开头。别名文件包含别名字符串到网络标识符的映射。

## 节点信任级别

### 默认信任关系

默认情况下，Troupe 中的所有节点相互不信任，这意味着发送和接收到其他节点的信息被视为 `'{}'` 级别。

### 自定义信任级别

可以通过提供信任映射文件增加对特定节点的信任，文件包含节点的身份和它们的最大信任级别。

## 远程进程创建

### 启用远程进程创建

远程进程创建默认是禁用的，需要使用 `--rspawn=true` 标志启用：

```bash
$TROUPE/rt/troupe out.js --rspawn=true
```

### 创建远程进程

在远程节点上创建进程，`spawn` 接受一个参数元组，其中第一个参数是远程机器的节点标识符字符串：

```
spawn(("<node_identifier>", fn() => ...))
```

## 网络通信中的信息流监控

### 发送数据时的信息流检查

当级别为 `llabel` 的信息发送到信任级别为 `ltrust` 的远程节点时，运行时执行检查 `llabel ⊑ ltrust`，确保没有敏感信息流向可能违反机密性的节点。

由于无法在远程节点上强制执行信息流，节点之间的信任关系具有传递性。

### 接收数据时的标签调整

从信任级别为 `ltrust` 的远程节点接收信息时，标签为 `l` 的数据接收到实际级别 `ltrust ⊔ l`。这确保运行时不会被低信任级别(或没有信任)的节点意外污染。

### 权威值的跨节点传输

跨节点传输的权威值受到相同的约束和衰减规则的约束。

## 邮箱操作与范围接收

邮箱清除是约束范围接收的机制，防止通过邮箱结构编码秘密信息：

```
// 提高邮箱清除级别
raisembox(level)

// 降低邮箱清除级别
lowermbox(capability, authority)
```

邮箱清除相关约束：

1. 要在 pc 下以邮箱清除 `lclear` 接收区间 (l1, l2) 上的消息，必须满足 `l2 ⊑ pc ⊑ lclear`
2. 提高邮箱清除级别的程序点的 pc 标签影响区间的下界
3. 如果进程的邮箱清除在分支中提高，必须在到达分支的连接点之前将其降低回来

------

## 示例：Echo 服务

### 服务端

```
let val _ = register("echo", self(), authority)
    fun loop() =
        let val _ = receive [
            hn ("ECHO", x, sender) => send(sender, ("REPLY", x)),
            hn _ => ()
        ]
        in loop()
        end
in loop()
end
```

### 客户端

```
let val echo = 
    whereis("@server_alias", "echo")  // 使用别名
    val _ = send(echo, ("ECHO", "Hello", self()))
in receive [hn x => print x]
end
```

## 最佳实践

1. 使用别名机制避免硬编码节点标识符
2. 谨慎设置节点信任级别，遵循最小权限原则
3. 注意远程通信中的信息流约束
4. 在使用跨节点通信的权威值时特别小心

完整的 echo 示例（包括上述代码和生成标识符的脚本）可在 `$TROUPE/examples/network/echo` 找到。