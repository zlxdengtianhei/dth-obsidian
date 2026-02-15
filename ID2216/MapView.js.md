# `src/views/MapView.jsx` - 中文说明文档

本文档详细解释 `src/views/MapView.jsx` 文件的代码和功能。

## 文件概述

`MapView.jsx` 是奶茶地图功能的 **View (视图)** 组件。在 MVP (Model-View-Presenter) 模式中，视图层的主要职责是**展示数据**和**将用户操作传递给 Presenter**。它应该尽量保持 "Dumb" (简单)，不包含复杂的业务逻辑。

**主要职责**: 
1.  **渲染 UI**: 根据从 `MapPresenter` 接收到的 props (数据状态和 UI 状态)，使用 React Native 组件构建用户界面。这包括列表视图、地图视图（目前是占位符）、加载指示器、错误提示、空状态、搜索栏、按钮等。
2.  **显示数据**: 展示奶茶店列表、选中的商店信息、用户当前位置（地址）、错误信息等。
3.  **响应用户交互**: 将用户的操作（如点击按钮、选择列表项、输入搜索文本、下拉刷新、滚动到底部）通过调用从 `MapPresenter` 传递过来的回调函数 (如 `onRefresh`, `onSelectShop`, `onLoadMore` 等) 来通知 Presenter。
4.  **适配平台**: 包含一些针对 Web 平台的特定 UI 调整和组件使用（例如，Web 上使用原生 `input` 和 Google Maps JavaScript API 实现自动补全，而移动端使用 `react-native-google-places-autocomplete`）。

**技术栈**: 
*   **React Native**: 使用核心组件 (`View`, `Text`, `FlatList`, `TouchableOpacity`, `Image`, `ActivityIndicator`, `TextInput`, `SafeAreaView`, `StatusBar`, `Platform`, `Dimensions`) 来构建跨平台的原生 UI。
*   **React**: 使用函数组件和 Hooks (`useState`, `useEffect`, `useRef`) 来管理视图自身的局部状态（如搜索框文本）和引用 DOM 元素 (主要用于 Web 平台的自动补全)。
*   **`react-native-google-places-autocomplete`**: 一个用于在 React Native 应用中实现 Google Places 自动补全搜索框的第三方库 (主要用于移动端)。
*   **Google Maps JavaScript API**: (仅在 Web 平台动态加载) 用于实现 Web 端的地点搜索自动补全功能。

你可以将其类比为：
*   **C++/C# (GUI)**: UI 窗口或控件定义文件 (如 XAML, QML, 或代码生成的 UI)，它包含布局和控件，并通过事件处理器调用 Presenter/Controller 的方法。
*   **Python (Web Frameworks)**: HTML 模板文件 (如 Jinja2, Django Templates)，它接收来自视图函数的数据并渲染成 HTML 页面。React Native 组件的角色类似于 HTML 标签和 CSS 样式的组合。

## Imports

```javascript
import React, { useRef, useState, useEffect } from 'react';
import { 
  View, Text, StyleSheet, FlatList, TouchableOpacity, 
  Image, ActivityIndicator, Dimensions, SafeAreaView, 
  StatusBar, Platform, TextInput
} from 'react-native';
import { GooglePlacesAutocomplete } from 'react-native-google-places-autocomplete';
```
*   `React`, `useRef`, `useState`, `useEffect`: React 核心库和 Hooks。
*   React Native Components: 导入了大量用于构建界面的基础组件。
    *   `View`: 基础容器，类似 HTML `div`。
    *   `Text`: 显示文本。
    *   `StyleSheet`: 创建样式对象，类似 CSS。
    *   `FlatList`: 高性能的列表渲染组件，用于显示奶茶店列表。
    *   `TouchableOpacity`: 带透明度变化的按钮/可点击区域。
    *   `Image`: 显示图片（商店图片）。
    *   `ActivityIndicator`: 显示加载动画。
    *   `Dimensions`: 获取屏幕尺寸。
    *   `SafeAreaView`: 自动处理刘海屏、底部指示条等安全区域的容器。
    *   `StatusBar`: 控制设备状态栏（时间、电量那一行）。
    *   `Platform`: 判断运行平台（iOS, Android, Web）。
    *   `TextInput`: 文本输入框 (用于 Web 平台的备用搜索)。
*   `GooglePlacesAutocomplete`: 导入第三方库，用于移动端的地点搜索自动补全。

## Component Definition and Props

```javascript
export function MapView(props) {
  const {
    shops = [],
    selectedShop,
    userLocation, // 注意：此 prop 未在前 250 行的渲染逻辑中使用
    isLoading,
    isLoadingMore,
    error,
    hasLocationPermission,
    viewMode,
    searchAddress,
    googleApiKey,
    nextPageToken,
    onSelectShop,
    onViewOnMap,
    onRefresh,
    onLoadMore,
    onToggleViewMode,
    onOpenDirections,
    onSearchLocation,
    onManualSearch,
    onRequestLocationPermission
  } = props;

  // ... View 内部状态和渲染逻辑
}
```
*   `export function MapView(props)`: 定义并导出 `MapView` 函数组件。
*   **Props Destructuring**: 从 `props` 对象中解构出所有由 `MapPresenter` 传递过来的数据和回调函数。
    *   **Data Props**: `shops` (奶茶店数组), `selectedShop` (当前选中的商店对象), `userLocation` (用户经纬度对象), `isLoading` (初始加载状态), `isLoadingMore` (加载更多状态), `error` (错误信息), `hasLocationPermission` (位置权限状态), `viewMode` ('list' 或 'map'), `searchAddress` (当前地址文本), `googleApiKey`, `nextPageToken` (用于判断是否还有更多数据)。
    *   **Callback Props**: `onSelectShop`, `onViewOnMap`, `onRefresh`, `onLoadMore`, `onToggleViewMode`, `onOpenDirections`, `onSearchLocation`, `onManualSearch`, `onRequestLocationPermission`。这些都是函数，当用户在 `MapView` 中执行相应操作时会被调用。
*   `shops = []`: 为 `shops` prop 设置了默认值空数组，防止在 `MapPresenter` 还没传递数据时因 `undefined` 而出错。

## View-Specific State and Refs

```javascript
const placesAutocompleteRef = useRef(null);
const [searchText, setSearchText] = useState(''); // 注意：这个状态在前 250 行未被使用
const [manualSearchText, setManualSearchText] = useState('');
const [webSuggestions, setWebSuggestions] = useState([]); // 注意：这个状态在前 250 行未被使用
const [showSuggestions, setShowSuggestions] = useState(false);
const inputRef = useRef(null); // 用于 Web input 元素
const autocompleteRef = useRef(null); // 用于存储 Web Google Autocomplete 实例
```
*   `MapView` 也使用 `useState` 和 `useRef` 来管理一些**只与视图自身相关的状态**，这些状态不适合放在 `MapModel` 或 `MapPresenter` 中。
*   `placesAutocompleteRef`: 用于引用 `GooglePlacesAutocomplete` 组件实例 (移动端)，可能用于调用其方法（如清空文本）。
*   `searchText`: (未使用) 可能原本打算用于受控的 `GooglePlacesAutocomplete` 输入。
*   `manualSearchText`, `webSuggestions`, `showSuggestions`: 主要用于 Web 平台的自定义搜索框和建议列表的状态。
*   `inputRef`: 引用 Web 平台的原生 `<input>` 元素，用于初始化 Google Places Autocomplete。
*   `autocompleteRef`: 存储 Web 平台 Google Places Autocomplete 服务实例。

## Conditional Rendering: Loading, Error, No Permission

视图组件通常会根据传入的 props (如 `isLoading`, `error`, `hasLocationPermission`) 来决定渲染哪个部分。

```javascript
// Loading state
if (isLoading && !isLoadingMore) {
  return (
    <SafeAreaView style={styles.loadingContainer}>
      <ActivityIndicator size="large" color="#6200ee" />
      <Text style={styles.loadingText}>Searching for bubble tea shops...</Text>
    </SafeAreaView>
  );
}

// Error state
if (error) {
  return (
    <SafeAreaView style={styles.errorContainer}>
      <Text style={styles.errorTitle}>Something went wrong</Text>
      <Text style={styles.errorMessage}>{error}</Text>
      <TouchableOpacity style={styles.retryButton} onPress={onRefresh}>
        <Text style={styles.retryButtonText}>Retry</Text>
      </TouchableOpacity>
    </SafeAreaView>
  );
}

// No location permission
if (!hasLocationPermission) {
  return (
    <SafeAreaView style={styles.errorContainer}> // 复用了 errorContainer 样式
      <Text style={styles.errorTitle}>Location Access Required</Text>
      <Text style={styles.errorMessage}>...</Text>
      <TouchableOpacity style={styles.retryButton} onPress={onRequestLocationPermission}>
        <Text style={styles.retryButtonText}>Grant Permission</Text>
      </TouchableOpacity>
    </SafeAreaView>
  );
}
```
*   **加载状态**: 如果 `isLoading` 为 true 且**不是** `isLoadingMore` (表示是初始加载，而不是加载更多)，则显示一个包含 `ActivityIndicator` (加载动画) 和加载文本的 `SafeAreaView`。
*   **错误状态**: 如果 `error` prop 有值（非 null 或 undefined），则显示错误标题、错误消息（`error` prop 的内容）和一个 "Retry" 按钮。点击该按钮会调用 `onRefresh` 回调函数 (通知 Presenter 处理重试逻辑)。
*   **无权限状态**: 如果 `hasLocationPermission` 为 false，则显示提示用户需要位置权限的消息和一个 "Grant Permission" 按钮。点击该按钮会调用 `onRequestLocationPermission` 回调函数 (通知 Presenter 处理请求权限的逻辑)。
*   **优先级**: 这三个条件渲染是按顺序检查的。这意味着如果 `isLoading` 为 true，即使 `error` 也有值，用户看到的仍然是加载界面。如果加载完成但有错误，则显示错误界面。如果没错误但无权限，则显示无权限界面。
*   **`SafeAreaView`**: 在顶层使用 `SafeAreaView` 可以确保内容不会被设备的刘海或状态栏遮挡。 

## Core UI Sub-Components

`MapView` 将 UI 拆分成了几个内部定义的子组件或渲染函数，以提高代码的可读性和组织性。

### `ViewModeToggle`

```javascript
const ViewModeToggle = () => (
  <TouchableOpacity 
    style={styles.viewModeToggle} 
    onPress={onToggleViewMode} // 点击时调用 Presenter 的切换视图处理函数
  >
    <Text style={styles.viewModeToggleText}>
      {/* 根据当前 viewMode 显示不同的文本 */}
      {viewMode === 'list' ? 'Switch to Map View' : 'Switch to List View'}
    </Text>
  </TouchableOpacity>
);
```
*   **目的**: 渲染一个可点击的按钮，用于在列表视图和地图视图之间切换。
*   **实现**: 一个简单的 `TouchableOpacity` 组件，包含根据当前 `viewMode` prop 动态变化的文本。
*   **交互**: `onPress` 事件直接绑定到从 Presenter 传入的 `onToggleViewMode` 回调函数。

### `LocationSearch`

```javascript
const LocationSearch = () => {
  // Web 平台特定的状态和引用
  const [manualSearchText, setManualSearchText] = useState('');
  const [webSuggestions, setWebSuggestions] = useState([]);
  const [showSuggestions, setShowSuggestions] = useState(false);
  const inputRef = useRef(null);
  const autocompleteRef = useRef(null);
  
  // Web 平台：动态加载并初始化 Google Maps Places Autocomplete API
  useEffect(() => {
    if (Platform.OS === 'web') {
      // 检查 window.google 是否已加载，避免重复加载
      if (!window.google || !window.google.maps) {
        const script = document.createElement('script');
        script.src = `https://maps.googleapis.com/maps/api/js?key=${googleApiKey}&libraries=places`;
        script.async = true;
        script.defer = true;
        script.onload = initAutocomplete; // 加载完成后初始化
        document.head.appendChild(script);
        
        // 清理函数：组件卸载时移除 script 标签
        return () => {
          if (document.head.contains(script)) { // 检查 script 是否还在
            document.head.removeChild(script);
          }
        };
      } else {
        initAutocomplete(); // 已加载，直接初始化
      }
    }
  }, [googleApiKey]); // 依赖 googleApiKey
  
  // Web 平台：初始化 Autocomplete 服务
  const initAutocomplete = () => {
    if (Platform.OS === 'web' && inputRef.current && window.google) {
      autocompleteRef.current = new window.google.maps.places.Autocomplete(
        inputRef.current, // 绑定到 input 元素
        { types: ['geocode'], fields: ['formatted_address', 'geometry', 'name'] } // 配置
      );
      // 监听 place_changed 事件
      autocompleteRef.current.addListener('place_changed', () => {
        const place = autocompleteRef.current.getPlace();
        if (place.geometry) {
          const location = { latitude: place.geometry.location.lat(), longitude: place.geometry.location.lng() };
          const address = place.formatted_address || place.name;
          setManualSearchText(address); // 更新输入框显示
          onSearchLocation(location, address); // 通知 Presenter 处理搜索
          setShowSuggestions(false);
        }
      });
    }
  };
  
  // Web 平台：处理输入变化
  const handleWebInputChange = (e) => {
    const value = e.target.value;
    setManualSearchText(value);
    setShowSuggestions(value.length > 0); // 控制建议列表显示（此处未实现建议列表渲染）
  };
  
  return (
    <View style={[styles.searchContainer, Platform.OS === 'web' ? styles.searchContainerWeb : null]}>
      {/* 移动端：使用 react-native-google-places-autocomplete */}
      {Platform.OS !== 'web' ? (
        <GooglePlacesAutocomplete
          ref={placesAutocompleteRef}
          placeholder='Search for location'
          fetchDetails={true} // 获取地点详情
          onPress={(data, details = null) => { // 选择建议后的回调
            if (details && details.geometry) {
              const location = { latitude: details.geometry.location.lat, longitude: details.geometry.location.lng };
              onSearchLocation(location, details.formatted_address); // 通知 Presenter
            }
          }}
          query={{
            key: googleApiKey, // API Key
            language: 'en', // 语言
            types: 'geocode', // 只搜索地理编码结果（地址）
          }}
          // ... 其他配置和样式
          styles={{
              // ... 大量样式配置，控制输入框、建议列表外观
          }}
        />
      ) : (
        // Web 平台：使用自定义的 input 和按钮
        <View style={styles.webSearchContainer}>
          {/* 使用 div 和原生 input 元素 */} 
          <div style={{ width: '100%', position: 'relative' }}>
            <input
              ref={inputRef} // 引用 input 元素
              style={styles.webSearchInput} // 应用样式
              type="text"
              placeholder="Enter location (city, address, etc.)"
              value={manualSearchText} // 受控组件
              onChange={handleWebInputChange} // 处理输入变化
              onKeyDown={(e) => { // 处理回车键
                if (e.key === 'Enter' && !autocompleteRef.current?.getPlace()) { // 避免选择建议时触发
                  onManualSearch(manualSearchText); // 调用 Presenter 的手动搜索
                  e.preventDefault();
                }
              }}
            />
            {/* 建议列表可以在这里渲染 (基于 webSuggestions) */}
          </div>
          <TouchableOpacity 
            style={styles.webSearchButton}
            onPress={() => onManualSearch(manualSearchText)} // 调用 Presenter 的手动搜索
          >
            <Text style={styles.webSearchButtonText}>Search</Text>
          </TouchableOpacity>
        </View>
      )}
      
      {/* 使用当前位置按钮 */}
      <TouchableOpacity 
        style={[styles.currentLocationButton, Platform.OS === 'web' ? styles.currentLocationButtonWeb : null]}
        onPress={() => {
          // 清空搜索框文本
          if (Platform.OS === 'web') {
            setManualSearchText('');
          } else if (placesAutocompleteRef.current) {
            placesAutocompleteRef.current.setAddressText(''); // 调用库的方法清空
          }
          onRefresh(); // 调用 Presenter 的刷新方法（会获取当前位置）
        }}
      >
        <Text style={styles.currentLocationButtonText}>Use My Location</Text>
      </TouchableOpacity>
      
      {/* 显示当前地址或 Web 平台的位置错误 */}
      {error && Platform.OS === 'web' && error.includes('Location access') ? (
        <Text style={styles.locationErrorText}>{error}</Text>
      ) : searchAddress ? (
        <Text style={styles.currentAddressText} numberOfLines={1}>{searchAddress}</Text>
      ) : null}
    </View>
  );
};
```
*   **目的**: 提供一个统一的地点搜索 UI，但根据运行平台采用不同的实现方式。
*   **平台判断 (`Platform.OS`)**: 这是实现跨平台 UI 的关键。
*   **移动端 (iOS/Android)**:
    *   使用 `GooglePlacesAutocomplete` 组件。
    *   **配置**: 
        *   `placeholder`: 输入框提示文字。
        *   `fetchDetails: true`: 获取选中地点的详细信息（包含经纬度）。
        *   `onPress`: 当用户从建议列表中选择一个地点时的回调函数。从 `details` 参数中提取经纬度和地址，然后调用 `onSearchLocation` 通知 Presenter。
        *   `query`: 配置传递给 Google Places API 的参数（API Key, 语言, 类型限制为 `geocode`）。
        *   `styles`: 传递大量样式对象来自定义组件的外观。
*   **Web 平台**: 
    *   **动态加载 Google API**: 使用 `useEffect` 在组件挂载时动态地将 Google Maps JavaScript API (包含 Places 库) 的 `<script>` 标签添加到 HTML 的 `<head>` 中。这样做是为了避免在非 Web 平台加载不必要的脚本，并且确保在使用 API 前脚本已加载完成。
    *   **初始化 Autocomplete**: `initAutocomplete` 函数在脚本加载完成后被调用，它使用 `new window.google.maps.places.Autocomplete()` 将自动补全功能附加到原生的 `<input>` 元素 (`inputRef.current`) 上。
    *   **监听选择事件**: `autocompleteRef.current.addListener('place_changed', ...)` 监听用户从 Google 提供的建议列表中选择地点的事件。回调函数获取选中的 `place` 对象，提取经纬度和地址，并调用 `onSearchLocation` 通知 Presenter。
    *   **自定义输入框**: 使用 React Native 的 `View`, `TouchableOpacity` 和一个**原生 HTML `<input>` 元素** (包裹在 `div` 中以便更好地控制样式和定位) 来构建搜索栏和搜索按钮。
        *   `<input>` 是一个受控组件，其 `value` 绑定到 `manualSearchText` 状态，`onChange` 绑定到 `handleWebInputChange`。
        *   处理 `onKeyDown` 事件，当用户按下回车键**且没有通过 Google Autocomplete 选择地点**时，调用 `onManualSearch` 通知 Presenter 执行手动搜索。
        *   搜索按钮的 `onPress` 也调用 `onManualSearch`。
*   **"Use My Location" 按钮**: 
    *   提供一个快速使用当前设备位置进行搜索的方式。
    *   点击时，清空当前的搜索框文本（区分 Web 和移动端实现），然后调用 `onRefresh` 回调 (Presenter 的 `handleRefresh` 会获取当前位置并搜索)。
*   **地址/错误显示**: 
    *   在搜索框下方，根据情况显示信息：
        *   如果在 Web 平台且 `error` prop 包含特定位置错误信息，则显示错误。
        *   否则，如果 `searchAddress` prop 有值，则显示该地址。

### `ListFooter`

```javascript
const ListFooter = () => {
  if (shops.length === 0 || isLoading) { // 无数据或初始加载时不显示
    return null;
  }
  const hasMoreData = !!nextPageToken; // !! 将 nextPageToken 转换为布尔值
  
  if (!hasMoreData) { // 没有更多数据
    return (
      <View style={styles.listFooter}>
        <Text style={styles.noMoreDataText}>No more shops found</Text>
      </View>
    );
  }
  
  // 有更多数据，根据 isLoadingMore 状态显示按钮或加载指示器
  return (
    <View style={styles.listFooter}>
      {isLoadingMore ? (
        <View style={styles.loadingMoreContainer}>
          <ActivityIndicator size="small" color="#6200ee" />
          <Text style={styles.loadingMoreText}>Loading more shops...</Text>
        </View>
      ) : (
        <TouchableOpacity style={styles.loadMoreButton} onPress={onLoadMore}>
          <Text style={styles.loadMoreButtonText}>Load More Shops</Text>
        </TouchableOpacity>
      )}
    </View>
  );
};
```
*   **目的**: 作为 `FlatList` 的底部组件，根据加载状态和是否有更多数据来显示不同的 UI。
*   **条件渲染**: 
    1.  如果商店列表为空 (`shops.length === 0`) 或者正在进行初始加载 (`isLoading`)，则不渲染任何内容 (`return null`)。
    2.  通过检查 `nextPageToken` prop 是否存在来判断 `hasMoreData`。
    3.  如果 `!hasMoreData`，显示 "No more shops found" 文本。
    4.  如果 `hasMoreData`:
        *   检查 `isLoadingMore` prop：如果为 true，显示一个小的 `ActivityIndicator` 和 "Loading more shops..." 文本。
        *   如果为 false，显示一个 "Load More Shops" 按钮，点击时调用 `onLoadMore` 回调。

### `renderShopItem`

```javascript
const renderShopItem = ({ item }) => (
  // 可点击的商店项容器
  <TouchableOpacity 
    style={[
      styles.shopItem, 
      selectedShop?.id === item.id && styles.selectedShopItem // 如果是选中的商店，应用高亮样式
    ]}
    onPress={() => onSelectShop(item.id)} // 点击时调用 onSelectShop 回调
  >
    <View style={styles.shopHeader}> // 商店信息和图片行
      <View style={styles.shopInfo}> // 左侧信息区域
        <Text style={styles.shopName}>{item.name}</Text>
        <Text style={styles.shopAddress}>{item.address}</Text>
        
        {/* 条件渲染距离 */}
        {item.distance && (
          <Text style={styles.distanceText}>
            {item.distance < 1000 ? 
              `${item.distance} m` : 
              `${(item.distance / 1000).toFixed(1)} km`} away
          </Text>
        )}
        
        {/* 条件渲染评分 */}
        {item.rating && (
          <View style={styles.ratingContainer}>
            <Text style={styles.ratingText}>Rating: {item.rating}★</Text>
          </View>
        )}
      </View>
      
      {/* 条件渲染商店图片 */}
      {item.photoUrl && (
        <Image source={{ uri: item.photoUrl }} style={styles.shopImage} />
      )}
    </View>
    
    <View style={styles.shopButtons}> // 底部按钮行
      <TouchableOpacity 
        style={styles.mapButton}
        onPress={() => onViewOnMap(item.id)} // 调用 onViewOnMap 回调
      >
        <Text style={styles.mapButtonText}>View on Map</Text>
      </TouchableOpacity>
      <TouchableOpacity 
        style={styles.directionsButton}
        onPress={() => onOpenDirections(item)} // 调用 onOpenDirections 回调
      >
        <Text style={styles.directionsButtonText}>Directions</Text>
      </TouchableOpacity>
    </View>
  </TouchableOpacity>
);
```
*   **目的**: 定义如何渲染 `FlatList` 中的每一个商店项目。
*   **参数**: `FlatList` 会为列表中的每个数据项调用这个函数，并将数据项本身作为 `item` 属性传递进来 (这里使用了对象解构 `{ item }`)。
*   **结构**: 
    *   最外层是 `TouchableOpacity`，使得整个列表项都可以点击。`onPress` 调用 `onSelectShop` 回调。
    *   **高亮选中项**: `style` 属性是一个数组。`styles.shopItem` 是基础样式。`selectedShop?.id === item.id && styles.selectedShopItem` 是一个条件样式：如果 `selectedShop` prop 存在且其 `id` 与当前 `item.id` 匹配，则额外应用 `styles.selectedShopItem` 样式（例如边框高亮）。`?.` 是可选链操作符，防止 `selectedShop` 为 `null` 或 `undefined` 时出错。
    *   **内容布局**: 使用 `View` 和 `flexDirection: 'row'` (在样式中定义) 来组织布局。
        *   `shopHeader`: 包含左侧的商店信息 (`shopInfo`) 和右侧的商店图片 (`Image`)。
        *   `shopInfo`: 包含名称 (`shopName`)、地址 (`shopAddress`)、距离 (`distanceText`) 和评分 (`ratingText`)。距离和评分是**条件渲染**的，只有当 `item` 对象中存在相应属性时才显示。
        *   `shopButtons`: 包含 "View on Map" 和 "Directions" 两个按钮，它们的 `onPress` 分别调用 `onViewOnMap` 和 `onOpenDirections` 回调。
*   **数据格式化**: 
    *   距离显示：如果距离小于 1000 米，显示为 "X m"；否则转换为公里并保留一位小数，显示为 "Y.Z km"。
```

## Main Rendering Logic

这部分组合了之前定义的子组件和渲染函数，构建最终的 UI。

```javascript
// Empty state (如果 shops 数组为空，且没有错误和加载状态)
if (shops.length === 0 && !isLoading && !error && hasLocationPermission) {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.viewModeContainer}>
        <ViewModeToggle />
      </View>
      <LocationSearch />
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyText}>No bubble tea shops found nearby.</Text>
        <Text style={styles.emptySubtext}>Try a different location or try again later.</Text>
        <TouchableOpacity style={styles.refreshButton} onPress={onRefresh}>
          <Text style={styles.refreshButtonText}>Refresh</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

// List View rendering function
const renderListView = () => (
  <>
    <FlatList
      data={shops} // 奶茶店数据数组
      renderItem={renderShopItem} // 用于渲染每个项目的函数
      keyExtractor={item => item.id} // 指定每个项目的唯一 key
      contentContainerStyle={styles.listContainer} // 列表内容容器样式
      showsVerticalScrollIndicator={false} // 隐藏垂直滚动条
      ListFooterComponent={ListFooter} // 列表底部组件
      // onEndReached={onLoadMore} // 可以考虑用这个代替 ListFooter 中的按钮
      // onEndReachedThreshold={0.5} // 触发 onEndReached 的距离
      // refreshControl={...} // 可以添加下拉刷新控件
    />
      
    {/* 浮动刷新按钮 */}
    <TouchableOpacity style={styles.floatingRefreshButton} onPress={onRefresh}>
      <Text style={styles.refreshButtonText}>Refresh</Text>
    </TouchableOpacity>
  </>
);

// Map View rendering function (Placeholder)
const renderMapView = () => (
  <View style={styles.mapPlaceholder}>
    <Text style={styles.mapPlaceholderText}>
      Map View Coming Soon{'\n'} 
      (Will be implemented with Google Maps)
    </Text>
    
    {/* 在地图占位符上显示选中商店的信息 */}
    {selectedShop && (
      <View style={styles.mapOverlay}>
        <Text style={styles.selectedShopName}>{selectedShop.name}</Text>
        <Text style={styles.selectedShopAddress}>{selectedShop.address}</Text>
        {selectedShop.distance && (
          <Text style={styles.selectedShopDistance}>
             {/* 距离格式化 */}
          </Text>
        )}
        <TouchableOpacity 
          style={styles.directionsButton}
          onPress={() => onOpenDirections(selectedShop)}
        >
          <Text style={styles.directionsButtonText}>Get Directions</Text>
        </TouchableOpacity>
      </View>
    )}
    
    {/* 地图视图也有浮动刷新按钮 */}
    <TouchableOpacity style={styles.floatingRefreshButton} onPress={onRefresh}>
      <Text style={styles.refreshButtonText}>Refresh</Text>
    </TouchableOpacity>
  </View>
);

// Main return statement
return (
  <SafeAreaView style={styles.container}>
    <View style={styles.viewModeContainer}>
      <ViewModeToggle />
    </View>
    
    <LocationSearch />
    
    {/* 根据 viewMode 渲染列表或地图视图 */}
    {viewMode === 'list' ? renderListView() : renderMapView()}
  </SafeAreaView>
);
```
*   **空状态处理**: 在主要的 `return` 之前，添加了一个检查：如果已经排除了加载、错误和无权限状态，并且 `shops` 数组仍然为空，则渲染一个 "No bubble tea shops found" 的空状态提示，包含搜索栏和刷新按钮。
*   **`renderListView()`**: 
    *   使用 `FlatList` 组件来高效地渲染商店列表。
    *   **Props**: 
        *   `data`: 数据源 (从 props 传入的 `shops` 数组)。
        *   `renderItem`: 指定使用 `renderShopItem` 函数来渲染每个列表项。
        *   `keyExtractor`: 告诉 `FlatList` 如何为每个数据项生成一个唯一的 key (React 列表渲染需要)，这里使用商店的 `id`。
        *   `contentContainerStyle`: 设置列表内容区域的内边距等样式。
        *   `showsVerticalScrollIndicator`: 隐藏滚动条。
        *   `ListFooterComponent`: 指定使用 `ListFooter` 组件作为列表的底部。
    *   **浮动刷新按钮**: 在 `FlatList` 下方（但在视觉上可能覆盖它，取决于布局和 zIndex）添加了一个 `TouchableOpacity` 作为浮动按钮，点击调用 `onRefresh`。
*   **`renderMapView()`**: 
    *   **占位符**: 目前这个函数只渲染一个简单的灰色背景和文本，提示地图视图即将推出。
    *   **选中商店浮层**: 如果 `selectedShop` prop 有值，则在占位符上方渲染一个半透明的浮层 (`mapOverlay`)，显示选中商店的名称、地址、距离和 "Get Directions" 按钮。
    *   **浮动刷新按钮**: 地图视图也包含一个浮动刷新按钮。
*   **最终渲染 (`return (...)`)**: 
    1.  使用 `SafeAreaView` 作为根容器。
    2.  渲染顶部的 `ViewModeToggle` 按钮容器。
    3.  渲染 `LocationSearch` 组件。
    4.  使用三元运算符 `viewMode === 'list' ? renderListView() : renderMapView()` 根据 `viewMode` prop 的值，条件性地调用 `renderListView()` 或 `renderMapView()` 来渲染主内容区域。

## StyleSheet

```javascript
const { width, height } = Dimensions.get('window'); // 获取屏幕宽高

const styles = StyleSheet.create({
  container: { /* ... */ },
  viewModeContainer: { /* ... */ },
  viewModeToggle: { /* ... */ },
  // ... 大量的样式定义 ...
  webSearchContainer: { /* ... */ },
  webSearchInput: { /* ... */ },
  webSearchButton: { /* ... */ },
});
```
*   **`Dimensions.get('window')`**: 获取当前窗口（屏幕）的宽度和高度，可用于动态计算样式（虽然在此代码片段中未直接使用 `width` 和 `height` 变量，但定义它们是常见的做法）。
*   **`StyleSheet.create({...})`**: 这是 React Native 中创建和组织样式的标准方式。
    *   它接收一个包含多个样式规则的对象（每个键是一个样式名称，值是一个包含 CSS-like 属性的对象）。
    *   `StyleSheet.create` 会对样式进行处理和优化（例如，将样式 ID 化），提高性能。
*   **样式属性**: 使用类似 CSS 的属性名 (但通常是驼峰式命名，如 `backgroundColor`, `fontSize`, `flexDirection`)。
*   **布局 (`flexbox`)**: React Native 主要使用 Flexbox 模型进行布局 (`flex: 1`, `flexDirection: 'row'`, `justifyContent`, `alignItems` 等)。
*   **单位**: 尺寸值（如 `padding: 16`, `fontSize: 14`）通常是无单位的逻辑像素 (Density-independent Pixels, DP)。
*   **平台特定样式**: 可以看到一些样式名称包含 "Web" (如 `searchContainerWeb`)，并在组件中使用 `Platform.OS === 'web' ? styles.webStyle : null` 的方式条件性地应用，以微调 Web 平台的布局或外观。
*   **样式组织**: 将所有样式集中在 `StyleSheet.create` 中，使得组件的 JSX 结构更清晰，并且方便管理和复用样式。

## 总结

`MapView.jsx` 组件忠实地扮演了 View 的角色。它接收数据和回调函数，并专注于使用 React Native 组件将这些信息渲染成用户界面。它处理了不同的 UI 状态（加载、错误、空、无权限），并根据平台提供了不同的搜索栏实现。通过将复杂的 UI 结构拆分成更小的内部组件/渲染函数 (`ViewModeToggle`, `LocationSearch`, `ListFooter`, `renderShopItem`, `renderListView`, `renderMapView`)，代码保持了较好的可读性。

关键技术和模式：
*   React Native 核心组件和布局 (`View`, `Text`, `FlatList`, `TouchableOpacity`, `StyleSheet`, Flexbox)。
*   Props 驱动的 UI 渲染。
*   通过回调函数将用户事件传递给 Presenter。
*   条件渲染处理不同的 UI 状态。
*   使用 `FlatList` 高效渲染列表。
*   平台判断 (`Platform.OS`) 实现跨平台 UI 差异。
*   `StyleSheet.create` 组织和优化样式。
*   (Web) 动态加载外部 JS 库和与原生 DOM 元素交互。