On Error Resume Next

Dim ConstServerName
ConstServerName = "Ingest Management Server, MOS Gateway Server, MPC Task Console, MPC Task Console-Backup, Background Server, Background Server-Backup, Material List Server, Playout Background Server, Archive Management Server, Ingest Device, MPC Transform, MPC EDL-Executor"

Class Module
  'ģ����
	Private mName
	
	Public Property Get ModuleName()
		ModuleName = mName
	End Property
	
	Public Property Set ModuleName(Value)
		mName = Value
	End Property
	
	Public Property Let ModuleName(Value)
		mName = Value
	End Property
'IP��ַ����	
	Private mIps
	
	Public Property Get IPs()
		IPs = mIps
	End Property
	
	Public Property Set IPs(Value)
		mIps = Value
	End Property
	
	Public Property Let IPs(Value)
		mIps = Value
	End Property

'��־·������	
	Private mLogs
	
	Public Property Get Logs()
		Logs = mLogs
	End Property
	
	Public Property Set Logs(Value)
		mLogs = Value
	End Property
	
	Public Property Let Logs(Value)
		mLogs = Value
	End Property
	
	
	Private Sub Class_Initialize
	End Sub
	
	Private Sub Class_Terminate()
	End Sub
	
	Public Function ToString()
		Dim str
		str = ModuleName & "   " & vbCrlf

		For Each ip in IPs
			str = str & ip & "  " & vbCrlf
		Next
		

		For Each l in Logs
			str = str & l & "  " & vbCrlf
		Next


		
		ToString = str 
		
	End Function

End Class

Class Host
	Private mIP
	
	Public Property Get IP()
		IP = mIP
	End Property
	
	Public Property Set IP(Value)
		mIP = Value
	End Property
	
	Public Property Let IP(Value)
		mIP = Value
	End Property
	
	private mModule
	
	Public Property Get Module()
		Module = mModule
	End Property
	
	Public Property Set Module(Value)
		mModule = Value
	End Property
	
	Public Property Let Module(Value)
		mModule = Value
	End Property

End Class


Class ConfigurationHelp
	Dim dic
	
	 Private Sub Class_Initialize()
		Set dic = CreateObject("Scripting.Dictionary")
	End Sub

	 Private Sub Class_Terminate()
		Set dic = nothing
	 End Sub
	
	Public Function GetServerByModule	
		Dim KeyValues
		KeyValues = vbsGetIniFields("Configuration.ini","KeyValue")
		Dim ar       
		ar = Split(ConstServerName,",")	
		Dim Modules(12)
		Dim findIndex
		findIndex = 0	

		For i=0 To UBound(KeyValues)	
			'WSH.Echo i 
			Dim Key
			Dim Value
			Dim KeyValue
			Dim Ips
			
			KeyValue = Split(KeyValues(i),"=")
			Key = KeyValue(0)	
			Value = KeyValue(1)				
			
			IF InStr(ConstServerName,Key)<>0 Then
				'WSH.Echo Key			
				Dim m
				Set m = new Module
				m.ModuleName = Key			
				m.IPs = Split(Value,";")			
				m.Logs = vbsGetIniFields("LogPath.ini",Cstr(m.ModuleName()))
				
				Set Modules(findIndex) = m	
				findIndex = findIndex + 1
			End IF		
		Next

		GetServerByModule = 	Modules

	End Function	
	
	 Public Property Get GetServerByHost()
		Dim KeyValues
		Dim reStr
		
		dic.RemoveAll()
		
		KeyValues = vbsGetIniFields("Configuration.ini","KeyValue")
			
		For i=0 To UBound(KeyValues)			
			Dim Key
			Dim Value
			Dim KeyValue
			Dim Ips
			
			KeyValue = Split(KeyValues(i),"=")
			Key = KeyValue(0)	
			Value = KeyValue(1)		
			
			IF InStr(ConstServerName,Key)<>0 Then
				Ips = Split(Value,";")		
				For Each ip in Ips
					'WSH.Echo ip
					If dic.Exists(ip) = false Then
						Dim h
						Set h = new Host
						h.IP = ip
						h.Module = Key						

						dic.Add ip, h
						
					Else
						dic.Item(ip).Module = dic.Item(ip).Module & ";" & Key
					End If
				Next
			end if
		next		
		Set GetServerByHost = dic
	End Property
	
End Class

Dim UserName 
UserName = GetValueByKey("Configuration.ini","KeyValue","Windows User Name")

Dim Password
Password = GetValueByKey("Configuration.ini","KeyValue","Windows Password")

Dim SONAPS_DB_SID
SONAPS_DB_SID = GetValueByKey("Configuration.ini","KeyValue","SONAPS DB SID")

Dim SONAPS_DB_User_Name
SONAPS_DB_User_Name =  GetValueByKey("Configuration.ini","KeyValue","SONAPS DB User Name")

Dim SONAPS_DB_Password
SONAPS_DB_Password =  GetValueByKey("Configuration.ini","KeyValue","SONAPS DB Password")

Dim Archive_DB_SID
Archive_DB_SID =  GetValueByKey("Configuration.ini","KeyValue","Archive DB SID")

Dim Archive_DB_User_Name
Archive_DB_User_Name =  GetValueByKey("Configuration.ini","KeyValue","Archive DB User Name")

Dim Archive_DB_Password
Archive_DB_Password =  GetValueByKey("Configuration.ini","KeyValue","Archive DB Password")

Dim rootPath
Dim TimeString
Dim LogPath

Function CreateRootPath()
    TimeString = GetNowTime()
    if Wscript.Arguments.count=1 then
	    rootPath = WScript.Arguments(0)
    else
	    rootPath = createobject("Scripting.FileSystemObject").GetFile(Wscript.ScriptFullName).ParentFolder.Path & "\" & TimeString
    end if

    Dim fso
    Dim check_exist
    Set fso = CreateObject("Scripting.FileSystemObject")
    check_exist = fso.FolderExists(rootPath)
    If check_exist = false Then
	    fso.CreateFolder(rootPath)
	    WSH.Echo "start create folder:"& rootPath
    end If
    CreateRootPath = rootPath
    
    

End Function

Sub WriteLog(msg)
    

    Dim fso
    Dim path
    Dim file
    Dim time    
   
    path = rootPath & "\SystemInformationCollect.txt"  
	'WSH.Echo path
    Set fso =  CreateObject("Scripting.FileSystemObject")
    
    If fso.FileExists(path) Then
        Set file = fso.OpenTextFile(path,8)
    else
        Set file = fso.CreateTextFile(path,false)
    end if 

	time = Now()'GetNowTime() 	
	'time = "-------"
    msg = time & "      " &  msg    
    file.WriteLine msg 
    WSH.Echo msg    
    file.close
    
End Sub

Sub CreateSubFolder(subFolder)
    
    Dim check_exist
    Dim fso
    Set fso = CreateObject("Scripting.FileSystemObject")
    check_exist = fso.FolderExists(subFolder)
    if check_exist = false then
         fso.CreateFolder(subFolder)
         'WSH.Echo "start create folder:" & subFolder
    end if


End Sub

'��ȡini
Function vbsGetIniFields(inipath, initypes)
	'WSH.Echo initypes
    Const ForReading = 1 '���峣��
    'FSO����,�ı�����,��һ�����ݱ���,�ַ�������λ��
    Dim objFSO, objTextFile, strNextLine, intLineFinder
    Dim state 'ָ���Ƿ���ƥ���inittypes���Ƿ��ҵ��ֶ�
    Dim tmp 'ָ���洢�ַ���
    Dim typelist '�ָ��ַ�������ַ���list
    Dim reStr '��������ֵ
    Set objFSO = CreateObject("Scripting.FileSystemObject") '����FSO����
    Set objTextFile = objFSO.OpenTextFile(inipath, ForReading)'���ĵ�
    Do Until objTextFile.AtEndOfStream   '����ÿһ��
         strNextLine = objTextFile.ReadLine '��ȡһ������
        '����Ѿ��ҵ���initypes�����ҵ���"[]"����˵���ֶ�δ�ҵ�
        If InStr(strNextLine, "[") <> 0 And InStr(strNextLine, "]") <> 0 Then
             If state = 1 Then
                 Exit DO
             End if
              tmp = Trim(Mid(Trim(strNextLine),InStr(strNextLine, "[")+1,Len(initypes)))    
              if tmp = Trim(initypes) Then '�ҵ���initypes  
                 state = 1
                 strNextLine = objTextFile.ReadLine
              End if
        End if
  
        If state = 1 Then  
             'intLineFinder = InStr(strNextLine,"=") '�����ַ����е�"="
             'If intLineFinder <> 0 Then '����ҵ�"="
             '    typeList = Split(strNextLine,"=") '�ָ��ַ���
                 rsStr =rsStr & ",""" & strNextLine & """" '��ֵ 
             'End If
        End if

      Loop
      objTextFile.Close '�ر��ĵ�
	  'WSH.Echo rsStr
      Execute "vbsGetIniFields = Array(" & right(rsStr,Len(rsStr) - 1) & ")" '����ֵ
End Function


'��ȡini�ļ���Ӧkey��value
Function GetValueByKey(file,initypes,key)
	Dim t
	Dim typeList
	Dim ret
	t = vbsGetIniFields(file,initypes)
	'MsgBox (Ubound(t))
	For i = 0 To UBound(t)
		IF InStr(t(i),key)>0 Then
			
			typeList = Split(t(i),"=")
			'MsgBox(typeList(1))
			ret = typeList(1)
			Exit For
		END IF
	Next
	GetValueByKey=ret
END Function


'��ȡ�̷�ID
Function GetDrive()
      Dim t
      Dim reStr '��������ֵ
      t = vbsGetIniFields("Drives.ini","Drives")
      For i = 0 To UBound(t)
        If (Right(t(i),4)) = "True" Then
           Dim discID
           discID = LCase(Left(t(i),2))
           rsStr =rsStr & ",""" & discID & """" '��ֵ 
	   'MsgBox rsStr
       End If
      Next
  Execute "GetDrive = Array(" & right(rsStr,Len(rsStr) - 1) & ")" '����ֵ
End Function

'��ȡ�̷���Ŀ¼���ļ�/�ļ����Լ���С
Sub GetFolderSize(discName,txt)
  Set objWMI = GetObject("winmgmts:") 
  Set oFiles = objWMI.ExecQuery("ASSOCIATORS OF {Win32_Directory.Name='" & discName & "'}" & "where ResultClass = CIM_logicalfile")             

  For Each oFile In oFiles 
     
      If oFile.name <>  left(oFile.name,instrrev(oFile.name,"\")-1) &"\system volume information" Then  
          Dim fileStr
         'txt.Write(left(oFile.name,instrrev(oFile.name,"\")-1)  & ",")
         'fileStr = fileStr & left(oFile.name,instrrev(oFile.name,"\")-1)  & ","
		 txt.Write(oFile.name & ",")	
		 fileStr = fileStr & oFile.name & ","

		 if oFile.FileType="File Folder" then 
		 
		    'fileStr = fileStr & left(oFile.name,instrrev(oFile.name,"\")-1)  & ","
		    'fileStr = fileStr & oFile.name & ","
			
			Set objFolder = oFSO.GetFolder(oFile.name) 

			txt.WriteLine(CLng(objFolder.Size/1024) &"KB") 
			fileStr = fileStr & (CLng(objFolder.Size/1024) &"KB") 

			
		 else 
			txt.WriteLine(CLng(oFile.FileSize/1024) &"KB") 
			fileStr = fileStr & (CLng(oFile.FileSize/1024) &"KB") 
		
		 End If 
		'WSH.Echo fileStr

      End If
      WriteLog fileStr
	  fileStr = ""
  Next
  'Execute "GetFolderSize = fileStr" '����ֵ
End Sub

'����201503061500
Function GetNowTime()
	Dim dtmNowDate
	dtmNowDate = Now()
	Dim NowSysTime

	Dim myYear
	Dim myMonth
	Dim myDay
	Dim myHour
	Dim myMinute
	Dim mySecond

	myYear = Year(dtmNowDate)  

	myMonth = Month(dtmNowDate)
	if myMonth <10 then
		myMonth = "0" & myMonth
	end if

	myDay = Day(dtmNowDate)
	if myDay <10 then
		myDay = "0" & myDay
	end if
	
	myHour = Hour(dtmNowDate)
	if myHour < 10 then 
		myHour = "0" & myHour
	end if

	myMinute = Minute(dtmNowDate) 
	if myMinute <10 then
		myMinute = "0" & myMinute
	end if
	mySecond = Second(dtmNowDate)
	if mySecond <10 then
		mySecond = "0" & mySecond
	end if

	NowSysTime = myYear  & myMonth & myDay & myHour & myMinute & mySecond
	Execute "GetNowTime = NowSysTime" '����ֵ
End Function

Rem :  ===========  ���ļ��� folder1 ���Ƶ��ļ��� folder2 ��
Rem :  ===========  folder1�������
Rem :  ===========  folder2������������Բ���Ϊֻ��
Rem :  ===========  foler2�в��ܴ�����folder1ͬ�����ļ����ļ���
Sub CopyFolder( folder1, folder2 )
	Dim f1, f2
	f1 = folder1
	f2 = folder2
	Dim fso
	set fso = CreateObject("Scripting.FileSystemObject")
	If Right(folder1,1) = "/" Then f1 = Left(folder1,Len(folder1) -1 )
	If Right(folder2,1) = "/" Then f2 = Left(folder2,Len(folder2) -1 )
	If fso.folderexists(f1)=False Then WriteLog "Folder : " & f1 & " does not exist"
	If fso.folderexists(f2)=False Then WriteLog "Folder : " & f2 & " does not exist"
	
	f = f2 & "/" & fso.GetBaseName(f1)
	If fso.fileexists(f) = True Or fso.folderexists(f) = True Then
		WriteLog f & " already exists"
		Exit Sub
	End If
	
	Dim errMsg
	On Error Resume Next
	Rem  ======  code begin
	fso.CopyFolder f1, f2 & "/", False
	Rem  ======  code end
	If Err.Number <> 0 Then
		errMsg = Err.Description
		'On Error Goto 0
		'Err.Raise vbObjectError+128, "CopyFolder", errMsg & vbNewLine & _
		'						"                folder1:" & vbTab & folder1 & vbNewLine & _
		'						"                folder2:" & vbTab & folder2
		WriteLog errMsg & vbNewLine &  _
								"                folder1:" & vbTab & folder1 & vbNewLine & _
								"                folder2:" & vbTab & folder2
		Exit Sub
	End If
End Sub



'''''''''''''''''
'FOR TEST
'rootPath = CreateRootPath()
'WriteLog ("hello world")
''''''''''''''''
