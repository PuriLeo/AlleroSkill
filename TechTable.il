

axlCmdRegister("tech1" 'create_techtable ?cmdType "general")  ; create tech table function


soldcolor_list = '(("GREEN" 0) ("BLUE" 1) ("YELLOW" 2) ("BLACK" 3) ("OTHER" 4) ) ; list of solder mask colors and their corresponding pos index
silkcolor_list = '(("WHITE" 0) ("RED" 1) ("YELLOW" 2) ("BLACK" 3)  ("OTHER" 4)) ; list of silkscreen colors and their corresponding pos index
surface_finish_list = '(("HASL(Sn/Pb)" 0) ("HASL(Pb-Free)" 1) ("IMMERSION GOLD" 2) ("ENIG" 3) ("OSP" 4) ("OTHER" 5)) ; list of surface finish and their corresponding pos index
board_material_list = '(("FR-4" 0) ("FR-4 TG150" 1) ("FR-4 TG170" 2) ("ROGERS 4003" 3) ("ROGERS 4350B" 4) ("OTHER" 5)) ; list of board material and their corresponding pos index
via_technic_list = '(("ALL VIA FILLED" 0) ("BY GERBER" 1)  ("OTHER" 2)) ; list of via technic and their corresponding pos index
inspection_list = '(("IPC-II" 0) ("IPC-III" 1) ("GJB" 2) ("GB-4588" 3) ("OTHER" 4)) ; list of inspection and their corresponding pos index

surface_finish_options_pos ='((2600.0000 2500.0000) (4600.0000 2500.0000) (7000.0000 2500.0000) (2600.0000 2300.0000) (4600.0000 2300.0000) (7000.0000 2300.0000))
board_material_options_pos ='((2600.0000 2100.0000) (4600.0000 2100.0000) (7000.0000 2100.0000) (2600.0000 1900.0000) (4600.0000 1900.0000) (7000.0000 1900.0000))
via_tech_options_pos ='((2600.0000 1700.0000) (4600.0000 1700.0000) (7000.0000 1700.0000))
qc_standard_options_pos ='((2600.0000 1500.0000) (3600.0000 1500.0000) (4600.0000 1500.0000) (5800.0000 1500.0000) (7000.0000 1500.0000))
month_list = '(("Jan" "01") ("Feb" "02") ("Mar" "03") ("Apr" "04") ("May" "05") ("Jun" "06") ("Jul" "07") ("Aug" "08") ("Sep" "09") ("Oct" "10") ("Nov" "11") ("Dec" "12")) ; list of month 


frmBoardThickness = nil ; global variable to store the board thickness field in the form, initialized as nil
frmSolderColor = nil ; global variable to store the solder color field in the form, initialized as nil
frmSilkColor = nil ; global variable to store the silkscreen color field in the form, initialized as nil
frmSurfaceFinish = nil ; global variable to store the surface finish field in the form, initialized as nil
frmBoardMaterial = nil ; global variable to store the board material field in the form, initialized as nil
frmViaTechnic = nil ; global variable to store the via technic field in the form, initialized as nil
frmQCStandard = nil ; global variable to store the QC standard field in the form, initialized as nil
frmDesigner = nil ; global variable to store the designer field in the form, initialized as nil
frmEmail = nil ; global variable to store the email field in the form, initialized as nil



/*TECHTABLE窗体的回调函数，参数为窗体对象，根据不同的curField执行不同的操作
form : TECHTABLE窗体对象
*/
defun( _formAction (form)

  let( (pfile str curCursonDbid_pos techtable_dbid,param_txt_path)

    case( form->curField
      
      ( "quit_techtable"
        axlFormClose(form)
    
      )
      ("place_techtable"

        techtable_dbid = AddTechTableToPCB()
        if(techtable_dbid != nil
        then 
            curCursonDbid_pos = get_option_cursor_coord_bid(techtable_dbid) ; get the dbid and coordinate of the option cursor in the tech table
            if(curCursonDbid_pos != nil
            then 
                move_cursor(form, techtable_dbid, curCursonDbid_pos) ; move the cursor to the selected options in the form
                fillText(form, techtable_dbid) ; fill the text fields in the tech table with the information from the form
                axlClearSelSet(techtable_dbid) ; clear selection set
                axlDehighlightObject(techtable_dbid) ; dehighlight the TECHTABLE symbol
                

                /*保存设计师名字和邮箱到文件中，以便下次打开TECHTABLE窗体时可以读取并显示在form field中*/
                param_txt_path = strcat( GetMySkillPath(), "/skillparam.txt") ; construct the file path for skillparam.txt
                pfile = outfile(param_txt_path) ; open a file to save the designer name and email
                when(pfile != nil
                    str = axlFormGetField(form "current_designer") ; get the current designer from the form field
                    when(str ==nil
                        str ="" ; if the designer field is empty, write an empty string to the file
                    )
                    fprintf(pfile "%s\n" str) ; write the designer name to the file
                    str = axlFormGetField(form "current_email") ; get the current email from the form field
                    when(str ==nil
                        str ="" ; if the email field is empty, write an empty string to the file
                    )
                    fprintf(pfile "%s\n" str) ; write the email to the file
                    close(pfile) ; close the file after writing
                )

                axlFormClose(form) ; close the form after placing the tech table and filling the information

            else
                printf("Failed to get option cursor dbid and coordinate\n") ;
            );end if
            
        )
 
      )

    );end case 

  ); end let 
); end defun


/* @Description:得到最大的bbox面积的对象，最大的一定为板框 
   @obj: 板子所有的outline对象的列表
*/
defun( GetMaxBoxByArea ( obj)

     prog( (ret i bbox maxBox area idx)
        
        maxBox = 0 
        idx = 0 
        for(i 0 length(obj)-1
        
            bbox = nth(i, obj)->bBox

            area = abs( xCoord(nth(1, bbox)) - xCoord(car(bbox)) )* abs( yCoord(nth(1, bbox)) - yCoord(car(bbox)) )

            if(area >=maxBox
            then 
                maxBox = area
                idx = i
            )
        )   ;end for 

       return( nth(idx, obj) ) ; return the object with the biggest bounding box area
     );end prog
); end defun   



/*初始化TECHTABLE窗体中的field，参数为窗体对象*/
defun( FormFieldDefultInit (form)

     prog( ( layer_num obj bbox saveVis current_unit size_w size_h current_date tmplist str pfile  param_txt_path) 
     
          axlFormSetField(form "board_name" axlCurrentDesign())   ;得到板子的名字从当前设计
          layer_num = axlGetParam("paramLayerGroup:ETCH")->nChildren ; 得到板子的层数
          axlFormSetField(form "layer_num" layer_num) ;设置板子的层数

          /*得到板子的大小，根据outline的bbox来得到板子的长宽*/
          saveVis = axlVisibleGet() ; save the current visibility state of the design
          axlVisibleDesign(nil)
          
          axlVisibleLayer( "BOARD GEOMETRY/OUTLINE", t)
          axlVisibleUpdate(t)

          axlSetFindFilter(?enabled '("noall" "SHAPES" "LINES") ?onButtons '("SHAPES" "LINES"))
          axlAddSelectAll()
          obj = axlGetSelSet()  
          bbox = GetMaxBoxByArea(obj)->bBox  
          axlVisibleSet(saveVis)
          axlVisibleUpdate(t) ;store

          if(bbox == nil
          then 
              printf("Failed to get the bounding box of the board outline\n") ;
              return(nil)
          );end if
         ; printf("bbox len %d\n" length(obj)) ; print the number of objects in the selection set to the console

          size_w  = abs( xCoord(nth(1, bbox)) - xCoord(car(bbox)) ) ; calculate the width of the board
          size_h  = abs( yCoord(nth(1, bbox)) - yCoord(car(bbox)) ) ; calculate the height of the board

          
          ;printf("Board size: %f mm x %f mm\n" size_w size_h) ; print the board size to the console

          current_unit =car( axlDBGetDesignUnits()) ; get the current unit of the design
          ;printf("Current design unit: %s\n" current_unit) ; print the current design unit to the console
          when(current_unit != "millimeters"    ;我们认为两种设计单位mil 和mm， 如果不是mm则转换为mm
               
              size_w = axlMKSConvert( size_w current_unit "millimeters") ; convert the width to millimeters 
              size_h = axlMKSConvert( size_h current_unit "millimeters") ; convert the height to millimeters
          )
          axlFormSetField(form "board_size_w" size_w) ;set board width field in the form
          axlFormSetField(form "board_size_h" size_h) ;set board height field in the form

          
          
          /*设置板子的厚度*/
          axlFormSetField(form "board_thickness" "1.6") ;set board thickness field in the form
         
          /*设置solder 颜色*/
          axlFormSetField(form "sold_color_enum" "GREEN") ;set default solder mask color in the form
          /*设置silkscreen颜色*/
          axlFormSetField(form "silk_color_enum" "WHITE") ;set default silkscreen color in the form
          /*设置surface finish*/
          axlFormSetField(form "surface_enum" "HASL(Pb-Free)") ;set default surface finish in the form
          /*设置board material*/
          axlFormSetField(form "material_enum" "FR-4") ;set default board material in the form
          /*设置via technic*/
          axlFormSetField(form "via_tech_enum" "BY GERBER") ;set default via technic in the form
          /*设置QC standard*/
          axlFormSetField(form "inspection_enum" "IPC-II") ;set default
          /*设置 date 用中国格式*/
          current_date = axlVersionIdGet() ;axlDBGetDesign()->prop->VERSION_ID ; get the current date from the design property
          current_date = axlVersionIdPrint(current_date)
          axlFormSetField(form "current_date" current_date)
          ;printf("Form initialized with current date: %s\n" current_date) ; print the current date to the console
          tmplist = parseString(current_date)
          str = nth(1, tmplist)
          str = nth(1, assoc(str month_list))
          axlFormSetField(form "current_date" strcat(nth(4, tmplist),"-", str,"-", nth(2, tmplist)))

          /*从文件中读取设计师名字和邮箱，并设置到form field中*/
          str = ""; initialize an empty string to store the content read from the file
          param_txt_path = strcat( GetMySkillPath(), "/skillparam.txt") ; construct the file path for skillparam.txt
          pfile = infile(param_txt_path)
                 
          when(pfile != nil
          
            gets(str,pfile) 
            if(str !=nil 
            then
                axlFormSetField(form "current_designer" str) ; set the content read from the file to the form field
            )
                  
            gets(str,pfile)
            if(str !=nil
            then
                axlFormSetField(form "current_email" str) ; set the content read from the file to the form field
            )
            close(pfile)

          );end when
 
     ); end let

); end defun

/*在PCB上添加TECHTABLE，返回TECHTABLE的DBID，如果添加失败则返回nil*/
defun( AddTechTableToPCB ()

     prog((ret symbol_info_list  techtable_at_pcb place_point)

         

          /*如果存在TECHTABLE SYMBOL，则Delete it */
          axlClearSelSet() ; clear selection set
          axlSetFindFilter(?enabled '( "SYMBOLS" "TEXT" "LINES") ?onButtons '("SYMBOLS")) ; 选择SYMBOLS对象作为过滤器
          techtable_at_pcb = axlSelectByName("SYMTYPE" "TECHTABLE") ; 得到TECHTABLE SYMBOL的对象信息列表
          when(techtable_at_pcb !=nil
               axlDeleteObject(car(techtable_at_pcb)) ; delete the existing TECHTABLE symbol
               axlClearSelSet() ; clear selection set after deletion
               axlVisibleUpdate(t) ; update the visibility after deletion
               
               printf("Existing TECHTABLE symbol deleted\n") ;
          )

          symbol_info_list = axlLoadSymbol("FORMAT", "TECHTABLE")
     
          if( symbol_info_list ==nil   ;加载TECHTABLE SYMBOL到数据库中，如果加载失败则返回nil
          then   
               printf("Failed to load TECHTABLE symbol\n") ;
               return(nil)
          else
               printf("TECHTABLE symbol loaded successfully\n") ;
          
          );end if

          /*place TECHTABLE symbol on pcb at user specified location*/
          axlClearDynamics() ; clear any existing dynamics
          axlDynamicsObject(symbol_info_list,symbol_info_list->xy) 
          axlFlushDisplay() ; flush the display to show the dynamic symbol 
         
          /*25.1.10可以显示动态预览 但是25.1.20就不行了 目前没有找到原因*/
          place_point = axlEnterPoint(?prompts list("Enter selected point") ?gridSnap t) ; prompt the user to enter a point for symbol placement
                    
          axlDBCreateSymbol(list("TECHTABLE" "format"),place_point) ; 
          axlVisibleUpdate(t)
          axlFinishEnterFun() ; finish the dynamic placement of the symbol
          axlShell("Done");

          /*选择放置好的TECHTABLE SYMBOL，返回 DBID*/
          axlClearSelSet() ; clear selection set
          axlSetFindFilter(?enabled '( "SYMBOLS" "TEXT" "LINES") ?onButtons '("SYMBOLS")) ; 选择SYMBOLS对象作为过滤器
          techtable_at_pcb = axlSelectByName("SYMTYPE" "TECHTABLE") ; 得到TECHTABLE SYMBOL的对象信息列表
          if(techtable_at_pcb !=nil
          then 
             return(car(techtable_at_pcb))
          else
        
             return(nil)
          );end if
          

     ); end prog

); end defun

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


/*创建TECHTABLE窗体，并显示出来*/
defun( create_techtable ()
    
      /* 创建窗体*/
   
      prog( (form_path) 


          form_path = GetMySkillPath()
          when(form_path == nil
              printf("Failed to get ChrisSkill path\n") ;
              return(nil)
          )
                    
          form = axlFormCreate( (gensym) strcat(form_path,"/techtableform.form") '(se outer) '_formAction t )
          if(form == nil
          then 
          printf("Failed to create TECHTABLE form\n") ;
               
          else
               printf("TECHTABLE form created successfully\n") ;
          /*显示窗体*/
               axlFormDisplay( form)
               /*初始化窗体field */
               FormFieldDefultInit(form)
          );end if
     )
); end defun




 /*得到TECHTABLE中option cursor的DBID和坐标，参数为TECHTABLE的DBID，返回一个列表，包含option cursor的DBID和坐标
  techtable_dbid : TECHTABLE的DBID
  return: (dbid x,y)
 */
defun(get_option_cursor_coord_bid ( aList)
    prog( (ret  num    blist clist objType nSeg, cnt option_cursor_coord_list )
        
         when(aList->name != "TECHTABLE"    ; check if the symbol is TECHTABLE again  
              printf("Selected symbol is not TECHTABLE %s\n" aList->name) ;
              return(nil)
         )
         
         blist = aList->children ; get the children of the symbol
         num = length(blist) ; get the number of  list
         printf("Number of children: %d\n" num) ; print the number of children to the console
         
         option_cursor_coord_list =(); initialize an empty list to store the coordinates of the option key
         ldbid =(); initialize an empty list to store the ldbid of the option key
         coord_bdid_list =(); initialize an empty list to store the bdid of the option key
         for(i 0 num-1
         
            objType = nth(i, blist)->objType ; get the object type of the child

           ; printf("Object type: %s\n" objType) ; print the object type to the console
            when(objType == "path"
            
                
                nSeg = nth(i, blist)->nSegs ; get the number of segments of the path
                when( nSeg ==2 ; cir need at least 2 segments
                
                   ; printf("Number of segments: %d\n" nSeg) ; print the number of segments to the console
                    clist = car(nth(i, blist)->segments) ; get the segments of the path
                    
                    when(clist->objType == "arc" ; check if the segment is an arc
                        
                          when(clist->radius == 60.0 && clist->width == 60.0  ; check if the radius of the arc is 60
                        
              
                            option_cursor_coord_list =  append1(option_cursor_coord_list, cons(nth(i, blist) clist->xy)) ;  arc last dbid and coordinate to the list
                           
                          );end when radius
                                       
                    );end when arc
                );end when nseg
           );end when objtype
                
         );end for

          ;printf("Number of circles with radius 60 and width 60: %d\n" length(option_cursor_coord_list)  ) ; print the count to the console
          return(option_cursor_coord_list) ; return the list of coordinates of the option cursor
    ) ;end prog
);end defun



/*移动光标到TECHTABLE中对应选项的位置，参数为TECHTABLE的DBID，option cursor的DBID和坐标，以及选项内容
techtable_dbid : TECHTABLE的DBID
cursor_dbid_xy : option cursor的DBID和坐标，是一个列表，包含option cursor的DBID和坐标
selected_color : 选项内容，例如solder color的选项内容可能是"GREEN"，"BLUE"等
*/
defun( soldcolor_move_cursor (techtable_dbid,cursor_dbid_xy, selected_color)
     prog((ret  cursor_dbid  cursor_coord color_index, tmplist selected_color_x selected_color_y techtable_pos)
     
          techtable_pos = techtable_dbid->xy ; get the coordinate of the tech table symbol, which is the base point for moving the cursor
          cursor_dbid = car(cursor_dbid_xy) ; get the dbid of the cursor
          cursor_coord = cdr(cursor_dbid_xy) ; get the coordinate of the cursor
          ;printf("Current cursor coordinate: %f %f\n" xCoord(cursor_coord) yCoord(cursor_coord)) ; print the current coordinate of the cursor to the console

          color_index  =car( cdr( assoc(selected_color, soldcolor_list) ) ) ; get the index of the selected color from the soldcolor_list

          selected_color_x = car(techtable_pos) +2200.00+ color_index*1200.00 ; calculate the x coordinate of the selected color based on the index 
          selected_color_y = yCoord(cursor_coord) ; the y coordinate of the selected color is the same as the current cursor y coordinate
          tmplist = list(selected_color_x selected_color_y) ; create a temporary list to store the new coordinate of the cursor

          axlTransformObject(cursor_dbid, ?move axlMXYSub( tmplist,cursor_coord)) ; move the cursor to the new coordinate

     ) ;end prog



);end defun

/*移动光标到TECHTABLE中对应选项的位置，参数为TECHTABLE的DBID，option cursor的DBID和坐标，以及选项内容
techtable_dbid : TECHTABLE的DBID
cursor_dbid_xy : option cursor的DBID和坐标，是一个列表，包含option cursor的DBID和坐标
selected_color : 选项内容，例如silkscreen color的选项内容可能是"WHITE"，"RED"等
*/
defun( silkcolor_move_cursor (techtable_dbid,cursor_dbid_xy, selected_color)
     prog((ret  cursor_dbid  cursor_coord color_index, tmplist selected_color_x selected_color_y techtable_pos)
     
          techtable_pos = techtable_dbid->xy ; get the coordinate of the tech table symbol, which is the base point for moving the cursor
          cursor_dbid = car(cursor_dbid_xy) ; get the dbid of the cursor
          cursor_coord = cdr(cursor_dbid_xy) ; get the coordinate of the cursor
          ;printf("Current cursor coordinate: %f %f\n" xCoord(cursor_coord) yCoord(cursor_coord)) ; print the current coordinate of the cursor to the console

          color_index  =car( cdr( assoc(selected_color, silkcolor_list) ) ) ; get the index of the selected color from the silkcolor_list

          selected_color_x = car(techtable_pos) +2200.00+ color_index*1200.00 ; calculate the x coordinate of the selected color based on the index 
          selected_color_y = yCoord(cursor_coord) ; the y coordinate of the silkscreen color is the same as the current cursor y coordinate
          tmplist = list(selected_color_x selected_color_y) ; create a temporary list to store the new coordinate of the cursor

          axlTransformObject(cursor_dbid, ?move axlMXYSub( tmplist,cursor_coord)) ; move the cursor to the new coordinate

     ) ;end prog

);end defun

/*移动光标到TECHTABLE中对应选项的位置，参数为TECHTABLE的DBID，option cursor的DBID和坐标，以及选项内容
techtable_dbid : TECHTABLE的DBID
cursor_dbid_xy : option cursor的DBID和坐标，是一个列表，包含option cursor的DBID和坐标
selected_surface : 选项内容，例如surface finish的选项内容可能是"HASL(Sn/Pb)"，"ENIG"等
*/
defun(surface_move_cursor (techtable_dbid,cursor_dbid_xy, selected_surface)
     prog((ret  cursor_dbid  cursor_coord surface_index, tmplist selected_surface_x selected_surface_y techtable_pos)
     
          techtable_pos = techtable_dbid->xy ; get the coordinate of the tech table symbol, which is the base point for moving the cursor
          cursor_dbid = car(cursor_dbid_xy) ; get the dbid of the cursor
          cursor_coord = cdr(cursor_dbid_xy) ; get the coordinate of the cursor
          ;printf("Current cursor coordinate: %f %f\n" xCoord(cursor_coord) yCoord(cursor_coord)) ; print the current coordinate of the cursor to the console

          surface_index  =car( cdr( assoc(selected_surface, surface_finish_list) ) ) ; get the index of the selected surface finish from the surface_finish_list

          selected_surface_x =   xCoord(nth(surface_index, surface_finish_options_pos))+xCoord(techtable_pos)  ; find in table
          selected_surface_y =   yCoord(nth(surface_index, surface_finish_options_pos))+yCoord(techtable_pos)  ; find in table  
          
          tmplist = list(selected_surface_x selected_surface_y) ; create a temporary list to store the new coordinate of the cursor

          axlTransformObject(cursor_dbid, ?move axlMXYSub( tmplist,cursor_coord)) ; move the cursor to the new coordinate

     ) ;end prog

);end defun

/*移动光标到TECHTABLE中对应选项的位置，参数为TECHTABLE的DBID，option cursor的DBID和坐标，以及选项内容
techtable_dbid : TECHTABLE的DBID
cursor_dbid_xy : option cursor的DBID和坐标，是一个列表，包含option cursor的DBID和坐标
selected_material : 选项内容，例如board material的选项内容可能是"FR-4"，"ROGERS 4003"等
*/
defun(board_material_move_cursor (techtable_dbid,cursor_dbid_xy, selected_material)
     prog((ret  cursor_dbid  cursor_coord material_index, tmplist selected_material_x selected_material_y techtable_pos)
     
          techtable_pos = techtable_dbid->xy ; get the coordinate of the tech table symbol, which is the base point for moving the cursor
          cursor_dbid = car(cursor_dbid_xy) ; get the dbid of the cursor
          cursor_coord = cdr(cursor_dbid_xy) ; get the coordinate of the cursor
          ;printf("Current cursor coordinate: %f %f\n" xCoord(cursor_coord) yCoord(cursor_coord)) ; print the current coordinate of the cursor to the console

          material_index  =car( cdr( assoc(selected_material, board_material_list) ) ) ; get the index of the selected board material from the board_material_list

          selected_material_x =   xCoord(nth(material_index, board_material_options_pos))+xCoord(techtable_pos)  ; find in table
          selected_material_y =   yCoord(nth(material_index, board_material_options_pos))+yCoord(techtable_pos)  ; find in table  
          
          tmplist = list(selected_material_x selected_material_y) ; create a temporary list to store the new coordinate of the cursor

          axlTransformObject(cursor_dbid, ?move axlMXYSub( tmplist,cursor_coord)) ; move the cursor to the new coordinate

     ) ;end prog

);end defun

/*移动光标到TECHTABLE中对应选项的位置，参数为TECHTABLE的DBID，option cursor的DBID和坐标，以及选项内容
techtable_dbid : TECHTABLE的DBID
cursor_dbid_xy : option cursor的DBID和坐标，是一个列表，包含option cursor的DBID和坐标
selected_technic : 选项内容，例如via technic的选项内容可能是"ALL VIA FILLED"，"BY GERBER"等
*/
defun(via_technic_move_cursor (techtable_dbid,cursor_dbid_xy, selected_technic)
     prog((ret  cursor_dbid  cursor_coord technic_index, tmplist selected_technic_x selected_technic_y techtable_pos)
     
          techtable_pos = techtable_dbid->xy ; get the coordinate of the tech table symbol, which is the base point for moving the cursor
          cursor_dbid = car(cursor_dbid_xy) ; get the dbid of the cursor
          cursor_coord = cdr(cursor_dbid_xy) ; get the coordinate of the cursor
          ;printf("Current cursor coordinate: %f %f\n" xCoord(cursor_coord) yCoord(cursor_coord)) ; print the current coordinate of the cursor to the console

          technic_index  =car( cdr( assoc(selected_technic, via_technic_list) ) ) ; get the index of the selected via technic from the via_technic_list

          selected_technic_x =   xCoord(nth(technic_index, via_tech_options_pos))+xCoord(techtable_pos)  ; find in table
          selected_technic_y =   yCoord(nth(technic_index, via_tech_options_pos))+yCoord(techtable_pos)  ; find in table  
          
          tmplist = list(selected_technic_x selected_technic_y) ; create a temporary list to store the new coordinate of the cursor

          axlTransformObject(cursor_dbid, ?move axlMXYSub( tmplist,cursor_coord)) ; move the cursor to the new coordinate

     ) ;end prog

);end defun

/*移动光标到TECHTABLE中对应选项的位置，参数为TECHTABLE的DBID，option cursor的DBID和坐标，以及选项内容
techtable_dbid : TECHTABLE的DBID
cursor_dbid_xy : option cursor的DBID和坐标，是一个列表，包含option cursor的DBID和坐标
selected_standard : 选项内容，例如QC standard的选项内容可能是"IPC-II"，"IPC-III"等
*/
defun(qc_standard_move_cursor (techtable_dbid,cursor_dbid_xy, selected_standard)
     prog((ret  cursor_dbid  cursor_coord standard_index, tmplist selected_standard_x selected_standard_y techtable_pos)
     
          techtable_pos = techtable_dbid->xy ; get the coordinate of the tech table symbol, which is the base point for moving the cursor
          cursor_dbid = car(cursor_dbid_xy) ; get the dbid of the cursor
          cursor_coord = cdr(cursor_dbid_xy) ; get the coordinate of the cursor
          ;printf("Current cursor coordinate: %f %f\n" xCoord(cursor_coord) yCoord(cursor_coord)) ; print the current coordinate of the cursor to the console

          standard_index  =car( cdr( assoc(selected_standard, inspection_list) ) ) ; get the index of the selected QC standard from the inspection_list

          selected_standard_x =   xCoord(nth(standard_index, qc_standard_options_pos))+xCoord(techtable_pos)  ; find in table
          selected_standard_y =   yCoord(nth(standard_index, qc_standard_options_pos))+yCoord(techtable_pos)  ; find in table  
          
          tmplist = list(selected_standard_x selected_standard_y) ; create a temporary list to store the new coordinate of the cursor

          axlTransformObject(cursor_dbid, ?move axlMXYSub( tmplist,cursor_coord)) ; move the cursor to the new coordinate

     ) ;end prog

);end defun

/*移动光标到TECHTABLE中对应选项的位置，参数为窗体，TECHTABLE的DBID，option cursor的DBID和坐标
form  : 窗体
curTechTableDbid : TECHTABLE的DBID
curCursorDbid_Xy : option cursor的DBID和坐标，是一个列表，包含6个元素，分别对应solder color, silkscreen color, surface finish, board material, via technic, QC standard，每个元素是一个列表，包含option cursor的DBID和坐标
*/
defun( move_cursor (form, curTechTableDbid, curCursorDbid_Xy)

   prog(( ret str )

      str = axlFormGetField(form "sold_color_enum") ; get the selected solder color from the form field
      soldcolor_move_cursor(curTechTableDbid, nth(0, curCursorDbid_Xy), str) ; move the solder color cursor to the selected color position in the tech table
      str = axlFormGetField(form "silk_color_enum") ; get the selected silkscreen color from the form field
      silkcolor_move_cursor(curTechTableDbid, nth(1, curCursorDbid_Xy), str) ; move the silkscreen color cursor to the selected color position in the tech table
      str = axlFormGetField(form "surface_enum") ; get the selected surface finish from the form field
      surface_move_cursor(curTechTableDbid, nth(2, curCursorDbid_Xy), str) ; move the surface finish cursor to the selected surface finish position in the tech table
      str = axlFormGetField(form "material_enum") ; get the selected board material from the form field
      board_material_move_cursor(curTechTableDbid, nth(3, curCursorDbid_Xy), str) ; move the board material cursor to the selected board material position in the tech table
      str = axlFormGetField(form "via_tech_enum") ; get the selected via technic from the form field
      via_technic_move_cursor(curTechTableDbid, nth(4, curCursorDbid_Xy), str) ; move the via technic cursor to the selected via technic position in the tech table
      str = axlFormGetField(form "inspection_enum") ; get the selected QC standard from the form field
      qc_standard_move_cursor(curTechTableDbid, nth(5, curCursorDbid_Xy), str) ; move the QC standard cursor to the selected QC standard position in the tech table

   );end prog

);end defun

/*根据文本内容获取TECHTABLE中对应文本对象的DBID
curTechTableDbid : TECHTABLE的DBID
text_content : 文本内容
*/
defun( get_txt_dbid_by_content (curTechTableDbid, text_content)
     prog((ret txtList txtObj)

          txtList = axlDBGetAttachedText(curTechTableDbid) ; get all the text objects attached to the tech table symbol
          ;printf("Number of text objects attached to the tech table: %d\n" length(txtList)) ; print the number of text objects to the console
          txtObj = nil ; initialize the variable to store the text object with the specified content
          for(k 0 length(txtList)-1
               txtObj = nth(k, txtList) ; get the text object
              ; printf("Text object content: %s\n" txtObj->text) ; print the content of the text object to the console
               if(txtObj->text == text_content ; find the text object with the specified content
               then 
                   ;printf("Found text object with content '%s' and dbid: %s\n" text_content txtObj->text) ; print the dbid of the text object to the console
                   ;txt_dbid = txtObj->dbId ; store the dbid of the found text object in a variable
                   return(txtObj)
               );end if
          );end for

          return(txtObj) ; return the text object with the specified content

     ) ;end prog


)


/*填充TECHTABLE中的文本字段，参数为窗体和TECHTABLE的DBID
form  :  窗体
curTechTableDbid : TECHTABLE的DBID
*/
defun( fillText (form,curTechTableDbid)
  prog((str designer_txt_dbid email_txt_dbid boardname_txt_dbid layernum_txt_dbid boardsize_txt_dbid boardthickness_txt_dbid impedence_control_txt_dbid impedence_report_txt_dbid)
  
      str = axlFormGetField(form "current_date") ; get the current date from the form field
      date_txt_dbid = get_txt_dbid_by_content(curTechTableDbid, "DATE:") ; get the dbid of the text object with content "Date:"
      when(date_txt_dbid != nil
           axlDBChangeText(date_txt_dbid, strcat(date_txt_dbid->text, " ", str)) ; change the text of the date text object to "Date: current date"
      )

      str = axlFormGetField(form "current_designer") ; get the current designer from the form field
      designer_txt_dbid = get_txt_dbid_by_content(curTechTableDbid, "DESIGNER:") ; get the dbid of the text object with content "Designer:"
      when(designer_txt_dbid != nil
           axlDBChangeText(designer_txt_dbid, strcat(designer_txt_dbid->text, " ", str)) ; change the text of the designer text object to "Designer: current designer"
      )

      str = axlFormGetField(form "current_email") ; get the current email from the form field
      email_txt_dbid = get_txt_dbid_by_content(curTechTableDbid, "EMAIL:") ; get the dbid of the text object with content "Email:"
      when(email_txt_dbid != nil
           axlDBChangeText(email_txt_dbid, strcat(email_txt_dbid->text, " ", str)) ; change the text of the email text object to "Email: current email"
      )

      str = axlFormGetField(form "board_name") ; get the board name from the form field
      boardname_txt_dbid = get_txt_dbid_by_content(curTechTableDbid, "BOARD NAME:") ; get the dbid of the text object with content "Board Name:"
      when(boardname_txt_dbid != nil
           axlDBChangeText(boardname_txt_dbid, strcat(boardname_txt_dbid->text, " ", str)) ; change the text of the board name text object to "Board Name: current board name"
      )

      
      str = sprintf(nil "%d" axlFormGetField(form "layer_num")) ; convert the layer number to string
      layernum_txt_dbid = get_txt_dbid_by_content(curTechTableDbid, "BOARD LAYER:") ; get the dbid of the text object with content "Board Layer:"
      when(layernum_txt_dbid != nil
           axlDBChangeText(layernum_txt_dbid, strcat(layernum_txt_dbid->text, " ", str)) ; change the text of the layer number text object to "Board Layer: current layer number"
     )

      str = axlFormGetField(form "board_size_w") ; get the board width from the form field
      str = strcat(str, "X", axlFormGetField(form "board_size_h"), "mm"  ) ; append "X" and the board height to the board width
      boardsize_txt_dbid = get_txt_dbid_by_content(curTechTableDbid, "BOARD SIZE:") ; get the dbid of the text object with content "Board Size:"
      when(boardsize_txt_dbid != nil
            axlDBChangeText(boardsize_txt_dbid, strcat(boardsize_txt_dbid->text, " ", str)) ; change the text of the board size text object to "Board Size: current board size"
      )

      str = axlFormGetField(form "board_thickness") ; get the board thickness from the form field
      boardthickness_txt_dbid = get_txt_dbid_by_content(curTechTableDbid, "BOARD THICKNESS:") ; get the dbid of the text object with content "Board Thickness:"
      when(boardthickness_txt_dbid != nil
           axlDBChangeText(boardthickness_txt_dbid, strcat(boardthickness_txt_dbid->text, " ", str,"mm")) ; change the text of the board thickness text object to "Board Thickness: current board thickness"
      )
       
      str = axlFormGetField(form "impendence_check") ; get the selected solder color from the form field
      if(str == nil
      then 
          str = "NO"
      else
          str = "YES"
      );end if
      impedence_control_txt_dbid = get_txt_dbid_by_content(curTechTableDbid, "CONTROL IMPEDANCE:") ; get the dbid of the text object with content "Impedence Check:"
      when(impedence_control_txt_dbid != nil
           axlDBChangeText(impedence_control_txt_dbid, strcat(impedence_control_txt_dbid->text, " ", str)) ; change the text of the impedence check text object to "Impedence Check: YES/NO"
      )
      impedence_report_txt_dbid = get_txt_dbid_by_content(curTechTableDbid, "IMPEDANCE REPORT:") ; get the dbid of the text object with content "Impedance Report:"
      when(impedence_report_txt_dbid != nil
           axlDBChangeText(impedence_report_txt_dbid, strcat(impedence_report_txt_dbid->text, " ", str)) ; change the text of the impedence report text object to "Impedance Report: YES/NO"
      )

  )

)




