/*
 * @Description: 
 * @Version: 1.0
 * @Author: leo@purichip.com
 * @Date: 2026-02-16 17:59:44
 * @LastEditors: leo@purichip.com
 * @LastEditTime: 2026-02-26 13:40:06
 */

/*导出PCB PDF文件*/
axlCmdRegister("ExportPcbPdf", 'ExportPcbPdf ?cmdType "general" )

/* export pcb pdf,adt pdf and adb pdf */
defun(ExportPcbPdf ()

  let( (fileName )
  
     printf("=============================================start export pdf================================================================\n")
     fileName  = strcat(axlCurrentDesign(),"_pcb")

    /*export pcb pdf*/
    p = outfile("export_pdf.scr\n")  ; 生成scr文件
    fprintf(p, "setwindow pcb\n")  ; 设置窗口为pcb
    fprintf(p, "pdf out\n")  ; 写入pdf out命令
    fprintf(p, "setwindow form.pdf_out\n")
    fprintf(p, "FORM pdf_out doc_open NO\n")  ; 不打开pdf文件
    fprintf(p, "FORM pdf_out selectall\n")  ; 选择所有对象
    fprintf(p, "FORM pdf_out filename %s\n" fileName)
    fprintf(p, "FORM pdf_out export\n" )  ; 导出pdf文件，文件名为当前设计名

    /*export pcb adt pdf*/
    fprintf(p, "FORM pdf_out clearall\n")  ; 清除选择
    
    fprintf(p, "FORM pdf_out pdftree adt\n")  ; 选择adt树
    fprintf(p, "FORM pdf_out pdftree 'MULTISEL YES' ADT\n")
    fprintf(p, "FORM pdf_out filename ADT\n")
    fprintf(p, "FORM pdf_out export\n" )  ; 

    /*export pcb adb pdf*/
    fprintf(p, "FORM pdf_out clearall\n")  ; 清除选择
    fprintf(p, "FORM pdf_out pdftree adb\n")  ; 选择adb
    fprintf(p, "FORM pdf_out pdftree 'MULTISEL YES' ADB\n")
    fprintf(p, "FORM pdf_out filename ADB\n")
    fprintf(p, "FORM pdf_out export\n" )  ; 

    /*close pdf form and set window back to pcb, then execute scr file and delete scr file*/
    fprintf(p, "setwindow form.pdf_out\n")
    fprintf(p, "FORM pdf_out cancel\n")
    fprintf(p, "setwindow pcb\n")
    close(p)  ; 关闭scr文件
    axlShell("replay export_pdf.scr")  ; 执行scr文件

    /*删除scr文件*/
    deleteFile("export_pdf.scr")  ; 删除scr文件
    printf("Export PCB PDF finished!\n")
)
   
)