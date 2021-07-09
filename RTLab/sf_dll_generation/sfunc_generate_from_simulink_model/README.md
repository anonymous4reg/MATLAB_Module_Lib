# 由Simulink model生成S-function的方法

## 1. 

### Step1: 将准备封装成S-Function的Subsystem放到一空白Model中

<img src="README.assets/image-20210701140737792.png" alt="image-20210701140737792"  />

### Step2: 在***Model Setting***中，将***System target file***选为***S-function Target***.

![image-20210701140536562](README.assets/image-20210701140536562.png)

### Step3: 确认勾选了***Create new model***，这样build完成的S-Function会以一个新Model的形式弹出。

<img src="README.assets/image-20210701140552921.png" alt="image-20210701140552921" style="zoom:80%;" />

### Step4: 点击Build按钮。如果Build按钮没有出现，则在App中搜索Coder，点击Simulink Coder即可调出Build按钮所在工具栏。

<img src="README.assets/image-20210701141133993.png" alt="image-20210701141133993" style="zoom:80%;" />

<img src="README.assets/image-20210701141218506.png" alt="image-20210701141218506" style="zoom:80%;" />



Build之后会产生与Model名称一致的.c/.h/.mexw64文件和一个文件夹

![image-20210701141620177](README.assets/image-20210701141620177.png)

同时弹出一个Model，即为Build封装好的S-Function. 

<img src="README.assets/image-20210701142005092.png" alt="image-20210701142005092" style="zoom:80%;" />

## 测试结果

![image-20210701142635654](README.assets/image-20210701142635654.png)





```bash
gcc -Wall -DRT -c *.c -I/App/MATLAB/R2020b/simulink/include/ -I/App/MATLAB/R2020b/extern/include/ -I/App/MATLAB/R2020b/toolbox/rtw/accel/accelTemplateFolder/ -I/App/MATLAB/R2020b/rtw/c/src/
```







<img src="README.assets/image-20210702085454659.png" alt="image-20210702085454659" style="zoom:120%;" />
