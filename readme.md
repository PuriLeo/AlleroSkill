<!--
 * @Description:  
 * @Version: 1.0
 * @Author: leo@purichip.com
 * @Date: 2026-02-27 00:07:41
 * @LastEditors: leo@purichip.com
 * @LastEditTime: 2026-02-27 01:17:03
-->
# 1. 安装ChrisSkill
  1. Copy ChrisSkil文件夹到安装目录下的SPB_Data\pcb_env下，比如我的路径为 **D:\Cadence\SPB_Data\pcbenv**
  2. allegro.ilinit 为Allegro的初始化文件，位于pcb_env目录下，打开后在末尾添加以下内容并保存 
``` 
    setSkillPath(append(getSkillPath() '("~/pcbenv/ChrisSkill"))) 
    load("ChrisSkillMenu.il") 
``` 
     其中的ChrisSkillMenu.il 是ChrisSkill的菜单文件 ，它的加载实现了所有的il文件的加载，并添加了菜单项。
  3. 重启Allegro，菜单栏会出现ChrisSkill菜单，点击菜单项可以看到ChrisSkill的功能。
 # 2. ClearMyLib 
   用来清理封装库中的垃圾文件，可以修改库的路径定义自己的库的位置 
```
    AllergoLibPath = "D:/WorkSync/MySync/EDALib2/AllergoLib/"     ; allergo库的目录路径
    OrcadLibPath = "D:/WorkSync/MySync/EDALib2/OrcadLib/"         ; Orcad库的目录路径
    FootPrintLibDir = '("Connect" "Discrete" "IC" "Mechanical" "Format" "Pad") ;allergo lib
    AllergoExtName =  '("dra" "psm" "ssm" "osm" "pad" "bsm") ;allergo file extension name
    目录结构
    --AllegroLib
    |--Connect
    |--Discrete  
    |--IC
    |--Mechanical
    |--Format
    |--Pad

```
# 3.TechTable
  运行Techtable弹出如下对话框，用户输出各项工艺参数后点击放置可以放置到PCB板上
 ![alt text](image.png)

 ![alt text](image-1.png)

 # 4. ExportPdf
  导出PCB PDF 和ADT ADB装配文件
 # 5. ExportDxf
   它具有TOP Bottom和All三种模式，分别导出PCB的TOP层、Bottom层和 Top&Bottom层的DXF文件，用户可以选择需要导出的层。
```
    ExportDxf Top  ; 导出TOP层的DXF文件
    ExportDxf Bottom ; 导出Bottom层的DXF文件
    ExportDxf All ; 导出TOP和Bottom层的DXF文件
```
# 6. NC_Auto
   它实现了Manfacture下 四个菜单的全自动操作
```NC paramters
   NC Drill
   NC Route
   NC Drill Legend
```
# 7. SetArt
设置 artwork 如下两个功能
1. 镜像 adb  
2. 设置 所以未定义的线宽为6mil或者0.1524mm（根据当前设计单位）
# 8. EXA
   导出如下目录结构并且填充文件内容，最终清空工作目录，只保留'.DSN' '.brd'和'-All' 
``` --All
    |-Cam
    |-Dxf
    |-Eq
    |-Sch
    |-Pcb
    |-Smt
        |-ASM
        |-SMD
        |-BOM
        |-POS
```
 
