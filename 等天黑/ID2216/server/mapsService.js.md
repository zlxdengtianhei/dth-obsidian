# `server/services/mapsService.js` - 中文说明文档

本文档详细解释 `server/services/mapsService.js` 文件的代码和功能。

## 文件概述

`server/services/mapsService.js` 文件是后端服务的**服务层 (Service Layer)**。它封装了所有与 Google Maps Platform API 交互的逻辑。这意味着路由层 (`routes/maps.js`) 不需要知道如何调用 Google API、如何构建请求参数、或者如何处理 API 返回的原始数据，它只需要调用这个服务层提供的简单易懂的函数即可。

**核心职责**: 
1.  与 Google Maps API 进行 HTTP 通信（使用 `axios` 库）。
2.  获取并使用存储在环境变量中的 Google Maps API 密钥。
3.  根据需要构建发送给 Google API 的请求参数。
4.  处理 Google API 的响应，提取需要的数据。
5.  将 Google API 返回的原始数据**转换 (transform)** 成前端更容易使用的格式。
6.  实现一些健壮性功能，如**请求重试**。
7.  处理与 API 调用相关的错误。

你可以将其类比为：
*   **C++**: 一个封装了特定外部库（例如一个地理信息库或网络请求库）调用的类或模块。它提供了一个更高级、更易于使用的接口，隐藏了底层库的复杂性。
*   **Python**: 一个包含与外部 API（如 `requests` 库调用 Google Maps API）交互的函数或类的模块。它处理认证、参数构建、响应解析和错误处理。

## 代码详解

```javascript
const axios = require('axios');

// 获取Google API密钥
const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY;
```

*   **`const axios = require('axios');`**: 导入 `axios` 库。
    *   `axios` 是一个非常流行的基于 Promise 的 HTTP 客户端，可用于浏览器和 Node.js。它使得发送 HTTP 请求（GET, POST 等）和处理响应变得非常简单。
    *   **关键技术**: HTTP 客户端库。它封装了 Node.js 底层的 `http` 或 `https` 模块，提供了更方便的 API。
    *   类比：C++ 中的 `libcurl` 或 `cpprestsdk`；Python 中的 `requests` 库。
*   **`const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY;`**: 
    *   从环境变量中读取 Google Maps API 密钥，并存储在一个常量中，方便后续函数使用。
    *   这强调了 API 密钥必须通过环境变量配置，而不是硬编码在代码中。

### 辅助函数: 请求重试 (`axiosWithRetry`)

```javascript
// 添加请求重试逻辑
const axiosWithRetry = async (config, retries = 3, delay = 1000) => {
  try {
    return await axios(config);
  } catch (error) {
    if (retries === 0) {
      throw error; // 重试次数耗尽，抛出最终错误
    }
    
    // 检查是否是配额限制错误 (OVER_QUERY_LIMIT 或 HTTP 429)
    const isQuotaError = error.response && 
                         (error.response.data.status === 'OVER_QUERY_LIMIT' || 
                          error.response.status === 429);
    
    // 如果是配额错误，采用指数退避策略，增加延迟时间
    const retryDelay = isQuotaError ? delay * 2 : delay;
    
    console.log(`请求失败，${retries}次重试后在 ${retryDelay}ms 后重新尝试...`);
    // 等待指定的延迟时间
    await new Promise(resolve => setTimeout(resolve, retryDelay));
    
    // 递归调用自身，减少重试次数并传入新的延迟
    return axiosWithRetry(config, retries - 1, retryDelay);
  }
};
```

*   **目的**: 封装 `axios` 请求，在请求失败时自动进行重试。
*   **背景**: 调用外部 API (如 Google Maps) 时，请求可能会因为网络波动、临时服务器问题或达到速率/配额限制而失败。自动重试可以提高应用的健壮性。
*   **参数**: 
    *   `config`: 传递给 `axios` 的配置对象（包含 URL, method, params 等）。
    *   `retries = 3`: 允许的最大重试次数，默认为 3 次。
    *   `delay = 1000`: 初始重试延迟（毫秒），默认为 1 秒。
*   **逻辑**: 
    1.  使用 `async/await`，因为内部有异步操作 (`axios`, `setTimeout`)。
    2.  `try` 块：尝试执行 `axios(config)` 发送请求。
        *   如果成功，直接返回响应。
    3.  `catch` 块：如果 `axios` 请求抛出错误：
        *   检查 `retries` 是否已为 0。如果是，说明重试次数已用完，不再重试，直接 `throw error` 将错误向上抛出。
        *   **检查配额错误**: 
            *   `error.response`: 检查错误对象中是否有 `response` 属性，这表示服务器返回了错误响应（而不是请求本身设置错误或网络错误）。
            *   检查 `error.response.data.status === 'OVER_QUERY_LIMIT'` (Google API 特定状态码) 或 `error.response.status === 429` (HTTP Too Many Requests 状态码)。
        *   **计算重试延迟 (`retryDelay`)**: 
            *   如果是配额错误，将当前延迟时间 `delay` 乘以 2，实现 **指数退避 (Exponential Backoff)**。这是一种常见的策略，避免在 API 限制时过于频繁地重试。
            *   如果不是配额错误（可能是其他临时网络问题），则使用当前的 `delay`。
        *   打印重试日志。
        *   `await new Promise(resolve => setTimeout(resolve, retryDelay));`: 
            *   **关键技术**: 使用 `setTimeout` 和 `Promise` 来实现异步等待。`setTimeout(callback, ms)` 会在 `ms` 毫秒后执行 `callback`，但它本身不阻塞 `async` 函数。通过将其包装在 `new Promise()` 中，并在 `callback` (即 `resolve`) 被调用时解决 (resolve) 这个 Promise，我们可以使用 `await` 来等待 `setTimeout` 完成。
        *   **递归调用**: `return axiosWithRetry(config, retries - 1, retryDelay);` 递归地调用自身，将重试次数减 1，并传入可能更新过的 `retryDelay`。
*   **用法**: 后续的 API 调用函数不再直接使用 `axios(config)`，而是使用 `axiosWithRetry(config)`。

### 服务函数 1: 搜索附近奶茶店 (`searchNearbyShops`)

```javascript
const searchNearbyShops = async (params) => {
  try {
    const { latitude, longitude, radius = 1500, pagetoken } = params;
    
    let url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
    
    // 构建请求参数
    const requestParams = pagetoken 
      ? { /* pagetoken 参数 */ }
      : { /* 初始搜索参数 */ };
    
    // Google API 对 pagetoken 请求有延迟要求
    if (pagetoken) {
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
    
    // 使用带重试的 axios 发送请求
    const response = await axiosWithRetry({
      method: 'GET',
      url,
      params: requestParams
    });
    
    const { data } = response;
    
    // 检查 Google API 返回的状态
    if (data.status !== 'OK' && data.status !== 'ZERO_RESULTS') {
      throw new Error(`Google Places API错误: ${data.status}`);
    }
    
    // 转换数据格式
    return {
      shops: data.results.map(result => ({
        id: result.place_id,
        name: result.name,
        location: { /* ... */ },
        address: result.vicinity,
        rating: result.rating ? result.rating.toString() : null,
        photoUrl: result.photos ? `https://...` : null,
        open_now: result.opening_hours ? result.opening_hours.open_now : null,
        price_level: result.price_level
      })),
      nextPageToken: data.next_page_token || null,
      status: data.status
    };
    
  } catch (error) {
    console.error('搜索奶茶店出错:', error);
    throw error; // 将错误向上抛给路由层处理
  }
};
```

*   **参数**: 接收一个 `params` 对象，包含从路由层传递过来的参数。
*   **URL**: 指定 Google Places API Nearby Search 的端点。
*   **构建 `requestParams`**: 
    *   使用三元运算符判断：如果提供了 `pagetoken`，则请求参数只包含 `pagetoken` 和 `key`。
    *   否则（初始搜索），请求参数包含 `location` (格式为 "纬度,经度"), `radius`, `keyword` (硬编码为 'bubble tea', 表示我们只关心奶茶店), `type` (进一步限制地点类型), 和 `key`。
*   **`pagetoken` 延迟**: Google 文档指出，使用 `next_page_token` 时，需要等待一小段时间才能生效。这里强制等待 2 秒。
*   **发送请求**: 调用 `axiosWithRetry` 而不是 `axios`。
*   **处理响应 `data`**: 
    *   `data` 是 `axios` 响应对象中的实际数据部分 (即 Google API 返回的 JSON 对象)。
    *   检查 `data.status`。Google API 使用 `status` 字段表示操作结果。`OK` 表示成功找到结果，`ZERO_RESULTS` 表示搜索成功但没有找到匹配项（这也是一种成功状态），其他状态（如 `OVER_QUERY_LIMIT`, `REQUEST_DENIED`, `INVALID_REQUEST`）表示错误。
    *   如果状态不是 `OK` 或 `ZERO_RESULTS`，则抛出一个自定义错误。
*   **数据转换 (Mapping)**: 
    *   `data.results` 是 Google API 返回的地点数组。
    *   使用 `map()` 方法遍历 `data.results` 数组，将每个 Google API 的原始 `result` 对象转换成我们自己定义的、更简洁的 `shop` 对象格式。
    *   **字段映射**: 
        *   `id`: 使用 `result.place_id`。
        *   `name`: 使用 `result.name`。
        *   `location`: 从 `result.geometry.location` 提取 `lat` 和 `lng`。
        *   `address`: 使用 `result.vicinity` (附近地址描述)。
        *   `rating`: 将数字评分转为字符串，如果不存在则为 `null`。
        *   `photoUrl`: 如果 `result.photos` 数组存在，构建 Google Place Photos API 的 URL 来获取第一张照片；否则为 `null`。
        *   `open_now`: 从 `result.opening_hours` 获取（如果存在）。
        *   `price_level`: 直接使用。
    *   返回一个包含 `shops` 数组、`nextPageToken` (如果 Google 返回了的话) 和 `status` 的对象。
*   **错误处理**: `catch` 块捕获任何错误（来自 `axiosWithRetry` 或状态检查），打印错误日志，然后 `throw error` 将错误重新抛出，由调用者（路由层）处理。

### 服务函数 2: 地址地理编码 (`geocodeAddress`)

```javascript
const geocodeAddress = async (address) => {
  try {
    const url = 'https://maps.googleapis.com/maps/api/geocode/json';
    
    const response = await axiosWithRetry({
      method: 'GET',
      url,
      params: {
        address, // 传入地址字符串
        key: GOOGLE_MAPS_API_KEY
      }
    });
    
    const { data } = response;
    
    if (data.status !== 'OK') {
      throw new Error(`地理编码错误: ${data.status}`);
    }
    
    // Geocoding API 返回的 results 也是数组，通常取第一个
    const result = data.results[0];
    
    // 转换数据
    return {
      location: { /* ... */ },
      formattedAddress: result.formatted_address,
      placeId: result.place_id
    };
    
  } catch (error) {
    console.error('地理编码请求出错:', error);
    throw error;
  }
};
```

*   **URL**: Google Geocoding API 端点。
*   **参数**: `address` 字符串和 API 密钥。
*   **逻辑**: 
    1.  调用 `axiosWithRetry`。
    2.  检查 `data.status`。
    3.  从 `data.results[0]` (Geocoding API 通常返回一个最匹配的结果) 提取所需信息 (`geometry.location`, `formatted_address`, `place_id`)。
    4.  返回转换后的对象。
    5.  错误处理同上。

### 服务函数 3: 反向地理编码 (`reverseGeocode`)

```javascript
const reverseGeocode = async (latitude, longitude) => {
  try {
    console.log(...); // 添加了调试日志
    const url = 'https://maps.googleapis.com/maps/api/geocode/json'; // 同 Geocoding API
    
    const params = {
      latlng: `${latitude},${longitude}`, // 参数名是 latlng
      key: GOOGLE_MAPS_API_KEY
    };
    
    const response = await axiosWithRetry({...});
    console.log(...); // 添加了调试日志
    const { data } = response;
    
    if (data.status !== 'OK') {
      console.error(...); // 更详细的错误日志
      throw new Error(...);
    }
    
    if (!data.results || data.results.length === 0) {
      console.error(...);
      throw new Error('反向地理编码无结果'); // 处理没有结果的情况
    }
    
    // 转换数据
    const result = {
      address: data.results[0].formatted_address,
      addressComponents: data.results[0].address_components // 返回详细的地址组件
    };
    
    console.log(...); // 添加了调试日志
    return result;
    
  } catch (error) {
    console.error('反向地理编码请求出错:', error);
    // 添加了更详细的错误类型判断和日志记录
    if (error.response) { ... } 
    else if (error.request) { ... } 
    else { ... }
    throw error;
  }
};
```

*   **URL**: 仍然使用 Geocoding API 端点，但参数不同。
*   **参数**: `latlng` (格式 "纬度,经度") 和 API 密钥。
*   **逻辑**: 
    1.  调用 `axiosWithRetry`。
    2.  检查 `data.status`。
    3.  **额外检查**: 检查 `data.results` 是否存在且不为空数组，因为即使状态为 `OK`，也可能没有返回具体地址结果。
    4.  从 `data.results[0]` 提取 `formatted_address` 和 `address_components` (详细的地址组成部分，如国家、城市、街道等)。
    5.  返回转换后的对象。
    6.  添加了更多的 `console.log` 和 `console.error` 用于调试。
    7.  `catch` 块中增加了对不同类型网络错误（服务器有响应 vs. 无响应 vs. 请求设置错误）的区分和日志记录，有助于排查问题。

### 服务函数 4: 获取地点详情 (`getPlaceDetails`)

```javascript
const getPlaceDetails = async (placeId) => {
  try {
    const url = 'https://maps.googleapis.com/maps/api/place/details/json';
    
    const response = await axiosWithRetry({
      method: 'GET',
      url,
      params: {
        place_id: placeId, // 使用地点 ID
        // 指定需要获取的字段，减少不必要的数据传输和费用
        fields: 'name,rating,formatted_address,geometry,photos,opening_hours,website,price_level,review',
        key: GOOGLE_MAPS_API_KEY
      }
    });
    
    const { data } = response;
    
    if (data.status !== 'OK') {
      throw new Error(`获取地点详情错误: ${data.status}`);
    }
    
    // Place Details API 返回的数据在 data.result (注意是 result 不是 results)
    const { result } = data;
    
    // 转换数据
    return {
      id: placeId, // 使用传入的 placeId
      name: result.name,
      address: result.formatted_address,
      location: { /* ... */ },
      rating: result.rating,
      photos: result.photos ? result.photos.map(photo => ({
        reference: photo.photo_reference,
        // 构建照片 URL
        url: `https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=${photo.photo_reference}&key=${GOOGLE_MAPS_API_KEY}`
      })) : [],
      opening_hours: result.opening_hours, // 可以直接使用，或进一步处理
      website: result.website,
      price_level: result.price_level,
      reviews: result.reviews // 用户评价信息
    };
    
  } catch (error) {
    console.error('获取地点详情出错:', error);
    throw error;
  }
};
```

*   **URL**: Google Places API Place Details 端点。
*   **参数**: 
    *   `place_id`: 要查询的地点 ID。
    *   `fields`: **非常重要**。指定需要返回的具体字段列表。Google Place Details API 按请求的字段计费，只请求需要的字段可以节省成本并提高性能。
    *   `key`: API 密钥。
*   **逻辑**: 
    1.  调用 `axiosWithRetry`。
    2.  检查 `data.status`。
    3.  Place Details API 的结果在 `data.result` 对象中 (注意是单数 `result`)。
    4.  **数据转换**: 从 `data.result` 提取所需字段，构建返回给路由层的对象。
        *   照片处理: 遍历 `result.photos` 数组 (如果存在)，为每张照片构建访问 URL。
        *   其他字段如 `opening_hours`, `website`, `reviews` 等根据需要提取。
    5.  错误处理同上。

### 导出服务函数

```javascript
module.exports = {
  searchNearbyShops,
  geocodeAddress,
  reverseGeocode,
  getPlaceDetails
};
```

*   将所有定义的服务函数放在一个对象中，并通过 `module.exports` 导出。
*   这样，其他文件（如 `routes/maps.js`）就可以通过 `require('../services/mapsService')` 导入这个对象，并调用其中的函数，例如 `mapsService.searchNearbyShops(...)`。

## 总结

`server/services/mapsService.js` 是一个典型的服务层实现。它通过封装对外部 Google Maps API 的调用，为应用的路由层提供了清晰、简洁的接口。关键技术包括：
*   使用 `axios` 进行 HTTP 请求。
*   通过环境变量管理 API 密钥。
*   实现请求重试和指数退避策略以提高健壮性。
*   调用不同的 Google Maps API 端点 (Nearby Search, Geocoding, Place Details)。
*   解析和转换 API 响应数据，使其更符合应用内部的需求。
*   通过 `module.exports` 导出功能模块。
这种分层结构（路由层调用服务层）是构建可维护、可测试的后端应用的常用模式。 