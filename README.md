## 基于高云IP核外挂SDRAM控制器的uart收发读写测试

#### 已经通过了仿真与上板验证

#### 文件结构如下：  

## 目录结构  
  
### 1. **SIM**  
- `SIM` 内存放了仿真文件，包括testbecn的tb文件，和sdram仿真模型文件，还有高云5A的仿真库文件
  
### 2. **src**  
- `src` 包含了uart_tx 、 rx 文件和控制SDRAM的两个模块IPtop、IPsdram ，还有 高云IP管理器自动生成的的IP文件夹 ，IP文件夹内还有的vo文件为仿真工程所需要。uart波特率9600，整个系统出现的所有时钟均为50MHz。上板的时候，需要去两个uart文件内取消`进入仿真` 的那一行代码 ，所使用的SDRAM为256M，华邦
  
### 3. **impl**  
- 
### 4. **work**  
- `work` 存放modelsim仿真内容

### 5. **picture**
- `picture`存放了上板的图片，使用的板子是speed公司开发的tang25k板卡，板载了高云5A芯片

### .gprj  
- 可以点击它直接打开工程
  
### .mpf
- 直接点击可打开modelsim仿真工程，两个uart文件夹内的仿真一行需要注意是否有取消注释
  
