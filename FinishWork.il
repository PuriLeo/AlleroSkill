/*
 * @Description: 
 * @Version: 1.0
 * @Author: leo@purichip.com
 * @Date: 2026-02-26 01:24:03
 * @LastEditors: leo@purichip.com
 * @LastEditTime: 2026-02-26 02:08:12
 */
axlCmdRegister("FinishWork" 'FinishWork ?cmdType "general")

defun( FinishWork ()
   
   
    printf("=============================================Finish work================================================================\n")
    
    axlShell("ExportPcbPdf\n")    ; 导出pcb adt adb pdf文件
    axlShell("ExportOptionalDxf TOP 0\n") ; 导出top层dxf文件，不包含位号
    axlShell("ExportOptionalDxf BOTTOM 0\n") ; 导出bottom层dxf文件，不包含位号
    axlShell("ExportOptionalDxf ALL 0\n");  ; 导出top和bottom层dxf文件，不包含位号

   
    /*导出坐标文件*/
    printf("=============================================export places================================================================\n")
    p = outfile("export_places.scr\n")  ; 生成scr文件
    fprintf(p, "setwindow pcb\n")  ; 设置窗口为pcb
    fprintf(p, "placementedit\n")   
    fprintf(p, "plctxt out\n")
    fprintf(p, "setwindow form.plctxt\n")
    fprintf(p, "FORM plctxt execute\n")  
    fprintf(p, "FORM plctxt cancel\n")
    fprintf(p, "setwindow pcb\n")
    close(p)  ; 关闭scr文件
    axlShell("replay export_places.scr")  ; 执行scr文件
    deleteFile("export_places.scr")  ; 删除scr文件
    printf("Export places finished!\n")

    axlShell("exa\n")    ;  导出all目录下的文件到指定路径

    printf("Finish work, have a good day!\n")
)

