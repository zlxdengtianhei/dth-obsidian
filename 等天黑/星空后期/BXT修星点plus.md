**BXT**

1. 星点图Bin2，用平场/game生成蒙版，对边缘变形星点操作

2. 1.2以下的卷积

3. 恢复Bin1

4. BXT，蒙版，对边缘操作
   (connect only)

5. 此时星点边缘会有阴影(过硬)，易在后续去星出问题，用一个轻微 (convolution (.06))

6. 缩星 BXT  correct first    sharpen 0.1    nonstellar: 0.

7. 用蒙版，找到星点变化明显的位置，然后直接替换中心为原图星点