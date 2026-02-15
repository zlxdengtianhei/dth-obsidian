# `server/routes/maps.js` - 中文说明文档

本文档详细解释 `server/routes/maps.js` 文件的代码和功能。

## 文件概述

`server/routes/maps.js` 文件定义了所有与地图相关的 API 端点（也称为路由）。在 `index.js` 中，我们通过 `app.use('/api/maps', mapsRoutes);` 将所有以 `/api/maps` 开头的请求都引导到这个文件中来处理。

这个文件利用了 Express 的 `Router` 功能，将相关的路由组织在一起，使得代码结构更清晰。它本身不执行复杂的业务逻辑（如调用 Google Maps API），而是将这些任务委托给 `services/mapsService.js` 文件中的函数。

你可以将其类比为：
*   **C++**: 一个专门处理特定类型网络请求的类或一组函数，它会接收请求数据，进行初步验证，然后调用其他模块（服务层）来完成实际工作。
*   **Python (Flask)**: 一个 Flask Blueprint，用于组织一组相关的视图函数（路由）。
*   **Python (Django)**: `urls.py` 文件中的一部分，定义了特定 URL 模式到视图函数的映射。

## 代码详解

```javascript
// server/routes/maps.js
const express = require('express');
const router = express.Router();
const mapsService = require('../services/mapsService');
```

*   **`const express = require('express');`**: 导入 Express 框架。
*   **`const router = express.Router();`**: 
    *   创建 Express 的一个 `Router` 实例。`Router` 就像一个 "迷你" 的 `app` 对象，你可以用它来定义路由、使用中间件，但它是模块化的。这允许我们将路由定义分散到不同的文件中。
    *   **关键技术**: Express Router。这是实现路由模块化的核心机制。
*   **`const mapsService = require('../services/mapsService');`**: 
    *   导入位于上级目录 (`../`) 下 `services` 文件夹中的 `mapsService.js` 文件。
    *   `mapsService` 预计会导出一个包含与 Google Maps API 交互的函数的对象。
    *   **关键技术**: 模块化与服务层。这是**关注点分离 (Separation of Concerns)** 的一个例子。路由层 (`routes`) 负责处理 HTTP 请求和响应，以及基本的参数验证；服务层 (`services`) 负责封装业务逻辑和与外部服务（如 Google Maps API）的交互。这使得代码更易于测试、维护和重用。
    *   类比：C++ 或 Python 代码中，一个处理用户输入的模块调用另一个专门负责数据库操作或网络通信的模块。

### 路由 1: 搜索附近奶茶店 (`/nearby`)

```javascript
/**
 * 搜索附近的奶茶店
 * GET /api/maps/nearby
 * ... (参数注释)
 */
router.get('/nearby', async (req, res, next) => {
  try {
    const { latitude, longitude, radius, pagetoken } = req.query;
    
    // 如果提供了pagetoken，直接使用
    if (pagetoken) {
      const result = await mapsService.searchNearbyShops({ pagetoken });
      return res.json(result);
    }
    
    // 验证必要参数
    if (!latitude || !longitude) {
      return res.status(400).json({ 
        status: 'error', 
        message: '必须提供经纬度参数' 
      });
    }
    
    const result = await mapsService.searchNearbyShops({
      latitude: parseFloat(latitude),
      longitude: parseFloat(longitude),
      radius: radius ? parseInt(radius) : undefined
    });
    
    res.json(result);
    
  } catch (error) {
    next(error);
  }
});
```

*   **`router.get('/nearby', ...)`**: 定义一个处理 HTTP GET 请求的路由。由于这个 `router` 实例在 `index.js` 中被挂载到了 `/api/maps` 路径下，所以这个路由实际对应的完整 URL 是 `GET /api/maps/nearby`。
*   **`async (req, res, next) => { ... }`**: 
    *   这是一个 **异步** 路由处理函数。使用 `async` 关键字是因为函数内部需要调用 `mapsService` 中的异步函数（可能涉及网络请求），并使用 `await` 来等待其完成。
    *   **关键技术**: `async/await`。这是现代 JavaScript 中处理异步操作（如网络请求、文件读写）的标准方式，它使得异步代码看起来更像同步代码，提高了可读性。Node.js 的核心是事件驱动和非阻塞 I/O，`async/await` 是构建在其 Promise 机制之上的语法糖。
    *   类比：C++ 中使用 `std::async`, `std::future` 或 Boost.Asio 等库进行异步编程；Python 中使用 `asyncio` 库和 `async/await` 关键字。
    *   **参数**: 
        *   `req` (Request): 代表客户端发来的 HTTP 请求的对象。包含了请求的所有信息，如 URL、查询参数、请求头、请求体等。
        *   `res` (Response): 代表服务器要发送给客户端的 HTTP 响应的对象。用于设置响应状态码、响应头和发送响应体。
        *   `next`: 一个函数，用于将控制权传递给下一个中间件或路由处理器。如果调用 `next(error)` 并传入一个错误对象，Express 会跳过所有后续的普通中间件和路由，直接将错误交给错误处理中间件（在 `index.js` 中定义）。
*   **`try...catch`**: 用于捕获路由处理函数中可能发生的同步或异步错误。
*   **`const { latitude, longitude, radius, pagetoken } = req.query;`**: 
    *   从 `req.query` 对象中提取 URL 查询参数。`req.query` 是 Express 自动解析 URL 中 `?` 后面的键值对（如 `/api/maps/nearby?latitude=30&longitude=120&radius=1000`）而生成的对象。
    *   这里使用了 JavaScript 的对象解构赋值语法，是一种简洁的提取对象属性的方式。
    *   **注意**: 从 `req.query` 获取的值**默认都是字符串类型**。
*   **分页令牌处理 (`if (pagetoken)`)**: Google Maps API 的 Nearby Search 结果可能是分页的。如果请求中带有 `pagetoken`（来自上一次请求的响应），则优先使用它来获取下一页结果，此时不再需要经纬度和半径。
*   **参数验证 (`if (!latitude || !longitude)`)**: 检查必需的参数是否存在。如果缺少，则：
    *   `res.status(400)`: 设置 HTTP 响应状态码为 400 (Bad Request)，表示客户端请求有问题。
    *   `.json(...)`: 发送一个 JSON 格式的错误响应。
    *   `return`: 提前结束函数执行，避免后续代码运行。
*   **调用服务层函数**: 
    *   `await mapsService.searchNearbyShops(...)`: 调用 `mapsService` 中对应的函数来执行实际的搜索逻辑。使用 `await` 等待异步操作完成。
    *   传递参数时：
        *   `parseFloat(latitude)`, `parseFloat(longitude)`: 将从 `req.query` 获取的字符串类型的经纬度转换为浮点数。
        *   `radius ? parseInt(radius) : undefined`: 如果 `radius` 参数存在，则将其转换为整数 (`parseInt`)；如果不存在，则传递 `undefined`（让 `mapsService` 使用其默认值）。这是三元运算符的用法。
*   **`res.json(result)`**: 如果一切顺利，将从 `mapsService` 获取的结果以 JSON 格式发送回客户端。Express 会自动设置 `Content-Type` 为 `application/json`。
*   **`next(error)`**: 如果在 `try` 块中发生任何错误（无论是 `mapsService` 调用失败还是其他意外错误），`catch` 块会捕获它，并通过 `next(error)` 将错误传递给 `index.js` 中定义的全局错误处理中间件。

### 路由 2: 地址地理编码 (`/geocode`)

```javascript
/**
 * 地址地理编码
 * GET /api/maps/geocode
 * ... (参数注释)
 */
router.get('/geocode', async (req, res, next) => {
  try {
    const { address } = req.query;
    
    if (!address) {
      return res.status(400).json({...});
    }
    
    const result = await mapsService.geocodeAddress(address);
    res.json(result);
    
  } catch (error) {
    next(error);
  }
});
```

*   **完整 URL**: `GET /api/maps/geocode`
*   **逻辑**: 与 `/nearby` 非常相似。
    1.  使用 `async/await`。
    2.  从 `req.query` 获取 `address` 参数。
    3.  验证 `address` 是否存在。
    4.  调用 `mapsService.geocodeAddress(address)` 执行地理编码。
    5.  成功则返回 JSON 结果。
    6.  失败则通过 `next(error)` 传递错误。

### 路由 3: 坐标反向地理编码 (`/reverse-geocode`)

```javascript
/**
 * 坐标反向地理编码
 * GET /api/maps/reverse-geocode
 * ... (参数注释)
 */
router.get('/reverse-geocode', async (req, res, next) => {
  try {
    console.log('收到反向地理编码请求:', req.query);
    const { latitude, longitude } = req.query;
    
    if (!latitude || !longitude) {
      console.error(...);
      return res.status(400).json({...});
    }
    
    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    
    if (isNaN(lat) || isNaN(lng)) { // 进一步验证是否为有效数字
      console.error(...);
      return res.status(400).json({...});
    }
    
    console.log(`处理反向地理编码: (${lat}, ${lng})`);
    const result = await mapsService.reverseGeocode(lat, lng);
    
    console.log('反向地理编码成功:', result);
    res.json(result);
    
  } catch (error) {
    console.error('反向地理编码路由错误:', error);
    // if (!res.headersSent) { // 这个检查通常不是必须的，如果已发送响应再调用next会出错，但这里的结构保证了不会
      next(error);
    // }
  }
});
```

*   **完整 URL**: `GET /api/maps/reverse-geocode`
*   **逻辑**: 与前两个类似，但增加了更详细的验证和日志记录。
    1.  获取 `latitude` 和 `longitude` 参数。
    2.  验证参数是否存在。
    3.  使用 `parseFloat` 转换参数为数字。
    4.  **额外验证**: 使用 `isNaN()` (Is Not a Number) 检查转换后的值是否确实是有效的数字。防止传入非数字字符串（如 `?latitude=abc`）导致后续错误。
    5.  调用 `mapsService.reverseGeocode(lat, lng)`。
    6.  返回结果或传递错误。
    7.  添加了 `console.log` 和 `console.error` 来在服务器端记录请求处理过程和潜在问题，这对于调试非常有用。

### 路由 4: 获取地点详情 (`/place/:placeId`)

```javascript
/**
 * 获取地点详情
 * GET /api/maps/place/:placeId
 * ... (参数注释)
 */
router.get('/place/:placeId', async (req, res, next) => {
  try {
    const { placeId } = req.params;
    
    if (!placeId) {
      // 理论上，如果路由匹配成功，placeId 总会存在，但验证一下更健壮
      return res.status(400).json({...});
    }
    
    const result = await mapsService.getPlaceDetails(placeId);
    res.json(result);
    
  } catch (error) {
    next(error);
  }
});
```

*   **完整 URL**: `GET /api/maps/place/<实际的地点ID>` (例如 `/api/maps/place/ChIJN1t_tDeuEmsRUsoyG83frY4`)
*   **`:placeId`**: 这是**路径参数 (Path Parameter)** 的定义方式。Express 会将 URL 中这部分实际的值提取出来。
*   **`const { placeId } = req.params;`**: 
    *   从 `req.params` 对象中提取路径参数。
    *   **关键技术**: 路径参数。这与查询参数 (`req.query`) 不同，路径参数是 URL 路径本身的一部分，通常用于标识特定的资源（如此处的特定地点）。
    *   类比：Flask 中的 `<variable_name>` 或 Django 的 URL 捕获组。
*   **逻辑**: 
    1.  从 `req.params` 获取 `placeId`。
    2.  验证 `placeId` (虽然通常因为路由匹配机制而总会存在)。
    3.  调用 `mapsService.getPlaceDetails(placeId)`。
    4.  返回结果或传递错误。

### 路由 5: 连接检查端点 (`/check`)

```javascript
// 添加连接检查端点
router.get('/check', (req, res) => {
  res.json({
    status: 'ok',
    message: 'API服务器正常运行',
    timestamp: new Date().toISOString(),
    googleApiKey: process.env.GOOGLE_MAPS_API_KEY ? '已配置' : '未配置'
  });
});
```

*   **完整 URL**: `GET /api/maps/check`
*   **目的**: 一个简单的、**同步**的端点，用于快速检查这个地图 API 路由模块是否正常加载并响应请求，以及检查 Google API 密钥是否已配置。
*   **同步处理**: 这个处理器没有 `async` 关键字，因为它不执行任何异步操作。它直接构造并发送响应。
*   **响应内容**: 返回一个包含状态、消息、当前时间戳和一个指示 API 密钥是否已在环境变量中设置的标志。

### 导出 Router

```javascript
module.exports = router;
```

*   将配置好的 `router` 对象导出，以便 `index.js` 文件可以通过 `require('./routes/maps')` 来导入和使用它。

## 总结

`server/routes/maps.js` 文件清晰地定义了所有地图相关的 API 接口。它有效地利用了 Express Router 进行模块化组织，并通过 `async/await` 处理异步服务调用。它还展示了如何处理查询参数 (`req.query`) 和路径参数 (`req.params`)，如何进行输入验证，以及如何通过调用服务层 (`mapsService`) 来分离关注点，并将错误统一传递给全局错误处理器。 