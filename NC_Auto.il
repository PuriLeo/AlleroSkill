/*
 * @Description: 
 * @Version: 1.0
 * @Author: leo@purichip.com
 * @Date: 2026-02-17 18:54:51
 * @LastEditors: leo@purichip.com
 * @LastEditTime: 2026-02-24 12:38:07
 */
axlCmdRegister("NCA" 'NC_Auto ?cmdType "general")   ;regsister nc auto function
axlCmdRegister("SetArt" 'SetArtParam ?cmdType "general")   ;regsister nc auto function

/*自动生成 nc_parameters form 和 nc_drill form 的参数，并执行nc drill和nc route drill_legend  功能的脚本*/
defun(NC_Auto ()
  p = outfile("nc_auto.scr")  ; 读取nc_auto.scr文件
  /*nc parameters*/
  fprintf(p "ncdrill param\n")  ;  
  fprintf(p "setwindow form.nc_parameters\n")  ;  
  fprintf(p "FORM nc_parameters enhanced_format YES\n")  ;  
  fprintf(p "FORM nc_parameters done \n")  ;  
  fprintf(p "setwindow pcb\n")  ; 
  /*nc drill*/
  fprintf(p "nctape_full\n")  ;
  fprintf(p "setwindow form.nc_drill\n")  ;
  fprintf(p "FORM nc_drill auto_tool_select YES\n")  ;
  fprintf(p "FORM nc_drill execute \n")  ;
  fprintf(p "FORM nc_drill close\n")  ;
  fprintf(p "setwindow pcb\n")  ;
  /*ncroute*/
  fprintf(p "ncroute\n")  ;
  fprintf(p "setwindow form.nc_route\n")  ;
  fprintf(p "FORM nc_route execute\n")  ;
  fprintf(p "FORM nc_route close\n")  ;
  fprintf(p "setwindow pcb\n")
  /*nc legend*/
  fprintf(p "ncdrill legend\n")  ;
  fprintf(p "setwindow form.nc_drilllegend\n")  ;
  fprintf(p "FORM nc_drilllegend done\n")  ;
  close(p)  ; 关闭文件

  axlShell("replay nc_auto.scr")  ; 执行nc_auto.scr文件
  deleteFile("nc_auto.scr")  ; 删除nc_auto.scr文件

)

/*自动设置artwork层的参数的脚本
1. mirror adb layer in film control form
2. 设置 所以未定义的线宽为6mil或者0.1524mm（根据当前设计单位）

*/
defun(SetArtParam ()

  let( (art_num art_lay_list str current_design_unit_list,current_line_width) 

      p = outfile("set_art.scr")  ; 读取set_art.scr文件
      fprintf(p "setwindow pcb\n")  ;  
      fprintf(p "artwork \n")  ;  
      fprintf(p "setwindow form.film_control\n")  ;
      
      ;set adb mirror
      fprintf(p "FORM film_control filmtree 'MULTISEL YES' ADB\n") ;select adb in film control form
      fprintf(p "FORM film_control mirror YES\n") ; set mirror in film control form
      

      
      art_num = axlGetParam("artwork")->nChildren  ;get artwork layer number
      
      art_lay_list = axlGetParam("artwork")->groupMembers ;get artwork layer list
      current_design_unit_list = axlDBGetDesignUnits(); get current design units
      if(car( current_design_unit_list) == "mils" then
        current_line_width = 6.00
        
      else
        current_line_width = 0.1524  ; 6 mil in mm
      )

      
      for(i 0 art_num-1

         str =  nth(i art_lay_list)
         if(str != nil then
           fprintf(p,"FORM film_control filmtree %s\n" str)
         )
         ;printf("Set artwork layer: %s\n" str)

         fprintf(p "FORM film_control undefined_line_width %.2f\n" current_line_width) ; set undefined line width
      
      )
  
      fprintf(p "FORM film_control ok\n")  ; close form
      fprintf(p "setwindow pcb\n")  ;set window to pcb
      close(p)  ; 关闭文件

      axlShell("replay set_art.scr")  ; 执行set_art.scr文件
      deleteFile("set_art.scr")  ; 删除set_art.scr文件

  )
  
)



