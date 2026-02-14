# 奶茶地图后端服务 - 中文说明文档

本文档是对 `server/README.md` 的中文解释和补充说明，旨在帮助初学者理解该后端服务。

## 概述

这个目录 (`server`) 包含了 "奶茶地图" 应用的后端服务代码。后端服务就像是应用的 "大脑" 和 "数据中心"，它不直接展示用户界面，而是负责处理来自前端（比如手机App或网页）的请求，执行核心逻辑（例如与外部服务交互），并返回数据给前端。

你可以将后端服务类比于：
*   **C/C++**: 一个后台运行的守护进程 (daemon) 或服务程序，它监听网络端口，接收客户端连接并处理请求。
*   **Python**: 一个使用像 Flask 或 Django 框架构建的 Web 服务器应用，它定义了不同的 URL 路径 (路由) 来执行特定的功能。

本项目后端主要使用 **Node.js** 平台和 **Express.js** 框架构建。
*   **Node.js**: 允许你用 JavaScript 编写服务器端代码。它与浏览器中的 JavaScript 不同，Node.js 可以直接操作文件系统、网络等。可以认为它提供了一个类似于 C/C++ 程序运行环境或 Python 解释器的环境，但专门为 JavaScript 设计，并且特别擅长处理并发的网络请求（I/O密集型任务）。
*   **Express.js**: 一个 Node.js 的 Web 应用框架，极大地简化了创建 Web 服务器和 API 的过程。它提供了路由、中间件等核心功能。你可以把它想象成 Python 中的 Flask 或 Django，或者 C++ 中一些 Web 框架（虽然 C++ 不常用作 Web 后端）。

## 功能

后端服务提供了以下核心功能，都是通过 API (应用程序接口) 的形式暴露给前端调用的：

1.  **搜索附近奶茶店**: 根据用户提供的地理位置（经纬度），查找一定范围内的奶茶店。这通常需要调用地图服务提供商（本项目是 Google Maps）的 API。
2.  **地址地理编码 (Geocoding)**: 将用户输入的文本地址（如 "北京市海淀区中关村"）转换成精确的经纬度坐标。
3.  **反向地理编码 (Reverse Geocoding)**: 将经纬度坐标转换成人类可读的地址描述。
4.  **获取地点详情**: 根据一个地点的唯一标识符 (Place ID)，获取该地点的详细信息，如名称、地址、评分、照片、营业时间等。

这些功能最终都是通过调用 **Google Maps Platform APIs** 实现的。后端服务起到了一个 **代理** 和 **封装** 的作用：
*   **代理**: 前端不直接调用 Google Maps API，而是调用我们的后端 API。这样做的好处是：
    *   **安全**: Google Maps API 密钥 (API Key) 存储在后端，不会暴露给前端用户，防止密钥被滥用。这就像把数据库密码放在服务器端，而不是写在客户端代码里。
    *   **控制**: 可以在后端对请求进行限制、缓存或处理，增加额外的逻辑。
*   **封装**: 后端可以将 Google Maps API 返回的复杂数据进行处理和简化，只返回前端需要的信息，或者将多个 Google API 调用合并成一个后端 API 调用。

## 配置

这部分说明了如何准备运行这个后端服务。

1.  **安装依赖**:
    ```bash
    npm install
    ```
    *   `npm` 是 Node.js 的包管理器 (Node Package Manager)，类似于 Python 的 `pip` 或者 C/C++ 项目中可能用到的 `make` (用于构建) 结合 `vcpkg`/`conan` (用于管理库依赖)。
    *   `npm install` 命令会读取项目根目录下的 `package.json` 文件（特别是 `dependencies` 和 `devDependencies` 字段），下载并安装所有必需的第三方库（称为 "包" 或 "模块"）到项目的 `node_modules` 目录下。这确保了项目代码可以找到并使用这些库提供的功能（例如 Express.js 框架、Google Maps 客户端库等）。

2.  **配置环境变量**:
    *   首先，复制 `.env.example` 文件并重命名为 `.env`。`.env.example` 是一个模板文件，告诉你需要配置哪些环境变量。`.env` 文件通常包含敏感信息（如 API 密钥），并且应该被添加到 `.gitignore` 文件中，以防止意外提交到版本控制系统（如 Git）。这是一种常见的安全实践，类似于 C/C++ 或 Python 项目中将配置文件或密钥文件与代码分开管理。
    *   在 `.env` 文件中填写 `GOOGLE_MAPS_API_KEY`。你需要去 Google Cloud Platform 申请一个有效的 Google Maps API 密钥，并确保启用了所需的 Maps API (如 Places API, Geocoding API)。这个密钥是后端服务调用 Google Maps 服务的凭证。
    *   **环境变量 (Environment Variables)**: 是一种在操作系统级别设置的变量，程序运行时可以读取它们。使用环境变量配置敏感信息（如 API 密钥、数据库密码）或环境特定的设置（如开发环境/生产环境的配置）是一种标准做法。Node.js 中通常使用 `dotenv` 这个库来方便地从 `.env` 文件加载环境变量到 `process.env` 对象中。`process.env` 类似于 C/C++ 中的 `getenv()` 函数或 Python 中的 `os.environ`。

## 启动服务

这部分介绍了如何启动后端服务器。

1.  **开发模式**:
    ```bash
    npm run server:dev
    ```
    *   `npm run <script_name>` 是 `npm` 的一个命令，用于执行在 `package.json` 文件中 `scripts` 部分定义的脚本。这里 `server:dev` 是一个自定义的脚本名称。
    *   这个命令通常会使用像 `nodemon` 这样的工具来启动服务器。`nodemon` 会监视项目文件的变化，一旦检测到文件被修改并保存，它会自动重启服务器。这极大地提高了开发效率，因为你不需要在每次修改代码后都手动停止和重启服务器。这类似于一些 C++ 或 Python 开发环境中的热重载 (Hot Reload) 功能。

2.  **生产模式**:
    ```bash
    npm run server
    ```
    *   这个命令用于在生产环境（即实际部署给用户使用的环境）中启动服务器。它通常直接使用 `node` 命令来运行入口文件（如 `server.js` 或 `index.js`），并且不会启用像 `nodemon` 这样的开发工具，以获得更好的性能和稳定性。

3.  **同时运行前端和后端**:
    ```bash
    npm run dev:all
    ```
    *   这个命令（同样是在 `package.json` 中定义的脚本）通常用于同时启动前端开发服务器（比如 React Native 的 Metro Bundler）和后端开发服务器。这对于全栈开发非常方便，可以让你同时进行前端和后端的调试。它可能使用了像 `concurrently` 这样的工具来并行运行多个命令。

## API 端点 (Endpoints)

这部分详细描述了后端提供的 API 接口。API 端点是前端可以访问的特定 URL，每个端点对应一个后端功能。

**关键概念**:
*   **HTTP 方法**: `GET` 是最常用的 HTTP 方法之一，用于从服务器获取数据。其他常见方法有 `POST` (创建数据), `PUT` (更新数据), `DELETE` (删除数据)。
*   **URL 路径**: 例如 `/api/maps/nearby`，定义了访问哪个资源的路径。`/api` 通常是 API 路由的前缀。
*   **查询参数 (Query Parameters)**: 跟在 URL `?` 后面的键值对，用于传递额外的信息给服务器。例如 `latitude=37.77&longitude=-122.4`。在 Express.js 中，可以通过 `req.query` 对象访问。这类似于 C/C++ 或 Python Web 框架中解析 URL 参数的方式。
*   **路径参数 (Path Parameters)**: 嵌入在 URL 路径中的变量。例如 `/api/maps/place/:placeId` 中的 `:placeId` 就是一个路径参数。前端请求时会用实际的 Place ID 替换它，如 `/api/maps/place/ChIJN1t...`。在 Express.js 中，可以通过 `req.params` 对象访问。
*   **请求 (Request)**: 前端发给后端的信息，包含 HTTP 方法、URL、参数、可能还有请求体 (Request Body，通常用于 `POST` 或 `PUT` 请求传递复杂数据)。
*   **响应 (Response)**: 后端返回给前端的信息，通常是 JSON 格式的数据，包含了请求的结果或状态。
*   **JSON (JavaScript Object Notation)**: 一种轻量级的数据交换格式，易于人阅读和编写，也易于机器解析和生成。它是现代 Web API 最常用的数据格式。其结构类似于 Python 的字典和列表，或者 C++ 中的 `std::map` 和 `std::vector` 的组合（但语法更简洁）。

**具体端点说明**:

### 1. 搜索附近奶茶店 (`GET /api/maps/nearby`)

*   **作用**: 查找指定坐标附近的奶茶店。
*   **参数**:
    *   `latitude`, `longitude` (必需): 用户当前的纬度和经度。
    *   `radius` (可选): 搜索半径（单位：米），默认为 1500 米。
    *   `pagetoken` (可选): Google Maps API 返回的一个令牌 (token)，用于获取下一页的搜索结果（因为一次请求可能无法返回所有结果）。这是一种常见的分页 (Pagination) 机制。
*   **响应**: 返回一个 JSON 对象，包含：
    *   `shops`: 一个奶茶店对象的数组。每个对象包含 ID, 名称, 位置, 地址, 评分, 照片 URL, 是否营业 (`open_now`), 价格水平 (`price_level`) 等信息。
    *   `nextPageToken`: 如果还有更多结果，会返回这个令牌，前端下次请求时带上它即可获取下一页数据。
    *   `status`: Google Maps API 返回的状态码，`OK` 表示成功。

### 2. 地址地理编码 (`GET /api/maps/geocode`)

*   **作用**: 将地址文本转换为经纬度坐标。
*   **参数**: `address` (必需): 要查询的地址字符串。
*   **响应**: 返回一个 JSON 对象，包含：
    *   `location`: 包含 `latitude` 和 `longitude` 的对象。
    *   `formattedAddress`: Google Maps 返回的标准化、完整的地址字符串。
    *   `placeId`: 该地址对应的 Google Maps 地点 ID。

### 3. 反向地理编码 (`GET /api/maps/reverse-geocode`)

*   **作用**: 将经纬度坐标转换为地址描述。
*   **参数**: `latitude`, `longitude` (必需): 要查询的坐标。
*   **响应**: 返回一个 JSON 对象，包含：
    *   `address`: 对应的地址字符串。
    *   `addressComponents`: 更详细的地址组成部分（如国家、省份、城市、街道等），是一个对象数组。

### 4. 获取地点详情 (`GET /api/maps/place/:placeId`)

*   **作用**: 根据 Place ID 获取某个地点的详细信息。
*   **路径参数**: `placeId` (必需): 要查询的地点的唯一 ID。
*   **响应**: 返回一个 JSON 对象，包含该地点的详细信息，比 `nearby` 接口返回的更丰富，例如：
    *   ID, 名称, 地址, 位置, 评分
    *   `photos`: 照片信息数组，包含照片引用和 URL。
    *   `opening_hours`: 营业时间信息，包括是否正在营业 (`open_now`) 和一周各天的营业时间文本 (`weekday_text`)。
    *   `website`: 官方网站 URL。
    *   `price_level`: 价格水平。
    *   `reviews`: 用户评价信息数组。

---

这个 `README.md` 文件为理解整个后端服务提供了一个高层次的概览。接下来的文件将深入代码细节。 