# 懒人开关灯

🚨 注意: 这是个人开发的玩具项目，练手项目，请勿直接复用，出现问题概不负责(●'◡'●) 🚨

**Version: 0.1**

## 项目简介

在不改变电路结构的基础上，实现通过手机蓝牙控制开关灯

```mermaid
graph TD;
    A[用户打开应用] --> B[连接到灯设备]
    B --> C{初始状态}
    C --> F[用户按下关按钮]
    C --> G[用户按下开按钮]
    F --> H[发送关闭指令到设备]
    G --> I[发送开启指令到设备]
    H --> J[设备收到关闭指令，灯关闭]
    I --> K[设备收到开启指令，灯开启]
```

### 项目特点

- 无需破坏现有设备，特别适合我这样的租房人群
- 电路实现了电源电池切换，可以使用电源直接供电，也可以使用锂电池供电
- 使用手机APP控制，随时开关灯（后期可通过蓝牙网关接入米家之类的）
- 双舵机适配不同开关数量
- 外壳采用滑槽设计，方便拿下来充电

## 技术栈

涉及以下技术：

- **PCB设计**: ![PCB Design](https://img.shields.io/badge/PCB_Design-008000?style=flat-square&logo=protoboard&logoColor=white)
- **Arduino**: ![Arduino](https://img.shields.io/badge/Arduino-00979D?style=flat-square&logo=arduino&logoColor=white)
- **SolidWorks**: ![SolidWorks](https://img.shields.io/badge/SolidWorks-900C3F?style=flat-square&logo=solidworks&logoColor=white)
- **Flutter**: ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)


## 项目图片展示


## 项目图片展示

<div style="display: flex; flex-wrap: wrap;">
  <div style="flex: 1; min-width: 300px;">
    <img src="05.Picture/Shell.jpg" width="300" height="200">
  </div>
  <div style="flex: 1; min-width: 300px;">
    <img src="05.Picture/Real.jpg" width="300" height="200">
  </div>
  <div style="flex: 1; min-width: 300px;">
    <img src="05.Picture/3DPCB.png" width="300" height="300">
  </div>
  <div style="flex: 1; min-width: 300px;">
    <img src="05.Picture/3DDesign.png" width="300" height="300">
  </div>
  <div style="flex: 1; min-width: 100%;">
    <img src="05.Picture/App.jpg" width="400" height="500">
  </div>
</div>
