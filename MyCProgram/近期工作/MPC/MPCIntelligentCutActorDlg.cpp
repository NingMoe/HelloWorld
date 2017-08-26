// MPCIntelligentCutActorDlg.cpp : ʵ���ļ�
//

#include "stdafx.h"
#include "MPCIntelligentCutActor.h"
#include "MPCIntelligentCutActorDlg.h"
#include "DlgSet.h"
#include "TransBaseThread.h"
#include "locale.h"
#include "IntelligentCutThread.h"
#include "SEDLIntelligentCutThread.h"


#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// ����Ӧ�ó��򡰹��ڡ��˵���� CAboutDlg �Ի���

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// �Ի�������
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV ֧��

// ʵ��
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
END_MESSAGE_MAP()


// CMPCIntelligentCutActorDlg �Ի���




CMPCIntelligentCutActorDlg::CMPCIntelligentCutActorDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CMPCIntelligentCutActorDlg::IDD, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);

	m_strTaskStatus			= _T("��ִ�У�0 ���ɹ���0 ʧ�ܣ�0 ��");
	m_strHiveText			= _T("");
	//m_bExitAtNext			= FALSE;
	m_nTaskFinished			= 0;
	m_nTaskSucceed			= 0;
	m_nTaskID				= 0;
	m_strErrorInfo			= _T("");
	m_strDispIP				= _T("");
	m_strLocalHostIP		= _T("");

	m_arrTaskInfo.RemoveAll();
	m_strDispatchMQ			= _T("");
	m_bWriteLog				= FALSE;
	m_arrTaskInfo.RemoveAll();
	m_arrMediaFile.RemoveAll();
	m_arrMediaFileOut.RemoveAll();
	m_eResult				= MPC_RESULTTYPE_NOTSUPPORT;
	m_bExit					= FALSE;
	m_nPercentage			= 0;
	m_ulJobID				= 0;
	m_strSysRootPath		= _T("");

	m_bWorkOver = FALSE;
	m_bWorkStatus = 0;

	m_strObjGroupType		= _T("");
	m_strObjMediaType		= _T("");

	m_nUpdateStatus			= 0;
}

void CMPCIntelligentCutActorDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);

	DDX_Control(pDX, IDC_CURRENTTASK, m_lcCurrentTask);
	DDX_Control(pDX, IDC_HISTORYTASK, m_lcHistoryTask);
}

BEGIN_MESSAGE_MAP(CMPCIntelligentCutActorDlg, CDialog)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	//}}AFX_MSG_MAP
	ON_WM_DESTROY()
	ON_WM_TIMER()
	ON_BN_CLICKED(IDCCLEAR, OnBnClickedClear)
	ON_BN_CLICKED(IDCCLOSE, OnBnClickedClose)
	ON_MESSAGE(WM_GWSHUTDOWN, OnDispatchShutdown)
	ON_MESSAGE(WM_MSG_UPDATE, OnActorStatusUpdate)
	//}}AFX_MSG_MAP
	ON_BN_CLICKED(IDCSET, &CMPCIntelligentCutActorDlg::OnBnClickedSet)
END_MESSAGE_MAP()


// CMPCIntelligentCutActorDlg ��Ϣ�������

BOOL CMPCIntelligentCutActorDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// ��������...���˵�����ӵ�ϵͳ�˵��С�

	// IDM_ABOUTBOX ������ϵͳ���Χ�ڡ�
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}
	
	// ���ô˶Ի����ͼ�ꡣ��Ӧ�ó��������ڲ��ǶԻ���ʱ����ܽ��Զ�
	//  ִ�д˲���
	SetIcon(m_hIcon, TRUE);			// ���ô�ͼ��
	SetIcon(m_hIcon, FALSE);		// ����Сͼ��

	// TODO: �ڴ���Ӷ���ĳ�ʼ������

	CRect rect;
	GetClientRect(&rect);
	m_szWnd.cx		= rect.Width();
	m_szWnd.cy		= rect.Height();
	m_fScan			= 0.7f;

	InitFace();
	m_nTaskID		= 1;

	if(!GetConfigInfo())
	{
		MessageBox(_T("����ȷ����MPCIntelligentCutActor����������"), _T("MPCIntelligentCutActor"), MB_ICONWARNING | MB_OK);
		EndDialog(-1);
		return FALSE;
	}

	if(!RegisterActor())
	{
		MessageBox(_T("ע��MPCIntelligentCutActorʧ�ܣ�ȷ�����ú�״̬��ȷ��"), _T("MPCIntelligentCutActor"), MB_ICONWARNING | MB_OK);
		EndDialog(-1);
		return FALSE;
	}

	TCHAR tcValue[_MAX_PATH];
	::GetModuleFileName(NULL, tcValue, _MAX_PATH);
	size_t	iLen		= _tcslen(tcValue);
	tcValue[iLen - 3]	= _T('l');
	tcValue[iLen - 2]	= _T('o');
	tcValue[iLen - 1]	= _T('g');
	setlocale(LC_ALL, "");

	MPC_FRAMERESULT eResult(MPC_FRAMEERROR_NOERROR);
	eResult	= m_cSvcFrame.InitSnmp();

	//�������ܴ���������ȡ�ӿ�ָ��
	GetCurrentDirectory(MAX_PATH, tcValue);
	CString strDir  = tcValue;
	CIntelligentCutThread::LoadIAPlugin(strDir);
	CSEDLIntelligentCutThread::LoadIAPlugin(strDir);

	return TRUE;  // ���ǽ��������õ��ؼ������򷵻� TRUE
}

void CMPCIntelligentCutActorDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// �����Ի��������С����ť������Ҫ����Ĵ���
//  �����Ƹ�ͼ�ꡣ����ʹ���ĵ�/��ͼģ�͵� MFC Ӧ�ó���
//  �⽫�ɿ���Զ���ɡ�

void CMPCIntelligentCutActorDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // ���ڻ��Ƶ��豸������

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// ʹͼ���ڹ����������о���
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// ����ͼ��
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

//���û��϶���С������ʱϵͳ���ô˺���ȡ�ù��
//��ʾ��
HCURSOR CMPCIntelligentCutActorDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}

void CMPCIntelligentCutActorDlg::OnSize(UINT nType, int cx, int cy)
{

	if(cx < 200)cx	= 200;
	if(cy < 400)cy	= 400;

	CDialog::OnSize(nType, cx, cy);

	if(nType == SIZE_MAXHIDE || nType == SIZE_MINIMIZED)
		return;

	int		nOffsetX = cx - m_szWnd.cx;
	int		nOffsetY = cy - m_szWnd.cy;
	CRect	rect;
	int		nHeight	= (int)((float)nOffsetY * m_fScan);

	m_szWnd			= CSize(cx, cy);
	if(m_lcCurrentTask.GetSafeHwnd() == NULL)
		return;
	m_lcCurrentTask.GetParent()->GetParent()->GetWindowRect(rect);
	ScreenToClient(rect);
	m_lcCurrentTask.GetParent()->GetParent()->SetWindowPos(NULL, 0, 0, rect.Width() + nOffsetX, rect.Height() + nOffsetY - nHeight, SWP_NOZORDER|SWP_NOMOVE);

	m_lcHistoryTask.GetParent()->GetParent()->GetWindowRect(rect);
	ScreenToClient(rect);
	m_lcHistoryTask.GetParent()->GetParent()->SetWindowPos(NULL, rect.left, rect.top + nOffsetY - nHeight, rect.Width() + nOffsetX, rect.Height() + nHeight, SWP_NOZORDER);
	GetDlgItem(IDC_HISTORYTASK_LABEL)->GetWindowRect(&rect);
	ScreenToClient(&rect);
	GetDlgItem(IDC_HISTORYTASK_LABEL)->SetWindowPos(NULL, rect.left, rect.top + nOffsetY - nHeight, 0, 0, SWP_NOSIZE | SWP_NOZORDER);

	HWND		hWnd;
	TCHAR		lpszClassName[256];
	memset(lpszClassName, 0, sizeof(TCHAR) * 256);
	hWnd		= ::GetWindow(m_hWnd,GW_CHILD);
	for(;hWnd; hWnd = ::GetWindow(hWnd,GW_HWNDNEXT))
	{
		::GetClassName(hWnd,lpszClassName,256);
		if(_tcsncmp(lpszClassName,_T("Button"),6) == 0)
		{
			::GetWindowRect(hWnd,rect);
			ScreenToClient(rect);
			::SetWindowPos(hWnd, NULL, rect.left + nOffsetX, rect.top + nOffsetY, 0, 0, SWP_NOZORDER | SWP_NOSIZE);
			::RedrawWindow(hWnd, NULL, NULL, RDW_INVALIDATE | RDW_UPDATENOW);
		}
	}

	GetDlgItem(IDC_STATUSBAR)->GetWindowRect(&rect);
	ScreenToClient(&rect);
	GetDlgItem(IDC_STATUSBAR)->SetWindowPos(NULL, rect.left, rect.top + nOffsetY, rect.Width() + nOffsetX, rect.Height(), SWP_NOZORDER);

}

void CMPCIntelligentCutActorDlg::OnDestroy()
{
	ClearData();


	CDialog::OnDestroy();
}

void CMPCIntelligentCutActorDlg::InitFace()
{

	m_lcCurrentTask.InsertColumn(0, _T("ID#"), LVCFMT_LEFT, 60);
	m_lcCurrentTask.InsertColumn(1, _T("��������"), LVCFMT_LEFT, 200);
	m_lcCurrentTask.InsertColumn(2, _T("��������"), LVCFMT_LEFT, 80);
	m_lcCurrentTask.InsertColumn(3, _T("��ʼʱ��"), LVCFMT_LEFT, 130);
	m_lcCurrentTask.InsertColumn(4, _T("�������"), LVCFMT_LEFT, 70);
	m_lcCurrentTask.InsertColumn(5, _T("����״̬"), LVCFMT_LEFT, 120);
	m_lcCurrentTask.InsertColumn(6, _T("�������"), LVCFMT_LEFT, 65);
	m_lcCurrentTask.InsertColumn(7, _T("�������"), LVCFMT_LEFT, 240);

	m_lsImage.Create(12,12, ILC_COLOR32, 2, 1);
	m_lsImage.Add(AfxGetApp()->LoadIcon(IDI_ICON_RUN));
	m_lsImage.Add(AfxGetApp()->LoadIcon(IDI_ICON_PAUSE));

	m_lcCurrentTask.SetImageList(&m_lsImage, LVSIL_SMALL);
#define LVS_EX_BORDERSELECT     0x00008000 // border selection style instead of highlight
	m_lcCurrentTask.SetExtendedStyle(m_lcCurrentTask.GetExtendedStyle() | LVS_EX_BORDERSELECT | LVS_EX_FLATSB | LVS_EX_FULLROWSELECT /*| LVS_EX_GRIDLINES*/ | LVS_EX_SUBITEMIMAGES);

	m_lcHistoryTask.InsertColumn(0, _T("ID#"), LVCFMT_LEFT, 60);
	m_lcHistoryTask.InsertColumn(1, _T("��������"), LVCFMT_LEFT, 200);
	m_lcHistoryTask.InsertColumn(2, _T("��������"), LVCFMT_LEFT, 80);
	m_lcHistoryTask.InsertColumn(3, _T("��ʼʱ��"), LVCFMT_LEFT, 130);
	m_lcHistoryTask.InsertColumn(4, _T("����ʱ��"), LVCFMT_LEFT, 130);
	m_lcHistoryTask.InsertColumn(5, _T("������"), LVCFMT_LEFT, 80);
	m_lcHistoryTask.InsertColumn(6, _T("����״̬"), LVCFMT_LEFT, 120);
	m_lcHistoryTask.InsertColumn(7, _T("�������"), LVCFMT_LEFT, 65);
	m_lcHistoryTask.InsertColumn(8, _T("�������"), LVCFMT_LEFT, 240);

	m_lcHistoryTask.SetExtendedStyle(m_lcHistoryTask.GetExtendedStyle() | LVS_EX_FLATSB | LVS_EX_FULLROWSELECT /*| LVS_EX_GRIDLINES*/);
}

BOOL CMPCIntelligentCutActorDlg::GetConfigInfo()
{
	TCHAR tcValue[_MAX_PATH];
	::GetModuleFileName(NULL, tcValue, _MAX_PATH);
	size_t	iLen		= _tcslen(tcValue);
	tcValue[iLen - 3]	= _T('i');
	tcValue[iLen - 2]	= _T('n');
	tcValue[iLen - 1]	= _T('i');
	CString strIniPath	= tcValue;

	TCHAR  tcBaseValue[1024];
	::GetPrivateProfileString(_T("BaseSetting"), _T("DispatchIP"), _T(""), tcBaseValue, 1024, (LPCTSTR)strIniPath);
	m_strDispIP			= tcBaseValue;
	::GetPrivateProfileString(_T("BaseSetting"), _T("LocalHostIP"), _T(""), tcBaseValue, 1024, (LPCTSTR)strIniPath);
	m_strLocalHostIP			= tcBaseValue;
	::GetPrivateProfileString(_T("BaseSetting"), _T("SystemRootPath"), _T(""), tcBaseValue, 1024, (LPCTSTR)strIniPath);
	m_strSysRootPath	= tcBaseValue;

	if(m_strDispIP.IsEmpty() || m_strLocalHostIP.IsEmpty())
	{
		CDlgSet dlg;
		dlg.SetConfig(m_strDispIP, m_strLocalHostIP, m_strSysRootPath);
		if(dlg.DoModal()  == IDOK)
		{
			dlg.GetConfig(m_strDispIP, m_strLocalHostIP, m_strSysRootPath);

			TCHAR tcValue[_MAX_PATH];
			::GetModuleFileName(NULL, tcValue, _MAX_PATH);
			size_t	iLen		= _tcslen(tcValue);
			tcValue[iLen - 3]	= _T('i');
			tcValue[iLen - 2]	= _T('n');
			tcValue[iLen - 1]	= _T('i');
			CString strIniPath	= tcValue;

			::WritePrivateProfileString(_T("BaseSetting"), _T("DispatchIP"), (LPCTSTR)m_strDispIP, (LPCTSTR)strIniPath);
			::WritePrivateProfileString(_T("BaseSetting"), _T("LocalHostIP"), (LPCTSTR)m_strLocalHostIP, (LPCTSTR)strIniPath);
			::WritePrivateProfileString(_T("BaseSetting"), _T("SystemRootPath"), (LPCTSTR)m_strSysRootPath, (LPCTSTR)strIniPath);

			MessageBox(_T("����MPCIntelligentCutActorӦ�����ã�"), _T("MPCIntelligentCutActor"), MB_ICONWARNING | MB_OK);

			m_bExit		= TRUE;
			ClearData();
			char		tcExe[1024];
			sprintf_s(tcExe, "mdkregister.exe -t %d", ::GetCurrentProcessId());
			::WinExec(tcExe, SW_HIDE);

			CDialog::OnCancel();

			return FALSE;
		}

		return FALSE;
	}

	int nWriteLog	= ::GetPrivateProfileInt(_T("BaseSetting"), _T("IsWriteLog"), -1, (LPCTSTR)strIniPath);
	if(nWriteLog == -1)
	{
		::WritePrivateProfileString(_T("BaseSetting"), _T("IsWriteLog"), _T("1\t\t;0:��д��־��1д��־"), (LPCTSTR)strIniPath);
	}
	if(nWriteLog == 0)
		m_bWriteLog	= FALSE;
	else
		m_bWriteLog	= TRUE;


	int nUseHiveDispatch	=	::GetPrivateProfileInt(_T("HiveConfig"), _T("UseHiveDispatch"), -1, (LPCTSTR)strIniPath);
	if(nUseHiveDispatch == -1)
	{
		nUseHiveDispatch = 0;
		::WritePrivateProfileString(_T("HiveConfig"), _T("UseHiveDispatch"), _T("0\t\t;�Ƿ�ʹ��HIVE���ȣ�0��ʹ��������MPC���ȣ�1��ʹ��HIVE���ȣ�"), (LPCTSTR)strIniPath);
	}
	if (nUseHiveDispatch == 1)
	{
		m_strHiveText = _T("HIVE���ȣ�׼��");
		m_bHiveDispatch = TRUE;
		UpdateStatus();
	}

	return TRUE;
}

BOOL CMPCIntelligentCutActorDlg::RegisterActor()
{
	MPC_FRAMERESULT		eResult;
	//m_strDispatchMQ	= _T("DIRECT=TCP:") + m_strDispIP + _T("\\PRIVATE$\\MPC_DispatchSvcMQ");
	m_strDispatchMQ		= _T("MPC_DispatchSvcMQ");
	CString				strHookMQ		= _T("MPCIntelligentCutActor");
	CString				strGwIpAddr		= m_strDispIP;
	CString				strGwMQName		= _T("mpc_dispatchsvcmq");
	CString				strLocalIpAddr	= m_strLocalHostIP;
	CString				strSvcName		= _T("MPCIntelligentCutActor");

	CStringArray		saAttachTypes;
	MPC_AttachArray		saSvcData;
	CStringArray		saSvcType;
	CString				strSvcGuid(_T(""));
	MPC_AttachArray		arrServiceData;
	saAttachTypes.RemoveAll();
	saSvcData.RemoveAll();
	saSvcType.RemoveAll();

	UINT				uMaxTaskCount(1);

	saSvcType.Add(_T("intelligentcut"));
	saSvcType.Add(_T("sedlintelligentcut"));
	saAttachTypes.Add(_T("tv_intelligentcutjobparam"));
	saAttachTypes.Add(_T("tv_sedlintelligentcutjobparam"));
	//saSvcType.Add(_T("materialclip"));
	//saAttachTypes.Add(_T("tv_clipmakerjobparam2"));

	if (m_bHiveDispatch)
	{
		//CString strLocalIp = GetIpAddress();
		eResult			= m_cHiveSvcFrame.InitilizeForHive(strGwIpAddr, strLocalIpAddr/*strLocalIp*/,
			strSvcName, saSvcType, saAttachTypes, uMaxTaskCount, &strSvcGuid);
	}
	else
	{
		eResult				= m_cSvcFrame.Initilize5(strHookMQ, strGwIpAddr, 
			strGwMQName, strSvcName, strLocalIpAddr, saSvcType, saAttachTypes, arrServiceData, uMaxTaskCount, &strSvcGuid);
	}

	SAFEDELETEOBJECTARRAY(arrServiceData);

	if(eResult != MPC_FRAMEERROR_NOERROR)
		return FALSE;
	if (m_bHiveDispatch)
	{
		eResult		= m_cHiveSvcFrame.SetCallBackHiveServiceStatus(HiveServiceStatus_CB, this);

		eResult		= m_cHiveSvcFrame.SetCallBackProc2(AssignTask_CB, CancelTask_CB, PauseTask_CB, ResumeTask_CB, QueryStatus_CB, ConfigManage_CB, UnknownMethod_CB, this);
		if(eResult != MPC_FRAMEERROR_NOERROR)
			return FALSE;

		eResult		= m_cHiveSvcFrame.StartWork();
		if(eResult != MPC_FRAMEERROR_NOERROR)
			return FALSE;
	}
	else
	{
		eResult		= m_cSvcFrame.SetCallBackProc(AssignTask_CB, CancelTask_CB, PauseTask_CB, ResumeTask_CB, QueryStatus_CB, this);

		if(eResult != MPC_FRAMEERROR_NOERROR)
			return FALSE;

		eResult		= m_cSvcFrame.SetNotifyMsg(m_hWnd, WM_GWSHUTDOWN);
		if(eResult != MPC_FRAMEERROR_NOERROR)

			return FALSE;

		eResult		= m_cSvcFrame.StartWork();
		if(eResult != MPC_FRAMEERROR_NOERROR)
			return FALSE;

	}
	return TRUE;
}
BOOL CMPCIntelligentCutActorDlg::HiveServiceStatus_CB( int nType, int nValue, const CString& strText, LPVOID lpUserData )
{
	CMPCIntelligentCutActorDlg*	pThis	= static_cast<CMPCIntelligentCutActorDlg*>(lpUserData);
	ASSERT(pThis);
	return pThis->HiveServiceStatus(nType, nValue, strText);
}
BOOL CMPCIntelligentCutActorDlg::ConfigManage_CB(MPC_RESULTTYPE& eResult, CString& strRemark, MPC_AttachArray& arrConfigs, const BOOL bForceReboot, const BOOL bForQuery, const LPVOID lpUserData)
{
	CMPCIntelligentCutActorDlg*	pThis	= static_cast<CMPCIntelligentCutActorDlg*>(lpUserData);
	ASSERT(pThis);
	return pThis->ConfigManage(eResult, strRemark, arrConfigs, bForceReboot, bForQuery);
}
void CMPCIntelligentCutActorDlg::UnknownMethod_CB(const CString& strMethod, const BSTR& bstrXml, const LPVOID lpUserData)
{
	CMPCIntelligentCutActorDlg*	pThis	= static_cast<CMPCIntelligentCutActorDlg*>(lpUserData);
	ASSERT(pThis);
	return pThis->UnknownMethod(strMethod, bstrXml);
}
BOOL CMPCIntelligentCutActorDlg::AssignTask_CB(MPC_RESULTTYPE& eResult, MPC_JOBATTRIB& dwAttribute, CString& strRemark, const CString& strJobType, const ULONG ulJobID, const BOOL bBreakResume, const MPC_PROJECTBASE& stBaseInfo, const MPC_AttachArray& arrTaskInfo, const MPC_MediaFileArray& arrMediaFile, const LPMPC_ATTACH lpJobInfo, const CString& strJobSource, const CString& strJobObject, const LPMPC_ATTACH lpBreakPack, const LPVOID lpUserData)
{
	CMPCIntelligentCutActorDlg* pDlg = static_cast<CMPCIntelligentCutActorDlg*>(lpUserData);
	if(pDlg == NULL)
		return FALSE;

	return pDlg->AssignTask(eResult, dwAttribute, strRemark, strJobType, ulJobID, bBreakResume, stBaseInfo, arrTaskInfo, arrMediaFile, lpJobInfo, strJobSource, strJobObject, lpBreakPack);
}

BOOL CMPCIntelligentCutActorDlg::CancelTask_CB(const ULONG ulJobID, const CString& strRemark, const LPVOID lpUserData)
{
	CMPCIntelligentCutActorDlg* pDlg = static_cast<CMPCIntelligentCutActorDlg*>(lpUserData);
	if(pDlg == NULL)
		return FALSE;

	return pDlg->CancelTask(ulJobID, strRemark);
}

BOOL CMPCIntelligentCutActorDlg::PauseTask_CB(MPC_RESULTTYPE& eResult, LPMPC_ATTACH& pBreakpack, const ULONG ulJobID, const BOOL bSuspend, const LPVOID lpUserData)
{
	CMPCIntelligentCutActorDlg* pDlg = static_cast<CMPCIntelligentCutActorDlg*>(lpUserData);
	if(pDlg == NULL)
		return FALSE;

	return pDlg->PauseTask(eResult, pBreakpack, ulJobID, bSuspend);
}

BOOL CMPCIntelligentCutActorDlg::ResumeTask_CB(MPC_RESULTTYPE& eResult, const ULONG ulJobID, const LPVOID lpUserData)
{
	CMPCIntelligentCutActorDlg* pDlg = static_cast<CMPCIntelligentCutActorDlg*>(lpUserData);
	if(pDlg == NULL)
		return FALSE;

	return pDlg->ResumeTask(eResult, ulJobID);
}

BOOL CMPCIntelligentCutActorDlg::QueryStatus_CB(MPC_SVCSTATE& eSvcState, UINT& nJobCount, MPC_JobGuageArray& arrJobInfo, const LPVOID lpUserData)
{
	CMPCIntelligentCutActorDlg* pDlg = static_cast<CMPCIntelligentCutActorDlg*>(lpUserData);
	if(pDlg == NULL)
		return FALSE;

	return pDlg->QueryStatus(eSvcState, nJobCount, arrJobInfo);
}

BOOL CMPCIntelligentCutActorDlg::AssignTask(MPC_RESULTTYPE& eResult, MPC_JOBATTRIB& dwAttribute, CString& strRemark, const CString& strJobType, const ULONG ulJobID, const BOOL bBreakResume, const MPC_PROJECTBASE& stBaseInfo, const MPC_AttachArray& arrTaskInfo, const MPC_MediaFileArray& arrMediaFile, const LPMPC_ATTACH lpJobInfo, const CString& strJobSource, const CString& strJobObject, const LPMPC_ATTACH lpBreakPack)
{
	if(m_bExit)
	{
		eResult						=	MPC_RESULTTYPE_FULLLOAD;
		return	TRUE;
	}

	if(strJobType == _T("intelligentcut"))//��������Ϊ���ܴ���
	{
		CTransBaseThread*	pThread		=	CTransBaseThread::CreateTransThread(strJobType);
		if(pThread == NULL)
		{
			eResult						=	MPC_RESULTTYPE_ERROR;
			strRemark					=	_T("��������ʧ�ܣ�������");
			return TRUE;
		}
		pThread->SetMainWnd(this);
		if(!pThread->SetJobInfo(ulJobID, strJobSource, strJobObject, bBreakResume))
		{
			pThread->GetResult(eResult, strRemark);
			return TRUE;
		}
		if(!pThread->SetTaskParam(stBaseInfo, arrTaskInfo, arrMediaFile, lpJobInfo))
		{
			pThread->GetResult(eResult, strRemark);
			return TRUE;
		}

		pThread->SetSystemRootPath(GetSystemRootPath());

		pThread->SetJobType(strJobType);
		OnAddTask((WPARAM)pThread, 1);

		if(bBreakResume)
			pThread->SetBreakpoint(lpBreakPack);

		UpdateStatus();

		pThread->ResumeThread();

		eResult			=	MPC_RESULTTYPE_ACCEPTED;

	}
	else if(strJobType == _T("sedlintelligentcut"))
	{
		CTransBaseThread*	pThread		=	CTransBaseThread::CreateTransThread(strJobType);
		if(pThread == NULL)
		{
			eResult						=	MPC_RESULTTYPE_ERROR;
			strRemark					=	_T("��������ʧ�ܣ�������");
			return TRUE;
		}
		pThread->SetMainWnd(this);
		if(!pThread->SetJobInfo(ulJobID, strJobSource, strJobObject, bBreakResume))
		{
			pThread->GetResult(eResult, strRemark);
			return TRUE;
		}
		if(!pThread->SetTaskParam(stBaseInfo, arrTaskInfo, arrMediaFile, lpJobInfo))
		{
			pThread->GetResult(eResult, strRemark);
			return TRUE;
		}

		pThread->SetSystemRootPath(GetSystemRootPath());

		pThread->SetJobType(strJobType);
		OnAddTask((WPARAM)pThread, 1);

		if(bBreakResume)
			pThread->SetBreakpoint(lpBreakPack);

		UpdateStatus();

		pThread->ResumeThread();

		eResult			=	MPC_RESULTTYPE_ACCEPTED;
	}
	else
	{
		strRemark		= _T("��֧�ֵ��������ͣ�");
		eResult			=	MPC_RESULTTYPE_NOTSUPPORT;
	}


	return TRUE;
}

BOOL CMPCIntelligentCutActorDlg::CancelTask(const ULONG ulJobID, const CString& strRemark)
{
	return FALSE;
}

BOOL CMPCIntelligentCutActorDlg::PauseTask(MPC_RESULTTYPE& eResult, LPMPC_ATTACH& pBreakpack, const ULONG ulJobID, const BOOL bSuspend)
{
	eResult		= MPC_RESULTTYPE_PENDING;

	return FALSE;
}

BOOL CMPCIntelligentCutActorDlg::ResumeTask(MPC_RESULTTYPE& eResult, const ULONG ulJobID)
{
	eResult		= MPC_RESULTTYPE_PENDING;

	return FALSE;
}

BOOL CMPCIntelligentCutActorDlg::QueryStatus(MPC_SVCSTATE& eSvcState, UINT& nJobCount, MPC_JobGuageArray& arrJobInfo)
{
	nJobCount	= m_lcCurrentTask.GetItemCount();
	for(INT_PTR i = 0; i < nJobCount; i++)
	{
		//CTranscodeThread* pThread = (CTranscodeThread*)(DWORD_PTR)m_lcCurrentTask.GetItemData(i);
		CTransBaseThread* pThread = (CTransBaseThread*)(DWORD_PTR)m_lcCurrentTask.GetItemData(i);
		if(pThread)
		{
			LPMPC_JOBGUAGE	lpGuage = MPC_JOBGUAGE::CreateObject();
			if(lpGuage)
			{
				lpGuage->ulJobID	= pThread->GetJobID();
				lpGuage->strJobType	= m_lcCurrentTask.GetItemText(i, 3);				
				lpGuage->nPercentage = pThread->GetTaskGuage();
				lpGuage->strInfo = _T("n/a");
			}

			arrJobInfo.Add(lpGuage);
		}
	}

	return TRUE;
}

BOOL CMPCIntelligentCutActorDlg::OnAddTask(WPARAM wParam, LPARAM lParam)
{
	CTransBaseThread	*pThread	= (CTransBaseThread*)(wParam);
	if(pThread == NULL)
		return FALSE;
	int		nItem					=	m_lcCurrentTask.GetItemCount();
	CString	strID;
	CString strJobID;
	CString strStartTime;
	CString	strTaskType;

	m_nPercentage	= 0;
	m_eResult		= MPC_RESULTTYPE_NOTSUPPORT;
	m_strErrorInfo	= _T("");


	CTime	tm						=	CTime::GetCurrentTime();
	strStartTime					=	tm
		.Format(_T("%Y-%m-%d %H:%M:%S"));
	strID.Format(_T("%u"), m_nTaskID++);
	strJobID.Format(_T("%u"), pThread->GetJobID());
	MPC_PROJECTBASE	stBaseInfo = pThread->GetProjectBase();

	nItem			= m_lcCurrentTask.InsertItem(nItem, strID);							//ID#
	m_lcCurrentTask.SetImageList(&m_lsImage, 0);
	m_lcCurrentTask.SetItemText(nItem, 1, stBaseInfo.strTaskName);						//��������
	m_lcCurrentTask.SetItemText(nItem, 2, pThread->GetJobType());						//��������
	m_lcCurrentTask.SetItemText(nItem, 3, strStartTime);								//��ʼʱ��
	m_lcCurrentTask.SetItemText(nItem, 4, _T("0%"));									//�������
	m_lcCurrentTask.SetItemText(nItem, 5, stBaseInfo.strTaskLength);					//���񳤶�
	m_lcCurrentTask.SetItemText(nItem, 6, strJobID);									//�������
	m_lcCurrentTask.SetItemText(nItem, 7, stBaseInfo.strTaskGUID);						//�������
	m_lcCurrentTask.SetItemData(nItem, (DWORD)(DWORD_PTR)pThread);

	SetTimer(1, 1000, NULL);
	m_ulJobID = pThread->GetJobID();
	
	return TRUE;
}

void CMPCIntelligentCutActorDlg::OnTimer(UINT_PTR nIDEvent)
{
	if(nIDEvent == 1)
	{
		CTransBaseThread* pThread = (CTransBaseThread*)(DWORD_PTR)m_lcCurrentTask.GetItemData(0);

		//�ж��Ƿ�ʧ�� 
		if(m_lcCurrentTask.GetItemCount() > 0 )
		{
			MPC_RESULTTYPE eRusult = 0;
			CString strErrorInfo = _T("");
			if(pThread)
			{
				pThread->GetResult(eRusult, strErrorInfo);
				if(eRusult == MPC_RESULTTYPE_ERROR)//�������崦������г��ֵĴ���
				{
					m_eResult = eRusult;
					m_strErrorInfo = strErrorInfo;
					if (m_strErrorInfo.IsEmpty())
					{
						m_strErrorInfo = _T("����ʧ�ܣ�ԭ��δ֪��");
					}
					if (m_bHiveDispatch)
					{
						m_cHiveSvcFrame.FinishTask(pThread->GetJobID(), m_eResult, m_arrTaskInfo, pThread->GetOutMediaFile(), (m_eResult == MPC_RESULTTYPE_SUCCEED) ? _T("success") : m_strErrorInfo);
					}
					else
					{
						m_cSvcFrame.FinishTask(m_ulJobID, m_eResult, m_arrTaskInfo, /*m_arrMediaFileOut*/pThread->GetOutMediaFile(), m_strErrorInfo);
					}
					
					SAFEDELETEOBJECTARRAY(m_arrTaskInfo);
					SAFEDELETEOBJECTARRAY(m_arrMediaFile);
					SAFEDELETEOBJECTARRAY(m_arrMediaFileOut);

					InsertHistoryAndRemoveCurrent(TRUE);
					pThread->PostThreadMessage(WM_QUIT, 0, 0);

					if (pThread->m_bOverTime)
						RerunApp();
				}
			}
		}

		//�жϽ���
		if(m_lcCurrentTask.GetItemCount() > 0 && m_nPercentage >= 100)
		{
			BOOL bFailed;

			if(m_eResult == MPC_RESULTTYPE_ERROR || (m_eResult == MPC_RESULTTYPE_ACCEPTED && m_strErrorInfo.CompareNoCase(_T("AllOK")) != 0))
			{
				m_eResult		= MPC_RESULTTYPE_RETRYERROR/*MPC_RESULTTYPE_FAILEDFLAG*/;
				bFailed			= TRUE;
			}
			else
			{
				bFailed			=	FALSE;
				m_strErrorInfo	=	_T("success");
				m_eResult		=	MPC_RESULTTYPE_SUCCEED;
			}

			FillMediaFileOut();
			if (m_bHiveDispatch)
			{
				m_cHiveSvcFrame.FinishTask(pThread->GetJobID(), m_eResult, pThread->GetOutTaskInfo(),/* m_arrTaskInfo,*/ pThread->GetOutMediaFile(), (m_eResult == MPC_RESULTTYPE_SUCCEED) ? _T("success") : m_strErrorInfo);
			}
			else
			{
				m_cSvcFrame.FinishTask(m_ulJobID, m_eResult, pThread->GetOutTaskInfo(), /*m_arrTaskInfo, m_arrMediaFileOut*/pThread->GetOutMediaFile(), m_strErrorInfo);		
			}
			SAFEDELETEOBJECTARRAY(m_arrTaskInfo);
			SAFEDELETEOBJECTARRAY(m_arrMediaFile);
			SAFEDELETEOBJECTARRAY(m_arrMediaFileOut);

			InsertHistoryAndRemoveCurrent(bFailed);
			pThread->PostThreadMessage(WM_QUIT, 0, 0);
		}

		//��ʾ����
		if(m_lcCurrentTask.GetItemCount() > 0 && m_nPercentage <= 100)
		{
			CString strProgress(_T(""));

			if(pThread)
			{
				m_nPercentage = pThread->GetTaskGuage();
				//��������ķ���������Ϣ
				if (m_bHiveDispatch)
				{
					if(m_cHiveSvcFrame.FeedbackGuage(pThread->GetJobID(), m_nPercentage) != MPC_FRAMEERROR_NOERROR)
					{
						CString			strInfo;
						strInfo.Format(_T("send guage failed[%d, %d]"), pThread->GetJobID(), m_nPercentage);
						::OutputDebugString(strInfo);
					}
				}
				else
				{
					m_cSvcFrame.FeedbackGuage(pThread->GetJobID(), m_nPercentage);
				}
			}
			strProgress.Format(_T("%d%%"), m_nPercentage);
			m_lcCurrentTask.SetItemText(0, 4, strProgress);	//����
		}
	}

	CDialog::OnTimer(nIDEvent);

}

void CMPCIntelligentCutActorDlg::InsertHistoryAndRemoveCurrent(BOOL bFailed)
{
	CString strTaskResult;
	if(bFailed)
		strTaskResult	= _T("failure");
	else
		strTaskResult	= _T("success");

	m_lcCurrentTask.SetItemText(0, 5, (LPCTSTR)strTaskResult);

	CTime		tm			=	CTime::GetCurrentTime();
	CString		strEndTime	=	tm.Format(_T("%Y-%m-%d %H:%M:%S"));
	int			iCurIndex	=	0;
	m_lcHistoryTask.InsertItem(0, m_lcCurrentTask.GetItemText(iCurIndex, 0));				//ID#
	m_lcHistoryTask.SetItemText(0, 1, m_lcCurrentTask.GetItemText(iCurIndex, 1));			//��������
	m_lcHistoryTask.SetItemText(0, 2, m_lcCurrentTask.GetItemText(iCurIndex, 2));			//��������
	m_lcHistoryTask.SetItemText(0, 3, m_lcCurrentTask.GetItemText(iCurIndex, 3));			//��ʼʱ��
	m_lcHistoryTask.SetItemText(0, 4, strEndTime);											//����ʱ��
	if(bFailed)
		m_lcHistoryTask.SetItemText(0, 5, m_strErrorInfo);									//������
	else
		m_lcHistoryTask.SetItemText(0, 5, strTaskResult);
	m_lcHistoryTask.SetItemText(0, 6, m_lcCurrentTask.GetItemText(iCurIndex, 5));			//���񳤶�
	m_lcHistoryTask.SetItemText(0, 7, m_lcCurrentTask.GetItemText(iCurIndex, 6));			//�������
	m_lcHistoryTask.SetItemText(0, 8, m_lcCurrentTask.GetItemText(iCurIndex, 7));			//�������

	m_lcCurrentTask.DeleteItem(iCurIndex);

	if(!bFailed)
		m_nTaskSucceed	++;
	m_nTaskFinished	++;

	UpdateStatus();

}
BOOL CMPCIntelligentCutActorDlg::FillMediaFileOut()
{
	//m_arrMediaFile.RemoveAll();

	for(INT_PTR iArr = 0; iArr < m_arrMediaFileOut.GetCount(); iArr ++)
	{
		LPMPC_MEDIAFILE	lpMediaFile = m_arrMediaFileOut.GetAt(iArr);
		lpMediaFile->llInPoint			=	0;
		lpMediaFile->llOutPoint			=	-1;
		lpMediaFile->pFileParam			=	NULL;
	}

	return TRUE;
}
CString CMPCIntelligentCutActorDlg::GetSystemRootPath()
{
	TCHAR  tcBaseValue[1024];
	::GetPrivateProfileString(_T("BaseSetting"), _T("SystemRootPath"), _T(""), tcBaseValue, 1024, (LPCTSTR)GetIniFileName());
	m_strSysRootPath	= tcBaseValue;

	return m_strSysRootPath;
}

void CMPCIntelligentCutActorDlg::UpdateStatus()
{
	if (m_bHiveDispatch)
	{
		m_strTaskStatus.Format(_T("��ִ��:%d(�ɹ���%d ʧ�ܣ�%d)(%s)"), m_nTaskFinished, m_nTaskSucceed,
			m_nTaskFinished - m_nTaskSucceed, m_strHiveText);
	}
	else
	{
		m_strTaskStatus.Format(_T("��ִ�У�%d ���ɹ���%d ʧ�ܣ�%d ��"), m_nTaskFinished, m_nTaskSucceed, m_nTaskFinished - m_nTaskSucceed);
	}
	GetDlgItem(IDC_STATUSBAR)->SetWindowText(m_strTaskStatus);
}



void CMPCIntelligentCutActorDlg::OnBnClickedClear()
{

	m_lcHistoryTask.DeleteAllItems();
}

void CMPCIntelligentCutActorDlg::OnBnClickedClose()
{
	if(m_lcCurrentTask.GetItemCount() > 0)
	{
		if(MessageBox(_T("��ǰ�����������У��Ƿ��ڸ�������ɺ��˳���"), _T("MPCIntelligentCutActor"), MB_OKCANCEL | MB_ICONWARNING) == IDCANCEL)
		{
			return;
		}
		if(m_lcCurrentTask.GetItemCount() > 0)
		{
			m_bExit		= TRUE;
			return;
		}
	}
	else
	{
		if(MessageBox(_T("ȷ���˳�MPCIntelligentCutActor��"), _T("MPCIntelligentCutActor"), MB_OKCANCEL | MB_ICONWARNING) == IDCANCEL)
		{
			return;
		}
		else
		{
			CMPCApp::UninstallDogMonitor();
			ClearData();
			CDialog::OnCancel();
		}
	}

}

void CMPCIntelligentCutActorDlg::OnBnClickedSet()
{
	CDlgSet	dlg;
	dlg.SetConfig(m_strDispIP, m_strLocalHostIP, m_strSysRootPath);
	if(dlg.DoModal() == IDOK)
	{
		dlg.GetConfig(m_strDispIP, m_strLocalHostIP, m_strSysRootPath);
		TCHAR	tcPath[_MAX_PATH];
		::GetModuleFileName(NULL, tcPath, _MAX_PATH);
		size_t  iLen		= _tcslen(tcPath);
		tcPath[iLen - 3]	= _T('i');
		tcPath[iLen - 2]	= _T('n');
		tcPath[iLen - 1]	= _T('i');
		CString strIniPath	= tcPath;

		::WritePrivateProfileString(_T("BaseSetting"), _T("DispatchIP"), (LPCTSTR)m_strDispIP, (LPCTSTR)strIniPath);
		::WritePrivateProfileString(_T("BaseSetting"), _T("LocalHostIP"), (LPCTSTR)m_strLocalHostIP, (LPCTSTR)strIniPath);
		::WritePrivateProfileString(_T("BaseSetting"), _T("SystemRootPath"), (LPCTSTR)m_strSysRootPath, (LPCTSTR)strIniPath);

		m_bExit		= TRUE;
		ClearData();
		char		tcExe[1024];
		sprintf_s(tcExe, "mdkregister.exe -t %d", ::GetCurrentProcessId());
		::WinExec(tcExe, SW_HIDE);

		CDialog::OnCancel();
	}

}

LRESULT CMPCIntelligentCutActorDlg::OnDispatchShutdown(WPARAM wParam, LPARAM lParam)
{

	return 0L;
}

LRESULT CMPCIntelligentCutActorDlg::OnActorStatusUpdate(WPARAM wParam, LPARAM lParam)
{
	int nMsgType = (int)wParam;
	if (nMsgType == MSG_TYPE_ADDTASK)
	{
		if(!OnAddTask(wParam, lParam))
		{
			m_nUpdateStatus = 1;
			return 0;
		}
	}

	return 0L;
}

void CMPCIntelligentCutActorDlg::OnCancel()
{
	OnBnClickedClose();
}

void CMPCIntelligentCutActorDlg::ClearData()
{
	if (m_bHiveDispatch)
	{
		m_cHiveSvcFrame.Uninitilize();
	}
	else
	{
		m_cSvcFrame.Uninitilize();
	}
	SAFEDELETEOBJECTARRAY(m_arrTaskInfo);
	SAFEDELETEOBJECTARRAY(m_arrMediaFile);
	SAFEDELETEOBJECTARRAY(m_arrMediaFileOut);

}

LRESULT CMPCIntelligentCutActorDlg::WorkFinished(WPARAM wParam, LPARAM lParam)
{
	CTransBaseThread *pThread		=	(CTransBaseThread*)(wParam);
	if(pThread == NULL)
		return -1L;

	UINT				ulJobID(pThread->GetJobID());

	MPC_AttachArray		arrTaskInfo;
	arrTaskInfo.RemoveAll();
	MPC_PROJECTBASE		stBaseInfo		=	pThread->GetProjectBase();
	pThread->GetTaskInfo(arrTaskInfo);

	pThread->GetResult(m_eResult, m_strErrorInfo);
	if(m_eResult == MPC_RESULTTYPE_ERROR)
		m_eResult							=	MPC_RESULTTYPE_RETRYERROR;
	if(m_eResult == MPC_RESULTTYPE_SUSPENDED)
	{
		m_cSvcFrame.SuspendedTask(pThread->GetJobID());
	}
	else
	{
		if (m_bHiveDispatch)
		{
			m_cHiveSvcFrame.FinishTask(pThread->GetJobID(), m_eResult, arrTaskInfo, pThread->GetOutMediaFile(), (m_eResult == MPC_RESULTTYPE_SUCCEED) ? _T("success") : m_strErrorInfo);
		}
		else
		{
			m_cSvcFrame.FinishTask(pThread->GetJobID(), m_eResult, arrTaskInfo, pThread->GetOutMediaFile(), (m_eResult == MPC_RESULTTYPE_SUCCEED) ? _T("success") : m_strErrorInfo);
		}
	}

	BOOL  bFailed(FALSE);
	if(m_eResult != MPC_RESULTTYPE_SUCCEED)
		bFailed = TRUE;

	InsertHistoryAndRemoveCurrent(bFailed);

	return 1;
}
BOOL CMPCIntelligentCutActorDlg::IsTerminateProcess()
{
	int		iTerminate		=	::GetPrivateProfileInt(BASE_INI_SECTION, _T("IsTerminateProcess(0/1)"), -1, GetIniFileName());
	if(iTerminate == -1)
	{
		iTerminate			=	1;	
		::WritePrivateProfileString(BASE_INI_SECTION, _T("IsTerminateProcess(0/1)"), _T("1"), GetIniFileName());
	}
	return	(BOOL)iTerminate;
}
void CMPCIntelligentCutActorDlg::RerunApp(void)
{
	//CMPCApp::UninstallDogMonitor();
	//CMPCApp::SetRerunProcessFlag();
	//m_bExitAtNext	= TRUE;
	if(IsTerminateProcess())
	{
		if (m_bHiveDispatch)
		{
			m_cHiveSvcFrame.Uninitilize();
		}
		else
		{
			m_cSvcFrame.Uninitilize();
		}
		/*char		tcExe[1024];
		sprintf_s(tcExe, "mdkregister.exe -t %d", ::GetCurrentProcessId());
		::WinExec(tcExe, SW_HIDE);*/
		HANDLE hHandle	= ::GetCurrentProcess();
		if(hHandle)
		{
			::TerminateProcess(hHandle, 1);
		}

	}
	/*if(m_bIsFree)
		CMPCDialog::OnCancel();*/
}

BOOL CMPCIntelligentCutActorDlg::ConfigManage(MPC_RESULTTYPE& eResult, CString& strRemark, MPC_AttachArray& arrConfigs, const BOOL bForceReboot, const BOOL bForQuery)
{
	if(bForQuery)
	{
		BOOL				bResult(CConfigManager::Instance().QueryConfig(arrConfigs, strRemark));
		eResult				= bResult ? MPC_RESULTTYPE_SUCCEED : MPC_RESULTTYPE_ERROR;

		return TRUE;
	}
	else
	{
		BOOL				bNeedReboot(FALSE);
		BOOL				bResult(CConfigManager::Instance().SaveConfig(arrConfigs, strRemark, bNeedReboot));
		eResult				= bResult ? MPC_RESULTTYPE_SUCCEED : MPC_RESULTTYPE_ERROR;

		if(bResult && (bNeedReboot || bForceReboot))
			RerunApp();

		return TRUE;
	}

	return TRUE;
}

void CMPCIntelligentCutActorDlg::UnknownMethod(const CString& strMethod, const BSTR& bstrXml)
{
	if(strMethod == _T("UniformConfig"))
		CConfigManager::Instance().UniformConfig(bstrXml);
}
BOOL CMPCIntelligentCutActorDlg::HiveServiceStatus( int nType, int nValue, const CString& strText )
{
	TCHAR lpBuffer[1024] = {0};
	SYSTEMTIME	tm;
	GetLocalTime(&tm);		
	wsprintf(lpBuffer, _T("[%0.2d:%0.2d:%0.2d]"),tm.wHour,tm.wMinute,tm.wSecond);

	m_strHiveText = lpBuffer;
	m_strHiveText += strText;

	UpdateStatus();

	return TRUE;
}