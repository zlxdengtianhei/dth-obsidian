# Troupe 语言快速指南

## 简介

Troupe 是一种动态类型的函数式编程语言，具有并发特性和信息流控制机制。本指南总结了 Troupe 语言的基本特性，帮助初学者快速上手。

## 基本特性

### 编译和运行程序

```bash
# 编译 Troupe 程序
$TROUPE/bin/troupec program.trp -o out.js

# 运行编译后的程序
$TROUPE/rt/troupe out.js --localonly

# 或使用简化脚本
local.sh program.trp
```

输出值的格式为 `值@安全标签%类型安全标签`，例如 `42@{}%{}`。

### 数据类型

- **Unit**: 单元类型，值为 `()`
- **Booleans**: 布尔类型，值为 `true` 或 `false`
- **Number**: 数字类型
- **String**: 字符串类型，使用双引号，如 `"hello, world"`
- **Tuple**: 元组类型，如 `("hello", (), true, 42)`
- **List**: 列表类型，空列表为 `[]`
- **Function**: 函数类型，通过 `fn x => e` 或 `let fun` 声明
- **Process Id**: 进程标识符
- **Label**: 安全标签
- **Authority**: 降级能力

### 基本操作

- 数字支持基本算术和比较操作
- 字符串支持比较和连接操作（使用 `^` 符号）
- 布尔运算：`andalso`（与）和 `orelse`（或）
- 列表构造：`::`

## 语言结构

### 条件表达式

```
if e0 then e1 else e2
```

### 模式匹配 (Case)

```
case e of
  pat_1 => e_1
  pat_2 => e_2
  ...
  pat_n => e_n
```

### 变量绑定 (Let)

```
let val x = 20
    val y = x + 2
in x + y
end
```

### 函数声明

```
let fun fib x =
    if x > 2 then fib (x - 1) + fib (x - 2)
    else 1
in fib 10
end
```

递归函数使用 `and` 关键字：

```
let fun even x = if x = 0 then true else odd (x - 1)
    and odd x = if x = 0 then false else even (x - 1)
in even 7
end
```

## 库导入

```
import lists
import stdio
import declassifutil
```

## 并发特性

### 创建进程

```
let fun foo() = ...
in spawn foo
end
```

`spawn` 返回新进程的标识符。

### 发送和接收消息

发送消息：

```
send (进程标识符, 消息)
```

接收消息：

```
receive [
  hn 模式 when 条件 => 表达式,
  hn 模式 => 表达式
]
```

### 并发编程示例

超时接收：

```
let fun timeout p r t = 
    let val _ = sleep t
    in send (p, r)
    end
    
    val p = self()
    val r = mkuuid()
    val _ = spawn(fn () => timeout p r 1000)
in 
    receive [
      hn ("MESSAGE", x) => print x,
      hn s when s = r => print "timeout"
    ]
end
```

可更新服务：

```
let fun server_v1 n =
    receive [
      hn ("REQUEST", sender) => 
        let val _ = send(sender, n)
        in server_v1(n+1)
        end,
      hn ("UPDATE", newversion) => newversion n
    ]
    
    val service = spawn(fn () => server_v1 0)
in
    ... // 使用和更新服务
end
```

## 调试

设置进程调试名称：

```
_setProcessDebuggingName "进程名称"
```

## 信息流控制

Troupe 实现了基于进度敏感非干扰性的安全监控器，能够防止信息泄露。违反信息流控制会导致进程终止。

------

希望这个指南能帮助你快速了解 Troupe 语言。如需了解更多细节，请参考完整的语言文档。