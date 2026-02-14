ls 列出文件
ls -l(ll) 列出文件以及其属性
ls -a 可以列出隐藏文件
ls -la 列出包括隐藏文件的属性

权限相关的，前三个为所有者权限，中间为用户组权限，最后为其他用户

cd 命令记得用整正斜杠/ 只有windows是反斜杠\

cd - 可以回到刚才所在的目录

cd ..
cd../dd

pwd 当前工作目录

cat 查看文件内容 

head filename 可以看到文件头 

head --lines=3 filename可以看前3行

tail可以看到尾

ctrl a可以将光标移到最开始

less/more filename 可以逐行查看文件

nano filename 修改文件

vim filename 可以进入查看文件，按i进入编辑模式，按esc退出模式，:wq写入修改后退出vim，:q! 不写强制退出

file filename 查看文件属性（文件类型

whereis 可以直接查找文件

echo 打印命令

shell编程：h="hello" echo $h 定义变量并打印

h="hello" echo abc-${h}-efg 包含变量的打印

mv filename filename1 完成改名

掐头为#，去尾为%

![[Pasted image 20250831023409.png]]![[Pasted image 20250831023451.png]]

![[Pasted image 20250831023533.png]]![[Pasted image 20250831023614.png]]
![[Pasted image 20250831024215.png]]