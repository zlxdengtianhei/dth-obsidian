# `src/presenters/MapPresenter.jsx` - 中文说明文档

本文档详细解释 `src/presenters/MapPresenter.jsx` 文件的代码和功能。

## 文件概述

`MapPresenter.jsx` 是奶茶地图功能的核心 **Presenter (展示器)** 组件。在软件设计模式中，Presenter 扮演着协调者的角色，它位于 View (视图，这里是 `MapView.jsx`) 和 Model (模型，这里是 `MapModel`) 之间。

**主要职责**: 
1.  **业务逻辑处理**: 包含获取用户位置、请求API、处理用户输入等核心逻辑。
2.  **状态管理**: 维护与地图视图相关的 UI 状态（如视图模式、加载状态），并与 `MapModel` 交互以读取和更新共享的应用状态（如奶茶店列表、用户位置、错误信息）。
3.  **视图交互**: 接收来自 `MapView` 的用户操作事件（如刷新、搜索、切换视图），调用相应的业务逻辑，并更新 `MapModel` 或组件自身状态，最终驱动 `MapView` 的更新。
4.  **模型交互**: 调用 `MapModel` 的方法来执行数据相关的操作（如调用后端 API、反向地理编码）。
5.  **原生功能集成**: 利用 Expo 提供的 API 与设备原生功能交互，特别是地理位置服务 (`expo-location`) 和链接 (`Linking`)。

**技术栈**: 
*   **React**: 使用函数组件和 Hooks (`useState`, `useEffect`, `useRef`) 来构建用户界面和管理组件生命周期及状态。
*   **MobX (`mobx-react-lite`)**: 使用 `observer` 高阶组件将该组件与 `MapModel` (一个 MobX store) 连接起来。当 `MapModel` 中的可观察状态发生变化时，`observer` 会自动触发该组件的重新渲染。
*   **Expo**: 使用 `expo-location` 获取设备位置信息，`expo-router` 进行导航，`Platform` 进行平台判断，`Linking` 打开外部应用（如地图导航）。
*   **Axios**: (虽然直接使用处未见于前 250 行，但通常 Presenter 或 Model 会用它进行网络请求，且已导入)。

你可以将其类比为：
*   **C++/C# (MVC/MVP)**: Controller 或 Presenter 类，负责处理用户输入，调用 Model 进行数据操作，并更新 View。
*   **Python (Django/Flask)**: 视图函数或类视图，处理 HTTP 请求，调用服务层或模型方法，准备上下文数据，并选择模板进行渲染。这里的区别在于 React 组件本身也承担了一部分视图更新的责任，但核心业务逻辑在 Presenter 中。

## Imports and Constants

```javascript
import { observer } from "mobx-react-lite";
import { MapView } from "../views/MapView";
import { useEffect, useState, useRef } from "react";
import { useRouter } from "expo-router";
import * as Location from 'expo-location';
import { Linking, Platform, Alert } from 'react-native';
import axios from 'axios';
import { API_BASE_URL } from '../MapModel'; // 从模型导入API基础URL
```

*   `observer`: 来自 `mobx-react-lite`，用于将 React 函数组件转换为能响应 MobX 可观察状态变化的 "观察者" 组件。
*   `MapView`: 导入对应的视图组件，Presenter 会将需要显示的数据和处理用户操作的回调函数传递给它。
*   `useEffect`, `useState`, `useRef`: React Hooks，分别用于处理副作用（如组件挂载时初始化）、管理组件局部状态和创建可变引用（常用于访问 DOM 或存储不触发渲染的值，如此处的订阅对象）。
*   `useRouter`: 来自 `expo-router`，用于访问路由功能，实现页面导航（例如，跳转到店铺详情页）。
*   `Location`: 来自 `expo-location`，提供访问设备地理位置信息的功能（请求权限、获取当前位置、监听位置变化）。
*   `Linking`, `Platform`, `Alert`: 来自 `react-native` (Expo 建立在其之上)，分别用于打开外部链接/应用、判断当前运行平台（iOS, Android, Web）、显示原生警告框。
*   `axios`: 用于发送 HTTP 请求（与后端 API 通信）。
*   `API_BASE_URL`: 从 `MapModel` 导入后端 API 的基础 URL，确保 Presenter 和 Model 使用一致的配置。
*   `GOOGLE_MAPS_API_KEY`: (硬编码的密钥，仅用于客户端的自动补全功能，**注意**: 在生产环境中硬编码密钥通常是不安全的，但这里可能仅用于免费的、有限制的客户端 API)。

## Component Definition and Props

```javascript
export const MapPresenter = observer(function MapPresenter(props) {
  const { MapModel } = props;
  // ... state and functions
});
```

*   `export const MapPresenter = ...`: 定义并导出 `MapPresenter` 函数组件。
*   `observer(...)`: 用 `observer` 包裹组件函数，使其能够响应 `MapModel` 中状态的变化。
*   `function MapPresenter(props)`: 组件接收 `props` 对象作为参数。
*   `const { MapModel } = props;`: 从 `props` 中解构出 `MapModel`。这表示 `MapPresenter` 依赖于一个 `MapModel` 的实例，该实例应该由父组件或其他依赖注入机制传入。`MapModel` 负责管理应用的核心数据状态和与后端 API 的交互逻辑。

## State Management

Presenter 使用 React Hooks (`useState`, `useRef`) 和传入的 `MapModel` 来管理状态。

**组件局部状态 (`useState`)**: 
```javascript
const [hasLocationPermission, setHasLocationPermission] = useState(false);
const [viewMode, setViewMode] = useState('list'); // 'list' or 'map'
const [searchAddress, setSearchAddress] = useState('');
const [isLoadingMore, setIsLoadingMore] = useState(false);
const [locationPermissionRequested, setLocationPermissionRequested] = useState(false);
```
*   `hasLocationPermission`: 布尔值，表示用户是否已授予位置权限。
*   `viewMode`: 字符串 ('list' 或 'map')，控制当前显示的是列表视图还是地图视图。
*   `searchAddress`: 字符串，存储当前搜索框或反向地理编码得到的地址文本。
*   `isLoadingMore`: 布尔值，表示是否正在加载更多奶茶店数据（用于分页）。
*   `locationPermissionRequested`: 布尔值，标记是否已经尝试请求过位置权限（用于避免重复请求或处理拒绝后的情况）。

**引用 (`useRef`)**: 
```javascript
const locationSubscription = useRef(null);
```
*   `locationSubscription`: 用于存储 `expo-location` 的 `watchPositionAsync` 返回的订阅对象。`useRef` 在这里的作用是：
    1.  存储订阅对象，以便后续可以调用其 `.remove()` 方法来取消监听。
    2.  `useRef` 的值的变化**不会**触发组件重新渲染，这对于存储订阅对象这类非渲染数据非常合适。

**共享应用状态 (通过 `MapModel`)**: 
Presenter 通过调用 `MapModel` 上的方法（如 `MapModel.setUserLocation`, `MapModel.setError`, `MapModel.searchNearbyShops`, `MapModel.reverseGeocode` 等）来读取和更新应用的核心状态。这些状态（如用户位置、奶茶店列表、错误信息）被定义为 MobX 的可观察状态，当它们变化时，`observer` 会自动更新 `MapPresenter` 和 `MapView`。 

## Location Handling Functions

这部分包含了处理设备地理位置相关的所有核心逻辑。

### `requestAndCheckLocationPermission()`

```javascript
const requestAndCheckLocationPermission = async () => {
  try {
    console.log('Requesting location permission...');
    
    // Web平台特殊处理
    if (Platform.OS === 'web') {
      setLocationPermissionRequested(true); // 标记已尝试
      setHasLocationPermission(true);      // Web 在调用API时才实际请求，这里先假设有
      return true;
    }
    
    // 检查现有权限
    let { status } = await Location.getForegroundPermissionsAsync();
    console.log('Current location permission status:', status);
    
    // 如果没有权限且未请求过权限
    if (status !== 'granted' && !locationPermissionRequested) {
      console.log('Requesting permission...');
      // 请求前台位置权限
      const { status: newStatus } = await Location.requestForegroundPermissionsAsync();
      console.log('New permission status:', newStatus);
      setLocationPermissionRequested(true); // 标记已请求
      
      if (newStatus !== 'granted') {
        console.log('Permission denied');
        MapModel.setError('Location access is required...'); // 设置错误信息
        setHasLocationPermission(false);
        return false; // 返回失败
      }
      // 如果新状态是 granted，则更新状态并继续
      status = newStatus; 
    }
    
    // 权限已获取 (无论是初始检查还是请求后)
    if (status === 'granted') {
      console.log('Permission granted');
      setHasLocationPermission(true);
      return true; // 返回成功
    } else {
      // 处理 status 不是 granted 且 locationPermissionRequested 为 true 的情况
      console.log('No permission after request or initial check');
      if (!MapModel.error) { // 只有在没有设置错误时才设置，避免覆盖已有错误
          MapModel.setError('Location access is required...');
      }
      setHasLocationPermission(false);
      return false; // 返回失败
    }
  } catch (error) {
    console.error('Error requesting location permission:', error);
    MapModel.setError(`Error requesting location: ${error.message}`);
    setHasLocationPermission(false);
    return false;
  }
};
```
*   **目的**: 检查应用是否具有访问设备位置的权限，如果没有，则向用户请求权限。
*   **异步**: 使用 `async/await` 因为需要调用 Expo Location 的异步 API。
*   **平台差异 (`Platform.OS === 'web'`)**: 
    *   Web 平台的位置权限处理方式与原生 App 不同。浏览器通常在 JavaScript 尝试访问位置信息时（如下面的 `getCurrentPositionAsync`）才会弹出权限请求对话框，而不是通过显式 API 调用来预先请求。
    *   因此，在 Web 平台上，此函数直接假设有权限（`setHasLocationPermission(true)`) 并标记为已请求 (`setLocationPermissionRequested(true)`)，实际的权限检查会发生在 `getUserLocation` 中。
*   **原生平台 (iOS/Android)**:
    1.  `Location.getForegroundPermissionsAsync()`: 首先检查当前应用**前台**位置权限的状态。应用只有在前台运行时才能访问位置。
    2.  **条件请求**: `if (status !== 'granted' && !locationPermissionRequested)`
        *   只有在当前状态不是 `granted` (未授权) **并且** 之前没有请求过权限 (`!locationPermissionRequested`) 时，才执行请求。
        *   `Location.requestForegroundPermissionsAsync()`: 向用户弹出请求位置权限的系统对话框。
        *   `setLocationPermissionRequested(true)`: 记录已经尝试过请求，避免用户拒绝后反复弹出请求。
        *   如果请求后的新状态 (`newStatus`) 仍然不是 `granted`，则设置错误消息 (`MapModel.setError`)，更新权限状态 (`setHasLocationPermission(false)`)，并返回 `false`。
    3.  **最终状态检查**: 检查最终的 `status` (可能是初始获取的，也可能是请求后更新的)。
        *   如果是 `granted`，更新状态 (`setHasLocationPermission(true)`) 并返回 `true`。
        *   否则 (权限被拒绝或出现其他问题)，设置错误信息（如果尚未设置），更新状态 (`setHasLocationPermission(false)`) 并返回 `false`。
*   **错误处理**: `try...catch` 捕获 Expo API 调用可能发生的任何错误，记录错误，设置错误信息，更新状态，并返回 `false`。
*   **返回值**: 布尔值，指示权限是否最终被授予。

### `getUserLocation()`

```javascript
const getUserLocation = async () => {
  try {
    // 先确保有权限
    const hasPermission = await requestAndCheckLocationPermission();
    if (!hasPermission) {
      console.log('No location permission, cannot get location');
      return null; // 无权限则返回 null
    }
    
    console.log('Getting current position...');
    
    // 设置默认和 Web 平台特定的选项
    let options = {
      accuracy: Location.Accuracy.Balanced, // 平衡精度和功耗
      timeInterval: 5000 // (对 getCurrentPositionAsync 可能无效，但保留)
    };
    if (Platform.OS === 'web') {
      options = {
        accuracy: Location.Accuracy.Low, // Web 上降低精度要求，提高成功率
        timeInterval: 10000, // Web 上增加超时时间
        mayShowUserSettingsDialog: true // 允许显示浏览器设置对话框
      };
    }
    
    // 获取当前位置信息 (只会获取一次)
    const location = await Location.getCurrentPositionAsync(options);
    console.log('Got position:', location);
    
    // 返回包含经纬度的对象
    return {
      latitude: location.coords.latitude,
      longitude: location.coords.longitude
    };
  } catch (error) {
    console.error('Error getting location:', error);
    // 区分 Web 和原生平台的错误信息
    if (Platform.OS === 'web') {
        if (error.message.includes('denied') || error.message.includes('permission')) {
          MapModel.setError('Location access denied...');
        } else if (error.message.includes('timeout')) {
          MapModel.setError('Location request timed out...');
        } else {
          MapModel.setError(`Something went wrong. ${error.message}`);
        }
      } else {
        MapModel.setError(`Error getting location: ${error.message}`);
      }
    return null; // 出错则返回 null
  }
};
```
*   **目的**: 获取设备当前的地理位置（经纬度）。
*   **异步**: 使用 `async/await`。
*   **权限检查先行**: 首先调用 `requestAndCheckLocationPermission()` 确保拥有权限，如果失败则直接返回 `null`。
*   **获取位置选项 (`options`)**: 
    *   `Location.Accuracy`: 定义获取位置的精度要求。`Balanced` 是一个折衷选项。Web 平台上使用 `Low` 可能更容易成功。
    *   `timeInterval`: (主要用于 `watchPositionAsync`)。对于 `getCurrentPositionAsync`，它更像是一个内部提示。
    *   `mayShowUserSettingsDialog` (Web Only): 如果浏览器阻止了位置请求，是否允许 Expo Location 尝试显示浏览器的设置对话框。
*   **`Location.getCurrentPositionAsync(options)`**: 调用 Expo Location API 获取**一次性**的当前位置。在 Web 平台上，如果之前没有授权，此时浏览器会弹出权限请求。
*   **返回值**: 
    *   成功时，返回一个包含 `latitude` 和 `longitude` 的对象。
    *   失败（无权限或 API 调用出错）时，返回 `null`。
*   **错误处理**: `catch` 块捕获错误，设置错误信息（区分 Web 平台的特定错误类型，如权限拒绝、超时），并返回 `null`。

### `updateLocationAndSearch()`

```javascript
const updateLocationAndSearch = async () => {
  try {
    const location = await getUserLocation(); // 1. 获取位置
    if (!location) {
      console.log('Failed to get location');
      return; // 获取失败则中止
    }
    
    MapModel.setUserLocation(location); // 2. 更新 Model 中的用户位置
    
    // 3. 进行反向地理编码以获取地址
    const address = await MapModel.reverseGeocode(location);
    setSearchAddress(address); // 更新本地状态以显示地址
    
    // 4. 使用当前位置搜索附近商店
    await MapModel.searchNearbyShops(); 
    
  } catch (error) {
    console.error('Error updating location and searching:', error);
    MapModel.setError('Failed to update location and search');
  }
};
```
*   **目的**: 这是一个核心的业务流程函数，用于获取用户当前位置，并以此位置为中心搜索附近的奶茶店。
*   **异步**: 使用 `async/await`。
*   **流程**: 
    1.  调用 `getUserLocation()` 获取用户经纬度。
    2.  如果成功获取到 `location`，调用 `MapModel.setUserLocation(location)` 将位置信息更新到共享的 `MapModel` 中。
    3.  调用 `MapModel.reverseGeocode(location)` 将经纬度转换为可读地址，并用 `setSearchAddress` 更新到组件的本地状态（可能用于显示在搜索框中）。
    4.  调用 `MapModel.searchNearbyShops()`，这个方法（在 `MapModel` 中定义）应该会使用模型中刚更新的用户位置，向后端 API 发起搜索请求。
*   **错误处理**: `catch` 块捕获整个流程中任何步骤的错误，记录日志并设置通用的错误信息。

### Initialization (`useEffect`)

```javascript
// 初始化 - 组件挂载时请求位置并搜索
useEffect(() => {
  console.log('MapPresenter mounted, initializing...');
  updateLocationAndSearch();
  // 注意：这里没有返回清理函数，因为 updateLocationAndSearch 是单次操作
  // 如果有订阅等需要清理的操作，需要在 useEffect 返回函数中处理
}, []); // 空依赖数组 [] 表示这个 effect 只在组件首次挂载时运行一次
```
*   **目的**: 在 `MapPresenter` 组件首次加载（挂载）到屏幕上时，自动执行一次位置获取和附近搜索。
*   **`useEffect(callback, dependencies)`**: React Hook 用于处理副作用。
    *   `callback`: 包含副作用逻辑的函数。
    *   `dependencies` (数组): 控制 `callback` 何时执行。
        *   `[]` (空数组): `callback` 只在组件**挂载**时执行一次。相当于类组件的 `componentDidMount`。
        *   如果省略，`callback` 在每次渲染后都会执行。
        *   如果包含变量 `[var1, var2]`，`callback` 在挂载时执行，并且在 `var1` 或 `var2` 的值发生变化后的每次渲染时执行。
*   **逻辑**: 在组件挂载时，调用 `updateLocationAndSearch()` 来初始化地图数据。

### `startLocationUpdates()`

```javascript
const startLocationUpdates = async () => {
  // 如果已有订阅，先移除旧的订阅
  if (locationSubscription.current) {
    locationSubscription.current.remove();
    locationSubscription.current = null; // 清理引用
  }
  
  try {
    // 开始监听位置变化
    locationSubscription.current = await Location.watchPositionAsync(
      {
        accuracy: Location.Accuracy.Balanced, // 精度
        distanceInterval: 100, // 至少移动 100 米才触发更新
        timeInterval: 60000, // 至少 60 秒才触发更新 (Android only)
      },
      (location) => { // 当位置变化时执行的回调函数
        const { latitude, longitude } = location.coords;
        MapModel.setUserLocation({ latitude, longitude }); // 更新 Model 中的位置
        updateAddressFromCoords(latitude, longitude); // 异步更新地址显示
      }
    );
  } catch (error) {
    console.error('Error starting location updates:', error);
    // 通常这不是关键功能失败，可以允许静默失败，不设置全局错误
  }
};
```
*   **目的**: 启动持续的位置更新监听。当用户移动时，可以自动更新其位置信息。
*   **异步**: 使用 `async/await`。
*   **清理旧订阅**: `if (locationSubscription.current)` 检查是否已经存在一个位置监听订阅。如果是，调用 `locationSubscription.current.remove()` 来取消之前的监听，防止重复监听和内存泄漏。然后将 `locationSubscription.current` 设为 `null`。
*   **`Location.watchPositionAsync(options, callback)`**: Expo Location API 用于**持续**监听设备位置变化。
    *   `options`: 
        *   `accuracy`: 精度要求。
        *   `distanceInterval`: 设备必须移动多少米（相对于上一次回调的位置）才会触发 `callback`。
        *   `timeInterval`: (主要影响 Android) 两次 `callback` 触发之间的最小时间间隔。
    *   `callback(location)`: 当满足 `options` 条件的位置更新发生时，这个回调函数会被调用，参数 `location` 包含新的位置信息。
*   **回调逻辑**: 
    1.  从 `location.coords` 提取经纬度。
    2.  调用 `MapModel.setUserLocation` 更新共享状态。
    3.  调用 `updateAddressFromCoords` （见下）来异步更新 UI 上显示的地址。
*   **存储订阅**: 将 `watchPositionAsync` 返回的订阅对象存储在 `locationSubscription.current` 中，以便将来可以取消它。
*   **错误处理**: `catch` 块捕获启动监听时可能发生的错误（例如，权限问题）。这里选择仅打印错误，不设置全局错误状态，因为持续监听可能不是应用的核心功能。
*   **注意**: 这个函数被定义了，但在前 250 行代码中没有看到它被调用的地方。它可能在组件的其他地方（例如，用户手动开启跟踪）或在 `useEffect` 中有条件地被调用。

### `updateAddressFromCoords()`

```javascript
const updateAddressFromCoords = async (latitude, longitude) => {
  try {
    console.log(`Attempting to get address for coords: (${latitude}, ${longitude})`);
    // 调用 MapModel 中的反向地理编码方法
    const address = await MapModel.reverseGeocode({ latitude, longitude });
    console.log('Got address:', address);
    
    if (address) {
      setSearchAddress(address); // 更新本地状态以显示地址
    } else {
      console.warn('reverseGeocode returned empty address');
      setSearchAddress('Unable to fetch address'); // 显示获取失败
    }
  } catch (error) {
    console.error('Reverse geocode error:', error);
    setSearchAddress('Address fetch failed'); // 显示获取失败
  }
};
```
*   **目的**: 根据给定的经纬度坐标，调用 `MapModel` 的反向地理编码功能获取地址，并更新 `searchAddress` 状态。
*   **异步**: 使用 `async/await`。
*   **调用模型**: `await MapModel.reverseGeocode({ latitude, longitude })`。
*   **更新状态**: 
    *   如果成功获取到 `address`，使用 `setSearchAddress(address)` 更新 UI。
    *   如果 `MapModel.reverseGeocode` 返回空地址或发生错误，则设置一个表示失败的地址字符串。
*   **调用场景**: 主要在 `startLocationUpdates` 的回调中被调用，用于在用户位置自动更新时，同步更新显示的地址。

## User Interaction Handlers

这部分包含了响应用户在 `MapView` 中操作的函数。这些函数通常会被作为 props 传递给 `MapView`。

### `handleRefresh()`

```javascript
const handleRefresh = async () => {
  console.log('Refreshing...');
  MapModel.setError(null); // 清除任何现有错误
  await updateLocationAndSearch(); // 重新执行获取位置和搜索流程
};
```
*   **目的**: 处理用户下拉刷新或点击刷新按钮的操作。
*   **逻辑**: 
    1.  调用 `MapModel.setError(null)` 清除之前可能显示的任何错误信息。
    2.  调用 `updateLocationAndSearch()` 重新获取用户当前位置并搜索附近的商店。

### `handleSearchLocation()`

```javascript
const handleSearchLocation = async (location, address) => {
  console.log('Searching location:', location, address);
  MapModel.setError(null); // 清除错误
  
  try {
    setSearchAddress(address); // 更新显示的地址
    MapModel.setUserLocation(location); // 更新模型中的位置
    await MapModel.searchNearbyShops(); // 使用新位置搜索
  } catch (error) {
    console.error('Error during location search:', error);
    // 处理错误...
  }
};
```
*   **目的**: 处理用户通过搜索框选择了一个地点后的操作（例如，从自动补全建议中选择）。
*   **参数**: `location` (包含 `latitude`, `longitude` 的对象), `address` (用户选择的地址字符串)。
*   **逻辑**: 
    1.  清除旧错误。
    2.  用 `setSearchAddress` 更新 UI 上显示的地址。
    3.  用 `MapModel.setUserLocation` 更新模型中的当前搜索中心点。
    4.  调用 `MapModel.searchNearbyShops` 使用这个新位置进行搜索。
    5.  错误处理。

### `handleManualSearch()`

```javascript
const handleManualSearch = async (searchText) => {
  if (!searchText || searchText.trim().length < 3) {
    return; // 忽略空或过短的搜索文本
  }
  
  try {
    MapModel.setLoading(true); // 开始加载状态
    
    // 1. 使用地址文本进行地理编码
    const location = await MapModel.geocodeAddress(searchText);
    
    if (location) {
      // 2. 如果地理编码成功，使用获取到的坐标进行位置搜索
      await handleSearchLocation(location, searchText);
    } else {
      MapModel.setError('Location not found...'); // 地理编码失败
    }
  } catch (error) {
    console.error('Manual search error:', error);
    MapModel.setError('Search failed...');
  } finally {
    MapModel.setLoading(false); // 结束加载状态
  }
};
```
*   **目的**: 处理用户直接在搜索框输入文本并提交搜索的操作。
*   **参数**: `searchText` 用户输入的文本。
*   **逻辑**: 
    1.  简单的输入验证（非空且长度足够）。
    2.  设置加载状态 (`MapModel.setLoading(true)`)。
    3.  调用 `MapModel.geocodeAddress(searchText)` 将用户输入的地址文本转换为经纬度坐标 (`location`)。
    4.  如果地理编码成功 (`location` 有效），则调用 `handleSearchLocation(location, searchText)`，复用之前的逻辑，使用转换后的坐标进行附近搜索。
    5.  如果地理编码失败，设置错误信息。
    6.  使用 `finally` 块确保无论成功或失败，最终都关闭加载状态 (`MapModel.setLoading(false)`)。

### `handleLoadMore()`

```javascript
const handleLoadMore = async () => {
  try {
    // 防止重复加载或没有更多页面时加载
    if (!MapModel.nextPageToken || isLoadingMore) return;
    
    setIsLoadingMore(true); // 设置正在加载更多的状态
    await MapModel.loadMoreShops(); // 调用模型的方法加载下一页数据
  } catch (error) {
    console.error('Error loading more shops:', error);
    MapModel.setError('Failed to load more shops');
  } finally {
    setIsLoadingMore(false); // 结束加载更多状态
  }
};
```
*   **目的**: 处理用户滚动到底部或点击 "加载更多" 按钮的操作（分页加载）。
*   **逻辑**: 
    1.  检查 `MapModel.nextPageToken` 是否存在（是否有下一页）以及 `isLoadingMore` 是否为 `false`（防止重复触发），如果任一条件不满足则返回。
    2.  设置 `isLoadingMore` 为 `true`，向 UI 指示正在加载。
    3.  调用 `MapModel.loadMoreShops()`，该方法应使用存储在模型中的 `nextPageToken` 来向后端 API 请求下一页数据。
    4.  使用 `finally` 确保加载结束后将 `isLoadingMore` 设置回 `false`。

### `handleToggleViewMode()`

```javascript
const handleToggleViewMode = () => {
  setViewMode(viewMode === 'list' ? 'map' : 'list');
};
```
*   **目的**: 处理用户点击切换视图模式按钮（列表/地图）的操作。
*   **逻辑**: 使用 `setViewMode` 更新 `viewMode` 状态，在 'list' 和 'map' 之间切换。

### `handleSelectShop()`

```javascript
const handleSelectShop = (shopId) => {
  MapModel.selectShop(shopId); // 更新模型中当前选中的商店
  // 可以在此添加逻辑：如果当前是列表视图，自动切换到地图视图
  // if (viewMode === 'list') {
  //   setViewMode('map'); 
  // }
};
```
*   **目的**: 处理用户在列表或地图上选择（点击）某个商店的操作。
*   **参数**: `shopId` 被选中商店的 ID。
*   **逻辑**: 调用 `MapModel.selectShop(shopId)` 来更新 `MapModel` 中当前选中的商店状态。注释中提到了未来可能的增强：在列表视图中选择商店后自动切换到地图视图。

### `handleViewOnMap()`

```javascript
const handleViewOnMap = (shopId) => {
  MapModel.selectShop(shopId); // 1. 选中商店
  if (viewMode !== 'map') { // 2. 如果不在地图视图
    setViewMode('map');   // 3. 切换到地图视图
  }
};
```
*   **目的**: 处理用户在列表项上点击 "在地图上查看" 按钮的操作。
*   **参数**: `shopId` 要查看的商店 ID。
*   **逻辑**: 
    1.  调用 `MapModel.selectShop(shopId)` 选中该商店。
    2.  检查当前是否已经是地图视图 (`viewMode !== 'map'`)。
    3.  如果不是，则调用 `setViewMode('map')` 切换到地图视图。

### `handleOpenDirections()`

```javascript
const handleOpenDirections = (shop) => {
  if (!shop || !shop.location) return; // 检查商店数据有效性
  
  const { latitude, longitude } = shop.location;
  const label = encodeURIComponent(shop.name); // 编码商店名称用于 URL
  
  // 根据平台构建不同的地图 URL
  let url;
  if (Platform.OS === 'ios') {
    url = `maps://?daddr=${latitude},${longitude}&q=${label}`; // Apple Maps URL Scheme
  } else if (Platform.OS === 'android') {
    url = `google.navigation:q=${latitude},${longitude}&mode=d`; // Google Maps Intent (驾驶模式)
  } else {
    // Web 和其他平台使用 Google Maps 网页版
    url = `https://www.google.com/maps/dir/?api=1&destination=${latitude},${longitude}&destination_place_id=${shop.id}&travelmode=driving`;
  }
  
  // 使用 Linking API 尝试打开 URL
  Linking.canOpenURL(url)
    .then(supported => {
      if (supported) {
        Linking.openURL(url); // 打开原生应用或网页
      } else {
        // 如果特定平台的 URL 不支持，尝试回退到通用的 Google Maps 网页版
        Linking.openURL(`https://www.google.com/maps/dir/?api=1&destination=${latitude},${longitude}`);
      }
    })
    .catch(error => {
      console.error('Error opening maps:', error);
      Alert.alert('Error', 'Could not open maps application'); // 显示错误提示
    });
};
```
*   **目的**: 处理用户点击 "获取路线" 按钮的操作，尝试在设备上打开默认的地图应用并显示到选定商店的路线。
*   **参数**: `shop` 包含所选商店信息的对象 (需要 `location` 和 `name` 属性)。
*   **平台差异**: 
    *   iOS: 构建 `maps://` URL scheme 来打开 Apple Maps。
    *   Android: 构建 `google.navigation:` Intent URL 来打开 Google Maps。
    *   Web/其他: 构建标准的 Google Maps Directions 网页 URL。
*   **`encodeURIComponent(shop.name)`**: 对商店名称进行 URL 编码，确保特殊字符（如空格）能正确传递。
*   **`Linking.canOpenURL(url)`**: 检查设备上是否有应用可以处理这个特定格式的 URL。
*   **`Linking.openURL(url)`**: 尝试打开能处理该 URL 的应用（原生 App 或浏览器）。
*   **回退**: 如果特定平台的 URL (`maps://` 或 `google.navigation:`) 不被支持（例如，用户没有安装 Google Maps），则尝试打开通用的 Google Maps 网页版 URL。
*   **错误处理**: 如果 `Linking` 操作失败，捕获错误，记录日志，并使用 `Alert.alert` 显示一个原生的错误提示框给用户。

## Rendering the View

```javascript
// 如果模型中有错误，但我们有商店数据，清除错误
if (MapModel.error && MapModel.nearbyBubbleTeaShops.length > 0) {
  MapModel.setError(null);
}

return (
  <MapView
    // 将 Model 和 Presenter 的状态传递给 View
    shops={MapModel.nearbyBubbleTeaShops}
    selectedShop={MapModel.selectedShop}
    userLocation={MapModel.userLocation}
    isLoading={MapModel.isLoading}
    isLoadingMore={isLoadingMore} // 来自 Presenter 的本地状态
    error={MapModel.error}
    hasLocationPermission={hasLocationPermission} // 来自 Presenter 的本地状态
    searchRadius={MapModel.searchRadius}
    viewMode={viewMode} // 来自 Presenter 的本地状态
    searchAddress={searchAddress} // 来自 Presenter 的本地状态
    googleApiKey={GOOGLE_MAPS_API_KEY} // 传递 API Key (可能用于地图组件)
    nextPageToken={MapModel.nextPageToken}
    
    // 将事件处理函数作为 props 传递给 View
    onSelectShop={handleSelectShop}
    onViewOnMap={handleViewOnMap}
    onRefresh={handleRefresh}
    onLoadMore={handleLoadMore}
    onToggleViewMode={handleToggleViewMode}
    onOpenDirections={handleOpenDirections}
    onSearchLocation={handleSearchLocation}
    onManualSearch={handleManualSearch}
    onRequestLocationPermission={requestAndCheckLocationPermission}
  />
);
```
*   **条件性错误清除**: `if (MapModel.error && MapModel.nearbyBubbleTeaShops.length > 0)` 
    *   这是一个有趣的逻辑：如果在 `MapModel` 中记录了一个错误，但是同时模型中又确实存在一些商店数据（可能是之前成功加载的，或者是模拟数据），那么就清除这个错误 (`MapModel.setError(null)`)。
    *   这可能是为了在例如 API 请求失败但仍有旧数据或缓存数据可显示时，不向用户展示错误信息，提供稍微平滑一点的体验。
*   **`return <MapView ... />`**: Presenter 的渲染输出是 `MapView` 组件。
*   **传递 Props**: 
    *   **数据状态**: 将从 `MapModel` 获取的数据（`shops`, `selectedShop`, `userLocation`, `isLoading`, `error`, `searchRadius`, `nextPageToken`）和 Presenter 自身的 UI 状态（`isLoadingMore`, `hasLocationPermission`, `viewMode`, `searchAddress`）作为 props 传递给 `MapView`，供其显示。
    *   **回调函数**: 将之前定义的**所有** `handle...` 事件处理函数作为 props (通常以 `on...` 命名，如 `onRefresh`, `onSelectShop` 等) 传递给 `MapView`。这样 `MapView` 内部的按钮、列表项等组件就可以在用户交互时调用这些函数，将事件通知回 Presenter 进行处理。
*   **关注点分离**: Presenter 本身不包含任何复杂的 JSX 渲染逻辑，它只负责准备数据和处理逻辑，然后将这些传递给专门负责渲染 UI 的 `MapView` 组件。这就是 MVP/MVC 模式的核心思想。

## 总结

`MapPresenter.jsx` 是一个精心设计的 React 组件，它有效地运用了 Presenter 模式来分离业务逻辑和视图渲染。它集成了 MobX 进行状态管理，利用 Expo API 与原生功能（特别是地理位置）交互，并提供了处理用户各种交互（刷新、搜索、选择、导航、切换视图等）的健壮逻辑。

关键技术和模式：
*   React Hooks (`useState`, `useEffect`, `useRef`) 用于组件状态和生命周期管理。
*   MobX (`observer`) 用于响应共享状态变化。
*   Presenter 模式将业务逻辑与 UI 分离。
*   Expo API (`expo-location`, `Linking`, `Platform`) 用于访问原生功能。
*   `async/await` 处理异步操作（权限请求、位置获取、API 调用）。
*   平台差异处理 (`Platform.OS`) 适配 iOS, Android, Web。
*   通过 Props 将数据和回调函数传递给 View 组件 (`MapView`)。