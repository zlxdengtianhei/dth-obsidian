## 一、各种算法之间的选择

### EasyPR
[转载：车牌识别_ooserapho的博客-CSDN博客](https://blog.csdn.net/u012851870/article/details/83748648)

### HyperLPR

### YOLOV5+LPRnet（选用）
检测网络用的yolov5，识别网络用的lprnet

YOLOV5讲解：
[【YOLOV5-5.x 源码讲解】整体项目文件导航_v5源码_满船清梦压星河HK的博客-CSDN博客](https://blog.csdn.net/qq_38253797/article/details/119043919)

## 二、参考项目

### 1.项目1
项目源码：
[mirrors / kiloGrand / license-plate-recognition · GitCode](https://gitcode.net/mirrors/kiloGrand/license-plate-recognition?utm_source=csdn_github_accelerator)


### 2.项目2（选用）
[【项目三、车牌检测+识别项目】一、CCPD车牌数据集转为YOLOv5格式和LPRNet格式_ccpd数据集如何转换成yolo格式_满船清梦压星河HK的博客-CSDN博客](https://blog.csdn.net/qq_38253797/article/details/125042833)


先学会整体项目的代码 再补充学习基础知识：核心是yolov5和lprnet
再学习深度学习基础知识

## 三、项目代码架构

### 1.data

### 2.dataset


## 三、项目笔记

### 1.数据集的收集和制作

主要参考以下文章：
[【项目三、车牌检测+识别项目】一、CCPD车牌数据集转为YOLOv5格式和LPRNet格式_ccpd数据集如何转换成yolo格式_满船清梦压星河HK的博客-CSDN博客](https://blog.csdn.net/qq_38253797/article/details/125042833)

#### 过程


`对于ccpd2019数据集：

**1. 划分训练集、验证集和测试集**

| 训练集train | 验证集validation | 测试集test | 总计total     |
| -------- | -------- | --------|--------|
| 24911 | 3558 | 7117 |35586|

**2. 车牌检测数据集制作**
![[Pasted image 20230817172753.png]]

| 训练集train | 验证集validation | 测试集test | 总计total     |
| -------- | -------- | --------|--------|
| 24911 | 3558 | 7117 |35586|


**3. 车牌识别数据集制作**

![[Pasted image 20230817174321.png]]

| 训练集train | 验证集validation | 测试集test | 总计total     |
| -------- | -------- | --------|--------|
| 16766 | 3532 | 6981 |27279|
**为什么两个数据集数量不一样？**
主要是车牌识别是以车牌字符为文件名的，有些车牌检测照片重复了，自然就只能保留一个。

**准备好的数据集：**
![[Pasted image 20230818153524.png]]


`改用CCPD2020数据集（直接取用老师给的）`

对于**车牌检测数据集**：

![[Pasted image 20230818155514.png]]

| 训练集train | 验证集validation | 测试集test | 总计total     |
| -------- | -------- | --------|--------|
| 5769 | 1001 | 5006 |11776|

对于**车牌识别数据集**：
![[Pasted image 20230818161939.png]]

| 训练集train | 验证集validation | 测试集test | 总计total     |
| -------- | -------- | --------|--------|
| 1244 | 547 | 1594 |3385|

#### 注意事项：
1. 原项目所选用的数据集是ccpd2019的3万张照片+ccpd2020的1万张照片
共计4万张照片，后期可以考虑加入ccpd2019中其他数据集如blur等

2. 原项目完成的是一个demo

3. 本项目从ccpd2019的ccpd_base中挑选了**35586张**照片用于组成数据集、验证集和测试集

4. 不足之处：数据集是有缺陷的，只用了base数据集，还有一些复杂场景如：复杂天气（雨天、雪天），过亮过暗场景、远近距离场景、各个省份拍照数量不均（80%是皖）等等效果都有待提高。如果你是想和我一样做个demo的话，这近4万张图片应该是足够了，如果是考虑落地、实际展示的话，建议自行使用CCPD2019其他复杂数据进行扩充，也可以自己拍一些其他省份的数据再按我上面的方法进行扩充。


#### 补充知识

`1. 测试集、验证集、训练集`

参考文章：
[【机器学习】验证集和测试集有什么区别_验证集和测试集的区别_想变厉害的大白菜的博客-CSDN博客](https://blog.csdn.net/weixin_44211968/article/details/120814758?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522169226281916800197058748%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=169226281916800197058748&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduend~default-1-120814758-null-null.142^v93^chatsearchT3_2&utm_term=%E6%B5%8B%E8%AF%95%E9%9B%86%E5%92%8C%E9%AA%8C%E8%AF%81%E9%9B%86%E7%9A%84%E5%8C%BA%E5%88%AB&spm=1018.2226.3001.4187)

[训练集损失值loss、测试集val_loss、验证集loss相关问题总结_上课不要摸鱼江的博客-CSDN博客](https://blog.csdn.net/qq_43653405/article/details/121396954?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522169226274316800180612618%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=169226274316800180612618&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduend~default-1-121396954-null-null.142^v93^chatsearchT3_2&utm_term=%E6%B5%8B%E8%AF%95%E9%9B%86%E5%92%8C%E9%AA%8C%E8%AF%81%E9%9B%86loss&spm=1018.2226.3001.4187)

`2. demo`
```
demo本意是“试样唱片; 录音样带”。程序员延伸出了“例子、小样”的意思，所以写demo就是写个“小例子”。

大的完整的程序叫做项目，而那些小的，能实现一些特定功能的小程序就叫demo，比如微博，项目；实现微博的一部分功能的小程序叫demo

你需要先验证使用的技术是否可行。demo的作用就是验证一些技术是否可行，以便到时候【写】出【设计】的程序逻辑，可以用。这就是demo的作用进行测试。
```

`3. loss(损失函数) `
[损失函数](https://so.csdn.net/so/search?q=%E6%8D%9F%E5%A4%B1%E5%87%BD%E6%95%B0&spm=1001.2101.3001.7020)（loss function）是用来**估量模型的预测值f(x)与真实值Y的不一致程度**，它是一个非负实值函数,通常使用L(Y, f(x))来表示，损失函数越小，模型的鲁棒性就越好。

参考文章：
[深度学习——知识点总结3(损失函数Loss)_深度学习中loss_baobei0112的博客-CSDN博客](https://blog.csdn.net/baobei0112/article/details/95060370?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522169226283416800180678918%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=169226283416800180678918&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduend~default-2-95060370-null-null.142^v93^chatsearchT3_2&utm_term=loss%E6%8D%9F%E5%A4%B1%E5%80%BC%E6%98%AF%E4%BB%80%E4%B9%88&spm=1018.2226.3001.4187)


### 2.使用 YOLOv5进行车牌检测

参考文章：

1. [【项目三、车牌检测+识别项目】二、使用YOLOV5进行车牌检测_yolo车牌检测_满船清梦压星河HK的博客-CSDN博客](https://blog.csdn.net/qq_38253797/article/details/125027825)

2. [【YOLOV5-5.x 源码讲解】整体项目文件导航_v5源码_满船清梦压星河HK的博客-CSDN博客](https://blog.csdn.net/qq_38253797/article/details/119043919)


最后测试是使用的下面这个文章的方法：
[目标检测---教你利用yolov5训练自己的目标检测模型_yolov5安全帽预训练模型_炮哥带你学的博客-CSDN博客](https://blog.csdn.net/didiaopao/article/details/119954291?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522169231939216800182732105%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=169231939216800182732105&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~top_positive~default-2-119954291-null-null.142^v93^chatsearchT3_2&utm_term=yolov5&spm=1018.2226.3001.4187)

#### 过程

`2.opt参数设置（部分）`

权重文件使用yolov5s.pt
**epoch=100(迭代100次)**
batch_size=16
![[Pasted image 20230818161147.png]]


`1. 训练过程`

![[Pasted image 20230818161313.png]]

**一开始用CPU跑速度非常慢而且训到第5个epoch时报错**
**mAP**
![[Pasted image 20230818195939.png]]

![[Pasted image 20230818195954.png]]

![[Pasted image 20230818200023.png]]

**train_loss**
![[Pasted image 20230818200554.png]]

![[Pasted image 20230818200635.png]]

![[Pasted image 20230818200647.png]]

**val_loss**
![[Pasted image 20230818200718.png]]

![[Pasted image 20230818200732.png]]

![[Pasted image 20230818200743.png]]

![[Pasted image 20230818200928.png]]

![[Pasted image 20230818200939.png]]

![[Pasted image 20230818200956.png]]

**报错信息如下：**
![[Pasted image 20230818200408.png]]

![[Pasted image 20230818200424.png]]

#### 注意事项

#### 遇到的问题

`1. 报错“RuntimeError: shape '[1, 3, 6, 16, 16]' is invalid for input of size 32768”

解决方案（暂未解决）：
[运行yolov5中detect.py报错 RuntimeError: shape ‘[1, 3, 6, 80, 80]‘ is invalid for input of size 819200_QAQ_JUIMY的博客-CSDN博客](https://blog.csdn.net/QAQ_JUIMY/article/details/108625155?spm=1001.2101.3001.6650.2&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-2-108625155-blog-129890530.235%5Ev38%5Epc_relevant_anti_t3_base&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-2-108625155-blog-129890530.235%5Ev38%5Epc_relevant_anti_t3_base&utm_relevant_index=3)

`2. AttributeError: module numpy has no attribute int

解决方案（已解决）：
[AttributeError: module numpy has no attribute int .报错解决方案_小恶魔饿了的博客-CSDN博客](https://blog.csdn.net/weixin_46669612/article/details/129624331?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522169234259316800225510960%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=169234259316800225510960&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduend~default-1-129624331-null-null.142^v93^chatsearchT3_2&utm_term=AttributeError%3A%20module%20numpy%20has%20no%20attribute%20int.&spm=1018.2226.3001.4187)

`3. RuntimeError: result type Float can‘t be cast to the desired output type __int64

解决方案（已解决）：
[YOLO训练报错解决：RuntimeError: result type Float can‘t be cast to the desired output type __int64_强盛小灵通专卖员的博客-CSDN博客](https://blog.csdn.net/crasher123/article/details/131540634?spm=1001.2101.3001.6650.2&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7EYuanLiJiHua%7EPosition-2-131540634-blog-130336910.235%5Ev38%5Epc_relevant_anti_t3_base&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7EYuanLiJiHua%7EPosition-2-131540634-blog-130336910.235%5Ev38%5Epc_relevant_anti_t3_base&utm_relevant_index=3)

`4.CPU训练yolov5训练速度慢且内存不够`
[YOLOv5训练速度慢的一些解决方法_yolov5训练慢_豆浆没有油条的博客-CSDN博客](https://blog.csdn.net/weixin_54048889/article/details/127934092?ops_request_misc=&request_id=&biz_id=102&utm_term=yolov5%E8%AE%AD%E7%BB%83%E9%80%9F%E5%BA%A6&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-0-127934092.142^v93^chatsearchT3_2&spm=1018.2226.3001.4187)

[关于yolov5训练大量数据存在的问题记录_yolo训练 缓存_门前大橋下丶的博客-CSDN博客](https://blog.csdn.net/weixin_44883371/article/details/124298163?ops_request_misc=&request_id=&biz_id=102&utm_term=yolov5%E8%AE%AD%E7%BB%83%E9%80%9F%E5%BA%A6%E6%85%A2&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-2-124298163.142^v93^chatsearchT3_2&spm=1018.2226.3001.4187)

解决方案：
用GPU训 采用pytorch+CUDA

`5.换用GPU训练后遇到的问题解决`

[【深度学习】YOLOV5训练模型报错：OSError: [WinError 1455] 页面文件太小,无法完成操作。 Error loading “D:\Softw_训练模型时报错 页面大小不足_别出BUG求求了的博客-CSDN博客](https://blog.csdn.net/weixin_39589455/article/details/124527537?ops_request_misc=&request_id=&biz_id=102&utm_term=YOLOv5%20OSError:%20%5BWinError%201455&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-0-124527537.142^v93^chatsearchT3_2&spm=1018.2226.3001.4187)

[已解决yolov5报错RuntimeError: CUDA out of memory. Tried to allocate 14.00 MiB_爱笑的男孩。的博客-CSDN博客](https://blog.csdn.net/Code_and516/article/details/129798540?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522169236165416800186527283%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fall.%2522%257D&request_id=169236165416800186527283&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~first_rank_ecpm_v1~rank_v31_ecpm-4-129798540-null-null.142^v93^chatsearchT3_2&utm_term=RuntimeError%3A%20CUDA%20out%20of%20memory.%20Tried%20to%20allocate%2014.00%20MiB%20%28GPU%200%3B%204.00%20GiB%20total%20capacity%3B%202.39%20GiB%20already%20allocated%3B%202.45%20MiB%20free%3B%202.43%20GiB%20reserved%20in%20total%20by%20PyTorch%29&spm=1018.2226.3001.4187)

#### 补充知识

`1. epoch、batch、batch size的介绍以及设定`
[深度学习中Epoch、Batch以及Batch size的设定_batchsize和epoch_风度丶的博客-CSDN博客](https://blog.csdn.net/qq_39026874/article/details/118787663?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522169227084916800211574989%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=169227084916800211574989&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~top_click~default-2-118787663-null-null.142^v93^chatsearchT3_2&utm_term=epoch%E5%92%8Cbatchsize&spm=1018.2226.3001.4187)

`2.YOLOV5的loss`
[YOLOv5损失函数定义_yolov5的损失函数_明天才有空的博客-CSDN博客](https://blog.csdn.net/WZT725/article/details/123896386?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522169234952416800188528869%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=169234952416800188528869&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~top_click~default-1-123896386-null-null.142^v93^chatsearchT3_2&utm_term=box_loss&spm=1018.2226.3001.4187)

[【网络收敛】如何根据loss判断网络是否收敛_神经网络loss值多少才算收敛_知己不识君的博客-CSDN博客](https://blog.csdn.net/qq_42745706/article/details/124237478?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522169234965216777224425518%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fall.%2522%257D&request_id=169234965216777224425518&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~first_rank_ecpm_v1~rank_v31_ecpm-2-124237478-null-null.142^v93^chatsearchT3_2&utm_term=loss%E4%B8%BA%E5%A4%9A%E5%B0%91&spm=1018.2226.3001.4187)

[卷积神经网络loss不下降,神经网络loss多少算正常_损失函数多少算正常_小六oO的博客-CSDN博客](https://blog.csdn.net/mr_yu_an/article/details/127433231?ops_request_misc=&request_id=&biz_id=102&utm_term=loss%E4%B8%BA%E5%A4%9A%E5%B0%91&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-1-127433231.142^v93^chatsearchT3_2&spm=1018.2226.3001.4187)


`3.batchsize的设置`
[【调参】batch_size的选择_batchsize选择_there2belief的博客-CSDN博客](https://blog.csdn.net/dou3516/article/details/128034109?ops_request_misc=&request_id=&biz_id=102&utm_term=batchsize%E5%A4%9A%E5%B0%91%E5%90%88%E9%80%82&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-1-128034109.142^v93^chatsearchT3_2&spm=1018.2226.3001.4187)

`4.TensorBoard的使用`
[本地pytorch环境下利用YOLOv5训练自己的数据（包括加速训练参数设置与tensorboard查看）_yolo训练tensorboard_LaternZ的博客-CSDN博客](https://blog.csdn.net/qq_45874142/article/details/124884219?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_utm_term~default-0-124884219-blog-128856483.235^v38^pc_relevant_anti_t3_base&spm=1001.2101.3001.4242.1&utm_relevant_index=3)

`5.目标检测评估指标mAP`
[目标检测模型评估指标——mAP计算的讨论_metrics/map_0.5_子季鹰才的博客-CSDN博客](https://blog.csdn.net/hitzijiyingcai/article/details/84185764?ops_request_misc=&request_id=&biz_id=102&utm_term=metrics%20mAP%E6%98%AF%E4%BB%80%E4%B9%88&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-0-84185764.142^v93^chatsearchT3_2&spm=1018.2226.3001.4187)

[mAP@0.5与mAP@0.5:0.95的含义_map0.5:0.95_Fighting_1997的博客-CSDN博客](https://blog.csdn.net/frighting_ing/article/details/121197733)

[平均精度均值(mAP)——目标检测模型性能统计量 - 郭耀华 - 博客园 (cnblogs.com)](https://www.cnblogs.com/guoyaohua/p/9901614.html)

由于只有1个类别——车牌，所以mAP可以直接反应车牌这个目标检测的平均精度均值

### 3. lprnet车牌识别
