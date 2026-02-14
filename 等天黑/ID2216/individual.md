

**实现功能概述**

我实现了一个“附近奶茶店查找”的功能。该功能允许用户查看其当前位置或指定位置附近的奶茶店。用户可以在列表视图和地图视图之间切换。列表视图会展示奶茶店的名称、地址、距离、评分、价格水平、营业状态以及照片等信息，并提供查看地图和导航的功能。地图视图则会在地图上标记出这些奶茶店的位置，用户点击标记点可以查看商店详情，并同样可以获取导航。应用支持通过关键词搜索地点，也支持加载更多店铺信息。后端通过 Firebase Cloud Functions 提供 API 服务，负责与 Google Maps API 交互，进行地点搜索、详情获取、地理编码和反向地理编码等操作。前端使用 React Native 构建，通过 MobX进行状态管理，实现了用户界面展示和业务逻辑处理。

**`firebase_index.js` (后端 Firebase Cloud Functions)**

这个文件是应用的后端服务核心，部署在 Firebase Cloud Functions 上，因此没有在git中展示出来，我将它放在了这个文件的末尾作为附录。它使用 Express.js 框架搭建了一系列 API 端点，作为前端应用与 Google Maps 服务之间的桥梁。

最关键的部分首先是 Express 应用的初始化和中间件的配置，例如 `const app = express()` 创建了应用实例，`app.use(cors({origin: true}))` 和 `app.use(express.json())` 分别启用了跨域资源共享和 JSON 请求体解析，这对于前端应用的顺利调用至关重要。

其次是 `mapsService` 对象，它封装了与 Google Maps API 交互的逻辑。`mapsService.searchNearbyShops` 方法负责根据经纬度、半径或分页令牌（pagetoken）调用 Google Places API 的附近搜索功能，查找奶茶店。`mapsService.getPlaceDetails` 方法则根据地点 ID 获取特定商店的详细信息，如电话、网站、评论等。这两个方法是获取核心数据的关键。

API 路由定义是另一关键部分。例如，`/api/maps/nearby` 端点接收前端的搜索请求，调用 `mapsService.searchNearbyShops`，并通过 `transformToClientFormat` 函数处理原始数据，使其符合前端的展示需求，然后返回商店列表和用于分页的 `nextPageToken`。`/api/maps/place/:placeId` 端点则用于获取特定商店的详情，调用 `mapsService.getPlaceDetails` 并使用 `transformPlaceDetailsFormat` 进行数据转换。此外，还有 `/api/maps/reverse-geocode` 和 `/api/maps/geocode` 端点分别用于将坐标转换为地址和将地址转换为坐标，这些对于基于位置的搜索和显示非常重要。`/api/maps/embed` 端点则用于生成嵌入式地图的 URL，主要服务于 Web 平台的地图展示。

最后，`exports.api = onRequest(...)` 将整个 Express 应用导出为一个可公开访问的 HTTP Cloud Function，这是所有 API 请求的入口。错误处理中间件确保了在发生服务器内部错误时，能向客户端返回统一格式的错误信息。

**`src/models/MapModel.js` (前端 MobX 状态模型)**

此文件定义了应用前端的状态管理逻辑，使用了makeAutoObservable 来创建可观察的状态和行为。`MapModelClass` 是核心，其实例 `MapModel` 在整个应用中共享。

关键的状态属性包括 `nearbyBubbleTeaShops`，一个数组，用于存储从后端获取或使用模拟数据生成的奶茶店列表；`selectedShop` 用于存储用户当前选中的商店对象；`userLocation` 存储用户的地理位置；`isLoading` 和 `error` 分别表示加载状态和错误信息；`nextPageToken` 用于实现分页加载。这些状态的变化会自动触发 UI 的更新。

核心方法封装了与后端 API 的交互和状态更新逻辑。`searchNearbyShops(params)` 方法是获取奶茶店列表的主要途径，它会根据参数（如位置、半径、是否加载更多）构建请求，调用后端的 `/api/maps/nearby` 接口。成功获取数据后，它会更新 `nearbyBubbleTeaShops` 和 `nextPageToken`。此方法还包含了错误处理逻辑，在 API 请求失败时会尝试使用 `MOCK_BUBBLE_TEA_SHOPS` 作为备用数据。`loadMoreShops()` 方法则利用 `nextPageToken` 来加载更多商店。`geocodeAddress(address)` 和 `reverseGeocode(location)` 方法分别调用后端的地理编码和反向地理编码接口，用于地址和坐标之间的转换，并更新相关状态。`selectShop(shopId)` 方法用于更新 `selectedShop` 状态。

此外，`calculateDistance` 函数用于计算两点间的距离，这有助于在前端对商店进行排序或过滤。模块加载时执行的 `testApiConnection` 函数会尝试连接后端 `/check` 接口，用于早期诊断 API 的可用性。

**`src/views/MapView.jsx` (前端 React Native 视图组件)**

这个文件是用户界面的核心，负责展示所有与地图和商店列表相关的内容。它是一个 React Native 组件，根据从 Presenter 传入的 props 来渲染不同的视图。

关键的布局和组件渲染体现在几个方面。首先是条件渲染逻辑，根据 `isLoading`、`error` 和 `hasLocationPermission` 等 prop，组件会分别展示加载指示器、错误信息（及重试按钮）或请求位置权限的界面。

`LocationSearch` 组件是用户输入和定位的核心交互区。在移动端，它集成了 `GooglePlacesAutocomplete` 组件，提供地址搜索和建议功能；在 Web 端，它提供了一个自定义的文本输入框和搜索按钮。它还包含一个 "Use my location" 按钮，允许用户快速使用当前设备位置进行搜索。

视图模式的切换由 `ViewModeToggle` 组件实现，允许用户在列表视图 (`renderListView`) 和地图视图 (`renderMapView`) 之间切换。

`renderListView` 方法使用 `FlatList` 来高效地展示 `shops` 数组。每个商店通过 `renderShopItem` 函数渲染，`renderShopItem` 负责展示商店的名称、地址、图片、评分、营业状态，并提供 "View Map" 和 "Directions" 按钮。`ListFooter` 组件用于实现列表底部的 "Load More" 功能或显示 "No more shops" 提示。

`renderMapView` 方法根据平台 (`Platform.OS`) 渲染不同的地图实现。在 Web 端，它使用 `MapViewWrapper` (可能内嵌 iframe) 来显示通过 `/api/maps/embed` 获取的嵌入式地图，并在地图上方叠加一个 `shopsOverlay`（横向滚动的商店卡片列表）以及选中商店的详情卡片 (`selectedShopFloatingCard`)。在移动端，它也使用 `MapViewWrapper`（可能包装了 `react-native-maps`），在地图上渲染 `MapMarkerWrapper` 来标记商店位置和搜索位置，同样提供 `shopsOverlay` 和 `selectedShopFloatingCard`。

**`src/presenters/MapPresenter.jsx`**

该文件是连接 `MapView` (视图) 和 `MapModel` (模型) 的桥梁，负责处理应用的业务逻辑和用户交互的响应。它使用 MobX 的 `observer` 来监听 `MapModel` 的变化并自动更新视图。

核心方法和逻辑主要围绕位置处理、数据获取和用户交互响应。组件挂载时的 `init` 方法会尝试获取用户位置（如果失败则使用默认位置 `DEFAULT_REGION`），更新地图区域 (`region`) 和用户位置 (`MapModel.setUserLocation`)，然后调用 `MapModel.searchNearbyShops()` 来加载初始的商店数据。

`requestAndCheckLocationPermission` 处理位置权限的请求和检查。`getUserLocation` 异步获取用户当前位置。`updateLocationAndRegion` 是一个重要的辅助函数，用于统一更新 `lastSearchLocation` (最后一次搜索的有效位置)、地图的 `region` 状态以及 `MapModel` 中的用户位置，并且在地图视图下会自动触发商店搜索。

`handleRefresh` 用于刷新数据，`handleSearchLocation` 和 `handleManualSearch` 分别处理通过自动完成和手动输入进行的地点搜索，它们会调用 `MapModel` 的相应方法（如 `geocodeAddress`）获取坐标，然后更新位置并搜索商店。`handleLoadMore` 调用 `MapModel.loadMoreShops` 加载更多数据。`handleToggleViewMode` 负责切换列表和地图视图，并在切换到地图视图时智能地设置地图中心。`handleSelectShop` 和 `handleViewOnMap` 处理用户选择商店或在地图上查看商店的操作，会更新 `MapModel.selectedShop` 并相应调整地图视图。`handleOpenDirections` 则调用 `Linking.openURL` 来打开外部地图应用进行导航。

Presenter 通过 props 将 `MapModel` 中的数据（如 `shops`, `selectedShop`, `isLoading`, `error`）和自身管理的状态（如 `viewMode`, `searchAddress`, `region`）以及所有交互处理函数传递给 `MapView` 组件，从而驱动视图的渲染和响应用户操作。

### **“查找附近奶茶店”功能的集成方式**
“查找附近奶茶店”功能主要作为一个独立的模块集成到整个应用中，用户可以通过应用导航结构（定义在 `src/app/_layout.jsx`）访问到这一功能。其中 “map” 是一个屏幕选项，配备了 `map-outline` 图标并标注为“地图”。当用户点击该标签时，他们会被引导至地图功能界面，该界面接管该部分屏幕以显示附近的奶茶店、搜索功能以及地图视图。

这种设计确保了地图功能是一个单独的模块，但同时也可以轻松地与其他核心功能（如“首页”、“社区”、“AI” 和 “我的”）并列，便于用户访问。

地图功能整体布局使用了 与其他部分相同的**`SafeAreaView`** 来优雅地处理设备特定的屏幕特性（例如刘海屏和状态栏），确保用户界面正确定位并完全可见。

应用的颜色主题可能通过与其他页面相同的 **`COLORS`** 的对象集中定义。这些颜色用于背景、文本、活动元素和边框，确保无论用户是在首页、浏览社区动态，还是使用地图功能，都能体验到一致的视觉风格。


---

### **团队协作过程的反思**

通过这次代码项目，我对mvp的架构形式更加了解了，正是这种编码架构，能够让我们基于功能，可以独立创建代码文件，写出属于自己部分的完整功能实现，而不需要过多的修改同一个文件。将我们的不同功后结合在一起，就成为了一个功能齐全的应用。我也了解到了更多的关于git版本控制的知识，在我们进行代码合并时，git的冲突比较让我们能够很好的处理需要我们共同修改的文件。