/*
 * @Description: 
 * @Version: 1.0
 * @Author: leo@purichip.com
 * @Date: 2026-02-16 19:22:18
 * @LastEditors: leo@purichip.com
 * @LastEditTime: 2026-02-24 12:51:21
 */

axlCmdRegister("Import_2LRule", 'Import_2LRule ?cmdType "general" ) ; import 2l rule 


/*可以修改此路径*/
My2LNoRefDesRuleFile = "D:\\WorkSync\\MySync\\EDALib2\\AllergoRule\\L2_NoRef.prm" ; 双面板规则文件路径，不包含ref des
My2LWithRefDesRuleFile = "D:\\WorkSync\\MySync\\EDALib2\\AllergoRule\\L2.prm" ; 双面板规则文件路径，包含ref des

/*导入双面板的初始化文件，可以选择是否包含ref des*/

 defun( Import_2LRule ( is_exsist_ref_des)

  if(evalstring(is_exsist_ref_des ) == 1 then    ; 判断是否存在ref des
     ref_des_flag = t
  else
     ref_des_flag = nil
  )

  /*import 2L rule ,can modify the file path*/
  p = outfile("import_2l_rule.scr\n")  ; 生成scr文件
  fprintf(p, "setwindow pcb\n")  ; 设置窗口为pcb
  fprintf(p, "param in\n")  ; 写入param in命令
  fprintf(p, "setwindow form.parm_in\n")
  fprintf(p, "FORM parm_in browse\n")  ; 打开浏览文件对话框
  if(ref_des_flag!=nil then
     fprintf(p, "fillin \"%s\"\n", My2LWithRefDesRuleFile)  ; 填入文件路径
  else
     fprintf(p, "fillin \"%s\"\n", My2LNoRefDesRuleFile)  ; 填入文件路径
  )
 
  fprintf(p, "FORM parm_in execute\n")  ; 执行param in命令，导入规则文件
  fprintf(p, "setwindow form.parm_in\n")
  fprintf(p, "FORM parm_in cancel\n")  ; 关闭param in form
  fprintf(p, "setwindow pcb\n")  ; 设置窗口回pcb

 /* set board size*/
  fprintf(p, "prmed\n")  ; 打开prmed form
  fprintf(p, "setwindow form.prmedit\n")  ; 设置窗口为prmedit
  fprintf(p, "FORM prmedit design\n")  ; 设置窗口为prmedit
  fprintf(p, "FORM prmedit units Millimeter\n") ; 设置单位为毫米
  fprintf(p, "FORM prmedit width 1000.0000\n")  ; 设置板宽为1000mm
  fprintf(p, "FORM prmedit height 1000.0000\n")
  fprintf(p, "FORM prmedit x -100.0000\n")  ; 设置原点x坐标为-100mm
  fprintf(p, "FORM prmedit y -100.0000\n")  ; 设置原点y坐标为-100mm
  fprintf(p, "FORM prmedit done\n")  ; 关闭prmedit form
  
  /*display orign*/
  fprintf(p, "setwindow pcb\n")  ; 设置窗口为pcb
  fprintf(p, "prmed\n")  ; 打开prmed form
  fprintf(p, "setwindow form.prmedit\n")  ; 设置窗口为prmedit
  fprintf(p, "FORM prmedit display\n") 
  fprintf(p, "FORM prmedit display_org YES\n")  ; 显示原点
  
  ;fprintf(p, "FORM prmedit display apply\n")  ; 应用设置
  fprintf(p, "FORM prmedit done\n")  ; 关闭prmedit form 
  fprintf(p, "setwindow pcb\n")  ; 设置窗口回pcb



  close(p)  ; 关闭scr文件

  axlShell("replay import_2l_rule.scr")  ; 执行scr文件
  deleteFile("import_2l_rule.scr")  ; 删除scr文件

 )