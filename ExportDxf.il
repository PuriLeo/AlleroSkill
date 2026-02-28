/*
 * @Description: 
 * @Version: 1.0
 * @Author: leo@purichip.com
 * @Date: 2026-02-13 21:05:16
 * @LastEditors: leo@purichip.com
 * @LastEditTime: 2026-02-26 01:32:49
 */

/*导出当前显示内容到dxf*/
axlCmdRegister("ExportCurrentDxf" 'ExportCurrentDxf ?cmdType "general")   
/*导出可选内容到dxf
1 TOP ;导入top层
2 BOTTOM ;导入bottom层
3 ALL ;导入top和bottom层
4 is_exsist_ref_des ;0 不包含位号 1 包含位号
*/
axlCmdRegister("ExportOptionalDxf" 'ExportOptionalDxf ?cmdType  "general")



/*导出当前显示内容到dxf*/
defun(ExportCurrentDxf ()
  export_dxf(axlCurrentDesign())   ; 传输当前设计
)


/*导出可选内容到dxf
1 TOP ;导入top层
2 BOTTOM ;导入bottom层
3 ALL ;导入top和bottom层
4 is_exsist_ref_des ;0 不包含位号 1 包含位号
*/
defun(ExportOptionalDxf ( top_bottom_sel is_exsist_ref_des)   
  
  printf("=============================================start export dxf================================================================\n")
  if(evalstring(is_exsist_ref_des ) == 1 then    ; 判断是否存在ref des
     ref_des_flag = t
  else
     ref_des_flag = nil
  )

  vis_list  = axlVisibleGet() ; 获取当前可见层列表
  axlVisibleDesign(nil)  ; 设置所有层不可见 
  top_bottom_sel = upperCase(top_bottom_sel)  ; 转换输入为大写

  axlVisibleLayer("BOARD GEOMETRY/OUTLINE", t)  ; outline layer
  if(top_bottom_sel=="TOP" then   ; top layer
     axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_TOP", t) 
     axlVisibleLayer( "Pin/Top", t)
     axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP", t)
     if(ref_des_flag!=nil then
       axlVisibleLayer( "REF DES/SILKSCREEN_TOP", t)
     )
     export_dxf_name = strcat(axlCurrentDesign(), "_top")  ; 传输当前设计加上_top后缀
  else
     if( top_bottom_sel =="BOTTOM" then   ; bottom layer
      
        axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_BOTTOM", t) s
        axlVisibleLayer( "Pin/Bottom", t)
        axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM", t)
        if(ref_des_flag!=nil then
            axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM", t)
        )
        export_dxf_name = strcat(axlCurrentDesign(), "_bottom")  ; 传输当前设计加上_bottom后缀
      else 
        if( top_bottom_sel =="ALL" then  ;top and bottom layer
            axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_BOTTOM", t) s
            axlVisibleLayer( "Pin/Bottom", t)
            axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM", t)
            if(ref_des_flag!=nil then
                 axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM", t)
            )
          
            axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_TOP", t) 
            axlVisibleLayer( "Pin/Top", t)
            axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP", t)
            if(ref_des_flag!=nil then
                 axlVisibleLayer( "REF DES/SILKSCREEN_TOP", t)
            )
            export_dxf_name = axlCurrentDesign()  ; 传输当前设计加上_all后缀
        )
     )
  ) 
 
  export_dxf(export_dxf_name)  ; 调用导出函数
  axlVisibleSet(vis_list)   ; 恢复之前的可见层设置
  axlVisibleUpdate(t)       
  printf("Export DXF finished!\n")
)


/*导出当前显示内容到dxf*/
defun(export_dxf (filename)

  str = strcat(filename,"_1.cnv")  ; 生成cnv文件名
  if( isFile(str) then
     deleteFile(str)  ; 删除已存在的cnv文件
  )

   ; create scr file from  below command
  p = outfile("exportdxf.scr\n")  ; 创建一个新的文件来保存DXFscript
  fprintf(p "setwindow pcb\n")    
  fprintf(p "dxf out \n" filename)  
  fprintf(p "setwindow form.dxf_out\n")   ;  set dxf_out form as current form
  fprintf(p "FORM dxf_out browsedxf\n" filename)
  fprintf(p "fillin \"%s.dxf\"\n" filename)  ; set dxf name,use filename as dxf name
  fprintf(p "FORM dxf_out units MM\n")  ; set units to mm
  fprintf(p "FORM dxf_out browselayer\n") ; set cnv file name
  fprintf(p "fillin \"%s_1.cnv\"\n" filename)  ; set cnv name,use filename as cnv name

  fprintf(p "FORM dxf_out edit\n")  ;execute dxf_out edit button
  fprintf(p "setwindow form.dxfOutMapping\n")  ;  set dxfOutMapping form as current form
  fprintf(p "FORM dxfOutMapping selectall YES\n")  ; execute dxfOutMapping edit button
  fprintf(p "FORM dxfOutMapping usedefaultlayernames YES\n")  ; execute dxfOutMapping edit button
  fprintf(p "FORM dxfOutMapping map\n")  ; execute dxfOutMapping edit button
  fprintf(p "FORM dxfOutMapping done\n")  ; execute dxfOutMapping edit button
  fprintf(p, "setwindow form.dxf_out\n")  ; set dxf_out form as current form
  fprintf(p "FORM dxf_out execute\n")  ; execute dxf_out export button
  fprintf(p "FORM dxf_out close\n")  ; set pcb form as current form
  fprintf(p "setwindow pcb\n")  ; set pcb form as current form
  close(p)  ; 关闭文件
  axlShell("replay exportdxf.scr")  ; 执行生成的脚本文件
   
   deleteFile("exportdxf.scr")  ; 删除临时脚本文件
 
   str = strcat(filename,"_1.cnv")  ; 生成cnv文件名
   deleteFile(str)	;删除导出DXF的层文件

)




