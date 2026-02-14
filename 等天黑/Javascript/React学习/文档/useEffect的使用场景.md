
1. **数据获取 (Data Fetching)**
    
    - **场景**：当组件挂载或某个 ID 变化时，从服务器 API 获取数据。
    - **同步逻辑**：将组件的内部状态与远程服务器的数据保持同步。
    
    javascript
    
    ```javascript
    function UserProfile({ userId }) {
      const [user, setUser] = useState(null);
    
      useEffect(() => {
        // Effect: 获取数据
        fetch(`https://api.example.com/users/${userId}`)
          .then(res => res.json())
          .then(data => setUser(data));
    
        // 无需清理
      }, [userId]); // 依赖项：当 userId 变化时，重新获取数据
    
      // ...
    }
    ```
    
2. **设置订阅 (Subscriptions)**
    
    - **场景**：监听浏览器窗口大小变化，或者订阅一个实时消息服务。
    - **同步逻辑**：在组件存在于屏幕上时，保持对外部事件的监听；在组件消失时，取消监听。
    
    javascript
    
    ```javascript
// 导入 React 库中的 useState 和 useEffect 这两个 Hook
import React, { useState, useEffect } from 'react';

// 定义一个名为 WindowWidth 的函数组件
function WindowWidth() {
  // 使用 useState Hook 来创建和管理组件的状态。
  // 'width' 是当前状态的值，初始值为浏览器窗口的当前内部宽度。
  // 'setWidth' 是一个函数，用来更新 'width' 的值，并触发组件重新渲染。
  const [width, setWidth] = useState(window.innerWidth);

  // 使用 useEffect Hook 来处理副作用（与外部世界交互）。
  // 这里的副作用是监听浏览器的 'resize' 事件。
  useEffect(() => {
    // --- Effect 函数 ---
    // 这部分代码在组件挂载后执行。

    // 定义一个名为 handleResize 的函数。
    // 当这个函数被调用时，它会获取最新的窗口宽度，并使用 setWidth 更新组件的状态。
    const handleResize = () => setWidth(window.innerWidth);

    // 向 'window' 对象添加一个事件监听器。
    // 这告诉浏览器：“每当 'resize' 事件发生时，请调用 handleResize 函数。”
    // 这就是“订阅”的建立过程。
    window.addEventListener('resize', handleResize);

    // --- 清理函数 (Cleanup Function) ---
    // useEffect 的返回值必须是一个函数，这个函数就是清理函数。
    // 它会在组件被销毁（卸载）前，或者在下一次 effect 执行前被调用。
    return () => {
      // 从 'window' 对象上移除我们之前添加的事件监听器。
      // 这是为了防止组件销毁后，监听器仍然存在而导致的内存泄漏。
      // 这就是“取消订阅”的过程。
      window.removeEventListener('resize', handleResize);
    };
  }, []); // <--- 依赖项数组

  // 这个空的依赖项数组 [] 是关键！
  // 它告诉 React：这个 effect 只在组件第一次挂载时运行一次，
  // 并且它的清理函数只在组件卸载时运行一次。
  // 无论组件重新渲染多少次，这个 effect 都不会再次执行。

  // 组件的返回值，定义了该组件应该渲染成什么样子的 UI。
  // 这里我们显示一个 div，里面包含了当前的宽度值。
  return <div>Window width is: {width}</div>;
}
    ```
#### 设置订阅 (`WindowWidth` 组件)

让我们先来详细分析这个例子。

**这个订阅是如何工作的？**

1. **“订阅”的含义**：在这个上下文中，“订阅”是指我们告诉浏览器：“嘿，我（我们的组件）对某个特定的事件感兴趣。当这个事件发生时，请通知我。” 在这个例子里，我们感兴趣的事件是 `resize`，也就是浏览器窗口大小的改变。
2. **建立订阅**：我们使用 `window.addEventListener('resize', handleResize);` 来建立这个订阅。
    - `window`：是浏览器环境中的一个全局对象，代表整个浏览器窗口。
    - `addEventListener`：是一个方法，用于在目标（这里是 `window`）上设置一个函数，以便在指定事件发生时被调用。
    - `'resize'`：是我们想要监听的事件的名称。
    - `handleResize`：是我们的“回调函数”。当 `resize` 事件发生时，浏览器就会执行这个函数。
3. **事件发生时的动作**：在我们的 `handleResize` 函数中，我们调用了 `setWidth(window.innerWidth)`。`setWidth` 是一个由 `useState` 提供的状态更新函数。调用它会做两件事：
    - 更新组件内部的 `width` 状态。
    - 触发 `WindowWidth` 组件的重新渲染，以便在屏幕上显示新的宽度值。

**为什么只需要在开头和结尾处理两次就行？**

这是一个非常关键的问题，它直指 `useEffect` 的核心。这里的“开头”是指组件被创建并显示在屏幕上（称为**挂载 Mount**），“结尾”是指组件从屏幕上被移除（称为**卸载 Unmount**）。

**这个空的依赖项数组 `[]` 是不是不起作用？**

恰恰相反，这个**空的数组 `[]` 起着至关重要的作用**。它就是告诉 React “只在开头和结尾处理”的指令！

让我们来梳理一下完整的生命周期：

1. **组件挂载 (Mounting)**：
    
    - `WindowWidth` 组件第一次被渲染到屏幕上。
    - 渲染完成后，React 运行 `useEffect` 里的函数。
    - `window.addEventListener('resize', handleResize);` 被执行。此时，订阅被**创建**了。
2. **组件更新 (Updating)**：
    
    - 用户拖动浏览器边缘，改变了窗口大小。
    - 浏览器触发 `resize` 事件。
    - 我们之前注册的 `handleResize` 函数被调用。
    - `setWidth(window.innerWidth)` 更新了 state，触发了组件的**重新渲染**。
    - 在这次重新渲染后，React 会检查 `useEffect` 的依赖项数组。它看到当前的依赖项是 `[]`，上一次的依赖项也是 `[]`。因为数组中的值没有发生任何变化，**所以 React 会跳过 `useEffect` 函数的执行**。
    - **这一点至关重要！** 如果没有这个空数组（或者说，如果我们完全不提供依赖项数组），那么每次 `setWidth` 导致组件重新渲染时，`useEffect` 都会再次运行，我们就会不停地添加新的、重复的事件监听器，这会很快导致严重的性能问题和内存泄漏。
3. **组件卸载 (Unmounting)**：
    
    - 当 `WindowWidth` 组件不再需要显示时（例如，用户导航到另一个页面），React 会准备将其从 DOM 中移除。
    - 在移除之前，React 会执行 `useEffect` 中返回的那个**清理函数**。
    - `window.removeEventListener('resize', handleResize);` 被执行。此时，我们之前创建的订阅被**取消**了。这可以防止在组件已经不存在的情况下，浏览器还在尝试调用一个不存在的函数，从而避免了内存泄漏。

**总结**：空的依赖项数组 `[]` 告诉 `useEffect`：“这个 effect 与组件内的任何 props 或 state 都无关，它只需要在组件生命周期的最开始运行一次，并在最末尾清理一次即可。”

#### `useEffect` 是构造函数/析构函数吗？

**是的，你用“构造函数与析构函数”来类比，是一个非常精准且深刻的理解！**

在面向对象编程（如 C++ 或 Java）中：

- **构造函数 (Constructor)**：在一个对象被创建时自动运行，用于初始化资源（分配内存、打开文件、建立网络连接等）。
- **析构函数 (Destructor)**：在一个对象被销毁时自动运行，用于释放资源（释放内存、关闭文件、断开网络连接等），防止资源泄漏。

现在我们把它对应到 `useEffect`：

- **`useEffect` 的主函数体**（在依赖项 `[]` 为空时）：
    
    - 它在组件**第一次被创建并渲染到屏幕上（挂载 Mount）之后**运行。
    - 它扮演了**构造函数**的角色，负责“初始化”与外部世界的连接。在这个例子里，就是通过 `window.addEventListener` 建立对 `resize` 事件的订阅。
- **`useEffect` 返回的清理函数**：
    
    - 它在组件**即将从屏幕上被移除（卸载 Unmount）之前**运行。
    - 它扮演了**析构函数**的角色，负责“销毁”这个连接，清理之前占用的资源。在这个例子里，就是通过 `window.removeEventListener` 取消订阅，释放浏览器对这个监听函数的引用。

所以，`useEffect(effect, [])` 的模式，就是 React 提供给我们的、用于在函数组件中模拟“构造”和“析构”行为的官方工具。它完美地将资源的“获取”和“释放”绑定在了组件的生命周期上。

---

#### `handleResize` 是回调函数吗？监听函数是如何工作的？

是的，`handleResize` 正是一个典型的**回调函数 (Callback Function)**。

#### 什么是回调函数？

回调函数的定义很简单：**你定义一个函数 A，但不是立即调用它，而是把它作为参数传递给另一个函数 B。由函数 B 在未来的某个特定时刻，负责“回过头来调用”你传给它的函数 A。**

在这个场景里：

- 函数 A 是我们的 `handleResize`。
- 函数 B 是浏览器的 `window.addEventListener`。

我们调用 `window.addEventListener('resize', handleResize)` 时，我们并没有执行 `handleResize`。我们只是对浏览器说：“这是我的电话号码 (`handleResize`)，你把它记在你的通讯录里，跟‘窗口尺寸变化’这件事关联起来。以后什么时候窗口尺寸变了，你就帮我打这个电话。”

#### 监听函数的运行机制：它不是“一直运行”

这是你问题的核心，也是一个常见的误解。监听函数（如 `handleResize`）在被注册后，**并不会在一个固定的空间内“保持运行”或“持续监听”**。这样做会瞬间耗尽 CPU 资源，冻结整个浏览器。

真实的工作机制要高效得多，它依赖于浏览器的**事件循环 (Event Loop)** 模型。我们可以用一个生动的比喻来理解它：

**把浏览器想象成一个大型的调度中心。**

1. **注册阶段 (登记任务)**
    
    - 当你调用 `window.addEventListener('resize', handleResize)` 时，你并没有启动任何新的进程。
    - 你只是走到了调度中心的“事件登记处”，对工作人员说：“你好，请在‘窗口尺寸变化’这个事件的通知列表上，记下 `handleResize` 这个处理方法。”
    - 工作人员就在一个内部的、高度优化的**事件表 (Event Table)** 里增加了一条记录：`{ event: 'resize', handler: handleResize }`。
    - 做完登记后，你的 JavaScript 代码就继续往下执行了。这个登记过程本身几乎不消耗任何资源。`handleResize` 函数本身处于**休眠状态**，只是一个被存储起来的引用。
2. **监听阶段 (浏览器核心的工作)**
    
    - 浏览器自身有一个非常底层的、用 C++ 等高性能语言编写的核心。这个核心在**持续不断地、非常高效地**监测各种底层操作系统信号，包括鼠标移动、键盘输入、网络数据包到达、以及窗口尺寸变化。
    - **是浏览器核心在“监听”，而不是你的 JavaScript 函数在监听。**
3. **触发与排队阶段 (事件发生)**
    
    - 用户拖动了浏览器窗口。
    - 浏览器核心捕获到了这个变化。它立刻去查阅它的“事件表”。
    - 它发现：“哦，有人登记过对 `resize` 事件感兴趣，对应的处理方法是 `handleResize`。”
    - 于是，浏览器核心并**不直接执行** `handleResize`，而是创建了一个“任务”，内容是“执行 `handleResize` 函数”，然后把这个任务放进一个叫做**事件队列 (Event Queue)** 的等待区。这就像调度员把一个待办事项贴在了任务板上。
4. **执行阶段 (JavaScript 的工作)**
    
    - JavaScript 是单线程的，它有一个叫做**事件循环 (Event Loop)** 的机制。
    - 这个事件循环可以想象成一个孜孜不倦的工人，它永远在重复做一件事：
        1. 查看主工作台（调用栈 Call Stack）上有没有活要干。
        2. 如果主工作台空了，就去任务板（事件队列 Event Queue）上看有没有新的任务。
        3. 如果任务板上有任务，就取下第一个任务，放到主工作台上开始执行。
    - 所以，当 JavaScript 主线程空闲下来时，事件循环就会发现事件队列里的“执行 `handleResize`”任务，然后把它拿出来执行。这时，`setWidth` 才被调用，React 的状态才被更新，UI 才重新渲染。

**总结一下这个机制：**

- **注册 (Registration)**：`addEventListener` 只是一个轻量级的登记行为，将你的函数（回调）与一个事件名关联起来。
- **休眠 (Dormancy)**：你的回调函数在绝大多数时间里都处于休眠状态，不占用任何 CPU。
- **触发 (Triggering)**：当事件发生，浏览器将一个“执行该函数”的任务放入队列。
- **执行 (Execution)**：当 JavaScript 主线程空闲时，事件循环从队列中取出任务并执行它。

所以，`useEffect` 的析构（清理）函数所做的 `removeEventListener`，就是在告诉调度中心的登记处：“请把之前登记在‘窗口尺寸变化’通知列表里的 `handleResize` 这个条目划掉。” 这样，下次事件再发生时，浏览器就不会再为它创建任务了，从而干净利落地切断了联系。

[[关于resize与addEnventListener]]

---

1. **手动操作 DOM**
    
    - **场景**：根据组件的状态动态修改页面标题。
    - **同步逻辑**：将组件的 props 或 state 与 `document.title` 这个外部 DOM 属性保持同步。
    
    javascript
    
    ```javascript
    function Page({ title }) {
      useEffect(() => {
        // Effect: 修改 DOM
        document.title = title;
      }, [title]); // 依赖项：当 title 变化时，更新 document.title
    
      return <h1>{title}</h1>;
    }
    ```
**总结**：空的依赖项数组 `[]` 告诉 `useEffect`：“这个 effect 与组件内的任何 props 或 state 都无关，它只需要在组件生命周期的最开始运行一次，并在最末尾清理一次即可。”

---

#### 手动操作 DOM (`Page` 组件)

**什么是 DOM？**

**DOM** 是 **Document Object Model**（文档对象模型）的缩写。你可以把它想象成浏览器为你的 HTML 文档在内存中创建的一个**实时、可交互的树状结构图**。

1. **源头是 HTML**：当浏览器加载一个网页时，它会读取 HTML 代码。
2. **构建模型**：浏览器会根据 HTML 的层级关系，在内存中构建一个对应的树形结构。`<html>` 是根节点，`<head>` 和 `<body>` 是它的子节点，`<body>` 里面的 `<h1>`, `<div>` 等又是 `<body>` 的子节点，以此类推。
3. **对象化**：这个树中的每一个节点（比如一个 `<h1>` 标签）都是一个**对象**，拥有自己的属性（如 `id`, `className`）和方法（如 `addEventListener`）。
4. **可交互**：最重要的一点是，我们可以使用 JavaScript 来访问和操作这个 DOM 树。例如，`document.title = '新标题'` 就是直接访问并修改了 DOM 中代表页面标题的那个节点的属性。`document.getElementById('my-div')` 则是通过 ID 在 DOM 树中查找一个特定的节点对象。

**React 和 DOM 的关系**：React 的一个主要优势是它不直接操作 DOM。它在内存中维护一个轻量级的“虚拟 DOM”。当组件状态改变时，React 会计算出一个新的虚拟 DOM，然后通过一个叫做“协调”（Reconciliation）的过程，高效地计算出新旧虚拟 DOM 之间的差异，最后只把这些差异应用到真实的浏览器 DOM 上。这比手动、频繁地操作整个 DOM 要快得多。

`useEffect` 在这里的作用就是作为一个“桥梁”或“逃生舱口”，允许我们在 React 的世界里，安全、可控地去操作那些不被 React 直接管理的外部系统，比如 `document.title`。

**这个场景是如何工作的？**

1. **同步逻辑**：我们的目标是让浏览器的标签页标题 (`document.title`) 始终与 `Page` 组件接收到的 `title` prop 保持一致。
2. **触发时机**：我们希望在 `title` prop 发生变化时更新 `document.title`。因此，我们将 `[title]` 作为 `useEffect` 的依赖项。
3. **执行流程**：
    - 当 `Page` 组件第一次渲染时（或者当它从父组件接收到一个新的 `title` prop 时），React 会运行 `useEffect` 里的函数。
    - `document.title = title;` 执行，将浏览器标签页的标题设置为当前 `title` prop 的值。
    - 当组件因为其他原因（比如父组件重新渲染，但 `title` prop 没变）重新渲染时，React 会比较新的 `title` 和旧的 `title`。因为它们相同，所以 `useEffect` 的函数不会被执行。
    - 只有当父组件传递了一个**不同**的 `title` prop 时，`useEffect` 才会再次运行，从而更新 `document.title`。

这完美地实现了“将外部系统 (`document.title`) 与 React 内部状态 (`title` prop) 同步”的目标。
