/*
 * @Description: 
 * @Version: 1.0
 * @Author: leo@purichip.com
 * @Date: 2026-02-17 00:19:37
 * @LastEditors: leo@purichip.com
 * @LastEditTime: 2026-02-26 20:39:00
 */

 /*生成所有的目录
 --All
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
  */
axlCmdRegister("exb",  'ExportAllDir ?cmdType "general") ; export all directory of current project to a specific path

/*单独的函数用于更新文件到-All目录下对应的子目录中，方便代码的维护和扩展
    cmd参数用于指定需要更新的文件类型，可以是SCH、PCB、DXF、CAM、ASM、POS或BOM中的一个，根据不同的cmd参数执行不同的文件复制操作
    支持uda clear  ; 仅删除当前设计目录下的文件，除了 .brd .dsn file  -all directory
        uda sch    ; update sch file to -All/Sch/ directory
        uda pcb    ; update pcb file to -All/PCB/ directory
        uda dxf    ; update dxf file to -All/DXF/ directory
        uda cam    ; update cam file to -All/Cam/ directory
        uda asm    ; update asm file to -All/SMT/ASM/ directory
        uda pos    ; update place_txt.txt file to -All/SMT/POS/ directory
        uda bom    ; update bom excel file to -All/SMT/BOM/ directory

*/
axlCmdRegister("uda",  'uda ?cmdType "general") ; user defined attributes



/*获取skill文件存放的路径
  ~/代表的是当前用户的home目录，在注册表中可以找到，用getSkillPath()函数获取
  return: skill文件存放的路径 
*/
defun( GetMySkillPath ()

     prog((ret myPath index )

          myPath = getSkillPath()

          for(i 0 length(myPath)-1
              
              index = nindex( nth(i, myPath),"ChrisSkill") ; find the index of the path that contains "ChrisSkill"

              if( index  != nil  ; find the path that contains "ChrisSkill"
              then
                  return(nth(i, myPath)) ; return the path that contains "ChrisSkill"
              )

          )
          return(nil)

     ); end prog
)

defun( GetMySkillAbsPath ()

    prog((str ret tmplist str1)
    
         str =  getShellEnvVar("HOME") ; return "\"路径

         tmplist = parseString(str "\\")  ; split the path by "\"
        
         str = "" ;  
         for(i 0 length(tmplist)-1   ;change to "/"路径
             
             if( i == length(tmplist)-1  then
                 str = strcat(str,nth(i, tmplist))  
             else
               str = strcat(str,nth(i, tmplist),"/" );
             )
         )
        
        str = strcat(str, index(GetMySkillPath(),"/")) ; add "/" at the end of the path
        return(str)
    
    ); end let

); end defun    




defun( ExportAllDir ()
  prog( (str)             

         if( CreateAllDir() == nil     ;创建目录
            
            return(nil)
         
         ) ; create -All directory and subdirectory
    ;-----------------------------------start copy file to corresponding dir--------------------------------------
         uda("SCH")  ; update sch file to -All/Sch/
         uda("PCB")  ; update pcb file to -All/PCB/
         uda("DXF")  ; update dxf file to -All/DXF/
         uda("CAM")  ; update cam file to -All/Cam/  
         uda("ASM")  ; update asm file to -All/SMT/ASM/
         uda("POS")  ; update place_txt.txt file to -All/SMT/POS/
         uda("BOM")  ; update bom excel file to -All/SMT/BOM/
        ;-------------------------------------------del file,exclude .brd .dsn file  -all directory ----------------------------
        
        
        if( dir_clear() == nil then   
            printf("Clear directory fail\n") ; only warning
        )


        
        str = GetMySkillAbsPath() ; get skill absolute path, which is the path of the directory where the skill file is located
        when(str != nil
            str = strcat(str, "/readme.pdf") ;  get readme file path

            axlOSFileCopy(str, strcat(axlCurrentDesign(), "-All/readme.pdf"), nil)
            
        ); end when str  

        printf("Export all directory successfully.\n")
        
  )
)

/*
    copy 生成的gerber目录下的文件到-All/Cam/目录下
        1. 过滤掉文件名中包含",1"的文件，因为这类文件是allegro在生成gerber文件时自动生成的临时文件，不需要保留
        2. 过滤掉文件名长度小于等于2的文件，因为这类文件不符合正常的命名规则，也不需要保留
        3. 过滤掉ADT.art和ADB.art文件，因为这两个文件是用于SMT/ASM目录的，不需要复制到CAM目录下
    src: gerber目录路径
    dst: -All/Cam/目录路径

*/
defun( CamCopy (src dst )
   prog( (ret files file_len str) 
   
      if(isDir("Gerber") then 
          
          files = getDirFiles("Gerber")  ; 获取Gerber目录下的所有文件
          foreach(file files
             
             ;printf("File name is %s\n" file)

              if( file != "ADT.art" && file != "ADB.art" then  ;过滤掉不需要复制的文件
               
                 file_len = strlen(file)
                 ;printf("File length is %d\n" file_len)
                 when( file_len > 2  ; 过滤掉文件名长度小于等于2的文件)

                    str = substring(file,(file_len-1),2)
                    ;printf("File suffix is %s\n" str)
                    when(str != ",1"   ; 过滤掉文件名中包含",1"的文件

                       ret = axlOSFileCopy(strcat("Gerber/", file), strcat(dst, file), nil)  ;  copy gerber file to -All/Cam/
                       
                    );end when str
                 );end when file_len
                 
              );end if file

          ) ;end foreach 
        
      else
         printf("Gerber dir no found\n") 
         
       ); end if isDir
       
       if(ret == nil then
           printf("Copy cam file fail\n") ; only warning
       ); end when ret
       return( ret ) 
  ); end prog
   
);end defun


/*
    用DOS批处理文件清除当前设计目录下的.jrl和.log文件，这些文件是allegro在运行过程中生成的日志文件，不需要保留
*/
defun(ClearHistory ()

    prog( (p)
    
        /*
        p = axlDMOpenFile("tmp","./tmp.bat","w")
        fprintf(p "del /f /s /q ".\\*.jrl"\n")
        fprintf(p "del /f /s /q ".\\*.log"\n")
        fprintf(p "del /s /q tmp.bat\n")
        axlDMClose(p)

        shell("tmp.bat") 
        */
    )

); end defun


/*
    删除当前设计目录下的文件，除了 .brd .dsn file  -all directory
        1. 过滤掉文件名长度小于等于2的文件，因为这类文件不符合正常的命名规则，也不需要保留
        2. 过滤掉.dsn、.brd文件，因为这两个文件是当前设计的原始文件，不需要删除
       
*/
defun( dir_clear ()

    let( ( project_path ret extName )
        project_path  = axlCurrentDesign() ; get current design path
         
        files_deleted = getDirFiles("./")  ;  获取当前设计目录下的所有文件
        foreach(file files_deleted

            ; ClearHistory() ; jrl and  log不能删除，调用 WIN 的DELETE 

            when(isFile(file) != nil   ; 过滤掉文件夹
            
                 /*; 过滤掉文件名长度小于等于2的文件和.dsn、.brd文件和allegro.jrl文件，allegro.jrl is the log file generated during export process, which is not necessary to be kept, so also delete it*/

                
                extName = parseString(file ".")  ; 获取文件扩展名
                extName = upperCase(nth(1 extName))   ; 转换为大写，方便比较
                when(  extName != "DSN" && 
                       extName != "BRD" && 
                       extName != "DSNLCK" &&
                       file != "allegro.jrl" && 
                       file != "signoise.log" 
                       
                      
                       
                    
                    ret = deleteFile(file)  ; 删除文件
                    ;ret = axlRecursiveDelete(file)  ; 删除文件，使用递归删除函数可以删除只读文件和隐藏文件
                    when(ret == nil
                        printf("Delete file %s fail.\n" file) ; only warning
                    ); end when ret
                ); end when  strlen(file)
            
            ); end when isFile(file)
                   
        ); end foreach

       
        
        files_deleted = getDirFiles("./")  ; 获取当前目录下的所有文件夹
        foreach(file files_deleted
            when(isDir(file) != nil && file != "." && file != ".." && file != strcat(project_path,"-All") ; 过滤掉dir

                    ret = axlRecursiveDelete(file)  ; 删除文件夹
                    when(ret == nil
                        printf("Delete dir %s fail.\n" file) ; only warning
                    );end when ret
                
            ); end when isDir(file)
                   
        ); end foreach
       
        printf("Clear directory finished.\n")

    ); end let 


) ;end defun


/*文件复制函数，将指定的文件复制到目标目录下
    fileName: 需要复制的文件名，必须包含扩展名
    dstDir: 目标目录路径
    返回值：复制成功返回t，复制失败返回nil
*/
defun( FileCopy2Dir (note,fileName,dstDir)

    prog( (str tmplist newFileName)

       if( isFile(fileName) == nil  then
       
            printf("[%s] %s no found\n" note fileName)
            return(nil)
      
       )


       if( index(fileName, "/") != nil then  ; 如果文件名包含路径，则提取文件名部分进行复制

            tmplist  = parseString(fileName "/")  ; 
            str  = nth(length(tmplist)-1, tmplist) ; 仅获取文件名，不带路径
            newFileName = str;
           ; printf("Extracted file name is %s\n" fileName)
        else 
            newFileName = fileName
       )
       
             
      ; printf("Copy file %s to dir %s\n" fileName dstDir) 
      ; printf("New file name is %s\n" newFileName)
       return( axlOSFileCopy(fileName, strcat(dstDir, newFileName), nil) )   ; copy file to dstDir
    ); end prog

); end defun

defun( GetDestPath (cmd,project_name )


    prog( (dstPath AllDirPath)


        AllDirPath = strcat(project_name, "-All/") ; get -All directory path
        case(cmd
            ("SCH" dstPath = strcat(AllDirPath, project_name, "-SCH/") )
            ("PCB" dstPath = strcat(AllDirPath, project_name, "-PCB/") )
            ("DXF" dstPath = strcat(AllDirPath, project_name, "-DXF/") )
            ("CAM" dstPath = strcat(AllDirPath, project_name, "-CAM/") )
            ("ASM" dstPath = strcat(AllDirPath, project_name, "-SMT/ASM/") )
            ("POS" dstPath = strcat(AllDirPath, project_name, "-SMT/POS/") )
            ("BOM" dstPath = strcat(AllDirPath, project_name, "-SMT/BOM/") )
            ("SMD" dstPath = strcat(AllDirPath, project_name, "-SMT/SMD/") )
            ("All" dstPath = AllDirPath )
            (t 
                printf("Unsupported cmd, please input CMD as SCH, PCB, DXF, CAM, ASM, POS, BOM or SMD\n")
                dstPath = nil
            )
        ); end case
       
       ; printf("Destination path is %s\n" dstPath)
        return( dstPath )
    ); end prog

)


defun( CreateAllDir ()

    prog( (project_path AllDirPath )

        project_path = axlCurrentDesign() ; 获取当前设计的路径

        printf("=============================================start export all dir================================================================\n")

        if( isFile(strcat(project_path, ".dsn")) == nil then   ;没有.dsn文件不创建 -All目录
            printf("No dsn file,fail\n ")
            return(nil)
        )
        if(isFile(strcat(project_path, ".brd")) == nil then   ;没有.brd文件不创建 -All目录
            
            printf("No brd file,fail\n ")
            return(nil)   
        )

        if(isDir("Gerber") == nil then   ;没有Gerber目录不创建 -All目录
            printf("No Gerber dir,fail\n ")
            return(nil)   
        )
        
        AllDirPath = strcat(project_path, "-All")   
        if( isDir(AllDirPath) == nil then  ; -All存在不创建，必须用户删除已存在的目录才能重新创建
            createDir(AllDirPath)  ;  -All 
            
            
            AllDirPath = strcat(AllDirPath, "/")  ; 获取当前设计的路径
            printf("Create All Path is %s\n" AllDirPath)
           
        else 
           printf("Directory already exists, please delete it before exporting\n") ;must user delete the existing directory before exporting
           return(nil)
        )

        createDir(strcat(AllDirPath, project_path,"-CAM"))  ; -All/Cam
        createDir(strcat(AllDirPath, project_path,"-DXF"))  ; -All/DXF
        createDir(strcat(AllDirPath, project_path,"-EQ"))   ; -All/EQ
        createDir(strcat(AllDirPath, project_path,"-SCH"))  ; -All/Sch
        createDir(strcat(AllDirPath, project_path,"-PCB"))  ; -All/Pcb
        createDir(strcat(AllDirPath, project_path,"-SMT"))  ; -All/SMT
        createDir(strcat(AllDirPath, project_path,"-SMT/ASM"))  ; -All/SMT/ASM
        createDir(strcat(AllDirPath, project_path,"-SMT/SMD"))  ; -All/SMT/SMD
        createDir(strcat(AllDirPath, project_path,"-SMT/BOM"))  ; -All/SMT/BOM
        createDir(strcat(AllDirPath, project_path,"-SMT/POS"))  ; -All/SMT/POS

         return(t) 

    ); end prog

); end defun



/*
    独立的函数用于更新文件到-All目录下对应的子目录中，方便代码的维护和扩展
    cmd：用于指定需要更新的文件类型，可以是SCH、PCB、DXF、CAM、ASM、POS或BOM中的一个，根据不同的cmd参数执行不同的文件复制操作
*/
defun( uda ( cmd)
    prog( ( ret  current_cmd dst_path project_name  src_path )

        current_cmd = upperCase(cmd)   ; upper cmd 
        project_name = axlCurrentDesign() ; get current design path
         
        case(current_cmd
            ("CLEAR"
                ret = dir_clear()  ; delete file in current directory, exclude .brd .dsn file  -all directory
                when(ret == nil
                    printf("Clear directory fail\n") ; only warning
                ); end when ret
                printf("Clear directory Finished.\n")
                ;shell("del /f /s /q  *.jrl")
                ;shell("del /f /s /q  *.log")
            ) ;end case "CLEAR"
            ("SCH" ; updat sch  to all/sch

               dst_path = GetDestPath("SCH", project_name) ; get destination path
               FileCopy2Dir(current_cmd, strcat(project_name, ".dsn"), dst_path)   
               FileCopy2Dir(current_cmd, strcat(project_name, ".pdf"), dst_path)   
               printf("Update sch finished\n")
                 
            );end sch
            ("BOM"  ;update BOM
               dst_path = GetDestPath("BOM", project_name) ; get destination path
               FileCopy2Dir(current_cmd, strcat(project_name, ".xlsx"), dst_path)
               FileCopy2Dir(current_cmd, strcat(project_name, "-S.xlsx"), dst_path)   
               printf("Update BOM finished\n")  

            ); end case "BOM"
            ("CAM"  ; update cam file to -All/Cam/
               dst_path = GetDestPath("CAM", project_name) ; get destination path
                CamCopy("Gerber", dst_path)
                printf("Update cam finished\n")

            ); end cam
            ("DXF"  ; update dxf file to -All/DXF/
               dst_path = GetDestPath("DXF", project_name) ; get destination path
               FileCopy2Dir(current_cmd, strcat(project_name, ".dxf"), dst_path)
               FileCopy2Dir(current_cmd, strcat(project_name, "_top.dxf"), dst_path)  
               FileCopy2Dir(current_cmd, strcat(project_name, "_bottom.dxf"), dst_path)
               printf("Update dxf finished\n")
             
            ); end dxf 
            ("PCB"  ; update pcb file to -All/PCB/
                dst_path = GetDestPath("PCB", project_name) ; get destination path
                FileCopy2Dir(current_cmd, strcat(project_name, ".brd"), dst_path)  
                FileCopy2Dir(current_cmd, strcat(project_name, "_pcb.pdf"), dst_path)  
                printf("Update pcb finished\n")
            )
            ("POS"
                dst_path = GetDestPath("POS", project_name) ; get destination path
                FileCopy2Dir(current_cmd, "place_txt.txt" , dst_path)   
                printf("Update pos finished\n")
            )
            ("ASM"
                dst_path = GetDestPath("ASM", project_name) ; get destination path
                FileCopy2Dir(current_cmd, "Gerber/ADT.art", dst_path) ; copy adt.art file to -All/SMT/ASM/
                FileCopy2Dir(current_cmd, "Gerber/ADB.art", dst_path) ; copy adb.art file to -All/SMT/ASM/
                FileCopy2Dir(current_cmd, "ADT.pdf", dst_path)  ; copy adt pdf file to -All/SMT/ASM/
                FileCopy2Dir(current_cmd, "ADB.pdf", dst_path)  ; copy adb pdf file to -All/SMT/ASM/
                printf("Update asm finished\n")
                
            ); end ASM
            (t
                
                 printf("Unsupported cmd, please input CMD as CLEAR, SCH, BOM, CAM, DXF, PCB, POS or ASM\n") ; tell user not support 
            )
 
       );end case 
        
    ); end prog
);end defun
 