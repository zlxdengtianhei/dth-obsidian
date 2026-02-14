# Troupe 语言信息流控制指南

## 信息流控制基础

Troupe 实现了一种称为"进度敏感非干扰"的安全模型，用于防止信息泄露。核心特点是：

- 安全监控针对单个进程的粒度
- 违反安全策略会终止违规进程，但不影响其他进程或节点
- 除非进程被沙箱化，否则所有信息流违规都会导致进程终止

## 权限与权威机制

### 权威 (Authority)

Troupe 的权威是不可伪造的能力，用于执行特权操作：

```
// 获取最高权威（主程序开始时自动绑定）
authority

// 降级权威
attenuate(authority, '{alice}')
```

权威减弱的两种方式：

1. 程序化减弱：使用 `attenuate` 原语
2. 运行时减弱：远程接收的数据会自动从 l 减弱到 l∐ltrust（ltrust 为发送节点的信任级别）

## 标签和信息流监控

### 标签值

Troupe 中的每个值都有深度标签，表示机密性策略：

```
// 格式：值@值标签%类型标签
30@{alice,bob}%{}
```

创建带标签的值：

```
let val x = 10 raisedTo '{alice}'
```

### 信息流类型

1. **显式流**：通过值计算传播

   ```
   let val x = 10 raisedTo '{alice}'
       val y = 20 raisedTo '{bob}'
   in x + y
   end
   // 结果：30@{alice,bob}%{}
   ```

2. **隐式流**：通过控制流传播

   ```
   let val x = 10 raisedTo '{alice}'
   in if x > 5 then 1 else 0
   end
   // 结果：1@{alice}%{alice}
   ```

3. **终止和阻塞流**：通过程序终止或阻塞操作传播

### 程序计数器与阻塞标签

每个线程有两个运行时标签：

- 程序计数器标签 (pc)：跟踪控制流依赖
- 阻塞标签 (block)：跟踪可能通过阻塞操作泄露的信息

使用 `debugpc()` 查看当前标签状态：

```
let val _ = debugpc()
// 输出：
// PID:2dfe86ae-6bf3-4bfc-8a0c-200230e0296c@{}%{}
// PC:{}
// BL:{}
```

## 降级机制

降级是放宽信息流控制约束的机制，需要适当的权威。

### 基本降级

```
// 降级语法
declassify(表达式, 权威, 目标标签)

// 示例
let val x = 10 raisedTo '{alice}'
in declassify(x, authority, '{}')
end
```

当权威不足时，会报错：

```
let val authAlice = attenuate(authority, '{alice}')
    val x = 1 raisedTo '{bob}'
in declassify(x, authAlice, '{}')
end
// 错误：权威不足
```

### 阻塞标签的降级

使用 `let pini` 声明降级阻塞标签：

```
let val x = 10 raisedTo '{alice}'
    val z = 
    let pini authority
        val _ = if x > 1000 then receive [] else ()
        val z = y + 1
    in z
    end
in z
end
```

`let pini` 使得高安全性条件分支中的阻塞操作不会污染后续计算。

### 类型标签与隐式流

类型标签也会被控制流污染，影响需要类型检查的操作：

```
let val a = let pini authority
    val a = if y > 10 then z else "notaninteger"
in a
end
// a的类型标签包含y的标签
```

## I/O 与信息流控制

### 通用接收和邮箱清除

Troupe 提供了通用的接收原语：`rcv(lev1, lev2, handlers)`

- lev1: 存在标签的上界
- lev2: 存在标签的下界
- handlers: 处理程序列表

每条邮箱消息带有额外的存在标签（发送者的阻塞级别），接收时会传播此污染。

更简单的形式是 `rcvp(level, handlers)`，相当于接收特定标签级别的消息。

## 实用技巧

1. 使用 `debugpc()` 检查当前的标签状态
2. 遵循最小权限原则，使用 `attenuate` 减弱权威
3. 使用 `let pini` 在必要时降级阻塞标签
4. 注意类型标签对后续操作的影响

------

通过合理使用这些信息流控制机制，可以构建既安全又灵活的 Troupe 应用程序。