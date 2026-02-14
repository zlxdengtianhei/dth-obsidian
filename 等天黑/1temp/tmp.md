```mermaid
sequenceDiagram
    participant U as 用户
    participant S as Sisyphus
    participant Met as Metis
    participant Pro as Prometheus
    participant A as Atlas
    participant Mom as Momus
    participant TST as Testing Agent
    participant AB as Agent Builder
    participant SML as Skill/MCP 加载器
    participant Sub as 子 Agent
    participant PD as 进程文档
    participant R as 审查系统
    participant DN as 委派通知器

    U->>S: 任务请求
    S->>S: 创建 todo 列表
  
    Note over S,Met: 阶段1：预规划分析
    S->>Met: 委派预规划分析
    Met->>Met: 意图分类、歧义检测、风险识别
    Met-->>S: 分析报告 + Prometheus 指令
  
    Note over S,Pro: 阶段2：战略规划
    S->>Pro: 委派规划（附 Metis 指令）
    Pro->>Pro: 生成详细分步计划 + 验收标准
    Pro-->>S: 完整执行计划
  
    Note over S,A: 阶段3：计划编排
    S->>A: 委派编排
    A->>SML: 确定每个子任务的 skills/MCPs
    SML-->>A: Skill 清单
    A->>A: 分解为原子任务 + 分配 agent
  
    Note over A,TST: 阶段3.5：测试策略制定（强制审查步骤）
    A->>TST: 阶段1调用：根据计划设定验收标准
    TST->>TST: 分析计划，生成全局验收标准和测试策略
    TST-->>A: 验收标准 + 测试策略
  
    Note over A,Mom: 阶段3.6：计划审查（强制）
    A->>Mom: 审查完整计划（含测试策略）
    Mom->>Mom: 检查引用有效性、可执行性
    Mom-->>A: [OKAY] 或 [REJECT] + 修改建议
  
    alt 计划被拒绝
        A->>A: 根据 Momus 反馈修改计划
        A->>Mom: 重新审查
    end
  
    A-->>S: 分解后的计划 + 验收标准 + 测试策略
  
    Note over S,Sub: 阶段4：执行
    loop 每个子任务
        S->>AB: 为子任务构建 agent
        AB->>AB: 选择基础模板 + 模型
        AB-->>S: Agent 配置
        S->>Sub: delegate_task(prompt, skills, model)
        Sub->>PD: 记录操作（通过 hook）
        Sub-->>S: 任务结果
        DN-->>S: 委派广播
        S->>S: 验证验收标准
      
        alt 验证失败
            S->>AB: 构建修复 agent
            AB-->>S: 修复 agent 配置
            S->>Sub: delegate_task(修复 prompt)
            Sub-->>S: 修复结果
        end
    end
  
    Note over S,TST: 阶段5：测试验证
    S->>TST: 阶段2调用：执行所有测试
    TST->>TST: 运行验收标准中的所有测试
    TST-->>S: 测试结果报告
  
    Note over S,R: 阶段6：最终审查
    S->>R: 审查所有已完成工作
    R->>PD: 读取进程文档
    R-->>S: 审查裁决
  
    alt 审查发现问题
        S->>A: 调用 Atlas 重新规划修复方案
        A-->>S: 修复计划
        S->>Sub: 委派修复
        S->>TST: 重新测试
        S->>R: 重新审查
    end
  
    S-->>U: 最终结果 + 摘要
```

```sequenceDiagram
    participant U as 用户
    participant S as Sisyphus
    participant Met as Metis
    participant Pro as Prometheus
    participant SMA as Skill/MCP Allocator
    participant Mom as Momus
    participant Exec as 执行 Agent
    participant TR as Test Runner

    U->>S: 任务请求
    
    Note over S,Met: 阶段1：预规划分析
    S->>Met: 委派预规划分析
    Met-->>S: 分析报告 + Prometheus 指令
    
    Note over S,Pro: 阶段2：战略规划
    S->>Pro: 委派规划（附 Metis 指令）
    Pro-->>S: 完整计划（含验收标准，无 Skill/MCP）
    
    Note over S,SMA: 阶段3：Skill/MCP 分配
    S->>SMA: 为计划分配 Skills/MCPs
    SMA-->>S: 带 Skill/MCP 的计划
    
    Note over S,Mom: 阶段4：计划审查（Momus）
    S->>Mom: 审查计划（含验收标准 + Skill/MCP）
    Mom-->>S: [OKAY] 或 [REJECT]
    
    alt 计划被拒绝
        S->>Pro: 根据 Momus 反馈修改计划
        Pro-->>S: 修改后的计划
        S->>SMA: 重新分配 Skills/MCPs
        S->>Mom: 重新审查
    end
    
    Note over S,Exec: 阶段5：执行
    loop 逐一执行子任务
        S->>Exec: delegate_task（含 skills + mcps）
        Exec-->>S: 结果
    end
    
    Note over S,TR: 阶段6：测试验证
    S->>TR: 执行验收标准
    TR-->>S: 测试结果
```
