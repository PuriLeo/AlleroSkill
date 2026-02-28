/*
 * @Description: 
 * @Version: 1.0
 * @Author: leo@purichip.com
 * @Date: 2026-02-24 12:12:17
 * @LastEditors: leo@purichip.com
 * @LastEditTime: 2026-02-26 01:15:45
 */
/*
我的PCB封装库文件分类如下
1.  Connect   ;连接器封装
2.  Discrete  ;分离元器件封装
3.  IC        ;集成电路封装
4.  Mechanical ;机械零件封装
5.  Format     ;format lib 
6.  Pad    ;焊盘封装

*/
axlCmdRegister("ClearMyLib", 'ClearMyLib ?cmdType "general")

/*
 --AllegroLib
    |--Connect
    |--Discrete  
    |--IC
    |--Mechanical
    |--Format
    |--Pad

*/
AllergoLibPath = "D:/WorkSync/MySync/EDALib2/AllergoLib/"     ; allergo库的目录路径
OrcadLibPath = "D:/WorkSync/MySync/EDALib2/OrcadLib/"         ; Orcad库的目录路径
FootPrintLibDir = '("Connect" "Discrete" "IC" "Mechanical" "Format" "Pad") ;allergo lib
AllergoExtName =  '("dra" "psm" "ssm" "osm" "pad" "bsm") ;allergo file extension name


/*清理我的库文件，删除AllergoLib目录下的所有非关键文件和空目录，以及OrcadLib目录下的所有OBK文件
  1. 遍历AllergoLib目录下的所有子目录，删除其中的非关键文件和空目录
  2. 遍历OrcadLib目录下的所有文件，删除其中的OBK文件
  3. 输出删除的文件和目录数量
*/
defun( ClearMyLib ()

    printf("=============================================start clear my lib================================================================\n")
    prog((ret i files dirs file_path dirs files_deleted dirs_deleted str orcad_deleted_files ) 
        files_deleted = 0
        dirs_deleted = 0

        /*clear AllergoLib*/
        for( i 0 (length FootPrintLibDir)-1             

             files = getDirFiles( strcat(AllergoLibPath ,nth(i,FootPrintLibDir) ) )
             foreach( file files

                file_path = strcat(AllergoLibPath ,nth(i,FootPrintLibDir), "/" , file ) ;get the full path of the file

                if(isFile(file_path)  ; is file?
                then
                    when( isKeyFile(file)  == nil
   
                      ret = deleteFile(file_path) 
                      if(ret == nil 
                      then 
                          printf("Failed to delete file: %s\n" file_path)
                      else
                          printf("Deleted file: %s\n" file_path)
                          files_deleted++ 
                      )
                    )
                else 
                    if(isDir(file_path) &&  file != "." && file != ".."   ; is directory?
                    then
                    printf("Deleting directory: %s\n" file_path)
                    ret = axlRecursiveDelete(file_path)  ; 删除文件夹
                     when( ret 
                        dirs_deleted = dirs_deleted + 1
                      )
                    ); end if isDir(file_path

                ); end if isFile(file_path
                 
             ); end foreach
             
          ); end for

      /*clear OrcadLib*/
        files = getDirFiles( OrcadLibPath )
        orcad_deleted_files = 0
        foreach( file files
              str = nth(1 parseString(file "."))
              if(str == "OBK"
              then
                 file_path = strcat(OrcadLibPath ,"/",file ) ;get the full path of the file
                 ret = deleteFile(file_path) 
                 if(ret then orcad_deleted_files++ )      
 
              )
                  
        ); end foreach

      printf("Deleted %d files and %d directories in AllergoLib\n" files_deleted dirs_deleted)
      printf("Deleted %d ODK files in OrcadLib\n" orcad_deleted_files)
      printf("ClearMyLib finished!\n")
    
    )



); end defun



/*判断文件是否是关键文件，关键文件包括dra、psm、ssm、osm、pad、bsm等后缀的文件
  fileName: 文件名
  return: 如果是关键文件返回t，否则返回nil
*/

defun( isKeyFile ( fileName )

  prog(( ret  str )
  
    ret = nil 
    str =nth(1 parseString(fileName "."))
    str = lowerCase(str)
  
    ;if( str == nil then return nil   )
    
    if( member(str AllergoExtName) != nil
    then 
       
       ret = t 
   )
    return(ret)
    
  )
)