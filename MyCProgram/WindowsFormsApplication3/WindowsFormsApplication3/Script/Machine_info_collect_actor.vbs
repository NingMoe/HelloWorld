'On Error Resume Next

 

'****************************�ؼ���ע��***********************************
'cimv2 : common information model version 2  CIMģ�� �汾2
'winmgmts: WMI �ű��������
'ACPI: Advanced Configuration and Power Management Interface �߼����ú͵�Դ����ӿ�
'CIM_ManagedSystemElement :Ϊϵͳ����ȼ����ݵĻ���𡣳�Ա��׼: �κ��ر��ϵͳ������ɰ�������������
'CIM_PhysicalElement :��������κ����ر�����ʶ�����ϵͳ�����
'CIM_PhysicalPackage : ���������ӵ���������������Ԫ��
'CIM_PhysicalComponents : ����һ���׼����κεͲ����������
'CIM_LogicalElement : �������ϵͳ���������ϵͳ����Ļ����
'CIM_LogicalDevice : Ӳ��ʵ��ĳ������档��������֮�������κ����ڹ�������������õ��߼��豸������
'CIM_System : ���ۼ���һ����оٵĹ���ϵͳ���.���������幦�ܷ�ʽ��������
'CIM_DiskDrive : ����һ���ɲ���ϵͳ��Ϊ���������������
'*************************************************************************

 

'''
''' HTMLҳ����
'''
Class IEHTML
    Private ieobj  'ע�⣺����ǰ�治�ܳ���_ ���������Ʋ�����GET SET ����������һ���������ִ�Сд��
    Public Property Get IE() 'IE����
        Set IE = ieobj
    End Property
    Public Property Set IE(Value)
        Set ieobj = Value
    End Property

    Private Sub Class_Initialize   ' ���캯��
        Set IE = Wscript.CreateObject("InternetExplorer.Application")

        With IE
            .left=200
            .top=200
            .height=540
            .width=750
            .menubar=0
            .toolbar=0
            .statusBar=0
            .navigate "About:Blank"  'ת�����ַ
            .visible=1
            '.FullScreen = 11
         End With
     End Sub

 

    '�ȴ�ҳ��������
    '����IE��Document����
    public Function PredefinedDocument
        Dim ieDocument
        Dim css

        css = css & "<style type='text/css'>" & _
                           "body {" & _
                           "    color: purple;" & _
                           "    background-color: #d8da3d}" & _
                           "table {" & _
                           "    border-collapse:separate;" & _
                           "    bgcolor : #FFC080;" & _
                           "    border: 1px dotted gray;" & _
                           "    width : 100%}" & _
                           "td {" & _
                           "    bgcolor : #EFE7D6td}" & _
                           "</style>"

         Do While IE.Busy
         Loop
  
         '���ǰ����
         set WshShell = WScript.CreateObject("WScript.Shell")
         WshShell.Appactivate IE
         WshShell.sendkeys "{enter}"

         Set ieDocument = IE.Document 'ȡ��IE��Document����

         '��ʼ����Ĭ��HTML�ڵ�
        With ieDocument
            .Open
            .WriteLn "<HTML>"
            .WriteLn "<HEAD>"
            .WriteLn "<TITLE>������Ϣ�����</TITLE>"
            .WriteLn css
            .WriteLn "</HEAD>"
            .WriteLn "<BODY>"
            .WriteLn "<Form>"
            .WriteLn "<div align = 'center'>"
            .WriteLn "<strong>������Ϣ�����Ϣ�б�</strong>"
            .WriteLn "</div>"
            .WriteLn "</br></br>"
            .WriteLn "<div id = 'divInfo'></div>"
            .WriteLn "</Form>"
            .WriteLn "</BODY>"
            .WriteLn "</HTML>"
            '.Close '���Ԥ�ȹر� ��IE�ĺ��������޷�ȡ���Ѿ�д���ֵ����ζ��д�������һ������
        End With

        PredefinedDocument = ieDocument
     End Function

 

     '��ʾҳ����Ϣ
     public Sub WriteInfo(strInfo)
         Dim ieDocument , documentDiv
         PredefinedDocument() 'ִ��Ԥд����

         Set ieDocument = IE.Document' GetDocument()  'IE.Document�Ӻ�������֮�� �޷�ȡ�ö��� ԭ����
     
         with ieDocument
             '.open
             'IE.Document.write strInfo
             'MsgBox IE.Document.documentElement.innerHTML
            .getElementById("divInfo").innerHTML = strInfo
            .close
          End with
      End Sub

 

      '�����Ҫ�Զ������ ����ô˷���
      public Sub WriteInfo2(strInfo)
          Dim ieDocument

          While IE.Busy  
          wend
          Set ieDocument = IE.Document

          With ieDocument
              .open
              .Write strInfo
              .close
          End With
          'ieDocument.getElementById("divInfo").innerHTML = strInfo
       End Sub
 
       Private Sub Class_Terminate() '��������
           Set IE = nothing
       End Sub
End Class

 

'''
'''ö����
'''
Class PropertyEnum
 Dim dic

 Private Sub Class_Initialize()
  Set dic = CreateObject("Scripting.Dictionary")
 End Sub

 Private Sub Class_Terminate()
  Set dic = nothing
 End Sub

 '********************��������**************************
 Public Property Get CommonEnum(strproperty)
  dic.RemoveAll()

  Select Case strproperty
  Case "Status" '����ǰ�����ͷǲ�����״̬
   dic.add "OK", "ȷ��"
   dic.add "Error", "����"
   dic.add "Degraded", "�ѽ���"
   dic.add "Unknown", "δ֪"
   dic.add "Pred Fail", "Ԥ������"
   dic.add "Starting", "����"
   dic.add "Stopping", "ֹͣ"
   dic.add "Service", "����"
   dic.add "Stressed", "ǿ��"
   dic.add "NonRecover", "���ɻָ�"
   dic.add "NoContact", "�޹���"
   dic.add "LostComm", "ʧȥ�ź�"
  Case "PoweredOn" 
   dic.add "True", "��"
   dic.add "Flase", "��"
  End Select

  Set CommonEnum = dic
 End Property
 '*****************************************************

 '********************CPU����**************************
 Public Property Get CPUEnum(strproperty)
  dic.RemoveAll()

  Select Case strproperty
   Case "Architecture" 'Architecture ����ָ�����ڴ�ƽ̨�Ĵ����������
    dic.add "0", "x86 "
    dic.add "1", "MIPS "
    dic.add "2", "Alpha "
    dic.add "3", "PowerPC "
    dic.add "6", "ia64 "
   Case "Availability" '�豸�Ŀ����Ժ�״̬
    dic.add "3", "ȫ������ "
    dic.add "4", "���� "
    dic.add "5", "���� "
    dic.add "10", "���� "
    dic.add "13", "���� - δ֪ "
    dic.add "14", "���� - ����ģʽ "
    dic.add "15", "���� - ����״̬ "
    dic.add "17", "���� - ���� "
   Case "ConfigManagerErrorCode" '��ʾ Win32 ���ù������������
    dic.add "0", "��̨���ù���������"
    dic.add "1", "��̨�������õò��ԡ�"
    dic.add "2", "Windows ����Ϊ��̨���ü�����������"
    dic.add "3", "��̨���õ�������������𻵣���������ϵͳ���ڴ��������Դ���㡣"
    dic.add "4", "��̨���ù�����������ĳ�����������ע���������𻵡�"
    dic.add "5", "��̨���õ�����������Ҫһ�� Windows ���ܹ������Դ��"
    dic.add "6", "��̨���õ����������������豸���ͻ��"
    dic.add "7", "�޷�ɸѡ��"
    dic.add "8", "�Ҳ������豸����������"
    dic.add "9", "���ڿ��ƹ̼�û����ȷ�㱨�豸����Դ������豸�޷��������С�"
    dic.add "10", "����豸�޷�������"
    dic.add "11", "����豸ʧ�ܡ�"
    dic.add "12", "����豸�޷��ҵ��ɹ�ʹ�õĿ�����Դ��"
    dic.add "13", "Windows �޷�ʶ������豸ʹ�õ�������Դ��"
    dic.add "14", "�����������ļ����֮ǰ������豸�޷��������С�"
    dic.add "15", "���ڴ���һ������ö�ٵ����⣬����豸�޷��������С�"
    dic.add "16", "Windows �޷�ʶ������豸ʹ�õ�������Դ��"
    dic.add "17", "����豸������һ��δ֪��Դ���͡�"
    dic.add "18", "Ϊ����豸���°�װ��������"
    dic.add "19", "����ע����������"
    dic.add "20", "ʹ�� VxD ������ʧ�ܡ�"
    dic.add "21", "ϵͳʧ��: ����豸���Ը����������������������Ч�����������Ӳ���ĵ���Windows ����ɾ������豸��"
    dic.add "22", "����豸��ͣ�á�"
    dic.add "23", "ϵͳʧ��: ����豸���Ը����������������������Ч�����������Ӳ���ĵ���"
    dic.add "24", "����豸�����ڡ��޷�������������û�а�װ���е���������"
    dic.add "25", "Windows ���ڰ�װ����豸��"
    dic.add "26", "Windows ���ڰ�װ����豸��"
    dic.add "27", "����豸û����Ч����־���á�"
    dic.add "28", "����豸����������û�а�װ��"
    dic.add "29", "�����豸�Ĺ̼�û�и����������Դ������豸��ͣ�á�"
    dic.add "30", "����豸����ʹ����һ̨�豸ʹ�õ��ж�����(IRQ)��Դ��"
    dic.add "31", "���� Windows �޷���������豸����Ҫ��������������豸�޷��������С�"
   Case "StatusInfo" '�豸������״̬��Ϣ
    dic.add "1", "���� "
    dic.add "3", "������ "    
    dic.add "2", "δ֪ "
    dic.add "4", "��ͣ�� "
    dic.add "5", "������ "
   Case "Family" '������ϵ������
    dic.add "1", "����" 
    dic.add "2", "δ֪" 
    dic.add "3", "8086" 
    dic.add "4", "80286" 
    dic.add "5", "80386" 
    dic.add "6", "80486" 
    dic.add "7", "8087" 
    dic.add "8", "80287" 
    dic.add "9", "80387" 
    dic.add "10", "80487" 
    dic.add "11", "Pentium?  brand" 
    dic.add "12", "Pentium? Pro" 
    dic.add "13", "Pentium? II" 
    dic.add "14", "Pentium? processor with MMX technology"
    dic.add "15", "Celeron?" 
    dic.add "16", "Pentium? II Xeon" 
    dic.add "17", "Pentium? III" 
    dic.add "18", "M1 Family"
    dic.add "19", "M2 Family"
    dic.add "24", "K5 Family" 
    dic.add "25", "K6 Family" 
    dic.add "26", "K6-2" 
    dic.add "27", "K6-3" 
    dic.add "28", "AMD Athlon? Processor Family" 
    dic.add "29", "AMD? Duron? Processor" 
    dic.add "30", "AMD2900 Family" 
    dic.add "31", "K6-2+" 
    dic.add "32", "Power PC Family" 
    dic.add "33", "Power PC 601" 
    dic.add "34", "Power PC 603" 
    dic.add "35", "Power PC 603+" 
    dic.add "36", "Power PC 604" 
    dic.add "37", "Power PC 620" 
    dic.add "38", "Power PC X704" 
    dic.add "39", "Power PC 750" 
    dic.add "48", "Alpha Family" 
    dic.add "49", "Alpha 21064" 
    dic.add "50", "Alpha 21066" 
    dic.add "51", "Alpha 21164" 
    dic.add "52", "Alpha 21164PC" 
    dic.add "53", "Alpha 21164a" 
    dic.add "54", "Alpha 21264"
    dic.add "55", "Alpha 21364" 
    dic.add "64", "MIPS Family" 
    dic.add "65", "MIPS R4000" 
    dic.add "66", "MIPS R4200" 
    dic.add "67", "MIPS R4400" 
    dic.add "68", "MIPS R4600" 
    dic.add "69", "MIPS R10000" 
    dic.add "80", "SPARC Family" 
    dic.add "81", "SuperSPARC" 
    dic.add "82", "microSPARC II" 
    dic.add "83", "microSPARC IIep" 
    dic.add "84", "UltraSPARC" 
    dic.add "85", "UltraSPARC II" 
    dic.add "86", "UltraSPARC IIi" 
    dic.add "87", "UltraSPARC III" 
    dic.add "88", "UltraSPARC IIIi" 
    dic.add "96", "68040" 
    dic.add "97", "68xxx Family" 
    dic.add "98", "68000" 
    dic.add "99", "68010" 
    dic.add "100", "68020" 
    dic.add "101", "68030" 
    dic.add "112", "Hobbit Family" 
    dic.add "120", "Crusoe? TM5000 Family" 
    dic.add "121", "Crusoe? TM3000 Family" 
    dic.add "128", "Weitek" 
    dic.add "130", "Itanium? Processor" 
    dic.add "144", "PA-RISC Family" 
    dic.add "145", "PA-RISC 8500" 
    dic.add "146", "PA-RISC 8000" 
    dic.add "147", "PA-RISC 7300LC" 
    dic.add "148", "PA-RISC 7200" 
    dic.add "149", "PA-RISC 7100LC" 
    dic.add "150", "PA-RISC 7100" 
    dic.add "160", "V30 Family" 
    dic.add "176", "Pentium? III Xeon?" 
    dic.add "177", "Pentium? III Processor with Intel? SpeedStep? Technology" 
    dic.add "178", "Pentium? 4" 
    dic.add "179", "Intel? Xeon?" 
    dic.add "180", "AS400 Family" 
    dic.add "181", "Intel? Xeon? processor MP"
    dic.add "182", "AMD AthlonXP? Family" 
    dic.add "183", "AMD AthlonMP? Family" 
    dic.add "184", "Intel? Itanium? 2" 
    dic.add "185", "AMD Opteron? Family" 
    dic.add "190", "K7" 
    dic.add "200", "IBM390 Family" 
    dic.add "201", "G4" 
    dic.add "202", "G5" 
    dic.add "250", "i860" 
    dic.add "251", "i960" 
    dic.add "260", "SH-3" 
    dic.add "261", "SH-4" 
    dic.add "280", "ARM" 
    dic.add "281", "StrongARM" 
    dic.add "300", "6x86" 
    dic.add "301", "MediaGX" 
    dic.add "302", "MII" 
    dic.add "320", "WinChip" 
    dic.add "350", "DSP" 
    dic.add "500", "Video Processor" 
   Case "ProcessorType" '����������
   dic.add "1", "����" 
   dic.add "2", "δ֪" 
   dic.add "3", "���봦����" 
   dic.add "4", "���㴦����" 
   dic.add "5", "�����źŴ�����" 
   dic.add "6", "��Ƶ������" 
   Case "CpuStatus" '��������ǰ��״̬
   dic.add "0", "δ֪" 
   dic.add "1", "����" 
   dic.add "2", "BIOS������ʾ" 
   dic.add "3", "BIOS���ò���ʾ (�������)" 
   dic.add "4", "����" 
   dic.add "5", "����" 
   dic.add "6", "����" 
   dic.add "7", "����"
  End Select

  Set CPUEnum = dic
 End Property
 '*****************************************************

 '********************�ڴ�����*************************
 Public Property Get PhysicalMemoryEnum(strproperty)
  dic.RemoveAll()

  Select Case strproperty
   Case "MemoryType" 
    dic.add "0", "δ֪" 
    dic.add "1", "����" 
    dic.add "2", "DRAM" 
    dic.add "3", "Synchronous DRAM" 
    dic.add "4", "Cache DRAM" 
    dic.add "5", "EDO" 
    dic.add "6", "EDRAM" 
    dic.add "7", "VRAM" 
    dic.add "8", "SRAM" 
    dic.add "9", "RAM"
    dic.add "10", "ROM" 
    dic.add "11", "Flash" 
    dic.add "12", "EEPROM" 
    dic.add "13", "FEPROM" 
    dic.add "14", "EPROM" 
    dic.add "15", "CDRAM" 
    dic.add "16", "3DRAM" 
    dic.add "17", "SDRAM" 
    dic.add "18", "SGRAM" 
    dic.add "19", "RDRAM"
    dic.add "20", "DDR" 
   Case "InterleavePosition" 
    dic.add "0", "�ǽ���" 
    dic.add "1", "��һ��λ��" 
    dic.add "2", "�ڶ���λ��" 
  End Select

  Set PhysicalMemoryEnum = dic
 End Property
 '*****************************************************

    '********************��������*************************
 Public Property Get KeyBoradEnum(strproperty)
  dic.RemoveAll()

  Select Case strproperty
   Case "Password" 
    dic.add "1", "����" 
    dic.add "2", "δ֪" 
    dic.add "3", "��ͣ��" 
    dic.add "4", "������" 
    dic.add "5", "δִ��"
  End Select

  Set KeyBoradEnum = dic
 End Property
 '*****************************************************

    '********************�������*************************
 Public Property Get PointingDeviceEnum(strproperty)
  dic.RemoveAll()

  Select Case strproperty
   Case "DeviceInterface" 
    dic.add "1", "����" 
    dic.add "2", "δ֪" 
    dic.add "3", "������" 
    dic.add "4", "PS/2" 
    dic.add "5", "�����ߵ�" 
    dic.add "6", "HP-HIL" 
    dic.add "7", "�������" 
    dic.add "8", "ADB (Apple Desktop Bus)" 
    dic.add "160", "������� DB-9" 
    dic.add "161", "������� micro-DIN" 
    dic.add "162", "USB" 
   Case "Handedness" 
    dic.add "0", "δ֪" 
    dic.add "1", "������" 
    dic.add "2", "���ֲ���" 
    dic.add "3", "���ֲ���"
   Case "PointingType" 
    dic.add "1", "����" 
    dic.add "2", "δ֪" 
    dic.add "3", "���" 
    dic.add "4", "������" 
    dic.add "5", "Track Point" 
    dic.add "6", "Glide Point" 
    dic.add "7", "�������" 
    dic.add "8", "������" 
    dic.add "9", "������" 
  End Select

  Set PointingDeviceEnum = dic
 End Property
 '*****************************************************

   '********************��ʾ������*************************
 Public Property Get DesktopMonitorEnum(strproperty)
  dic.RemoveAll()

  Select Case strproperty
   Case "DisplayType" 
    dic.add "0", "δ֪" 
    dic.add "1", "����" 
    dic.add "2", "��ɨ��ɫ" 
    dic.add "3", "��ɫ������" 
    dic.add "4", "Fixed Frequency Color" 
    dic.add "5", "Fixed Frequency Monochrome" 
  End Select

  Set DesktopMonitorEnum = dic
 End Property
 '*****************************************************

    '********************����ϵͳ����*********************
 Public Property Get ComputerSystemEnum(strproperty)
  dic.RemoveAll()

  Select Case strproperty
   Case "AdminPasswordStatus"
    dic.add "1", "������" 
    dic.add "2", "����" 
    dic.add "3", "δ��Ч" 
    dic.add "4", "δ֪" 
   Case "BootOptionOnLimit"
    dic.add "1", "Ԥ��" 
    dic.add "2", "����ϵͳ" 
    dic.add "3", "ϵͳӦ��" 
    dic.add "4", "������"
   Case "ChassisBootupState"
    dic.add "1", "����" 
    dic.add "2", "δ֪" 
    dic.add "3", "��ȫ��" 
    dic.add "4", "�����" 
    dic.add "5", "Σ�յ�" 
    dic.add "6", "���ɻָ���"
   Case "DomainRole"
    dic.add "0", "����������" 
    dic.add "1", "��������Ա" 
    dic.add "2", "����������" 
    dic.add "3", "��������Ա" 
    dic.add "4", "���������Ա" 
    dic.add "5", "�������Ա"
   Case "FrontPanelResetStatus"
    dic.add "0", "������" 
    dic.add "1", "����" 
    dic.add "2", "����Ч" 
    dic.add "3", "δ֪" 
   Case "PowerManagementCapabilities"
    dic.add "0", "δ֪" 
    dic.add "1", "����֧��" 
    dic.add "2", "��ͣ��" 
    dic.add "3", "������" 
    dic.add "4", "�Զ��������ģʽ" 
    dic.add "5", "�����õĵ�Դ״̬" 
    dic.add "6", "֧�ֵ�Դ����" 
    dic.add "7", "֧�ֶ�ʱͨ��"
   Case "PowerState"
    dic.add "0", "δ֪" 
    dic.add "1", "ȫ��ģʽ" 
    dic.add "2", "����ģʽ" 
    dic.add "3", "����ģʽ" 
    dic.add "4", "����ģʽ" 
    dic.add "5", "����ѭ��" 
    dic.add "6", "��Դ�ر�" 
    dic.add "7", "����ģʽ-����״̬" 
   Case "WakeUpType"
    dic.add "0", "Ԥ��" 
    dic.add "1", "����" 
    dic.add "2", "δ֪" 
    dic.add "3", "�߼���Դ����ʱ��" 
    dic.add "4", "���ƽ����֪ͨ" 
    dic.add "5", "Զ������" 
    dic.add "6", "��Դ����" 
    dic.add "7", "PCI PME#" 
    dic.add "8", "AC Power Restored" 
   Case "BootupState"
       dic.add "Normal boot", "��������"
    dic.add "Fail-safe boot", "ʧЧ��������"
    dic.add "Fail-safe with network boot", "����ʧЧ��������"
   End Select

  Set ComputerSystemEnum = dic
 End Property
 '****************************************************

  '********************�ڴ�����*********************
 Public Property Get ProcessEnum(strproperty)
  dic.RemoveAll()

  Select Case strproperty
   Case "ExecutionState"
    dic.add "2", "����" 
    dic.add "3", "����" 
    dic.add "4", "����" 
  End Select

  Set ProcessEnum = dic
 End Property
 '****************************************************
End Class

 

'''
'''�ַ���������
'''
Class OperateString
    '����֮����ַ���
    Private buildstr 
    Public Property Get Str()
        Str = buildstr
    End Property
    Public Property Set Str(value)
        buildstr = value '�ַ�������SET
    End Property

    '''
    '''�������ʾ��ҳ���е�HTML�ַ���
    '''������text������ʾ�����ƣ� value(����ʾ��ֵ)
    Public Sub BuildStringHTML(text, value)
     '������SET�����Ը�ֵ
        Set Str = Str & _
                       "<tr><td>" & text & _
                       "</td><td>" & value & _
                       "</td></tr>"
    End Sub
	
	public Sub BuildStringHTMLForBeginTR()
		Set Str = Str & "<tr>"
	End Sub
	
	Public Sub BuildStringHTMLForEndTR
		Set Str = Str & "</tr>"
	End Sub
	
	Public Sub BuildStringHTMLForProcess(value)
		Set Str = Str & _
						"<td>" & value & _
						"</td>"
	End Sub
 
    '''
    '''���ش���֮����ַ���֮ǰ �ܷ�һ�δ��ַ���
    '''����: strHeader(���ֶ�����ı�ͷ����)
    Public Sub SealHTML(strHeader)
        Set Str = "<table>" & _
                       "<tr align = 'center' STYLE='font-size:14; background-color:beige'>" & _
                       "<td colSpan = '2'>" & _
                       strHeader & "��Ϣ�б�" & _
                       "</td></tr>" & _
                       "<tr><td width = '30%'></td></tr>" & _
                       Str & _
                       "</table>"
    End Sub

    Public function ReturnStrAndClear()
        ReturnStrAndClear = Str
        Set Str = ""
    End function
End Class

 

'''
'''�������ú�����
'''
Class OtherCommonOperate
    '����Dictionary�ļ�ȡ��ֵ
    Public Function GetEnumValue(dic, text)
        Dim dicKeys, dicItems

        If IsNull(text) Then Exit Function

        dicKeys = dic.Keys
        dicItems =  dic.Items
 
        For i = 0 To dic.count -1
            If dicKeys(i) = CStr(text) Then
                GetEnumValue = dicItems(i)
                Exit Function
            End If
       Next
    End Function
End Class


'''
''' WMIȡ�õ�����Ϣ
'''
Class WMIInfo
    Dim objWMI 'WMI���� CIMV2���
    Dim objWMI1 'WMI���� WINDOWS WMI�������
    Dim optstr '�ַ������������
    Dim objEnum 'ö�������
    Dim ocommonopt '��������������

 

 '���������
 'Set���ڱ����ڲ�  Let������ʵ����֮��ֵ�����
 Private strcomputer 
 Public Property Get computerName
  computerName = strcomputer
 End Property 
 Public Property Set computerName(Value)
     strcomputer = Value
 End Property 
 Public Property Let computerName(Value)
  strcomputer = Value

  Set objWMI = GetObject("winmgmts://" &  Value & "/root/cimv2") 
  Set objWMI1 = GetObject("winmgmts://" & Value & "/root/wmi")
 End Property

 Private Sub Class_Initialize '���캯��
  Set objWMI = GetObject("winmgmts://") 'winmgmts://Ĭ�ϴ�����CIMV2
  Set optstr = new OperateString
  Set objEnum = new PropertyEnum
  Set ocommonopt = new OtherCommonOperate
 End Sub

 Private Sub Class_Terminate() '��������
  Set objWMI = Nothing
  Set optstr = Nothing
  Set objEnum = Nothing
  Set ocommonopt = Nothing
  If IsEmpty(computerName) Then
   Set objWMI1 = Nothing
  End If
End Sub

 

 'ȡ��������Ϣ
 'ע:Win32_BaseBoard ���������(Ҳ��ĸ���ϵͳ��)
 'λ�ã�//DZW/ROOT/CIMV2/CIM_ManagedSystemElement/CIM_PhysicalElement/CIM_PhysicalPackage/CIM_Card
 Public Function GetBaseBoardInfo()
  'instancesofֻ����SWbemServices�����һ���򵥲�ѯ  
  '���ӵĲ�ѯ��Ҫʹ��SWbemServices.ExecQuery
  Set baseboard = objWMI.instancesof("win32_baseboard")
  
  For Each itembaseboard In baseboard 
   Call optstr.BuildStringHTML("���峧��" , itembaseboard.Manufacturer)
   Call optstr.BuildStringHTML("�����ͺ�" , itembaseboard.product)
   Call optstr.BuildStringHTML("����������", itembaseboard.SerialNumber)
   Call optstr.BuildStringHTML("��Դ��״̬",  _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"), itembaseboard.PoweredOn))
   Call optstr.BuildStringHTML("����״̬", _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("Status"), itembaseboard.Status))
      Call optstr.BuildStringHTML("�汾", itembaseboard.Version)
   Call optstr.BuildStringHTML("����", itembaseboard.Weight)
   Call optstr.BuildStringHTML("���", itembaseboard.Width)
   Call optstr.BuildStringHTML("��װʱ��", itembaseboard.InstallDate)
  Next 
  optstr.SealHTML("����")

  GetBaseBoardInfo = optstr.ReturnStrAndClear()
    End Function

 

     'ȡ��CPU��Ϣ
  'ע��Win32_Processor ������ ������
  'λ�ã�//DZW/ROOT/CIMV2/CIM_ManagedSystemElement/CIM_LogicalElement/CIM_LogicalDevice/CIM_Processor
 Public Function GetCPUInfo()
  Set cpu = objWMI.instancesof("win32_processor")

  For Each itemcpu In cpu
   Call optstr.BuildStringHTML("CPU����" , itemcpu.Manufacturer)
   Call optstr.BuildStringHTML("CPU����" , itemcpu.Name)
   Call optstr.BuildStringHTML("CPU��ʶ", itemcpu.DeviceID)
   Call optstr.BuildStringHTML("CPU����",  _
   ocommonopt.GetEnumValue(objEnum.CPUEnum("ProcessorType"), itemcpu.ProcessorType))
   Call optstr.BuildStringHTML("CPUϵ������",  _
   ocommonopt.GetEnumValue(objEnum.CPUEnum("Family"), itemcpu.Family))
   Call optstr.BuildStringHTML("CPU�������", _
   ocommonopt.GetEnumValue(objEnum.CPUEnum("Architecture"), itemcpu.Architecture))
   Call optstr.BuildStringHTML("��ǰ״̬", _
   ocommonopt.GetEnumValue(objEnum.CPUEnum("CpuStatus"), itemcpu.CpuStatus))
   Call optstr.BuildStringHTML("�����ͷǲ���״̬", _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("Status"), itemcpu.Status)) 
   Call optstr.BuildStringHTML("CPU����״̬��Ϣ", _
   ocommonopt.GetEnumValue(objEnum.CPUEnum("StatusInfo"), itemcpu.StatusInfo))
   Call optstr.BuildStringHTML("������", _
   ocommonopt.GetEnumValue(objEnum.CPUEnum("Availability"), itemcpu.Availability))
   Call optstr.BuildStringHTML("��ǰ�ٶ�", itemcpu.CurrentClockSpeed)
   Call optstr.BuildStringHTML("��ǰ����ٶ�(����)", itemcpu.MaxClockSpeed)
   Call optstr.BuildStringHTML("��ǰ��ѹ", itemcpu.CurrentVoltage)
   Call optstr.BuildStringHTML("��ַ���(λ)", itemcpu.AddressWidth)
   Call optstr.BuildStringHTML("���ݿ��(λ)", itemcpu.DataWidth)
   Call optstr.BuildStringHTML("�ⲿʱ��Ƶ��", itemcpu.ExtClock)
   Call optstr.BuildStringHTML("���������С", itemcpu.L2CacheSize)
   Call optstr.BuildStringHTML("��������ʱ���ٶ�", itemcpu.L2CacheSpeed)
   Call optstr.BuildStringHTML("���һ�븺������", itemcpu.LoadPercentage)
   Call optstr.BuildStringHTML("���弴��ID", itemcpu.PNPDeviceID)
   Call optstr.BuildStringHTML("CPU����������Ϣ", itemcpu.ProcessorId)
   Call optstr.BuildStringHTML("CPU��ɫ", itemcpu.Role)
   Call optstr.BuildStringHTML("оƬ�������", itemcpu.SocketDesignation)
   Call optstr.BuildStringHTML("������Ϣ", itemcpu.UpgradeMethod)
   Call optstr.BuildStringHTML("����������ϵͳ����", itemcpu.SystemName)
   Call optstr.BuildStringHTML("CPU�汾", itemcpu.Version)
   Call optstr.BuildStringHTML("CPU����", itemcpu.Caption)
   Call optstr.BuildStringHTML("Win32���ù���������" , _
   ocommonopt.GetEnumValue(objEnum.CPUEnum("ConfigManagerErrorCode"),itemcpu.ConfigManagerErrorCode))
   Call optstr.BuildStringHTML("��װʱ��", itemcpu.InstallDate)
  Next

  optstr.SealHTML("CPU")

  GetCPUInfo = optstr.ReturnStrAndClear()
 End Function

 

 'ȡ�÷������¶���Ϣ
 'λ�ã�//DZW/ROOT/WMI/MSAcpi/MSAcpi_ThermalZoneTemperature
 Public Function GetTemperatureInfo()
     If IsEmpty(objWMI1) Then
   Exit Function
     End If

  Set temperature = objWMI1.instancesof("MSAcpi_ThermalZoneTemperature")

  If IsNull(temperature) = true Then
	  For Each itemtemperature In temperature
	   Call optstr.BuildStringHTML("ʵ������" , itemtemperature.InstanceName)
	   Call optstr.BuildStringHTML("��ǰ�¶�" , CStr((CDbl(itemtemperature.CurrentTemperature)-2732)/10))
	   Call optstr.BuildStringHTML("ȡ������" , itemtemperature.SamplingPeriod)
	   Call optstr.BuildStringHTML("��һ����������" , itemtemperature.ThermalConstant1)
	   Call optstr.BuildStringHTML("�ڶ�����������" , itemtemperature.ThermalConstant2)
	   Call optstr.BuildStringHTML("����Ϣ�ı�ı�ʶ" , itemtemperature.ThermalStamp)

				'**Ԥ������**
	   'Call optstr.BuildStringHTML("Active" , itemtemperature.Active)
	   'Call optstr.BuildStringHTML("ActiveTripPointCount" , itemtemperature.ActiveTripPointCount)
	   'Call optstr.BuildStringHTML("CriticalTripPoint" , itemtemperature.CriticalTripPoint)
	   'Call optstr.BuildStringHTML("PassiveTripPoint" , itemtemperature.PassiveTripPoint)
	   'Call optstr.BuildStringHTML("Reserved" , itemtemperature.Reserved)
	   '************
	  Next
  End if

     optstr.SealHTML("CPU�¶�")

  GetTemperatureInfo = optstr.ReturnStrAndClear()
 End Function

 

 'ȡ���ڴ���Ϣ
 'Win32_PhysicalMemory ��� ���� ����ϵͳ���ڴ���
 'λ�ã�//DZW/ROOT/CIMV2/CIM_ManagedSystemElement/CIM_PhysicalElement/CIM_PhysicalComponent/CIM_Chip/CIM_PhysicalMemory
Public Function GetMemoryInfo()
  Set physicalmemory = objWMI.instancesof("Win32_PhysicalMemory")

  For Each itemphysicalmemory In physicalmemory
   Call optstr.BuildStringHTML("�ڴ泧��" , itemphysicalmemory.Manufacturer)
   Call optstr.BuildStringHTML("�ڴ�����" , itemphysicalmemory.Name)
   Call optstr.BuildStringHTML("�ڴ���", itemphysicalmemory.PartNumber)
   Call optstr.BuildStringHTML("�ڴ�������", itemphysicalmemory.SerialNumber)
   Call optstr.BuildStringHTML("�����ڴ�������(M)", Round((itemphysicalmemory.Capacity/1024^2),2))
   Call optstr.BuildStringHTML("�ڴ�����",  _
   ocommonopt.GetEnumValue(objEnum.PhysicalMemoryEnum("MemoryType"), itemphysicalmemory.MemoryType))
   Call optstr.BuildStringHTML("�����ͷǲ���״̬", _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("Status"), itemphysicalmemory.Status))
   Call optstr.BuildStringHTML("�ٶ�(����)", itemphysicalmemory.Speed)
   Call optstr.BuildStringHTML("���ݿ��(λ)", itemphysicalmemory.DataWidth)
   Call optstr.BuildStringHTML("�ڴ��ܿ��(λ)", itemphysicalmemory.TotalWidth)
   Call optstr.BuildStringHTML("�ڴ�λ��", itemphysicalmemory.BankLabel)
   Call optstr.BuildStringHTML("�ڴ����ڵ�·��", itemphysicalmemory.DeviceLocator)
   Call optstr.BuildStringHTML("оƬִ�и�ʽ", itemphysicalmemory.FormFactor)
   Call optstr.BuildStringHTML("�Ƿ�֧�����滻", itemphysicalmemory.HotSwappable)
   Call optstr.BuildStringHTML("������������������", itemphysicalmemory.InterleaveDataDepth)
   Call optstr.BuildStringHTML("�������ڴ��λ��",  _
   ocommonopt.GetEnumValue(objEnum.PhysicalMemoryEnum("InterleavePosition"), itemphysicalmemory.InterleavePosition))
   Call optstr.BuildStringHTML("��Դ��״̬",  _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"), itemphysicalmemory.PoweredOn))
   Call optstr.BuildStringHTML("�ڴ�汾", itemphysicalmemory.Version)
   Call optstr.BuildStringHTML("�ڴ�����", itemphysicalmemory.Description)
   Call optstr.BuildStringHTML("��װʱ��", itemphysicalmemory.InstallDate)
  Next

     optstr.SealHTML("�ڴ�")

  GetMemoryInfo = optstr.ReturnStrAndClear()
 End Function

 

    'ȡ��Ӳ����Ϣ
    'Win32_DiskDrive �������������������
 'λ�ã� //DZW/ROOT/CIMV2/CIM_ManagedSystemElement/CIM_LogicalElement/CIM_LogicalDevice/CIM_MediaAccessDevice/CIM_DiskDrive
    Public Function GetDiskDriveInfo()
  Set diskdrive = objWMI.instancesof("Win32_DiskDrive")

  For Each itemdiskdrive In diskdrive
   If not isnull(itemdiskdrive.size) Then
       '���������Ϣ����ָ��� ����
    If itemdiskdrive.index <> 0 Then
     Call optstr.BuildStringHTML("---------------------" , "")
    End If 
                
    Call optstr.BuildStringHTML("����" , itemdiskdrive.Manufacturer)
    Call optstr.BuildStringHTML("����" , itemdiskdrive.Name)
    Call optstr.BuildStringHTML("Ӳ��������(M)",  Round((itemdiskdrive.size/1024^2), 2))
    Call optstr.BuildStringHTML("������" , itemdiskdrive.Partitions)
    Call optstr.BuildStringHTML("ÿ�������ֽ���" , itemdiskdrive.BytesPerSector)
    Call optstr.BuildStringHTML("Ĭ�Ͽ��С(�ֽ�)" , itemdiskdrive.DefaultBlockSize)
    Call optstr.BuildStringHTML("������" , itemdiskdrive.DeviceID)
    Call optstr.BuildStringHTML("����������" , itemdiskdrive.Index)
    Call optstr.BuildStringHTML("���弴��ID" , itemdiskdrive.PNPDeviceID)
    Call optstr.BuildStringHTML("SCSI���ߺ�" , itemdiskdrive.SCSIBus)
    Call optstr.BuildStringHTML("SCSI�߼���λ��(LUN)" , itemdiskdrive.SCSILogicalUnit)
    Call optstr.BuildStringHTML("SCSI�˿ں�" , itemdiskdrive.SCSIPort)
    Call optstr.BuildStringHTML("SCSI��ID��" , itemdiskdrive.SCSITargetId)
    Call optstr.BuildStringHTML("ÿ���ŵ���������" , itemdiskdrive.SectorsPerTrack)
    Call optstr.BuildStringHTML("����ǩ��" , itemdiskdrive.Signature)
    Call optstr.BuildStringHTML("������(�ֽ�)" , itemdiskdrive.MaxBlockSize)
    Call optstr.BuildStringHTML("��֧���������(ǧ�ֽ�)" , itemdiskdrive.MaxMediaSize)
    Call optstr.BuildStringHTML("�Ƿ����" ,  _
    ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"),  itemdiskdrive.MediaLoaded))
    Call optstr.BuildStringHTML("����" , itemdiskdrive.MediaType)
    Call optstr.BuildStringHTML("��Сģ����(�ֽ�)" , itemdiskdrive.MinBlockSize)
    Call optstr.BuildStringHTML("�������ͺ�" , itemdiskdrive.Model)
    Call optstr.BuildStringHTML("�Ƿ���Ҫ����" ,  _
    ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"),  itemdiskdrive.NeedsCleaning))
    Call optstr.BuildStringHTML("��������" , itemdiskdrive.TotalCylinders)
    Call optstr.BuildStringHTML("��ͷ����" , itemdiskdrive.TotalHeads)
    Call optstr.BuildStringHTML("��������" , itemdiskdrive.TotalSectors)
    Call optstr.BuildStringHTML("�ŵ�����" , itemdiskdrive.TotalTracks)
    Call optstr.BuildStringHTML("ÿ������ŵ�����" , itemdiskdrive.TracksPerCylinder)
    Call optstr.BuildStringHTML("�����ͷǲ���״̬", _
    ocommonopt.GetEnumValue(objEnum.CommonEnum("Status"), itemdiskdrive.Status))
    Call optstr.BuildStringHTML("����" , itemdiskdrive.Caption)
    Call optstr.BuildStringHTML("����" , itemdiskdrive.Description)
   End If
  Next

     optstr.SealHTML("Ӳ��")

  GetDiskDriveInfo = optstr.ReturnStrAndClear()
 End Function

 

    'ȡ�ù�����Ϣ
    'Win32_CDROMDrive ������ CD-ROM ������
 'λ�ã� //DZW/ROOT/CIMV2/CIM_ManagedSystemElement/CIM_LogicalElement/CIM_LogicalDevice/CIM_MediaAccessDevice/CIM_CDROMDrive
Public Function GetCDROMDriveInfo()
  Set cdromdrive = objWMI.instancesof("Win32_CDROMDrive") 
        
  For Each itemcdromdrive In cdromdrive
   Call optstr.BuildStringHTML("����" , itemcdromdrive.Manufacturer)
   Call optstr.BuildStringHTML("����" , itemcdromdrive.Name)
   If not isnull(itemcdromdrive.size) Then
    Call optstr.BuildStringHTML("����������(M)",  Round((itemcdromdrive.size/1024^2), 2))
   End If

   Call optstr.BuildStringHTML("Ĭ�Ͽ��С(�ֽ�)" , itemcdromdrive.DefaultBlockSize)
   Call optstr.BuildStringHTML("������" , itemcdromdrive.DeviceID)
   Call optstr.BuildStringHTML("������" , itemcdromdrive.Drive)
   Call optstr.BuildStringHTML("��ʶ��������" , itemcdromdrive.Id)
   Call optstr.BuildStringHTML("SCSI���ߺ�" , itemcdromdrive.SCSIBus)
   Call optstr.BuildStringHTML("SCSI�߼���λ��(LUN)" , itemcdromdrive.SCSILogicalUnit)
   Call optstr.BuildStringHTML("SCSI�˿ں�" , itemcdromdrive.SCSIPort)
   Call optstr.BuildStringHTML("SCSI��ID��" , itemcdromdrive.SCSITargetId)
   Call optstr.BuildStringHTML("�Ƿ��׼ȷ��ȡ����"  , _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"),  itemcdromdrive.DriveIntegrity))
   Call optstr.BuildStringHTML("֧���ļ�����󳤶�" , itemcdromdrive.MaxBlockSize)
   Call optstr.BuildStringHTML("������(�ֽ�)" , itemcdromdrive.MaxBlockSize)
   Call optstr.BuildStringHTML("��֧���������(ǧ�ֽ�)" , itemcdromdrive.MaxMediaSize)
   Call optstr.BuildStringHTML("�Ƿ�����������" , _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"), itemcdromdrive.MediaLoaded))
   Call optstr.BuildStringHTML("����" , itemcdromdrive.MediaType)
   Call optstr.BuildStringHTML("��Сģ����(�ֽ�)" , itemcdromdrive.MinBlockSize)
   Call optstr.BuildStringHTML("�Ƿ���Ҫ����" ,  _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"),  itemcdromdrive.NeedsCleaning))
   Call optstr.BuildStringHTML("������" , itemcdromdrive.TransferRate)
   Call optstr.BuildStringHTML("����" , itemcdromdrive.VolumeName)
   Call optstr.BuildStringHTML("�����ͷǲ���״̬", _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("Status"), itemcdromdrive.Status))
   Call optstr.BuildStringHTML("����" , itemcdromdrive.Caption)
   Call optstr.BuildStringHTML("����" , itemcdromdrive.Description)
   Call optstr.BuildStringHTML("��װ����" , itemcdromdrive.InstallDate)
   Call optstr.BuildStringHTML("---------------------" , "")
  Next

  optstr.SealHTML("����")

  GetCDROMDriveInfo = optstr.ReturnStrAndClear()
 End Function


    'ȡ�ü�����Ϣ
    'Win32_Keyboard ������װ�� Win32 ϵͳ�ϵļ���
 'λ�ã� //DZW/ROOT/CIMV2/CIM_ManagedSystemElement/CIM_LogicalElement/CIM_LogicalDevice/CIM_UserDevice/CIM_Keyboard
    Public Function GetKeyBoardInfo()
  Set keyboard = objWMI.instancesof("Win32_Keyboard") 
        
  For Each itemkeyboard In keyboard
      Call optstr.BuildStringHTML("����" , itemkeyboard.Name)
   Call optstr.BuildStringHTML("������" , itemkeyboard.DeviceID)
   Call optstr.BuildStringHTML("���弴��ID" , itemkeyboard.PNPDeviceID)
   Call optstr.BuildStringHTML("�Ƿ�����"  , _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"),  itemkeyboard.IsLocked))
   Call optstr.BuildStringHTML("���̵ĸ�ʽ�Ͳ���" , itemkeyboard.Layout)
   Call optstr.BuildStringHTML("���ܼ���Ŀ" , itemkeyboard.NumberOfFunctionKeys)
   Call optstr.BuildStringHTML("�����Ƿ�����Ӳ������" , _
   ocommonopt.GetEnumValue(objEnum.KeyBoradEnum("Password"), itemkeyboard.Password))
   Call optstr.BuildStringHTML("�����ͷǲ���״̬" , _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("Status"), itemkeyboard.Status))
   Call optstr.BuildStringHTML("����" , itemkeyboard.Caption)
   Call optstr.BuildStringHTML("����" , itemkeyboard.Description)
   Call optstr.BuildStringHTML("��װ����" , itemkeyboard.InstallDate)
  Next

     optstr.SealHTML("����")

  GetKeyBoardInfo = optstr.ReturnStrAndClear()
 End Function

 

    'ȡ�������Ϣ
    'Win32_PointingDevice ����������ָ���ѡ�� Win32 �����ϵͳ��ʾ�ϵ�����
 'λ�ã� //DZW/ROOT/CIMV2/CIM_ManagedSystemElement/CIM_LogicalElement/CIM_LogicalDevice/CIM_UserDevice/CIM_PointingDevice
    Public Function GetPointingDeviceInfo()
  Set pointingdevice = objWMI.instancesof("Win32_PointingDevice") 
        
  For Each itempointingdevice In pointingdevice
   Call optstr.BuildStringHTML("����" , itempointingdevice.Manufacturer)
   Call optstr.BuildStringHTML("����" , itempointingdevice.Name)
   Call optstr.BuildStringHTML("������" , itempointingdevice.DeviceID)
   Call optstr.BuildStringHTML("���弴��ID" , itempointingdevice.PNPDeviceID)
   Call optstr.BuildStringHTML("�Ƿ�����" , _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"),  itempointingdevice.IsLocked))
   Call optstr.BuildStringHTML("ָʾ�豸�Ľ�������" , _
   ocommonopt.GetEnumValue(objEnum.PointingDeviceEnum("DeviceInterface"), itempointingdevice.DeviceInterface))
   Call optstr.BuildStringHTML("��������" , _
   ocommonopt.GetEnumValue(objEnum.PointingDeviceEnum("Handedness"), itempointingdevice.Handedness))
   Call optstr.BuildStringHTML("��ָ���Ӳ���������" , itempointingdevice.HardwareType)
   Call optstr.BuildStringHTML("����.inf�ļ�������" , itempointingdevice.InfFileName)
   Call optstr.BuildStringHTML("����.inf �ļ��Ķ�" , itempointingdevice.InfSection)
   Call optstr.BuildStringHTML("��ť��" , itempointingdevice.NumberOfButtons)
   Call optstr.BuildStringHTML("���" , _
   ocommonopt.GetEnumValue(objEnum.PointingDeviceEnum("PointingType"), itempointingdevice.PointingType))
   Call optstr.BuildStringHTML("���ٷֱ���" , itempointingdevice.Resolution)
   Call optstr.BuildStringHTML("��ѯ������Ϣ������" , itempointingdevice.SampleRate)
   Call optstr.BuildStringHTML("�����ͷǲ���״̬" , _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("Status"), itempointingdevice.Status))
   Call optstr.BuildStringHTML("����" , itempointingdevice.Caption)
   Call optstr.BuildStringHTML("����" , itempointingdevice.Description)
   Call optstr.BuildStringHTML("��װ����" , itempointingdevice.InstallDate)
   Call optstr.BuildStringHTML("---------------------" , "")
  Next

     optstr.SealHTML("���")

  GetPointingDeviceInfo = optstr.ReturnStrAndClear()
 End Function

 

    'ȡ����ʾ����Ϣ
    'Win32_DesktopMonitor �����������ڼ����ϵͳ�ϵĿ���������ʾ�豸�ļ���������
 'λ�ã� //DZW/ROOT/CIMV2/CIM_ManagedSystemElement/CIM_LogicalElement/CIM_LogicalDevice/CIM_UserDevice/CIM_Display/CIM_DesktopMonitor
    Public Function GetDesktopMonitorInfo()
  Set desktopmonitor = objWMI.instancesof("Win32_DesktopMonitor")

  For Each itemdesktopmonitor In desktopmonitor
   If Not IsNull(itemdesktopmonitor.ScreenHeight) And Not IsNull(itemdesktopmonitor.ScreenWidth) Then
       'ע���˴���INDEX���� ԭ����
    'If itemdesktopmonitor.index <> 0 Then
     'Call optstr.BuildStringHTML("---------------------" , "")
    'End If

    Call optstr.BuildStringHTML("����" , itemdesktopmonitor.MonitorManufacturer)
    Call optstr.BuildStringHTML("����" , itemdesktopmonitor.Name)
    Call optstr.BuildStringHTML("������" , itemdesktopmonitor.DeviceID)
    Call optstr.BuildStringHTML("����������(MegaHertz)" , itemdesktopmonitor.Bandwidth)
    Call optstr.BuildStringHTML("���弴��ID" , itemdesktopmonitor.PNPDeviceID)
    Call optstr.BuildStringHTML("�Ƿ�����" , _
    ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"),  itemdesktopmonitor.IsLocked))
    Call optstr.BuildStringHTML("����������������CRT" , _
    ocommonopt.GetEnumValue(objEnum.DesktopMonitorEnum("DisplayType"),  itemdesktopmonitor.DisplayType))
    Call optstr.BuildStringHTML("������������" , itemdesktopmonitor.MonitorType)
    Call optstr.BuildStringHTML("X ��(ˮƽ����)�ķֱ���" , itemdesktopmonitor.PixelsPerXLogicalInch)
    Call optstr.BuildStringHTML("Y ��(������)�ķֱ���" , itemdesktopmonitor.PixelsPerYLogicalInch)
    Call optstr.BuildStringHTML("��Ļ�߶�" , itemdesktopmonitor.ScreenHeight)
    Call optstr.BuildStringHTML("��Ļ���" , itemdesktopmonitor.ScreenWidth)
    Call optstr.BuildStringHTML("�����ͷǲ���״̬" , _
    ocommonopt.GetEnumValue(objEnum.CommonEnum("Status"), itemdesktopmonitor.Status))
    Call optstr.BuildStringHTML("����" , itemdesktopmonitor.Caption)
    Call optstr.BuildStringHTML("����" , itemdesktopmonitor.Description)
    Call optstr.BuildStringHTML("��װ����" , itemdesktopmonitor.InstallDate)
   End if
  Next

     optstr.SealHTML("��ʾ��")

  GetDesktopMonitorInfo = optstr.ReturnStrAndClear()
 End Function

 

    'ȡ�ò���ϵͳ��Ϣ
    'Win32 �����в����ļ����ϵͳ
 'λ�ã� //DZW/ROOT/CIMV2/CIM_ManagedSystemElement/CIM_LogicalElement/CIM_System/CIM_ComputerSystem/CIM_UnitaryComputerSystem
 Public Function GetComputerSystemInfo()
  Set computersystem = objWMI.instancesof("win32_computersystem")

  For Each itemcomputersystem In computersystem
   Call optstr.BuildStringHTML("����ϵͳ����" , itemcomputersystem.Manufacturer)
   Call optstr.BuildStringHTML("��Ʒ����" , itemcomputersystem.Model)
   Call optstr.BuildStringHTML("�����ϵͳ����" , itemcomputersystem.Name)
   Call optstr.BuildStringHTML("���Ƹ�ʽ" , itemcomputersystem.NameFormat)
   Call optstr.BuildStringHTML("��ǰ��½�û�����" , itemcomputersystem.UserName)
   Call optstr.BuildStringHTML("����������" , itemcomputersystem.Workgroup)
   Call optstr.BuildStringHTML("����Ա����״̬" ,  _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("AdminPasswordStatus"), itemcomputersystem.AdminPasswordStatus))
   Call optstr.BuildStringHTML("ϵͳ�����Ƿ�������" ,  _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"), itemcomputersystem.AutomaticResetBootOption))
   Call optstr.BuildStringHTML("���������Ƿ����" ,  _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"), itemcomputersystem.AutomaticResetCapability))
   Call optstr.BuildStringHTML("����ѡ��߽�" , _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("BootOptionOnLimit"), itemcomputersystem.BootOptionOnLimit))
   Call optstr.BuildStringHTML("��ʱ����ѡ��" , _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("BootOptionOnLimit"), itemcomputersystem.BootOptionOnWatchDog))
   Call optstr.BuildStringHTML("�Ƿ�֧������ROM" ,  _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"), itemcomputersystem.BootROMSupported))
   Call optstr.BuildStringHTML("ϵͳ����״̬" , _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("BootupState"), itemcomputersystem.BootupState))
   Call optstr.BuildStringHTML("�������״̬" , _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("ChassisBootupState"), itemcomputersystem.ChassisBootupState))
   Call optstr.BuildStringHTML("��һ�����������Դ״̬"  , _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("PowerSupplyState"), itemcomputersystem.PowerSupplyState))
   Call optstr.BuildStringHTML("ʱ��ƫ����(��ǰʱ��)" , itemcomputersystem.CurrentTimeZone)
   Call optstr.BuildStringHTML("��ʱֵ�Ƿ���Ч" ,  _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"), itemcomputersystem.DaylightInEffect))
   Call optstr.BuildStringHTML("�Ƿ��Ͽ���ʱ��" ,  _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"), itemcomputersystem.EnableDaylightSavingsTime))
   Call optstr.BuildStringHTML("����������" , itemcomputersystem.Domain)
   Call optstr.BuildStringHTML("���ɫ" , _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("DomainRole"), itemcomputersystem.DomainRole))
   Call optstr.BuildStringHTML("�Ƿ���ں���(IR)�˿�" ,  _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"), itemcomputersystem.InfraredSupported))
   Call optstr.BuildStringHTML("��ʼ����Ϣ" , itemcomputersystem.InitialLoadInfo)
   Call optstr.BuildStringHTML("���谴ť��ȫ����" , _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("FrontPanelResetStatus"), itemcomputersystem.FrontPanelResetStatus))
   Call optstr.BuildStringHTML("��������״̬��ȫ����" , _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("FrontPanelResetStatus"), itemcomputersystem.KeyboardPasswordStatus))
   Call optstr.BuildStringHTML("ͨ�����밲ȫ����"  , _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("FrontPanelResetStatus"), itemcomputersystem.PowerOnPasswordStatus))
   Call optstr.BuildStringHTML("���������ģʽ����״̬" ,  _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"), itemcomputersystem.NetworkServerModeEnabled))
   Call optstr.BuildStringHTML("cpu����" , itemcomputersystem.NumberOfProcessors)
   Call optstr.BuildStringHTML("�ض���Դ����" , _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("PowerManagementCapabilities"), itemcomputersystem.PowerManagementCapabilities))
   Call optstr.BuildStringHTML("�Ƿ�֧�ֵ�Դ����" ,  _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"), itemcomputersystem.PowerManagementSupported))
   Call optstr.BuildStringHTML("��Դ״̬" , _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("PowerState"), itemcomputersystem.PowerState))
   Call optstr.BuildStringHTML("ϵͳ��������ϵ��Ϣ" , itemcomputersystem.PrimaryOwnerContact)
   Call optstr.BuildStringHTML("ϵͳ������" , itemcomputersystem.PrimaryOwnerName)
   Call optstr.BuildStringHTML("Ӳ����������" , _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("ChassisBootupState"), itemcomputersystem.ResetCapability))
   Call optstr.BuildStringHTML("�ϴ��ֶ��������Զ�������" , itemcomputersystem.ResetCount)
   Call optstr.BuildStringHTML("ϵͳ������" , itemcomputersystem.ResetLimit)
   'Call optstr.BuildStringHTML("ϵͳ��IT�����еĽ�ɫ" , itemcomputersystem.Roles)
   Call optstr.BuildStringHTML("��ǰ״̬" ,  _
   ocommonopt.GetEnumValue(objEnum.CommonEnum("PoweredOn"), itemcomputersystem.Status))
   Call optstr.BuildStringHTML("�����ӳ�ʱ��" , itemcomputersystem.SystemStartupDelay)
   Call optstr.BuildStringHTML("ϵͳ����" , itemcomputersystem.SystemType)
   Call optstr.BuildStringHTML("��һ����������¶�״̬" , _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("ChassisBootupState"), itemcomputersystem.ThermalState))
   Call optstr.BuildStringHTML("ϵͳ�ӵ��¼�" , _
   ocommonopt.GetEnumValue(objEnum.ComputerSystemEnum("WakeUpType"),  itemcomputersystem.WakeUpType))
   Call optstr.BuildStringHTML("�����ڴ���ܴ�С(M)" , Round((itemcomputersystem.TotalPhysicalMemory/1024^2),2))
   Call optstr.BuildStringHTML("����" , itemcomputersystem.Caption)
   Call optstr.BuildStringHTML("����" , itemcomputersystem.Description)
   Call optstr.BuildStringHTML("��װ����" , itemcomputersystem.InstallDate)
  Next

  optstr.SealHTML("����ϵͳ")

  GetComputerSystemInfo = optstr.ReturnStrAndClear()
 End Function

 

    'ȡ�ý�����Ϣ
    'Win32_Process �������� Win32 ϵͳ�ϵĽ���
 'λ�ã� //DZW/ROOT/CIMV2/CIM_ManagedSystemElement/CIM_LogicalElement/CIM_Process
 'Win_Process��3��
Public Function GetProcessInfo()
  Set process = objWMI.instancesof("Win32_Process")
  	Call optstr.BuildStringHTMLForBeginTR()
    Call optstr.BuildStringHTMLForProcess("����" )
    Call optstr.BuildStringHTMLForProcess("������������������" )
    Call optstr.BuildStringHTMLForProcess("��ִ���ļ�·��" )
    'Call optstr.BuildStringHTMLForProcess("���̵Ĳ�������" , _
    'ocommonopt.GetEnumValue(objEnum.ProcessEnum("ExecutionState"),  itemprocess.ExecutionState))
    Call optstr.BuildStringHTMLForProcess("���̾��" )
    Call optstr.BuildStringHTMLForProcess("�������̴߳򿪾������" )
    Call optstr.BuildStringHTMLForProcess("����ģʽ��ʱ��(100����)" )
    Call optstr.BuildStringHTMLForProcess("���������С" )
    Call optstr.BuildStringHTMLForProcess("��С��������С" )
    Call optstr.BuildStringHTMLForProcess("�������" )
    Call optstr.BuildStringHTMLForProcess("������ϵͳ����" )
    Call optstr.BuildStringHTMLForProcess("����д֮���I/O������" )
    Call optstr.BuildStringHTMLForProcess("����д֮������ݴ�����" )
    Call optstr.BuildStringHTMLForProcess("ҳ������Ŀ" )
    Call optstr.BuildStringHTMLForProcess("��ǰʹ�õ�ҳ���ļ��հ���" )
    Call optstr.BuildStringHTMLForProcess("����������̵��Ǹ����̵�Ψһ��ʶ��" )
    Call optstr.BuildStringHTMLForProcess("����ҳ���ļ��հ�" )
    Call optstr.BuildStringHTMLForProcess("��ǰʹ�õ�ҳ���ļ��հ���" )
    Call optstr.BuildStringHTMLForProcess("��������ַ�ռ�" )
    Call optstr.BuildStringHTMLForProcess("�߷幤������С" )
    Call optstr.BuildStringHTMLForProcess("���ȼ�" )
    Call optstr.BuildStringHTMLForProcess("ָ�ɵĽ��̵�ǰҳ��" )
    Call optstr.BuildStringHTMLForProcess("ȫ�ֽ���ʶ���" )
    Call optstr.BuildStringHTMLForProcess("�Ƿ�ҳ��ʹ�õ��޶���Ŀ" )
    Call optstr.BuildStringHTMLForProcess("��ҳ��ʹ�õ��޶���Ŀ" )
    Call optstr.BuildStringHTMLForProcess("�Ƿ�ҳ��ʹ�õĸ߷��޶���Ŀ" )
    Call optstr.BuildStringHTMLForProcess("��ҳ��ʹ�õĸ߷��޶���Ŀ" )
    Call optstr.BuildStringHTMLForProcess("��ȡ��������" )
    Call optstr.BuildStringHTMLForProcess("���ݶ�ȡ��" )
    Call optstr.BuildStringHTMLForProcess("�Ự����ָ����Ωһ��ʶ��" )
    Call optstr.BuildStringHTMLForProcess("ֹͣ�����ʱ��" )
    Call optstr.BuildStringHTMLForProcess("��߳���Ŀ" )
    Call optstr.BuildStringHTMLForProcess("�û�ģʽ�µ�ʱ��(100����)" )
    Call optstr.BuildStringHTMLForProcess("�����ַ�ռ���ֽڴ�С" )
    Call optstr.BuildStringHTMLForProcess("Windows �汾" )
    Call optstr.BuildStringHTMLForProcess("�ڴ���(byte)" )
    Call optstr.BuildStringHTMLForProcess("д���������" )
    Call optstr.BuildStringHTMLForProcess("д���ȡ��" )
    Call optstr.BuildStringHTMLForProcess("�Ự����ָ����Ωһ��ʶ��" )
    Call optstr.BuildStringHTMLForProcess("�Ự����ָ����Ωһ��ʶ��" )   
    Call optstr.BuildStringHTMLForProcess("�����ͷǲ���״̬" )
    Call optstr.BuildStringHTMLForProcess("����" )
    Call optstr.BuildStringHTMLForProcess("����" )
    Call optstr.BuildStringHTMLForProcess("��װ����" )
	Call optstr.BuildStringHTMLForEndTR()

  For Each itemprocess In process
  
	Call optstr.BuildStringHTMLForBeginTR()
	
    Call optstr.BuildStringHTMLForProcess( itemprocess.Name)
    Call optstr.BuildStringHTMLForProcess( itemprocess.CommandLine)
    Call optstr.BuildStringHTMLForProcess( itemprocess.ExecutablePath)
    'Call optstr.BuildStringHTMLForProcess( _
    'ocommonopt.GetEnumValue(objEnum.ProcessEnum("ExecutionState"),  itemprocess.ExecutionState))
    Call optstr.BuildStringHTMLForProcess( itemprocess.Handle)
    Call optstr.BuildStringHTMLForProcess( itemprocess.HandleCount)
    Call optstr.BuildStringHTMLForProcess( itemprocess.KernelModeTime)
    Call optstr.BuildStringHTMLForProcess( itemprocess.MaximumWorkingSetSize)
    Call optstr.BuildStringHTMLForProcess( itemprocess.MinimumWorkingSetSize)
    Call optstr.BuildStringHTMLForProcess( itemprocess.OSCreationClassName)
    Call optstr.BuildStringHTMLForProcess( itemprocess.OSName)
    Call optstr.BuildStringHTMLForProcess( itemprocess.OtherOperationCount)
    Call optstr.BuildStringHTMLForProcess( itemprocess.OtherTransferCount)
    Call optstr.BuildStringHTMLForProcess( itemprocess.PageFaults)
    Call optstr.BuildStringHTMLForProcess( itemprocess.PageFileUsage)
    Call optstr.BuildStringHTMLForProcess( itemprocess.ParentProcessId)
    Call optstr.BuildStringHTMLForProcess( itemprocess.PeakPageFileUsage)
    Call optstr.BuildStringHTMLForProcess( itemprocess.PeakVirtualSize)
    Call optstr.BuildStringHTMLForProcess( itemprocess.PageFileUsage)
    Call optstr.BuildStringHTMLForProcess( itemprocess.PeakWorkingSetSize)
    Call optstr.BuildStringHTMLForProcess( itemprocess.Priority)
    Call optstr.BuildStringHTMLForProcess( itemprocess.PrivatePageCount)
    Call optstr.BuildStringHTMLForProcess( itemprocess.ProcessId)
    Call optstr.BuildStringHTMLForProcess( itemprocess.QuotaNonPagedPoolUsage)
    Call optstr.BuildStringHTMLForProcess( itemprocess.QuotaPagedPoolUsage)
    Call optstr.BuildStringHTMLForProcess( itemprocess.QuotaPeakNonPagedPoolUsage)
    Call optstr.BuildStringHTMLForProcess( itemprocess.QuotaPeakPagedPoolUsage)
    Call optstr.BuildStringHTMLForProcess( itemprocess.ReadOperationCount)
    Call optstr.BuildStringHTMLForProcess( itemprocess.ReadTransferCount)
    Call optstr.BuildStringHTMLForProcess( itemprocess.SessionId)
    Call optstr.BuildStringHTMLForProcess( itemprocess.TerminationDate)
    Call optstr.BuildStringHTMLForProcess( itemprocess.ThreadCount)
    Call optstr.BuildStringHTMLForProcess( itemprocess.UserModeTime)
    Call optstr.BuildStringHTMLForProcess( itemprocess.VirtualSize)
    Call optstr.BuildStringHTMLForProcess( itemprocess.WindowsVersion)
    Call optstr.BuildStringHTMLForProcess( itemprocess.WorkingSetSize)
    Call optstr.BuildStringHTMLForProcess( itemprocess.WriteOperationCount)
    Call optstr.BuildStringHTMLForProcess( itemprocess.WriteTransferCount)
    Call optstr.BuildStringHTMLForProcess( itemprocess.SessionId)
    Call optstr.BuildStringHTMLForProcess( itemprocess.SessionId)   
    Call optstr.BuildStringHTMLForProcess( _
    ocommonopt.GetEnumValue(objEnum.CommonEnum("Status"), itemprocess.Status))
    Call optstr.BuildStringHTMLForProcess( itemprocess.Caption)
    Call optstr.BuildStringHTMLForProcess( itemprocess.Description)
    Call optstr.BuildStringHTMLForProcess( itemprocess.InstallDate)
	Call optstr.BuildStringHTMLForEndTR()
   ' Call optstr.BuildStringHTMLForProcess("---------------------" , "")
	
	
'    Call optstr.BuildStringHTML("����" , itemprocess.Name)
'    Call optstr.BuildStringHTML("������������������" , itemprocess.CommandLine)
'    Call optstr.BuildStringHTML("��ִ���ļ�·��" , itemprocess.ExecutablePath)
'    'Call optstr.BuildStringHTML("���̵Ĳ�������" , _
'    'ocommonopt.GetEnumValue(objEnum.ProcessEnum("ExecutionState"),  itemprocess.ExecutionState))
'    Call optstr.BuildStringHTML("���̾��" , itemprocess.Handle)
'    Call optstr.BuildStringHTML("�������̴߳򿪾������" , itemprocess.HandleCount)
'    Call optstr.BuildStringHTML("����ģʽ��ʱ��(100����)" , itemprocess.KernelModeTime)
'    Call optstr.BuildStringHTML("���������С" , itemprocess.MaximumWorkingSetSize)
'    Call optstr.BuildStringHTML("��С��������С" , itemprocess.MinimumWorkingSetSize)
'    Call optstr.BuildStringHTML("�������" , itemprocess.OSCreationClassName)
'    Call optstr.BuildStringHTML("������ϵͳ����" , itemprocess.OSName)
'    Call optstr.BuildStringHTML("����д֮���I/O������" , itemprocess.OtherOperationCount)
'    Call optstr.BuildStringHTML("����д֮������ݴ�����" , itemprocess.OtherTransferCount)
'    Call optstr.BuildStringHTML("ҳ������Ŀ" , itemprocess.PageFaults)
'    Call optstr.BuildStringHTML("��ǰʹ�õ�ҳ���ļ��հ���" , itemprocess.PageFileUsage)
'    Call optstr.BuildStringHTML("����������̵��Ǹ����̵�Ψһ��ʶ��" , itemprocess.ParentProcessId)
'    Call optstr.BuildStringHTML("����ҳ���ļ��հ�" , itemprocess.PeakPageFileUsage)
'    Call optstr.BuildStringHTML("��ǰʹ�õ�ҳ���ļ��հ���" , itemprocess.PeakVirtualSize)
'    Call optstr.BuildStringHTML("��������ַ�ռ�" , itemprocess.PageFileUsage)
'    Call optstr.BuildStringHTML("�߷幤������С" , itemprocess.PeakWorkingSetSize)
'    Call optstr.BuildStringHTML("���ȼ�" , itemprocess.Priority)
'    Call optstr.BuildStringHTML("ָ�ɵĽ��̵�ǰҳ��" , itemprocess.PrivatePageCount)
'    Call optstr.BuildStringHTML("ȫ�ֽ���ʶ���" , itemprocess.ProcessId)
'    Call optstr.BuildStringHTML("�Ƿ�ҳ��ʹ�õ��޶���Ŀ" , itemprocess.QuotaNonPagedPoolUsage)
'    Call optstr.BuildStringHTML("��ҳ��ʹ�õ��޶���Ŀ" , itemprocess.QuotaPagedPoolUsage)
'    Call optstr.BuildStringHTML("�Ƿ�ҳ��ʹ�õĸ߷��޶���Ŀ" , itemprocess.QuotaPeakNonPagedPoolUsage)
'    Call optstr.BuildStringHTML("��ҳ��ʹ�õĸ߷��޶���Ŀ" , itemprocess.QuotaPeakPagedPoolUsage)
'    Call optstr.BuildStringHTML("��ȡ��������" , itemprocess.ReadOperationCount)
'    Call optstr.BuildStringHTML("���ݶ�ȡ��" , itemprocess.ReadTransferCount)
'    Call optstr.BuildStringHTML("�Ự����ָ����Ωһ��ʶ��" , itemprocess.SessionId)
'    Call optstr.BuildStringHTML("ֹͣ�����ʱ��" , itemprocess.TerminationDate)
'    Call optstr.BuildStringHTML("��߳���Ŀ" , itemprocess.ThreadCount)
'    Call optstr.BuildStringHTML("�û�ģʽ�µ�ʱ��(100����)" , itemprocess.UserModeTime)
'    Call optstr.BuildStringHTML("�����ַ�ռ���ֽڴ�С" , itemprocess.VirtualSize)
'    Call optstr.BuildStringHTML("Windows �汾" , itemprocess.WindowsVersion)
'    Call optstr.BuildStringHTML("�ڴ���(byte)" , itemprocess.WorkingSetSize)
'    Call optstr.BuildStringHTML("д���������" , itemprocess.WriteOperationCount)
'    Call optstr.BuildStringHTML("д���ȡ��" , itemprocess.WriteTransferCount)
'    Call optstr.BuildStringHTML("�Ự����ָ����Ωһ��ʶ��" , itemprocess.SessionId)
'    Call optstr.BuildStringHTML("�Ự����ָ����Ωһ��ʶ��" , itemprocess.SessionId)   
'    Call optstr.BuildStringHTML("�����ͷǲ���״̬" , _
'    ocommonopt.GetEnumValue(objEnum.CommonEnum("Status"), itemprocess.Status))
'    Call optstr.BuildStringHTML("����" , itemprocess.Caption)
'    Call optstr.BuildStringHTML("����" , itemprocess.Description)
'    Call optstr.BuildStringHTML("��װ����" , itemprocess.InstallDate)
'    Call optstr.BuildStringHTML("---------------------" , "")

  Next

     optstr.SealHTML("����")

  GetProcessInfo = optstr.ReturnStrAndClear()
 End Function
End Class

 

'''
'''ȡ�õ��Լ����Ϣ
'''���� ��computerName(�������������)
Public Function GetComputerInfo(computerName)
    Dim objWIMInfo, strComputerInfo

    Set objWIMInfo = new WMIInfo
    objWIMInfo.computerName = computerName

    strComputerInfo = strComputerInfo + objWIMInfo.GetBaseBoardInfo() 'ȡ��������Ϣ
    strComputerInfo = strComputerInfo + objWIMInfo.GetCPUInfo() 'ȡ��CPU��Ϣ
    strComputerInfo = strComputerInfo + objWIMInfo.GetTemperatureInfo 'ȡ���¶���Ϣ
    strComputerInfo = strComputerInfo + objWIMInfo.GetMemoryInfo() 'ȡ���ڴ���Ϣ
    strComputerInfo = strComputerInfo + objWIMInfo.GetDiskDriveInfo() 'ȡ��Ӳ����Ϣ
    strComputerInfo = strComputerInfo + objWIMInfo.GetCDROMDriveInfo()'ȡ�ù�����Ϣ
    strComputerInfo = strComputerInfo + objWIMInfo.GetKeyBoardInfo() 'ȡ�ü�����Ϣ
    strComputerInfo = strComputerInfo + objWIMInfo.GetPointingDeviceInfo() 'ȡ�������Ϣ
    strComputerInfo = strComputerInfo + objWIMInfo.GetDesktopMonitorInfo() 'ȡ����ʾ����Ϣ
    strComputerInfo = strComputerInfo + objWIMInfo.GetComputerSystemInfo()'ȡ�ò���ϵͳ��Ϣ
    strComputerInfo = strComputerInfo + objWIMInfo.GetProcessInfo()'ȡ�ý�����Ϣ
    GetComputerInfo = strComputerInfo

    Set objWIMInfo = Nothing
End Function


Public Sub Main()
    Dim iehtml
    Dim infoHTML '����ʾ�ĵ��Լ����Ϣ
    'Set iehtml = new IEHTML
	

    'infoHTML = "<table>"
    'infoHTML = infoHTML & "<tr align = 'center'><td colSpan = '2'>��ã�</td></tr></table>"
    
	'iehtml.WriteInfo(GetComputerInfo("."))
	
	Dim fso
	Set fso = CreateObject("Scripting.FileSystemObject")
	
	Dim fwite
	set   fwite=fso.CreateTextFile("c:\sony\Machine_Info.htm",true)  
	Dim str
	Dim ret
	ret = GetComputerInfo(".") 
	str = "<HTML>" & _
"<HEAD>" & _
"<TITLE>������Ϣ�����</TITLE>" & _
	"<style type='text/css'>" & _
                           "body {" & _
                           "    color: purple;" & _
                           "    background-color: #d8da3d}" & _
                           "table {" & _
                           "    border-collapse:separate;" & _
                           "    bgcolor : #FFC080;" & _
                           "    border: 1px dotted gray;" & _
                           "    width : 100%}" & _
                           "td {" & _
                           "    bgcolor : #EFE7D6td}" & _
                           "</style>" & _
"</HEAD>" & _
"<BODY>" & _
"<Form>" & _
"<div align = 'center'>" & _
"<strong>������Ϣ�����Ϣ�б�</strong>" & _
"</div>" & _
"</br></br>" & _
"<div id = 'divInfo'>" & _			
		ret & _
			"</div>"  & _
"</Form>" & _
"</BODY>" & _
"</HTML>" 
	
	
	fwite.write str
	fwite.close 
	
    'Set iehtml = nothing
    'MsgBox iehtml.IE.Document.documentElement.innerHTML
End Sub

Call Main