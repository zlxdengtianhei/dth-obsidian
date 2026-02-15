🎓 超详细代码注释版：Antigravity OAuth 实现
我会为你提供一个极其详细的注释版本，特别关注 TypeScript 语法、回调函数、以及调用链的解释。

---
📚 第一部分：TypeScript 基础语法速查
在进入代码之前，先了解一些关键的 TypeScript 语法： 
// ========================================
// 🔤 TypeScript 基础语法速查表
// ========================================
// 1️⃣ 类型注解（Type Annotations）
// TypeScript 使用冒号 `:` 来标注变量类型
let name: string = "hello";        // 字符串类型
let age: number = 25;              // 数字类型
let isActive: boolean = true;      // 布尔类型
let items: string[] = ["a", "b"];  // 字符串数组
let anything: any = "可以是任何类型"; // any 类型，关闭类型检查
// 2️⃣ 函数类型注解
// 参数类型在参数名后，返回类型在括号后
function greet(name: string): string {
  return `Hello, ${name}`;
}
// 箭头函数的类型注解
const add = (a: number, b: number): number => a + b;
// 3️⃣ 可选参数（Optional Parameters）
// 使用 `?` 表示参数可选
function sayHi(name?: string): void {
  console.log(name ?? "Guest");  // ?? 是空值合并运算符
}
// 4️⃣ 联合类型（Union Types）
// 使用 `|` 表示可以是多种类型之一
let id: string | number = "abc";
id = 123;  // 也可以是数字
// 5️⃣ 类型别名（Type Alias）
type UserId = string | number;
let myId: UserId = "user_123";
// 6️⃣ 接口（Interface）
// 定义对象的结构
interface User {
  name: string;
  age: number;
  email?: string;  // 可选属性
}
const user: User = { name: "Alice", age: 30 };
// 7️⃣ 泛型（Generics）
// 使用 <T> 创建可重用的类型
function identity<T>(arg: T): T {
  return arg;
}
identity<string>("hello");  // T = string
identity<number>(42);       // T = number
// 8️⃣ Promise 类型
// Promise<T> 表示异步操作，T 是成功时返回的类型
async function fetchData(): Promise<string> {
  return "data";
}
// 9️⃣ ReturnType<typeof fn>
// 获取函数返回值的类型
function createServer() { /* ... */ }
type ServerType = ReturnType<typeof createServer>;
// 🔟 类型断言（Type Assertion）
// 告诉编译器"相信我，我知道这是什么类型"
const element = document.getElementById("app") as HTMLDivElement;
// 或者使用尖括号语法（不推荐在 JSX 中使用）
const element2 = <HTMLDivElement>document.getElementById("app");
---
📖 第二部分：回调函数深度解析
在进入主代码之前，让我们彻底理解回调函数：
// ========================================
// 🔄 回调函数（Callback）完全指南
// ========================================
/**
 * 什么是回调函数？
 * 
 * 回调函数 = 作为参数传递给另一个函数的函数
 * 
 * 为什么需要回调？
 * - JavaScript 是单线程的，不能"等待"长时间操作
 * - 回调让我们说："当操作完成时，调用这个函数"
 * 
 * 类比：
 * 餐厅点餐后，服务员给你一个取餐器（回调）
 * 你不需要一直站着等，取餐器响了再去取
 */
// ========== 示例 1：最简单的回调 ==========
function doSomethingAsync(callback: () => void): void {
  //         ↑ 参数名      ↑ 参数类型：无参数、无返回值的函数
  
  console.log("开始异步操作...");
  
  setTimeout(() => {
    console.log("异步操作完成！");
    callback();  // 在这里"回调"传入的函数
  }, 1000);
}
// 调用方式 1：传入具名函数
function myCallback() {
  console.log("我被回调了！");
}
doSomethingAsync(myCallback);
// 调用方式 2：传入匿名函数
doSomethingAsync(function() {
  console.log("匿名函数被回调了！");
});
// 调用方式 3：传入箭头函数（最常用）
doSomethingAsync(() => {
  console.log("箭头函数被回调了！");
});
// ========== 示例 2：带参数的回调 ==========
/**
 * 回调函数可以接收参数
 * 这些参数由调用回调的代码提供
 */
function fetchUser(userId: string, callback: (user: User) => void): void {
  //                              ↑ 回调类型：接收 User 参数，无返回值
  
  // 模拟网络请求
  setTimeout(() => {
    const user: User = { name: "Alice", age: 25 };
    callback(user);  // 将获取到的用户传给回调
    //       ↑ 这个参数由这里提供，不是调用者提供
  }, 1000);
}
// 使用
fetchUser("user_123", (user) => {
  //                   ↑ user 参数来自 fetchUser 内部的 callback(user)
  console.log(`获取到用户: ${user.name}`);
});
// ========== 示例 3：错误处理回调（Node.js 风格）==========
/**
 * Node.js 约定：回调的第一个参数是错误对象
 * - 如果操作成功，error 为 null
 * - 如果操作失败，error 包含错误信息
 */
function readFile(
  path: string, 
  callback: (error: Error | null, data: string | null) => void
): void {
  setTimeout(() => {
    if (path === "bad.txt") {
      callback(new Error("文件不存在"), null);  // 失败
    } else {
      callback(null, "文件内容...");  // 成功
    }
  }, 1000);
}
// 使用
readFile("good.txt", (error, data) => {
  if (error) {
    console.error("读取失败:", error.message);
    return;
  }
  console.log("文件内容:", data);
});
// ========== 示例 4：嵌套回调（回调地狱）==========
/**
 * 当多个异步操作需要依次执行时，会出现嵌套回调
 * 这被称为"回调地狱"（Callback Hell）
 */
function step1(callback: (result: string) => void) {
  setTimeout(() => callback("步骤1完成"), 100);
}
function step2(input: string, callback: (result: string) => void) {
  setTimeout(() => callback(input + " → 步骤2完成"), 100);
}
function step3(input: string, callback: (result: string) => void) {
  setTimeout(() => callback(input + " → 步骤3完成"), 100);
}
// 回调地狱示例
step1((result1) => {
  console.log(result1);
  step2(result1, (result2) => {
    console.log(result2);
    step3(result2, (result3) => {
      console.log(result3);
      // 继续嵌套...代码越来越难读
    });
  });
});
// ========== 示例 5：使用 Promise 解决回调地狱 ==========
/**
 * Promise 是对回调的封装，让异步代码更易读
 * 
 * Promise 有三种状态：
 * - pending（等待中）：初始状态
 * - fulfilled（已完成）：操作成功
 * - rejected（已拒绝）：操作失败
 */
function step1Promise(): Promise<string> {
  return new Promise((resolve, reject) => {
    //                ↑ resolve: 成功时调用
    //                          ↑ reject: 失败时调用
    setTimeout(() => resolve("步骤1完成"), 100);
  });
}
function step2Promise(input: string): Promise<string> {
  return new Promise((resolve) => {
    setTimeout(() => resolve(input + " → 步骤2完成"), 100);
  });
}
function step3Promise(input: string): Promise<string> {
  return new Promise((resolve) => {
    setTimeout(() => resolve(input + " → 步骤3完成"), 100);
  });
}
// 使用 Promise 链（比嵌套回调清晰）
step1Promise()
  .then((result1) => step2Promise(result1))
  .then((result2) => step3Promise(result2))
  .then((result3) => console.log(result3))
  .catch((error) => console.error(error));
// 使用 async/await（最清晰的方式）
async function runSteps() {
  try {
    const result1 = await step1Promise();
    const result2 = await step2Promise(result1);
    const result3 = await step3Promise(result2);
    console.log(result3);
  } catch (error) {
    console.error(error);
  }
}
---
🔧 第三部分：代码实现超详细注释
步骤 1：创建本地 HTTP 服务器
// ========================================
// 📁 文件：src/oauth-server.ts
// 📝 功能：创建本地 HTTP 服务器接收 OAuth 回调
// ========================================
import { createServer } from 'http';
// ↑ 从 Node.js 内置的 'http' 模块导入 createServer 函数
// 这是 ES6 模块语法，等价于 CommonJS 的：
// const { createServer } = require('http');
import { open } from 'open';
// ↑ 从 'open' 包导入，用于跨平台打开浏览器
/**
 * ========================================
 * 🏗️ OAuthServer 类定义
 * ========================================
 * 
 * 类（Class）是 TypeScript/JavaScript 的面向对象编程基础
 * 
 * 类包含：
 * - 属性（存储数据）
 * - 方法（执行操作）
 * - 构造函数（初始化实例）
 */
class OAuthServer {
  
  // ========== 私有属性（Private Properties）==========
  
  /**
   * private 关键字：
   * - 该属性只能在类内部访问
   * - 类外部无法读取或修改
   * - 编译时检查，运行时无效（JavaScript 没有真正的私有）
   */
  private server: ReturnType<typeof createServer> | null = null;
  //      ↑ 属性名
  //             ↑ 类型：createServer 函数的返回类型，或者 null
  //                                                    ↑ 初始值：null
  
  /**
   * ReturnType<typeof createServer> 解释：
   * 
   * typeof createServer → 获取 createServer 函数的类型
   * ReturnType<...>     → 提取该函数的返回值类型
   * 
   * 结果等价于：http.Server 类型
   * 
   * 为什么不直接写 http.Server？
   * - ReturnType 是更通用的做法
   * - 如果 createServer 返回类型变了，这里自动适应
   */
  
  private port: number = 4120;
  //      ↑ 私有属性：端口号
  //            ↑ 类型：number
  //                     ↑ 默认值：4120
  
  // ========== 公共方法（Public Methods）==========
  
  /**
   * 🚀 启动本地 HTTP 服务器
   * 
   * async 关键字：
   * - 表示这是一个异步函数
   * - 函数内部可以使用 await
   * - 返回值自动包装成 Promise
   * 
   * 返回类型 Promise<string>：
   * - Promise 表示异步操作
   * - <string> 表示成功时返回字符串（服务器 URL）
   */
  async start(): Promise<string> {
    
    /**
     * ========================================
     * 🔄 Promise 构造函数详解
     * ========================================
     * 
     * new Promise((resolve, reject) => { ... })
     * 
     * Promise 构造函数接收一个"执行器函数"（executor）
     * 执行器函数有两个参数：
     * - resolve: 成功时调用，传入结果值
     * - reject:  失败时调用，传入错误对象
     * 
     * 执行器函数会立即执行（同步），但 resolve/reject 通常在异步操作完成后调用
     */
    return new Promise((resolve, reject) => {
      //              ↑ 这整个是"执行器函数"
      //               ↑ resolve 的类型：(value: string) => void
      //                        ↑ reject 的类型：(reason: any) => void
      
      /**
       * ========================================
       * 🌐 createServer 详解
       * ========================================
       * 
       * createServer 函数签名：
       * function createServer(
       *   requestListener?: (req: IncomingMessage, res: ServerResponse) => void
       * ): Server
       * 
       * 参数 requestListener 是一个回调函数，每次收到 HTTP 请求时被调用
       */
      this.server = createServer((req, res) => {
        //                        ↑ 这是请求处理回调函数
        //                         ↑ req: 请求对象（IncomingMessage 类型）
        //                              ↑ res: 响应对象（ServerResponse 类型）
        
        /**
         * 📥 req（请求对象）常用属性：
         * - req.url: 请求的 URL 路径（如 "/callback?code=xxx"）
         * - req.method: HTTP 方法（"GET", "POST" 等）
         * - req.headers: 请求头对象
         * - req.httpVersion: HTTP 版本
         * 
         * 📤 res（响应对象）常用方法：
         * - res.writeHead(statusCode, headers): 写入状态码和响应头
         * - res.write(data): 写入响应体数据
         * - res.end(data?): 结束响应，可选地写入最后的数据
         */
        
        console.log(`收到请求: ${req.url}`);
        // ↑ 模板字符串：使用反引号 ` 和 ${表达式} 插入变量
        
        /**
         * 可选链操作符 ?.
         * 
         * req.url?.startsWith('/callback') 等价于：
         * (req.url !== null && req.url !== undefined) ? req.url.startsWith('/callback') : undefined
         * 
         * 如果 req.url 是 null 或 undefined，整个表达式返回 undefined
         * 不会抛出 "Cannot read property 'startsWith' of null" 错误
         */
        if (req.url?.startsWith('/callback')) {
          
          /**
           * 📞 调用另一个方法处理回调
           * 
           * this.handleCallback(req, res, resolve, reject)
           * 
           * 注意：我们把 resolve 和 reject 传给了 handleCallback
           * 这样 handleCallback 可以决定 Promise 的最终状态
           * 
           * 这是一种常见模式：把 Promise 的控制权交给其他函数
           */
          this.handleCallback(req, res, resolve, reject);
          
        } else {
          // 返回 404 对于非回调路径
          res.writeHead(404, { 'Content-Type': 'text/plain' });
          //            ↑ HTTP 状态码：404 Not Found
          //                 ↑ 响应头：指定内容类型为纯文本
          res.end('Not Found');
          // ↑ 发送响应体并结束响应
        }
      });
      // ↑ createServer 回调结束
      // 此时服务器已创建，但还没开始监听
      
      /**
       * ========================================
       * 🎧 server.listen 详解
       * ========================================
       * 
       * server.listen(port, [hostname], [backlog], [callback])
       * 
       * 参数：
       * - port: 监听的端口号
       * - hostname: 监听的主机名（'127.0.0.1' = 仅本机，'0.0.0.0' = 所有接口）
       * - backlog: 待处理连接队列的最大长度（可选）
       * - callback: 服务器开始监听后的回调（可选）
       * 
       * 回调函数没有参数，因为 listen 成功后没有数据要传递
       */
      this.server.listen(this.port, '127.0.0.1', () => {
        //              ↑ 端口         ↑ 主机名     ↑ 成功回调
        console.log(`OAuth 服务器启动在 http://127.0.0.1:${this.port}`);
        
        // 调用 resolve，表示 Promise 成功完成
        resolve(`http://127.0.0.1:${this.port}`);
        //       ↑ 这个值会成为 await start() 的返回值
      });
      // ↑ listen 回调结束
      
      /**
       * ========================================
       * ⚠️ 错误事件处理
       * ========================================
       * 
       * server.on('event', callback) 是事件监听器模式
       * 
       * Node.js 中很多对象都是 EventEmitter，可以发出和监听事件
       * 
       * 常见的服务器事件：
       * - 'error': 发生错误时触发
       * - 'close': 服务器关闭时触发
       * - 'connection': 新连接建立时触发
       * - 'listening': 开始监听时触发
       */
      this.server.on('error', (err: Error) => {
        //         ↑ 事件名     ↑ 事件处理回调
        
        /**
         * 类型断言 (err as any).code
         * 
         * Error 类型没有 code 属性，但 Node.js 的系统错误有
         * 使用 (err as any) 告诉 TypeScript "我知道我在做什么"
         * 
         * 常见的错误码：
         * - EADDRINUSE: 端口已被占用
         * - EACCES: 没有权限访问端口
         * - ECONNREFUSED: 连接被拒绝
         */
        if ((err as any).code === 'EADDRINUSE') {
          console.error(`端口 ${this.port} 已被占用`);
          // 可以在这里尝试其他端口...
        }
        
        // 调用 reject，表示 Promise 失败
        reject(err);
        // ↑ 这个错误会被 catch 捕获，或导致 await 抛出异常
      });
      
    }); // ← Promise 构造函数结束
  } // ← start() 方法结束
  
  /**
   * ========================================
   * 🔄 处理 OAuth 回调
   * ========================================
   * 
   * 这个方法处理 Google 重定向回来的请求
   * 
   * 参数说明：
   * - req: HTTP 请求对象
   * - res: HTTP 响应对象
   * - resolve: Promise 的成功回调（从 start() 传入）
   * - reject: Promise 的失败回调（从 start() 传入）
   * 
   * 为什么传入 resolve/reject？
   * - 让这个方法可以控制外层 Promise 的结果
   * - handleCallback 成功 → start() 的 Promise 成功
   * - handleCallback 失败 → start() 的 Promise 失败
   */
  private handleCallback(
    req: any,   // 实际类型是 http.IncomingMessage
    res: any,   // 实际类型是 http.ServerResponse
    resolve: (value: string) => void,
    //       ↑ 函数类型：接收 string 参数，无返回值
    reject: (reason: any) => void
    //      ↑ 函数类型：接收 any 参数，无返回值
  ): void {
  // ↑ 返回类型 void：表示不返回任何值
    
    try {
      // 构造完整的 URL 字符串
      const fullUrl = `http://127.0.0.1:${this.port}${req.url}`;
      // 例如："http://127.0.0.1:4120/callback?code=4/0AX4XfW...&scope=..."
      
      /**
       * ========================================
       * 🔗 URL 类详解
       * ========================================
       * 
       * new URL(urlString) 解析 URL 字符串为对象
       * 
       * 属性：
       * - url.href:     完整 URL
       * - url.protocol: 协议（如 "http:"）
       * - url.hostname: 主机名（如 "127.0.0.1"）
       * - url.port:     端口号（如 "4120"）
       * - url.pathname: 路径（如 "/callback"）
       * - url.search:   查询字符串（如 "?code=xxx"）
       * - url.searchParams: URLSearchParams 对象，用于操作查询参数
       */
      const url = new URL(fullUrl);
      
      /**
       * URLSearchParams 方法：
       * - get(name):     获取参数值，不存在返回 null
       * - getAll(name):  获取同名参数的所有值（数组）
       * - has(name):     检查参数是否存在
       * - append(n, v):  添加参数
       * - set(n, v):     设置参数（覆盖现有）
       * - delete(name):  删除参数
       */
      const code = url.searchParams.get('code');
      //    ↑ 获取 URL 中的 code 参数（授权码）
      const error = url.searchParams.get('error');
      //    ↑ 获取 URL 中的 error 参数（如果有错误）
      
      // 错误处理
      if (error) {
        res.writeHead(400, { 'Content-Type': 'text/html' });
        res.end(`<h1>认证失败: ${error}</h1>`);
        
        // 调用 reject，让外层 Promise 失败
        reject(new Error(`OAuth error: ${error}`));
        return; // 提前返回，不继续执行
      }
      
      // 成功获取授权码
      if (code) {
        // 返回成功页面给用户的浏览器
        res.writeHead(200, { 
          'Content-Type': 'text/html',
          'Cache-Control': 'no-cache'  // 告诉浏览器不要缓存此页面
        });
        
        /**
         * 多行字符串模板
         * 使用反引号可以直接写多行字符串
         * 保留换行和缩进
         */
        res.end(`
          <html>
            <head>
              <title>认证成功</title>
              <style>
                body { font-family: Arial; text-align: center; padding-top: 50px; }
                .success { color: green; font-size: 24px; }
              </style>
            </head>
            <body>
              <h1 class="success">✅ 认证成功！</h1>
              <p>您可以关闭此窗口并返回终端。</p>
              <script>setTimeout(() => window.close(), 3000);</script>
            </body>
          </html>
        `);
        
        // 关闭服务器（任务完成，不再需要）
        this.stop();
        
        // 调用 resolve，让外层 Promise 成功
        // code 将作为 await start() 的返回值
        resolve(code);
        
      } else {
        // 没有 code 也没有 error，异常情况
        res.writeHead(400, { 'Content-Type': 'text/plain' });
        res.end('Missing authorization code');
        reject(new Error('No code received'));
      }
      
    } catch (err) {
      // 捕获任何意外错误
      res.writeHead(500, { 'Content-Type': 'text/plain' });
      res.end('Internal Server Error');
      reject(err);
    }
  }
  
  /**
   * 🛑 停止服务器
   */
  stop(): void {
    if (this.server) {
      this.server.close();
      //         ↑ 关闭服务器，停止接受新连接
      this.server = null;
      //         ↑ 清空引用，允许垃圾回收
      console.log('OAuth 服务器已关闭');
    }
  }
}
步骤 2：构建 Google OAuth URL
// ========================================
// 📁 文件：src/google-oauth.ts
// 📝 功能：处理 Google OAuth 2.0 认证
// ========================================
/**
 * ========================================
 * ⚙️ 配置对象（常量）
 * ========================================
 * 
 * const 声明的对象引用不可变，但对象的属性可以修改
 * 要完全不可变，需要使用 Object.freeze() 或 as const
 */
const GOOGLE_OAUTH_CONFIG = {
  // Google OAuth 2.0 授权端点（用户登录并授权的页面）
  authEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
  
  // Token 交换端点（用授权码换取 access_token）
  tokenEndpoint: 'https://oauth2.googleapis.com/token',
  
  /**
   * 客户端 ID（Client ID）
   * 
   * 这是在 Google Cloud Console 注册应用时获得的
   * 格式：{数字}.apps.googleusercontent.com
   * 
   * 重要：这个 ID 是公开的，可以出现在前端代码中
   * 但 Client Secret 必须保密！
   */
  clientId: '947346213753-6b0kmdku9k7qsd6rbrp9l0h6l7f2uojb.apps.googleusercontent.com',
  
  /**
   * 权限范围（Scopes）
   * 
   * Scope 定义了应用请求的权限
   * 用户会看到这些权限并选择是否授权
   */
  scopes: [
    'openid',        // OpenID Connect：获取用户唯一标识
    'email',         // 获取用户邮箱地址
    'profile',       // 获取用户姓名、头像等基本信息
    'https://www.googleapis.com/auth/cloud-platform'  // Google Cloud 完整访问权限
  ]
} as const;
//  ↑ as const 使对象变成只读，防止意外修改
/**
 * ========================================
 * 🔐 Token 接口定义
 * ========================================
 * 
 * interface 定义对象的结构（类型）
 * 用于类型检查，编译后会被移除
 */
interface Tokens {
  accessToken: string;    // 访问令牌，用于 API 调用
  refreshToken: string;   // 刷新令牌，用于获取新的 accessToken
  expiresIn: number;      // accessToken 有效期（秒）
  scope: string;          // 实际授予的权限
  tokenType: string;      // 令牌类型（通常是 "Bearer"）
}
class GoogleOAuth {
  
  /**
   * ========================================
   * 🔗 构建授权 URL
   * ========================================
   * 
   * 这个 URL 会打开 Google 的登录/授权页面
   * 用户登录并同意后，Google 会重定向到 redirectUri
   */
  buildAuthUrl(redirectUri: string): string {
    
    /**
     * URLSearchParams：构建 URL 查询字符串
     * 
     * 可以传入对象直接初始化
     * 自动处理 URL 编码（如空格 → %20）
     */
    const params = new URLSearchParams({
      /**
       * client_id：客户端标识
       * Google 用这个识别是哪个应用在请求授权
       */
      client_id: GOOGLE_OAUTH_CONFIG.clientId,
      
      /**
       * redirect_uri：重定向地址
       * 用户授权后，Google 会将浏览器重定向到这个地址
       * 必须和 Google Cloud Console 中注册的完全匹配
       */
      redirect_uri: redirectUri,
      
      /**
       * response_type：响应类型
       * - 'code': 授权码模式（最安全，推荐）
       * - 'token': 隐式模式（不推荐，令牌暴露在 URL 中）
       */
      response_type: 'code',
      
      /**
       * scope：请求的权限
       * 多个 scope 用空格分隔
       * join(' ') 把数组 ['a', 'b'] 变成 'a b'
       */
      scope: GOOGLE_OAUTH_CONFIG.scopes.join(' '),
      
      /**
       * access_type：访问类型
       * - 'online': 只需要短期访问（不返回 refresh_token）
       * - 'offline': 需要长期访问（返回 refresh_token）
       * 
       * refresh_token 允许在用户不在场时刷新 access_token
       */
      access_type: 'offline',
      
      /**
       * prompt：提示行为
       * - 'none': 不显示任何 UI（静默认证）
       * - 'consent': 强制显示同意界面（确保获取 refresh_token）
       * - 'select_account': 让用户选择账户
       * 
       * 重要：只有在 prompt=consent 时，Google 才一定返回 refresh_token
       */
      prompt: 'consent',
      
      /**
       * include_granted_scopes：包含已授予的权限
       * 如果用户之前授权过部分权限，这次请求会合并
       */
      include_granted_scopes: 'true'
    });
    
    // 生成并存储 state 参数（CSRF 防护）
    const state = this.generateRandomState();
    params.append('state', state);
    //     ↑ append 添加额外的参数
    this.saveState(state);
    
    // 拼接完整的授权 URL
    return `${GOOGLE_OAUTH_CONFIG.authEndpoint}?${params.toString()}`;
    //                                          ↑ toString() 生成查询字符串
  }
  
  /**
   * ========================================
   * 🎲 生成随机 state（CSRF 防护）
   * ========================================
   * 
   * state 参数用于防止 CSRF（跨站请求伪造）攻击
   * 
   * 攻击场景：
   * 1. 攻击者构造恶意链接：/callback?code=attacker_code
   * 2. 诱导受害者点击
   * 3. 受害者的账户被绑定到攻击者的授权
   * 
   * 防护机制：
   * 1. 发起授权时生成随机 state
   * 2. 回调时验证 state 是否匹配
   * 3. 不匹配则拒绝处理
   */
  private generateRandomState(): string {
    /**
     * crypto 模块：Node.js 加密模块
     * randomBytes(n)：生成 n 个加密安全的随机字节
     * toString('hex')：转换为十六进制字符串
     */
    const crypto = require('crypto');
    return crypto.randomBytes(32).toString('hex');
    //           ↑ 32 字节 = 256 位随机数
    //                        ↑ 结果是 64 个十六进制字符
  }
  
  private saveState(state: string): void {
    const fs = require('fs');
    const path = require('path');
    
    /**
     * process.env.HOME：当前用户的主目录
     * - macOS/Linux: /Users/username 或 /home/username
     * - Windows: C:\Users\username
     * 
     * || '' 是空值合并，如果 HOME 未定义则使用空字符串
     * （更现代的写法是 ?? ''）
     */
    const stateFile = path.join(
      process.env.HOME || '',
      '.config',
      'opencode',
      'oauth-state.json'
    );
    //     ↑ 结果：~/.config/opencode/oauth-state.json
    
    /**
     * JSON.stringify(object)：把对象转换为 JSON 字符串
     * 
     * 存储内容：
     * {
     *   "state": "a1b2c3d4...",
     *   "timestamp": 1234567890123
     * }
     */
    fs.writeFileSync(stateFile, JSON.stringify({ 
      state, 
      timestamp: Date.now() 
    }));
  }
  
  /**
   * ========================================
   * 🔄 用授权码交换 Token
   * ========================================
   * 
   * 这是 OAuth 2.0 的核心步骤
   * 
   * 流程：
   * 1. 用户授权后，我们获得一个短暂的授权码（code）
   * 2. 用 code + client_secret 向 Google 请求真正的令牌
   * 3. 获得 access_token（短期）和 refresh_token（长期）
   * 
   * 为什么需要两步？
   * - 授权码在 URL 中传输，可能被截获
   * - 但授权码必须配合 client_secret 才能换取令牌
   * - client_secret 只在服务器端，不会暴露
   */
  async exchangeCodeForTokens(code: string, redirectUri: string): Promise<Tokens> {
    
    /**
     * ========================================
     * 🌐 fetch API 详解
     * ========================================
     * 
     * fetch(url, options) 发送 HTTP 请求
     * 
     * 返回 Promise<Response>
     * - 网络错误会 reject
     * - HTTP 错误（如 404, 500）不会 reject！需要检查 response.ok
     */
    const response = await fetch(GOOGLE_OAUTH_CONFIG.tokenEndpoint, {
      /**
       * method：HTTP 方法
       * - GET: 获取数据
       * - POST: 提交数据（如表单）
       * - PUT: 更新数据（完整替换）
       * - PATCH: 部分更新
       * - DELETE: 删除数据
       */
      method: 'POST',
      
      /**
       * headers：请求头
       * 
       * Content-Type 告诉服务器请求体的格式
       * - application/json：JSON 格式
       * - application/x-www-form-urlencoded：表单格式（key=value&key2=value2）
       * - multipart/form-data：文件上传格式
       */
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json'  // 期望接收 JSON 响应
      },
      
      /**
       * body：请求体
       * 
       * URLSearchParams 自动生成表单格式的字符串
       * 例如：code=xxx&client_id=yyy&...
       */
      body: new URLSearchParams({
        code: code,                           // 授权码
        client_id: GOOGLE_OAUTH_CONFIG.clientId,
        client_secret: this.getClientSecret(),  // 客户端密钥（保密！）
        redirect_uri: redirectUri,              // 必须和请求授权时一致
        grant_type: 'authorization_code'        // OAuth 2.0 规范要求
      }).toString()
    });
    
    /**
     * ========================================
     * ✅ 响应处理
     * ========================================
     * 
     * response.ok：如果状态码是 200-299，则为 true
     * response.status：HTTP 状态码（如 200, 401, 500）
     * response.statusText：状态描述（如 "OK", "Unauthorized"）
     */
    if (!response.ok) {
      // 读取错误响应体
      const error = await response.text();
      //                          ↑ 读取响应体为文本
      throw new Error(`Token exchange failed: ${response.status} - ${error}`);
    }
    
    /**
     * response.json()：解析 JSON 响应
     * 
     * 返回 Promise，因为需要读取和解析响应流
     * 
     * Google 返回的 JSON 格式：
     * {
     *   access_token: "ya29.a0ARrdaM...",   // 访问令牌
     *   refresh_token: "1//0d7p2g5...",     // 刷新令牌
     *   expires_in: 3600,                    // 有效期（秒）
     *   scope: "openid email profile...",    // 授予的权限
     *   token_type: "Bearer"                 // 令牌类型
     * }
     */
    const tokens = await response.json();
    
    // 转换为我们定义的接口格式
    return {
      accessToken: tokens.access_token,
      refreshToken: tokens.refresh_token,
      expiresIn: tokens.expires_in,
      scope: tokens.scope,
      tokenType: tokens.token_type
    };
  }
  
  /**
   * ========================================
   * 🔄 刷新 Access Token
   * ========================================
   * 
   * access_token 通常只有 1 小时有效期
   * 过期后需要用 refresh_token 获取新的
   * 
   * refresh_token 通常长期有效，除非：
   * - 用户撤销授权
   * - 超过 6 个月未使用
   * - 应用的凭据被更换
   */
  async refreshAccessToken(refreshToken: string): Promise<string> {
    const response = await fetch(GOOGLE_OAUTH_CONFIG.tokenEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        refresh_token: refreshToken,
        client_id: GOOGLE_OAUTH_CONFIG.clientId,
        client_secret: this.getClientSecret(),
        grant_type: 'refresh_token'  // 使用刷新令牌流程
        //          ↑ 这告诉 Google 我们要刷新，不是新授权
      }).toString()
    });
    
    if (!response.ok) {
      throw new Error('Failed to refresh token');
    }
    
    const data = await response.json();
    return data.access_token;
    // 注意：刷新时通常不会返回新的 refresh_token
    // 继续使用原来的 refresh_token
  }
  
  private getClientSecret(): string {
    // 实际应该从安全存储读取
    return 'GOCSPX-...';
  }
}
步骤 3：设备指纹模拟
// ========================================
// 📁 文件：src/device-fingerprint.ts
// 📝 功能：生成设备指纹，模拟真实 IDE 客户端
// ========================================
/**
 * ========================================
 * 📱 设备信息接口
 * ========================================
 * 
 * Google 使用设备指纹来：
 * 1. 识别和追踪客户端
 * 2. 检测异常行为（如同一账户过多设备）
 * 3. 分配和管理配额
 * 4. 安全审计和风控
 */
interface DeviceInfo {
  deviceId: string;          // 设备唯一标识（UUID）
  sessionToken: string;      // 会话令牌
  userAgent: string;         // User-Agent 字符串
  apiClient: string;         // API 客户端标识
  clientMetadata: {          // 客户端元数据
    ideType: string;         // IDE 类型
    platform: string;        // 操作系统
    pluginType: string;      // 插件类型
    osVersion: string;       // 系统版本
    arch: string;            // CPU 架构
    sqmId: string;           // 软件质量监控 ID
  };
  quotaUser: string;         // 配额用户标识
  createdAt: number;         // 创建时间戳
}
class DeviceFingerprint {
  
  /**
   * 生成完整的设备指纹
   */
  generate(): DeviceInfo {
    return {
      deviceId: this.generateUUID(),
      sessionToken: this.generateSessionToken(),
      userAgent: this.getUserAgent(),
      apiClient: 'google-cloud-sdk vscode/1.86.0',
      clientMetadata: {
        ideType: 'VSCODE',
        platform: this.detectPlatform(),
        pluginType: 'GEMINI',
        osVersion: this.getOSVersion(),
        arch: this.detectArchitecture(),
        sqmId: this.generateSQMId()
      },
      quotaUser: `device-${this.generateRandomString(16)}`,
      createdAt: Date.now()
    };
  }
  
  /**
   * ========================================
   * 🔑 生成 UUID v4
   * ========================================
   * 
   * UUID（Universally Unique Identifier）：
   * - 128 位（16 字节）的唯一标识符
   * - 格式：8-4-4-4-12 的十六进制数字，用连字符分隔
   * - 示例：550e8400-e29b-41d4-a716-446655440000
   * 
   * UUID v4 使用随机数生成：
   * - 第 13 位固定是 4（表示版本）
   * - 第 17 位是 8, 9, a, 或 b（表示变体）
   */
  private generateUUID(): string {
    /**
     * 模板替换生成 UUID
     * 
     * 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
     *                ↑ 固定为 4（版本）
     *                     ↑ y 会被替换为 8, 9, a, 或 b
     */
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
      //                                          ↑ 正则表达式匹配 x 或 y
      //                                             ↑ g 标志表示全局替换
      //                                                 ↑ 替换回调函数
      //                                                    ↑ c 是当前匹配的字符
      
      const r = Math.random() * 16 | 0;
      //        ↑ 生成 0-15 的随机数
      //                        ↑ | 0 是位运算，效果是向下取整（比 Math.floor 快）
      
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      //        ↑ 三元运算符：条件 ? 真值 : 假值
      //                      ↑ 如果是 'x'，使用随机数
      //                              ↑ 如果是 'y'，确保结果是 8, 9, a, 或 b
      //                                ↑ r & 0x3 保留低 2 位（0-3）
      //                                       ↑ | 0x8 设置第 4 位（结果 8-11）
      
      return v.toString(16);
      //        ↑ 转换为十六进制字符
    });
  }
  
  /**
   * ========================================
   * 💻 检测操作系统平台
   * ========================================
   * 
   * process 是 Node.js 的全局对象
   * 包含当前进程的信息和控制方法
   */
  private detectPlatform(): string {
    /**
     * process.platform 可能的值：
     * - 'aix': IBM AIX
     * - 'darwin': macOS
     * - 'freebsd': FreeBSD
     * - 'linux': Linux
     * - 'openbsd': OpenBSD
     * - 'sunos': SunOS
     * - 'win32': Windows（包括 64 位）
     */
    const platform = process.platform;
    
    /**
     * switch 语句：多分支条件判断
     * 比多个 if-else 更清晰
     */
    switch (platform) {
      case 'darwin':
        return 'MACOS';
      case 'win32':
        return 'WINDOWS';
      case 'linux':
        return 'LINUX';
      default:
        return 'UNKNOWN';
    }
  }
  
  /**
   * ========================================
   * 🏗️ 检测 CPU 架构
   * ========================================
   */
  private detectArchitecture(): string {
    /**
     * process.arch 可能的值：
     * - 'arm': ARM 32 位
     * - 'arm64': ARM 64 位（如 Apple M1/M2）
     * - 'ia32': Intel 32 位
     * - 'mips': MIPS
     * - 'mipsel': MIPS Little Endian
     * - 'ppc': PowerPC
     * - 'ppc64': PowerPC 64 位
     * - 's390': IBM z/Architecture
     * - 's390x': IBM z/Architecture 64 位
     * - 'x64': x86 64 位（最常见）
     */
    return process.arch;
  }
  
  /**
   * ========================================
   * 🌐 构造 User-Agent
   * ========================================
   * 
   * User-Agent 是 HTTP 请求头，标识客户端软件
   * 
   * 常见格式：
   * Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/120.0.0.0
   */
  private getUserAgent(): string {
    const platform = process.platform;
    const arch = process.arch;
    
    // 模拟 Antigravity 插件的 User-Agent
    return `antigravity/1.15.8 ${platform}/${arch}`;
  }
  
  /**
   * ========================================
   * 📊 生成 SQM ID
   * ========================================
   * 
   * SQM（Software Quality Metrics）：
   * - 微软用于收集软件使用数据的系统
   * - 在 Windows 系统中存储于注册表
   * - 格式类似 GUID：{8C019E16-E823-46FD-978C-501F65DEF9C2}
   */
  private generateSQMId(): string {
    const parts = [];
    parts.push(this.generateHex(8));   // 8 位
    parts.push(this.generateHex(4));   // 4 位
    parts.push(this.generateHex(4));   // 4 位
    parts.push(this.generateHex(4));   // 4 位
    parts.push(this.generateHex(12));  // 12 位
    
    return `{${parts.join('-').toUpperCase()}}`;
    //       ↑ 用花括号包裹
    //               ↑ 用连字符连接
    //                     ↑ 转大写
  }
  
  /**
   * 生成指定长度的十六进制字符串
   */
  private generateHex(length: number): string {
    /**
     * Array(length).fill(0)：创建指定长度的数组，填充 0
     * 
     * .map(callback)：对每个元素应用回调，返回新数组
     * 
     * Math.floor(Math.random() * 16)：生成 0-15 的整数
     * .toString(16)：转换为十六进制
     * 
     * .join('')：把数组元素连接成字符串
     */
    return Array(length)
      .fill(0)
      .map(() => Math.floor(Math.random() * 16).toString(16))
      .join('');
  }
  
  private generateSessionToken(): string {
    return this.generateRandomString(32);
  }
  
  private generateRandomString(length: number): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
      //        ↑ charAt(index) 返回指定位置的字符
    }
    return result;
  }
  
  private getOSVersion(): string {
    const os = require('os');
    return os.release();  // 返回操作系统版本，如 "21.6.0"
  }
}
步骤 4：完整认证流程
// ========================================
// 📁 文件：src/auth-flow.ts
// 📝 功能：协调整个 OAuth 认证流程
// ========================================
import { OAuthServer } from './oauth-server';
import { GoogleOAuth } from './google-oauth';
import { DeviceFingerprint } from './device-fingerprint';
/**
 * ========================================
 * 📋 账户接口定义
 * ========================================
 */
interface Account {
  email: string;              // 用户邮箱
  refreshToken: string;       // 刷新令牌
  accessToken?: string;       // 访问令牌（可选，因为会过期）
  projectId: string;          // 项目 ID
  addedAt: number;            // 添加时间戳
  lastUsed: number;           // 最后使用时间戳
  enabled: boolean;           // 是否启用
  rateLimitResetTimes: {};    // 速率限制重置时间
  fingerprint: DeviceInfo;    // 设备指纹
}
/**
 * ========================================
 * 🔄 认证流程协调器
 * ========================================
 * 
 * 这个类协调整个 OAuth 流程：
 * 1. 启动本地服务器
 * 2. 打开浏览器
 * 3. 等待用户授权
 * 4. 交换令牌
 * 5. 保存账户
 */
class AuthFlow {
  /**
   * 类属性声明
   * 
   * private 表示只能在类内部访问
   * 这里声明了三个依赖的服务对象
   */
  private oauthServer: OAuthServer;
  private googleOAuth: GoogleOAuth;
  private deviceFingerprint: DeviceFingerprint;
  
  /**
   * 构造函数：创建实例时自动调用
   * 
   * constructor() 是特殊方法，用于初始化对象
   */
  constructor() {
    // 实例化依赖的服务
    this.oauthServer = new OAuthServer();
    this.googleOAuth = new GoogleOAuth();
    this.deviceFingerprint = new DeviceFingerprint();
  }
  
  /**
   * ========================================
   * 🚀 执行完整认证流程
   * ========================================
   * 
   * 这是主要的公共方法，调用它启动整个流程
   */
  async authenticate(): Promise<Account> {
    console.log('🚀 启动认证流程...\n');
    
    // ========== 步骤 1: 启动本地服务器 ==========
    console.log('步骤 1/7: 启动本地 OAuth 服务器...');
    
    /**
     * await 关键字：
     * - 暂停函数执行，等待 Promise 完成
     * - 获取 Promise 的结果值
     * - 只能在 async 函数中使用
     * 
     * 如果 Promise 被 reject，await 会抛出异常
     */
    const redirectUri = await this.oauthServer.start();
    //                  ↑ 等待服务器启动完成
    //                    ↑ redirectUri 是 start() 返回的服务器 URL
    console.log(`✅ 服务器启动: ${redirectUri}\n`);
    
    // ========== 步骤 2: 构建授权 URL ==========
    console.log('步骤 2/7: 构建 Google OAuth URL...');
    const authUrl = this.googleOAuth.buildAuthUrl(redirectUri + '/callback');
    //              ↑ 同步方法，直接返回结果，不需要 await
    console.log(`✅ 授权 URL 构建完成\n`);
    
    // ========== 步骤 3: 打开浏览器 ==========
    console.log('步骤 3/7: 打开浏览器...');
    console.log(`🌐 请在浏览器中完成登录: ${authUrl}\n`);
    await this.openBrowser(authUrl);
    
    // ========== 步骤 4-7: 等待回调并处理 ==========
    console.log('步骤 4/7: 等待 Google 回调...');
    console.log('⏳ 等待用户授权...\n');
    
    /**
     * try-catch-finally 结构：
     * - try: 可能出错的代码
     * - catch: 捕获并处理错误
     * - finally: 无论成功失败都会执行
     */
    try {
      // 等待用户在浏览器中完成授权
      // 服务器收到回调时会 resolve 这个 Promise
      const authCode = await this.waitForCallback();
      console.log(`✅ 收到授权码: ${authCode.substring(0, 20)}...\n`);
      //                            ↑ substring(0, 20) 截取前 20 个字符（保护隐私）
      
      // ========== 步骤 5: 交换 Token ==========
      console.log('步骤 5/7: 交换授权码获取 Token...');
      const tokens = await this.googleOAuth.exchangeCodeForTokens(
        authCode, 
        redirectUri + '/callback'
      );
      console.log('✅ Token 获取成功\n');
      
      // ========== 步骤 6: 生成设备指纹 ==========
      console.log('步骤 6/7: 生成设备指纹...');
      const fingerprint = this.deviceFingerprint.generate();
      console.log(`✅ 设备指纹: ${fingerprint.deviceId}\n`);
      
      // ========== 步骤 7: 保存账户 ==========
      console.log('步骤 7/7: 保存账户信息...');
      const account = await this.saveAccount(tokens, fingerprint);
      console.log('✅ 账户保存成功\n');
      
      console.log('🎉 认证流程完成！');
      console.log(`📧 账户: ${account.email}`);
      
      return account;
      
    } catch (error) {
      console.error('❌ 认证失败:', error);
      throw error;  // 重新抛出，让调用者处理
      //    ↑ throw 会立即终止函数执行
      
    } finally {
      /**
       * finally 块总是执行：
       * - 即使 try 成功
       * - 即使 catch 捕获了错误
       * - 即使有 return 语句
       * 
       * 用于清理资源，如关闭连接、释放内存
       */
      this.oauthServer.stop();  // 确保服务器关闭
    }
  }
  
  /**
   * ========================================
   * 🌐 跨平台打开浏览器
   * ========================================
   */
  private async openBrowser(url: string): Promise<void> {
    /**
     * require('child_process')：
     * Node.js 的子进程模块，可以执行系统命令
     * 
     * exec(command, callback)：
     * 执行命令，完成后调用回调
     */
    const { exec } = require('child_process');
    //    ↑ 解构赋值：从模块中提取 exec 函数
    
    const platform = process.platform;
    let command: string;
    
    /**
     * 不同操作系统打开浏览器的命令：
     * - macOS: open "url"
     * - Windows: start "" "url"
     * - Linux: xdg-open "url"
     */
    switch (platform) {
      case 'darwin':
        command = `open "${url}"`;
        break;
      case 'win32':
        command = `start "" "${url}"`;
        //         ↑ start 命令的第一个空字符串是窗口标题
        break;
      case 'linux':
        command = `xdg-open "${url}"`;
        //         ↑ xdg-open 是 Linux 的通用打开命令
        break;
      default:
        throw new Error(`不支持的平台: ${platform}`);
    }
    
    /**
     * 把 exec 包装成 Promise
     * 
     * exec 使用回调模式，但我们的代码使用 async/await
     * 需要把回调转换成 Promise
     */
    return new Promise((resolve, reject) => {
      exec(command, (error: any) => {
        //          ↑ error 参数：如果命令执行失败，包含错误信息
        //                       如果成功，是 null
        if (error) {
          reject(error);
        } else {
          resolve();  // 无参数，因为 Promise<void>
        }
      });
    });
  }
  
  /**
   * 等待 OAuth 回调
   * 
   * 实际实现会更复杂，需要和 OAuthServer 协调
   */
  private waitForCallback(): Promise<string> {
    return new Promise((resolve) => {
      // 实际实现会使用 EventEmitter 或其他机制
      // 这里简化为模拟
      setTimeout(() => resolve('mock-code'), 1000);
    });
  }
  
  /**
   * ========================================
   * 💾 保存账户到配置文件
   * ========================================
   */
  private async saveAccount(tokens: Tokens, fingerprint: DeviceInfo): Promise<Account> {
    /**
     * require('fs').promises：
     * Node.js 文件系统模块的 Promise 版本
     * 
     * 相比回调版本更适合 async/await
     */
    const fs = require('fs').promises;
    const path = require('path');
    
    // 配置文件路径
    const configDir = path.join(process.env.HOME || '', '.config', 'opencode');
    const accountsFile = path.join(configDir, 'antigravity-accounts.json');
    
    // 读取现有账户（如果存在）
    let data: any = { version: 3, accounts: [] };
    try {
      const existing = await fs.readFile(accountsFile, 'utf-8');
      //                              ↑ 文件路径  ↑ 编码
      data = JSON.parse(existing);
      //     ↑ 把 JSON 字符串解析为对象
    } catch (e) {
      // 文件不存在，使用默认值
      // 这里忽略错误是有意的
    }
    
    // 获取用户邮箱
    const email = await this.getEmailFromToken(tokens.accessToken);
    
    // 构建新账户对象
    const newAccount: Account = {
      email,
      refreshToken: tokens.refreshToken,
      projectId: email,  // 使用邮箱作为项目 ID
      addedAt: Date.now(),
      lastUsed: Date.now(),
      enabled: true,
      rateLimitResetTimes: {},
      fingerprint
    };
    
    /**
     * findIndex：查找数组中满足条件的第一个元素的索引
     * 如果没找到，返回 -1
     * 
     * (a: Account) => a.email === email
     * ↑ 箭头函数作为查找条件
     * ↑ a 是数组中的每个元素
     * ↑ 返回 true 表示找到了
     */
    const existingIndex = data.accounts.findIndex((a: Account) => a.email === email);
    
    if (existingIndex >= 0) {
      // 更新现有账户
      data.accounts[existingIndex] = newAccount;
      console.log('📝 更新现有账户');
    } else {
      // 添加新账户
      data.accounts.push(newAccount);
      //              ↑ push 在数组末尾添加元素
      console.log('📝 添加新账户');
    }
    
    // 确保目录存在
    await fs.mkdir(configDir, { recursive: true });
    //                         ↑ recursive: true 表示递归创建目录
    //                           如果父目录不存在也会创建
    
    // 写入文件
    await fs.writeFile(accountsFile, JSON.stringify(data, null, 2));
    //                               ↑ 第二个参数 null 是 replacer（可选）
    //                                       ↑ 第三个参数 2 是缩进空格数（美化输出）
    
    return newAccount;
  }
  
  /**
   * ========================================
   * 👤 获取用户邮箱
   * ========================================
   * 
   * 使用 access_token 调用 Google Userinfo API
   */
  private async getEmailFromToken(accessToken: string): Promise<string> {
    const response = await fetch(
      'https://www.googleapis.com/oauth2/v3/userinfo',
      {
        headers: {
          /**
           * Authorization 请求头：
           * 格式：Bearer <access_token>
           * 
           * Bearer 是一种授权类型，表示持有令牌即可访问
           */
          'Authorization': `Bearer ${accessToken}`
        }
      }
    );
    
    if (!response.ok) {
      throw new Error('Failed to get user info');
    }
    
    /**
     * Google Userinfo API 返回格式：
     * {
     *   sub: "1234567890",          // 用户唯一 ID
     *   name: "John Doe",           // 姓名
     *   given_name: "John",         // 名
     *   family_name: "Doe",         // 姓
     *   picture: "https://...",     // 头像 URL
     *   email: "john@example.com",  // 邮箱
     *   email_verified: true,       // 邮箱是否验证
     *   locale: "en"                // 语言偏好
     * }
     */
    const userInfo = await response.json();
    return userInfo.email;
  }
}
// ========================================
// 🏃 运行主程序
// ========================================
/**
 * 主函数
 * 
 * 使用 async 函数包装，因为顶层 await 需要特殊配置
 * （Node.js 14+ 支持，但需要 ES modules）
 */
async function main() {
  const auth = new AuthFlow();
  await auth.authenticate();
}
/**
 * 调用主函数并处理错误
 * 
 * .catch(console.error) 等价于：
 * .catch((error) => console.error(error))
 * 
 * 如果 Promise 被 reject，会打印错误信息
 */
main().catch(console.error);
---
📚 第四部分：重要知识深度扩展
1. 事件循环（Event Loop）详解
/**
 * ========================================
 * 🔄 Node.js 事件循环详解
 * ========================================
 * 
 * JavaScript 是单线程的，但通过事件循环实现并发
 * 
 * 核心概念：
 * - 调用栈（Call Stack）：执行同步代码
 * - 任务队列（Task Queue）：存放异步回调
 * - 微任务队列（Microtask Queue）：存放 Promise 回调
 */
// 示例：理解执行顺序
console.log('1. 同步代码');  // 第 1 个执行
setTimeout(() => {
  console.log('4. setTimeout 回调（宏任务）');  // 第 4 个执行
}, 0);
Promise.resolve().then(() => {
  console.log('3. Promise 回调（微任务）');  // 第 3 个执行
});
console.log('2. 同步代码');  // 第 2 个执行
/**
 * 输出顺序：1 → 2 → 3 → 4
 * 
 * 为什么？
 * 1. 同步代码立即执行：1, 2
 * 2. 微任务优先于宏任务：Promise 先执行
 * 3. 宏任务最后执行：setTimeout
 * 
 * 事件循环每次迭代：
 * 1. 执行一个宏任务（如 setTimeout 回调）
 * 2. 执行所有微任务（如 Promise 回调）
 * 3. 渲染 UI（浏览器环境）
 * 4. 重复
 */
2. HTTP 状态码完整解析
/**
 * ========================================
 * 📊 HTTP 状态码完整指南
 * ========================================
 */
const HTTP_STATUS = {
  // ========== 1xx 信息性状态码 ==========
  100: 'Continue',           // 继续发送请求体
  101: 'Switching Protocols', // 切换协议（如升级到 WebSocket）
  
  // ========== 2xx 成功 ==========
  200: 'OK',                 // 请求成功
  201: 'Created',            // 资源创建成功
  204: 'No Content',         // 成功但无响应体
  206: 'Partial Content',    // 部分内容（断点续传）
  
  // ========== 3xx 重定向 ==========
  301: 'Moved Permanently',  // 永久重定向（SEO 重要）
  302: 'Found',              // 临时重定向
  304: 'Not Modified',       // 资源未修改（使用缓存）
  307: 'Temporary Redirect', // 临时重定向（保持方法）
  308: 'Permanent Redirect', // 永久重定向（保持方法）
  
  // ========== 4xx 客户端错误 ==========
  400: 'Bad Request',        // 请求语法错误
  401: 'Unauthorized',       // 需要认证
  403: 'Forbidden',          // 无权限
  404: 'Not Found',          // 资源不存在
  405: 'Method Not Allowed', // 方法不允许
  408: 'Request Timeout',    // 请求超时
  409: 'Conflict',           // 资源冲突
  413: 'Payload Too Large',  // 请求体太大
  429: 'Too Many Requests',  // 请求过于频繁（限流）
  
  // ========== 5xx 服务器错误 ==========
  500: 'Internal Server Error', // 服务器内部错误
  502: 'Bad Gateway',           // 网关错误
  503: 'Service Unavailable',   // 服务不可用
  504: 'Gateway Timeout'        // 网关超时
};
/**
 * 在 OAuth 中常见的状态码：
 * - 200: Token 交换成功
 * - 400: 参数错误（如 code 无效）
 * - 401: 认证失败（如 client_secret 错误）
 * - 403: 权限不足（如 scope 未授权）
 * - 429: 请求太频繁
 */
3. Promise 高级用法
/**
 * ========================================
 * 🔮 Promise 高级技巧
 * ========================================
 */
// ========== Promise.all：并行执行 ==========
/**
 * 同时执行多个 Promise，全部成功后返回结果数组
 * 任何一个失败则整体失败
 */
async function fetchAllUsers() {
  const [user1, user2, user3] = await Promise.all([
    fetchUser('1'),
    fetchUser('2'),
    fetchUser('3')
  ]);
  // 三个请求并行执行，总时间 = 最慢的那个
  return [user1, user2, user3];
}
// ========== Promise.allSettled：不管成败 ==========
/**
 * 等待所有 Promise 完成，返回每个的状态和结果
 * 即使有失败的也会继续等待其他的
 */
async function tryFetchAll() {
  const results = await Promise.allSettled([
    fetchUser('1'),
    fetchUser('invalid'),  // 这个会失败
    fetchUser('3')
  ]);
  
  /**
   * results 格式：
   * [
   *   { status: 'fulfilled', value: user1 },
   *   { status: 'rejected', reason: Error },
   *   { status: 'fulfilled', value: user3 }
   * ]
   */
  
  const successfulUsers = results
    .filter((r) => r.status === 'fulfilled')
    .map((r) => (r as PromiseFulfilledResult<User>).value);
  
  return successfulUsers;
}
// ========== Promise.race：竞争 ==========
/**
 * 返回第一个完成的 Promise 的结果
 * 用于超时控制
 */
async function fetchWithTimeout(url: string, timeoutMs: number) {
  const timeout = new Promise<never>((_, reject) => {
    setTimeout(() => reject(new Error('Timeout')), timeoutMs);
  });
  
  const fetchPromise = fetch(url).then(r => r.json());
  
  // 谁先完成用谁
  return Promise.race([fetchPromise, timeout]);
}
// ========== 自定义 Promise 工具 ==========
/**
 * 带超时的 Promise 包装器
 */
function withTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
  let timeoutId: NodeJS.Timeout;
  
  const timeout = new Promise<T>((_, reject) => {
    timeoutId = setTimeout(() => {
      reject(new Error(`Operation timed out after ${ms}ms`));
    }, ms);
  });
  
  return Promise.race([promise, timeout]).finally(() => {
    clearTimeout(timeoutId);
  });
}
// 使用
const result = await withTimeout(
  fetch('https://api.example.com/data'),
  5000  // 5 秒超时
);
/**
 * 重试机制
 */
async function withRetry<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3,
  delay: number = 1000
): Promise<T> {
  let lastError: Error | null = null;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;
      console.log(`尝试 ${i + 1} 失败，${delay}ms 后重试...`);
      
      if (i < maxRetries - 1) {
        // 指数退避：1s, 2s, 4s...
        await new Promise(r => setTimeout(r, delay * Math.pow(2, i)));
      }
    }
  }
  
  throw lastError;
}
// 使用
const data = await withRetry(() => fetchUser('123'), 3, 1000);
4. TypeScript 高级类型
/**
 * ========================================
 * 🔷 TypeScript 高级类型技巧
 * ========================================
 */
// ========== 泛型约束 ==========
/**
 * 限制泛型必须具有某些属性
 */
interface HasId {
  id: string;
}
function findById<T extends HasId>(items: T[], id: string): T | undefined {
  //              ↑ T 必须有 id 属性
  return items.find(item => item.id === id);
}
// ========== 条件类型 ==========
/**
 * 根据条件选择类型
 */
type NonNullable<T> = T extends null | undefined ? never : T;
//                     ↑ 如果 T 是 null 或 undefined，结果是 never
//                                                    ↑ 否则结果是 T
type User = { name: string } | null;
type NonNullUser = NonNullable<User>;  // { name: string }
// ========== 映射类型 ==========
/**
 * 基于已有类型创建新类型
 */
type Readonly<T> = {
  readonly [P in keyof T]: T[P];
  //       ↑ 遍历 T 的所有属性
  //               ↑ 加上 readonly 修饰符
};
interface Mutable {
  name: string;
  age: number;
}
type ImmutablePerson = Readonly<Mutable>;
// 等价于：
// {
//   readonly name: string;
//   readonly age: number;
// }
// ========== 模板字面量类型 ==========
/**
 * 字符串字面量类型的模板
 */
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
type Endpoint = '/users' | '/posts';
type Route = `${HttpMethod} ${Endpoint}`;
// 结果：'GET /users' | 'GET /posts' | 'POST /users' | 'POST /posts' | ...
// ========== 类型守卫 ==========
/**
 * 自定义类型检查函数
 */
interface Cat {
  meow(): void;
}
interface Dog {
  bark(): void;
}
function isCat(animal: Cat | Dog): animal is Cat {
  //                               ↑ 类型谓词
  return (animal as Cat).meow !== undefined;
}
function makeSound(animal: Cat | Dog) {
  if (isCat(animal)) {
    animal.meow();  // TypeScript 知道这里是 Cat
  } else {
    animal.bark();  // TypeScript 知道这里是 Dog
  }
}
5. 安全最佳实践
/**
 * ========================================
 * 🔒 OAuth 安全最佳实践
 * ========================================
 */
// ========== 1. 永远使用 HTTPS ==========
// 所有 OAuth 通信必须通过 HTTPS
// 本地开发时可以用 localhost（HTTP），但生产必须 HTTPS
// ========== 2. 验证 State 参数 ==========
class SecureOAuth {
  private pendingStates = new Map<string, number>();
  //                       ↑ Map 存储 state 和创建时间
  
  generateState(): string {
    const state = crypto.randomBytes(32).toString('hex');
    this.pendingStates.set(state, Date.now());
    return state;
  }
  
  validateState(state: string): boolean {
    const createdAt = this.pendingStates.get(state);
    
    if (!createdAt) {
      console.error('未知的 state，可能是 CSRF 攻击');
      return false;
    }
    
    // 10 分钟过期
    if (Date.now() - createdAt > 10 * 60 * 1000) {
      console.error('State 已过期');
      this.pendingStates.delete(state);
      return false;
    }
    
    // 使用后立即删除，防止重放攻击
    this.pendingStates.delete(state);
    return true;
  }
}
// ========== 3. 使用 PKCE ==========
/**
 * PKCE（Proof Key for Code Exchange）
 * 防止授权码拦截攻击
 */
class PKCEFlow {
  private codeVerifier: string = '';
  
  async startAuth(): Promise<string> {
    // 生成随机 code_verifier
    this.codeVerifier = crypto.randomBytes(32).toString('base64url');
    
    // 计算 code_challenge
    const codeChallenge = crypto
      .createHash('sha256')
      .update(this.codeVerifier)
      .digest('base64url');
    
    // 授权 URL 包含 code_challenge
    return `https://accounts.google.com/o/oauth2/v2/auth?` +
      `code_challenge=${codeChallenge}&` +
      `code_challenge_method=S256&...`;
  }
  
  async exchangeCode(code: string): Promise<Tokens> {
    // 交换时包含 code_verifier
    const response = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      body: new URLSearchParams({
        code,
        code_verifier: this.codeVerifier,  // 关键！
        // ... 其他参数
      })
    });
    
    return response.json();
  }
}
// ========== 4. 安全存储令牌 ==========
/**
 * 令牌存储最佳实践
 */
class SecureTokenStorage {
  /**
   * 不同环境的存储方式：
   * - 桌面应用：操作系统密钥链
   * - 浏览器：HttpOnly Cookie（服务端）或内存（前端）
   * - 移动应用：Keychain (iOS) / Keystore (Android)
   */
  
  async storeToken(token: string): Promise<void> {
    const platform = process.platform;
    
    if (platform === 'darwin') {
      // macOS: 使用 Keychain
      const { exec } = require('child_process');
      exec(`security add-generic-password -a "myapp" -s "oauth" -w "${token}"`);
    } else if (platform === 'win32') {
      // Windows: 使用 Credential Manager 或 DPAPI
      // 需要 node-keytar 或类似库
    } else {
      // Linux: 使用 secret-service 或加密文件
    }
  }
}
// ========== 5. 令牌刷新策略 ==========
class TokenManager {
  private accessToken: string = '';
  private refreshToken: string = '';
  private expiresAt: number = 0;
  
  /**
   * 主动刷新策略：
   * 在令牌过期前提前刷新，避免请求失败
   */
  async getValidToken(): Promise<string> {
    // 提前 5 分钟刷新
    const BUFFER = 5 * 60 * 1000;
    
    if (Date.now() + BUFFER >= this.expiresAt) {
      await this.refresh();
    }
    
    return this.accessToken;
  }
  
  private async refresh(): Promise<void> {
    try {
      const response = await fetch('https://oauth2.googleapis.com/token', {
        method: 'POST',
        body: new URLSearchParams({
          refresh_token: this.refreshToken,
          grant_type: 'refresh_token',
          // ...
        })
      });
      
      const data = await response.json();
      this.accessToken = data.access_token;
      this.expiresAt = Date.now() + (data.expires_in * 1000);
      
    } catch (error) {
      // 刷新失败，可能需要重新授权
      console.error('Token 刷新失败，需要重新登录');
      throw new Error('Re-authentication required');
    }
  }
}
---
🎯 第五部分：调用流程可视化
┌─────────────────────────────────────────────────────────────────────────────┐
│                         OAuth 2.0 完整调用流程                               │
└─────────────────────────────────────────────────────────────────────────────┘
用户                      本地服务器                 Google                Antigravity API
 │                           │                        │                        │
 │  1. 调用 main()           │                        │                        │
 │  ─────────────────>       │                        │                        │
 │                           │                        │                        │
 │  2. new AuthFlow()        │                        │                        │
 │  ─────────────────>       │                        │                        │
 │                           │                        │                        │
 │  3. authenticate()        │                        │                        │
 │  ─────────────────────────│──────────────────────> │                        │
 │                           │                        │                        │
 │  4. oauthServer.start()   │                        │                        │
 │       (启动 HTTP 服务器)   │                        │                        │
 │  <─────────────────────── │                        │                        │
 │       返回: localhost:4120│                        │                        │
 │                           │                        │                        │
 │  5. buildAuthUrl()        │                        │                        │
 │       (构建授权 URL)       │                        │                        │
 │                           │                        │                        │
 │  6. openBrowser()         │                        │                        │
 │       (打开浏览器)         │                        │                        │
 │  ═══════════════════════════════════════════════> │                        │
 │                           │        用户在浏览器登录  │                        │
 │                           │                        │                        │
 │  7. 用户登录并授权         │                        │                        │
 │  ════════════════════════════════════════════════>│                        │
 │                           │                        │                        │
 │  8. Google 重定向到 localhost:4120/callback?code=xxx                        │
 │  <═══════════════════════ │ <═════════════════════ │                        │
 │                           │                        │                        │
 │  9. handleCallback()      │                        │                        │
 │       (处理回调，提取 code)│                        │                        │
 │  <─────────────────────── │                        │                        │
 │                           │                        │                        │
 │  10. exchangeCodeForTokens()                       │                        │
 │       (用 code 换 token)   │                        │                        │
 │  ─────────────────────────│──────────────────────> │                        │
 │                           │    POST /token         │                        │
 │                           │    code=xxx            │                        │
 │                           │    client_secret=yyy   │                        │
 │  <─────────────────────── │ <───────────────────── │                        │
 │       返回: access_token, │                        │                        │
 │             refresh_token │                        │                        │
 │                           │                        │                        │
 │  11. getEmailFromToken()  │                        │                        │
 │       (获取用户信息)       │                        │                        │
 │  ─────────────────────────│──────────────────────> │                        │
 │  <─────────────────────── │ <───────────────────── │                        │
 │       返回: email         │                        │                        │
 │                           │                        │                        │
 │  12. saveAccount()        │                        │                        │
 │       (保存到配置文件)     │                        │                        │
 │  <─────────────────────── │                        │                        │
 │                           │                        │                        │
 │  13. 后续 API 调用         │                        │                        │
 │  ─────────────────────────│────────────────────────│───────────────────────>│
 │       Authorization:      │                        │                        │
 │       Bearer access_token │                        │                        │
 │  <─────────────────────── │────────────────────────│───────────────────────<│
 │       返回: API 响应       │                        │                        │
 │                           │                        │                        │
 │  14. 当 access_token 过期  │                        │                        │
 │  ─────────────────────────│──────────────────────> │                        │
 │       POST /token         │                        │                        │
 │       refresh_token=zzz   │                        │                        │
 │  <─────────────────────── │ <───────────────────── │                        │
 │       返回: 新的           │                        │                        │
 │       access_token        │                        │                        │
 │                           │                        │                        │
 ▼                           ▼                        ▼                        ▼
---
📝 关键知识点总结
| 主题 | 关键点 |
|------|--------|
| TypeScript 类型 | : type 类型注解、interface 接口、<T> 泛型、? 可选、\| 联合类型 |
| 回调函数 | 作为参数传递的函数，在异步操作完成后被调用 |
| Promise | new Promise((resolve, reject) => {...}) 封装异步操作 |
| async/await | async 标记异步函数，await 等待 Promise 完成 |
| HTTP 服务器 | createServer(回调) 创建，server.listen(端口, 回调) 启动 |
| OAuth 2.0 | 授权码流程：授权 URL → code → token → API 调用 |
| 安全机制 | state 防 CSRF、PKCE 防拦截、refresh_token 长期访问 |
| 事件循环 | 同步代码 → 微任务（Promise）→ 宏任务（setTimeout） |
希望这份超详细的注释版本能帮助你理解代码！如果有任何不清楚的地方，随时问我！ 🚀