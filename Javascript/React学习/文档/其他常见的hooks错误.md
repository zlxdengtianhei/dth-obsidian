除了违反两条基本规则外，实际开发中还有其他常见的“陷阱”或错误。

#### 错误一：`useEffect` 中的过时闭包 (Stale Closure)

- **问题描述**：`useEffect` 的回调函数是一个闭包，它会“捕获”其定义时所在作用域的变量。如果你在 `useEffect` 中使用了某个 state 或 prop，但没有把它加入到依赖数组中，那么这个 effect 回调函数将永远持有该变量的**初始值**。
- **错误示例**：
    
    jsx
    
    ```text
    function Counter() {
      const [count, setCount] = useState(0);
    
      useEffect(() => {
        // 这个 effect 只在组件挂载时运行一次
        const intervalId = setInterval(() => {
          // 这里的 count 永远是 0，因为它是在初始渲染时被闭包捕获的
          console.log(`Count is: ${count}`); 
        }, 1000);
    
        return () => clearInterval(intervalId);
      }, []); // 依赖数组为空，意味着 effect 不会因为 count 变化而重新执行
    
      return (
        <div>
          <p>You clicked {count} times</p>
          <button onClick={() => setCount(count + 1)}>Click me</button>
        </div>
      );
    }
    ```
    
- **如何避免/修正**：
    1. **正确添加依赖**：将 `count` 加入依赖数组。但这会导致每次 `count` 变化都清除并重建定时器，对于定时器场景可能不是最优解。
        
        jsx
        
        ```text
        useEffect(() => { ... }, [count]);
        ```
        
    2. **使用函数式更新**：这是最佳实践。`setState` 函数可以接收一个函数作为参数，该函数会接收到**最新的** state 值。这样你的 effect 就不再依赖外部的 `count` 变量了。
        
        jsx
        
        ```text
        setCount(prevCount => prevCount + 1); 
        ```
        
        应用到上面的例子中：
        
        jsx
        
        ```text
        useEffect(() => {
          const intervalId = setInterval(() => {
            // 我们不再直接读取外部的 count，而是告诉 React：“把当前 count 加 1”
            // React 会确保 prevCount 是最新的值
            setCount(prevCount => prevCount + 1); 
          }, 1000);
          return () => clearInterval(intervalId);
        }, []); // 依赖数组可以保持为空
        ```
        

#### 错误二：`useEffect` 导致的无限重渲染循环 (Infinite Re-render Loop)

- **问题描述**：当 `useEffect` 的依赖项在每次渲染时都是一个新的引用（特别是对象或数组），并且 effect 内部又会触发状态更新，就会导致“渲染 -> effect 执行 -> 状态更新 -> 再次渲染”的死循环。
- **错误示例**：
    
    jsx
    
    ```text
    function MyComponent() {
      const [options, setOptions] = useState({ enabled: true });
      const [data, setData] = useState(null);
    
      // 每次渲染，{ enabled: true } 都是一个新的对象，引用地址不同
      // 所以 useEffect 的依赖项每次都被认为是“变化了”
      useEffect(() => {
        console.log('Fetching data...');
        // 假设这里 fetch data 后会 setData，为了简化，我们直接 setData
        setData({}); // 更新状态，触发重渲染，造成死循环
      }, [options]); // 依赖了一个非原始类型的变量
    
      return <div>...</div>;
    }
    ```
    
- **如何避免/修正**：
    1. **依赖原始类型**：如果可能，只依赖原始类型的值（字符串、数字、布尔值）。
        
        jsx
        
        ```text
        useEffect(() => { ... }, [options.enabled]);
        ```
        
    2. **使用 `useMemo` 或 `useCallback`**：如果必须依赖对象或函数，使用 `useMemo` 来缓存对象/数组，或 `useCallback` 来缓存函数，确保它们的引用地址在不必要时不发生变化。
    3. **在 effect 内部创建对象**：如果依赖的对象只在 effect 内部需要，就在 effect 内部创建它，不要放在依赖数组里。

#### 错误三：直接修改 State (Direct State Mutation)

- **问题描述**：React 通过比较新旧 state 的引用来决定是否需要重渲染。如果你直接修改一个对象或数组 state 的内部属性，它的引用地址并没有改变，React 会认为 state 没有变化，从而不会触发 UI 更新。
- **错误示例**：
    
    jsx
    
    ```text
    function TodoList() {
      const [user, setUser] = useState({ name: 'Alice', age: 25 });
    
      function handleAgeIncrease() {
        // 错误！直接修改了 user 对象
        user.age = user.age + 1; 
        // 传入的 user 引用地址和之前的 state 是一样的，React 认为没有变化
        setUser(user); 
      }
      // ...
    }
    ```
    
- **如何避免/修正**：
    
    - **始终创建新对象/数组**：遵循不可变性（Immutability）原则。使用展开语法 (`...`) 或数组方法 (`.map`, `.filter`) 来创建新的副本。
    
    jsx
    
    ```text
    function handleAgeIncrease() {
      // 正确！创建了一个新的 user 对象
      setUser({ ...user, age: user.age + 1 });
    }
    
    // 对于数组
    const [items, setItems] = useState(['a', 'b']);
    function addItem() {
      // 正确！创建了一个新的数组
      setItems([...items, 'c']); 
    }
    ```
    

### 总结表格

|问题名称 (Problem Name)|问题描述|错误示例|如何避免/修正|
|---|---|---|---|
|**违反 Hooks 规则**|在条件、循环或嵌套函数中调用 Hook，破坏了调用顺序的稳定性。|`if (condition) { useState() }`|**始终在函数组件的顶层调用 Hooks**。将逻辑判断移入 Hook 内部。|
|**过时闭包 (Stale Closure)**|`useEffect` 等 Hook 捕获了旧的 state/prop 值，因为它们未被包含在依赖数组中。|`useEffect(() => { setInterval(() => console.log(count), 1000) }, [])`|1. 正确填写依赖数组。<br>2. 使用**函数式更新** (`setCount(c => c + 1)`)。|
|**无限重渲染循环**|`useEffect` 的依赖项（通常是对象/数组）在每次渲染时都变化，同时 effect 又触发状态更新。|`useEffect(() => { setData({}) }, [optionsObject])`|1. 依赖尽量使用原始类型。<br>2. 使用 `useMemo` / `useCallback` 稳定引用。<br>3. 将非依赖的对象在 effect 内部创建。|
|**直接修改 State**|直接修改对象或数组类型的 state，其引用不变，导致 React 不触发重渲染。|`user.age++; setUser(user);`|**遵循不可变性**。使用展开语法 (`...`) 或 `.map()` 等方法创建新的 state 副本再 `set`。|