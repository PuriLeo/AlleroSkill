/*
 * @Description: 
 * @Version: 1.0
 * @Author: leo@purichip.com
 * @Date: 2026-02-24 17:45:27
 * @LastEditors: leo@purichip.com
 * @LastEditTime: 2026-02-26 02:01:19
 */

/*
skill加式的方法
1  在allergo.ilinit文件中加入如下代码：
   setSkillPath(append(getSkillPath() '("~/pcbenv/ChrisSkill"))) 
   load("ChrisSkillMenu.il")
   以上代码是告诉allergo Myil在哪里可以找到，并加载ChrisSkillMenu.il文件
2  在ChrisSkillMenu.il文件运行LoadAllSkills()，在这个函数中你可以加入你想要加载的il文件
3  axlTriggerSet('menu 'ChirsMenu)   此函数完成menu的添加，ChirsMenu函数中定义了菜单的结构和功能，你可以根据需要修改菜单结构和功能
   
此种方法使用相对路径和动态菜单加载

*/

defun( LoadAllSkills ()
    /*你能在这里加入你想要加载的il文件*/
    printf("Loading skills................................\n")  ; 
    load("ExportPdf.il")
    load("ExportDxf.il")
    load("ExportAllDir.il")
    load("Import_2LRule.il")
    load("NC_Auto.il")
    load("TechTable.il")
    load("ClearMyLib.il")
    load("FinishWork.il")
    printf("chirs skill load finished\n")  ; 
)

LoadAllSkills() ; execute the function to load all skills


defun( ChirsMenu (t_menuName)
 
  my_menu = '(
    (popup "ChirsSkill")  ;main menu name
       (separator)
       ("NC Auto","NCA") 
       ("Set Artwork Param","SetArt") 
       (separator)
       ("Place TechTable","tech1") 
       (separator)
       ("Export PDF","ExportPcbPdf")
       (separator)
       (popup "Export DXF")
          ("ALL_NO_REF_DES","ExportOptionalDxf ALL 0")
          ("All_REF_DES","ExportOptionalDxf ALL 1")
          ("TOP_NO_REF_DES","ExportOptionalDxf TOP 0")
          ("TOP_REF_DES","ExportOptionalDxf TOP 1")
          ("BOTTOM_NO_REF_DES","ExportOptionalDxf BOTTOM 0")
          ("BOTTOM_REF_DES","ExportOptionalDxf BOTTOM 1")
          ("Current Display","ExportCurrentDxf")
       (end)
       (separator) 
       ("Export All dir","exa")
       (popup "Update to All dir")
          ("SCH","UDA SCH")
          ("PCB","UDA PCB")
          ("CAM","UDA CAM")
          ("DXF","UDA DXF")
          ("ASM","UDA ASM")
          ("BOM","UDA BOM")
          ("POS","UDA POS")
          ("Clear","UDA Clear")
       (end)  
       (separator) 
       (popup "Import Rule")
          ("2L With Ref Des","Import_2LRule 1")
          ("2L No Ref Des","Import_2LRule 0")
        (end)
       ("Clear PCB lib","ClearMyLib") 
       (separator)
       ("FinishWork","FinishWork")
      (end)      
   )

    let( (palMenu)

      palMenu = axlUIMenuFind(nil -1)
      axlUIMenuInsert(palMenu my_menu)  

     )

);end defun

axlTriggerSet('menu 'ChirsMenu)   ; trigger the menu function to add menu to axl menu bar
