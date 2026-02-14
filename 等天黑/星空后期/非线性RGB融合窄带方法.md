加Ha为例：

1. 非线性去星
2. RGB拆通道
3. Ha再DBE一下
4. Ha从线性取值拉伸

先到核心可以看到
![[Pasted image 20241209224452.png]]

然后到Ha可以看到
![[Pasted image 20241209224506.png]]

然后切除部分背景，再强化部分Ha
![[Pasted image 20241209224520.png]]

五、提取Ha在星云的数值，以及同位置RGB的数值，看R值大约为多少，同位置Ha更亮，周边位置R的背景比低，对其重新拉伸
![[Pasted image 20241209224542.png]]

6. Ha去星，NXT0.5

7. 用ATWT提取Ha，慢慢试参数排除大尺度，可以Dynamic，16层开始，得到过度较平滑的Ha
![[Pasted image 20241209225047.png]]
![[Pasted image 20241209225124.png]]

8. range selection 做蒙版
![[Pasted image 20241209225532.png]]

9. 在R B中蒙版混入ha
![[Pasted image 20241209225914.png]]

10. 混合RGB，看效果改B参数

11. 贴星

 12. 再套上蒙版，拉曲线，在a模式下，鼠标滑动找到背景中性点，点锚点，拉S曲线