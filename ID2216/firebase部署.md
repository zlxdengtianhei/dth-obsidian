/**

* Import function triggers from their respective submodules:

*

* const {onCall} = require("firebase-functions/v2/https");

* const {onDocumentWritten} = require("firebase-functions/v2/firestore");

*

* See a full list of supported triggers at https://firebase.google.com/docs/functions

*/

  

const {onRequest} = require("firebase-functions/v2/https");

const logger = require("firebase-functions/logger");

  

// 引入 express 和其他依赖

const express = require("express");

const cors = require("cors");

const rateLimit = require("express-rate-limit");

  

// Create and deploy your first functions

// https://firebase.google.com/docs/functions/get-started

  

// exports.helloWorld = onRequest((request, response) => {

// logger.info("Hello logs!", {structuredData: true});

// response.send("Hello from Firebase!");

// });

  

// 硬编码 API 密钥 (在实际生产环境中，应该使用环境变量或 Secret Manager)

const MAPS_API_KEY = "AIzaSyBy_3T86s_9BrDvBTQoknuTXZ1Bh8y5LA8";

process.env.GOOGLE_MAPS_API_KEY = MAPS_API_KEY;

  

logger.info("API key set to hardcoded value (for demo)");

  

// 创建 Express 应用

const app = express();

  

// 中间件

app.use(cors({origin: true}));

app.use(express.json());

  

// 输出环境变量以便调试

logger.info("Environment vars:", {

GOOGLE_MAPS_API_KEY_EXISTS: !!process.env.GOOGLE_MAPS_API_KEY,

GOOGLE_MAPS_API_KEY_LENGTH: process.env.GOOGLE_MAPS_API_KEY ? process.env.GOOGLE_MAPS_API_KEY.length : 0,

NODE_ENV: process.env.NODE_ENV

});

  

// 复制 server/services/mapsService.js 内容到本地模块

const mapsService = {

async searchNearbyShops(options) {

try {

const { latitude, longitude, radius = 1500, pagetoken } = options;

// 更可靠的 API 密钥获取方式

const apiKey = process.env.GOOGLE_MAPS_API_KEY || MAPS_API_KEY;

if (!apiKey) {

throw new Error('Google Maps API密钥未配置');

}

// 构建API URL

let url;

if (pagetoken) {

url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=${pagetoken}&key=${apiKey}`;

} else {

url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latitude},${longitude}&radius=${radius}&keyword=bubble tea&type=restaurant|cafe|food&key=${apiKey}`;

}

logger.info(`Making API request to: ${url.substring(0, url.indexOf('key='))}`);

// 发送请求

const response = await fetch(url);

if (!response.ok) {

throw new Error(`Google Maps API请求失败: ${response.status} ${response.statusText}`);

}

const data = await response.json();

if (data.status !== 'OK' && data.status !== 'ZERO_RESULTS') {

throw new Error(`Google Maps API错误: ${data.status}, ${data.error_message || 'Unknown error'}`);

}

return {

status: 'success',

data: {

results: data.results || [],

next_page_token: data.next_page_token || null,

status: data.status

}

};

} catch (error) {

logger.error('搜索奶茶店失败:', error);

throw error;

}

},

async getPlaceDetails(placeId) {

try {

// 更可靠的 API 密钥获取方式

const apiKey = process.env.GOOGLE_MAPS_API_KEY || MAPS_API_KEY;

if (!apiKey) {

throw new Error('Google Maps API密钥未配置');

}

// 构建API URL

const url = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeId}&fields=name,rating,formatted_phone_number,formatted_address,opening_hours,website,photos,reviews,price_level,user_ratings_total,vicinity,geometry&key=${apiKey}`;

// 发送请求

const response = await fetch(url);

if (!response.ok) {

throw new Error(`Google Maps API请求失败: ${response.status} ${response.statusText}`);

}

const data = await response.json();

if (data.status !== 'OK') {

throw new Error(`Google Maps API错误: ${data.status}, ${data.error_message || 'Unknown error'}`);

}

return {

status: 'success',

data: data.result

};

} catch (error) {

logger.error('获取地点详情失败:', error);

throw error;

}

}

};

  

// 健康检查端点

app.get("/health", (req, res) => {

// 与检查端点一致的 API 密钥获取方式

const apiKey = process.env.GOOGLE_MAPS_API_KEY || MAPS_API_KEY;

res.status(200).json({

status: "OK",

message: "服务运行正常",

environment: process.env.NODE_ENV || "development",

apiKeyStatus: apiKey ? "已配置" : "未配置",

apiKeyInfo: apiKey ? `长度: ${apiKey.length}` : "无"

});

});

  

// 添加检查端点

app.get("/api/maps/check", (req, res) => {

// 重新获取 API 密钥状态

const apiKey = process.env.GOOGLE_MAPS_API_KEY || MAPS_API_KEY;

// 记录日志

logger.info("Check endpoint - API Key status:", {

envVar: process.env.GOOGLE_MAPS_API_KEY ? "存在" : "不存在",

directConfig: MAPS_API_KEY ? "存在" : "不存在",

finalKeyUsed: apiKey ? "存在" : "不存在"

});

res.json({

status: 'ok',

message: 'API服务器正常运行',

timestamp: new Date().toISOString(),

googleApiKey: apiKey ? '已配置' : '未配置',

googleApiKeyInfo: apiKey ? `长度: ${apiKey.length}, 前3位: ${apiKey.substring(0, 3)}` : '无',

configSource: process.env.GOOGLE_MAPS_API_KEY ? 'env' : (MAPS_API_KEY ? 'config' : 'none'),

serverVersion: '1.0'

});

});

  

// 添加测试端点

app.get("/api/maps/test", (req, res) => {

res.json({

message: '这是一个测试端点，不需要Google API',

timestamp: new Date().toISOString()

});

});

  

// 奶茶店搜索端点

app.get("/api/maps/nearby", async (req, res, next) => {

try {

const { latitude, longitude, radius, pagetoken } = req.query;

// 如果提供了pagetoken，直接使用

if (pagetoken) {

const result = await mapsService.searchNearbyShops({ pagetoken });

// 修改返回的数据格式，确保与客户端期望的匹配

return res.json({

status: 'success',

shops: transformToClientFormat(result.data.results),

nextPageToken: result.data.next_page_token

});

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

// 修改返回的数据格式，确保与客户端期望的匹配

res.json({

status: 'success',

shops: transformToClientFormat(result.data.results),

nextPageToken: result.data.next_page_token

});

} catch (error) {

next(error);

}

});

  

// 转换 Google Places API 结果为客户端期望的格式

function transformToClientFormat(places) {

if (!places || !Array.isArray(places)) return [];

return places.map(place => {

// 构建照片URL (如果有照片)

let photoUrl = null;

if (place.photos && place.photos.length > 0) {

const photo = place.photos[0];

const photoReference = photo.photo_reference;

const apiKey = process.env.GOOGLE_MAPS_API_KEY || MAPS_API_KEY;

photoUrl = `https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photoReference}&key=${apiKey}`;

}

return {

id: place.place_id,

name: place.name,

location: {

latitude: place.geometry.location.lat,

longitude: place.geometry.location.lng

},

address: place.vicinity || '地址未知',

rating: place.rating ? place.rating.toString() : '暂无评分',

photoUrl: photoUrl,

// 可以添加更多字段...

priceLevel: place.price_level,

userRatingsTotal: place.user_ratings_total,

openNow: place.opening_hours && place.opening_hours.open_now

};

});

}

  

// 获取地点详情

app.get("/api/maps/place/:placeId", async (req, res, next) => {

try {

const { placeId } = req.params;

if (!placeId) {

return res.status(400).json({

status: 'error',

message: '必须提供地点ID'

});

}

const result = await mapsService.getPlaceDetails(placeId);

// 转换结果格式为客户端期望的格式

const placeDetails = transformPlaceDetailsFormat(result.data);

res.json({

status: 'success',

placeDetails: placeDetails

});

} catch (error) {

next(error);

}

});

  

// 转换地点详情为客户端期望的格式

function transformPlaceDetailsFormat(place) {

if (!place) return null;

// 构建照片URL数组

const photos = [];

if (place.photos && Array.isArray(place.photos)) {

const apiKey = process.env.GOOGLE_MAPS_API_KEY || MAPS_API_KEY;

place.photos.forEach(photo => {

if (photo.photo_reference) {

photos.push({

url: `https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=${photo.photo_reference}&key=${apiKey}`

});

}

});

}

// 提取评论

const reviews = [];

if (place.reviews && Array.isArray(place.reviews)) {

place.reviews.forEach(review => {

reviews.push({

author: review.author_name || '匿名用户',

rating: review.rating,

text: review.text || '',

time: review.time ? new Date(review.time * 1000).toISOString() : null,

profilePhotoUrl: review.profile_photo_url

});

});

}

// 处理营业时间

let openingHours = [];

if (place.opening_hours && place.opening_hours.weekday_text) {

openingHours = place.opening_hours.weekday_text;

}

return {

id: place.place_id,

name: place.name,

address: place.formatted_address || place.vicinity || '',

phoneNumber: place.formatted_phone_number || '',

website: place.website || '',

rating: place.rating ? place.rating.toString() : '',

userRatingsTotal: place.user_ratings_total || 0,

priceLevel: place.price_level || 0,

openNow: place.opening_hours && place.opening_hours.open_now,

openingHours: openingHours,

photos: photos,

reviews: reviews,

location: place.geometry && place.geometry.location ? {

latitude: place.geometry.location.lat,

longitude: place.geometry.location.lng

} : null

};

}

  

// 错误处理中间件

app.use((err, req, res, next) => {

logger.error("Express Error Handler Invoked:", err);

res.status(500).json({

status: "error",

message: "服务器内部错误",

error: process.env.NODE_ENV === "development" ? err.message : undefined

});

});

  

// 添加反向地理编码端点

app.get("/api/maps/reverse-geocode", async (req, res, next) => {

try {

const { latitude, longitude } = req.query;

// 验证必要参数

if (!latitude || !longitude) {

return res.status(400).json({

status: 'error',

message: '必须提供经纬度参数'

});

}

// 构建Google Maps地理编码API URL

const apiKey = process.env.GOOGLE_MAPS_API_KEY || MAPS_API_KEY;

const url = `https://maps.googleapis.com/maps/api/geocode/json?latlng=${latitude},${longitude}&key=${apiKey}`;

// 发送请求

const response = await fetch(url);

if (!response.ok) {

throw new Error(`Google Maps API请求失败: ${response.status} ${response.statusText}`);

}

const data = await response.json();

if (data.status !== 'OK') {

throw new Error(`Google Maps API错误: ${data.status}, ${data.error_message || 'Unknown error'}`);

}

// 提取地址

let address = '未知地址';

if (data.results && data.results.length > 0) {

address = data.results[0].formatted_address || '未知地址';

}

// 返回数据

res.json({

status: 'success',

address: address,

results: data.results || []

});

} catch (error) {

logger.error('反向地理编码出错:', error);

next(error);

}

});

  

// 添加地理编码端点

app.get("/api/maps/geocode", async (req, res, next) => {

try {

const { address } = req.query;

// 验证必要参数

if (!address) {

return res.status(400).json({

status: 'error',

message: '必须提供地址参数'

});

}

// 构建Google Maps地理编码API URL

const apiKey = process.env.GOOGLE_MAPS_API_KEY || MAPS_API_KEY;

const url = `https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(address)}&key=${apiKey}`;

// 发送请求

const response = await fetch(url);

if (!response.ok) {

throw new Error(`Google Maps API请求失败: ${response.status} ${response.statusText}`);

}

const data = await response.json();

if (data.status !== 'OK') {

throw new Error(`Google Maps API错误: ${data.status}, ${data.error_message || 'Unknown error'}`);

}

// 提取位置

let location = null;

if (data.results && data.results.length > 0 && data.results[0].geometry && data.results[0].geometry.location) {

location = {

latitude: data.results[0].geometry.location.lat,

longitude: data.results[0].geometry.location.lng

};

}

// 返回数据

res.json({

status: 'success',

location: location,

results: data.results || []

});

} catch (error) {

logger.error('地理编码出错:', error);

next(error);

}

});

  

// 添加嵌入式地图API端点

app.get("/api/maps/embed", async (req, res, next) => {

try {

const { latitude, longitude, zoom = 14, q } = req.query;

// 验证必要参数

if (!latitude || !longitude) {

return res.status(400).json({

status: 'error',

message: '必须提供经纬度参数'

});

}

// 获取API密钥

const apiKey = process.env.GOOGLE_MAPS_API_KEY || MAPS_API_KEY;

// 构建Google Maps嵌入式地图URL

let mapUrl = `https://www.google.com/maps/embed/v1/search?key=${apiKey}`;

// 添加中心点

mapUrl += `&center=${latitude},${longitude}`;

// 添加缩放级别

mapUrl += `&zoom=${zoom}`;

// 添加搜索查询（如果有）

if (q) {

mapUrl += `&q=${encodeURIComponent(q)}`;

} else {

mapUrl += `&q=bubble+tea`;

}

// 返回地图URL

res.json({

status: 'success',

url: mapUrl

});

} catch (error) {

logger.error('生成嵌入式地图URL出错:', error);

next(error);

}

});

  

// 导出 API 函数 - 明确设置为公开访问

exports.api = onRequest({

minInstances: 0, // 最小实例数，0表示可以缩减到零

timeoutSeconds: 60, // 请求超时时间

invoker: "public", // 明确设置为公开访问，允许未经身份验证的请求

cors: true, // 启用 CORS

maxInstances: 5, // 最大实例数

}, app);

  

// 记录初始化日志

logger.info("Function initialized with Maps API key status:", {

keyConfigured: process.env.GOOGLE_MAPS_API_KEY ? true : false,

});

  

// 你也可以创建其他的 Cloud Functions 在这里，如果需要的话。

// 例如，一个响应数据库事件的函数，就像教程中提到的 makeUppercase 示例。