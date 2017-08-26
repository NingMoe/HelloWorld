// MPCIntelligentCutActorDlg.h : ͷ�ļ�
//

#pragma once
#include "Resource.h"
#include "..\..\..\MPCBaseLogic\Src\MPCHiveServiceFrame\MPCHiveServiceFrameAllExp.h"

#define WM_GWSHUTDOWN    (WM_USER + 102)
#define WM_MSG_UPDATE    (WM_USER + 103)
#define WM_AIR			 (WM_USER + 104)

#define MSG_TYPE_ADDTASK	1

// CMPCIntelligentCutActorDlg �Ի���
class CMPCIntelligentCutActorDlg : public CDialog
{
// ����
public:
	CMPCIntelligentCutActorDlg(CWnd* pParent = NULL);	// ��׼���캯��

// �Ի�������
	enum { IDD = IDD_MPCINTELLIGENTCUTACTOR_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV ֧��


// ʵ��
protected:
	HICON m_hIcon;

	// ���ɵ���Ϣӳ�亯��
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()

public:
	CListCtrl				m_lcCurrentTask;	//���������б�
	CListCtrl				m_lcHistoryTask;	//��ʷ�����б�
	CImageList				m_lsImage;			//��������ͼ���б�
	CString					m_strTaskStatus;	//����ͳ����Ϣ
	int						m_nTaskFinished	;   //�����������
	int						m_nTaskSucceed	;   //�ɹ����������
	int						m_nTaskID;			//����ID�ۼ���
	float					m_fScan;
protected:
	BOOL					m_bHiveDispatch;

	CSize					m_szWnd;
	CString					m_strErrorInfo;
	CString					m_strHiveText;
	//BOOL					m_bExitAtNext;
	//�����ܶ���
	CMPCSvcFrame			m_cSvcFrame;
	//Hive������
	CMPCHiveSvcFrame		m_cHiveSvcFrame;

	CString					m_strDispIP;
	CString					m_strLocalHostIP;
	CString					m_strDispatchMQ;
	BOOL					m_bWriteLog;
	MPC_RESULTTYPE			m_eResult;
	MPC_AttachArray			m_arrTaskInfo;
	MPC_MediaFileArray		m_arrMediaFile;
	MPC_MediaFileArray		m_arrMediaFileOut;
	BOOL					m_bExit;
	int						m_nPercentage;
	ULONG					m_ulJobID;
	CString					m_strSysRootPath;
	MPC_PROJECTBASE			m_stBaseInfo;		//���������Ϣ

	CString					m_strObjGroupType;
	CString					m_strObjMediaType;

protected:
	void				InitFace();
	void				RerunApp(void);
	BOOL				GetConfigInfo();
	BOOL				RegisterActor();
	BOOL				GetTaskNotifyQueue();
	BOOL				OnAddTask(WPARAM wParam, LPARAM lParam);
	void				InsertHistoryAndRemoveCurrent(BOOL bFailed);
	CString				GetSystemRootPath();
	void				UpdateStatus();
	static BOOL			AssignTask_CB(MPC_RESULTTYPE& eResult,	MPC_JOBATTRIB& dwAttribute,	CString& strRemark,	const CString& strJobType, const ULONG ulJobID, const BOOL bBreakResume, const MPC_PROJECTBASE& stBaseInfo, const MPC_AttachArray& arrTaskInfo, const MPC_MediaFileArray& arrMediaFile, const LPMPC_ATTACH lpJobInfo, const CString& strJobSource, const CString& strJobObject, const LPMPC_ATTACH lpBreakPack, const LPVOID lpUserData);
	static BOOL			CancelTask_CB(const ULONG ulJobID, const CString& strRemark, const LPVOID lpUserData);
	static BOOL			PauseTask_CB(MPC_RESULTTYPE& eResult, LPMPC_ATTACH& pBreakpack, const ULONG ulJobID, const BOOL bSuspend, const LPVOID lpUserData);
	static BOOL			ResumeTask_CB(MPC_RESULTTYPE& eResult, const ULONG ulJobID, const LPVOID lpUserData);
	static BOOL			QueryStatus_CB(MPC_SVCSTATE& eSvcState, UINT& nJobCount, MPC_JobGuageArray& arrJobInfo, const LPVOID lpUserData);	
	static BOOL			ConfigManage_CB(MPC_RESULTTYPE& eResult, CString& strRemark, MPC_AttachArray& arrConfigs, const BOOL bForceReboot, const BOOL bForQuery, const LPVOID lpUserData);
	static void			UnknownMethod_CB(const CString& strMethod, const BSTR& bstrXml, const LPVOID lpUserData);
	static BOOL			HiveServiceStatus_CB(int nType, int nValue, const CString& strText, LPVOID lpUserData);	
	
	BOOL				AssignTask(MPC_RESULTTYPE& eResult,	MPC_JOBATTRIB& dwAttribute,	CString& strRemark,	const CString& strJobType, const ULONG ulJobID, const BOOL bBreakResume, const MPC_PROJECTBASE& stBaseInfo, const MPC_AttachArray& arrTaskInfo, const MPC_MediaFileArray& arrMediaFile, const LPMPC_ATTACH lpJobInfo, const CString& strJobSource, const CString& strJobObject, const LPMPC_ATTACH lpBreakPack);
	BOOL				CancelTask(const ULONG ulJobID, const CString& strRemark);
	BOOL				PauseTask(MPC_RESULTTYPE& eResult, LPMPC_ATTACH& pBreakpack, const ULONG ulJobID, const BOOL bSuspend);
	BOOL				ResumeTask(MPC_RESULTTYPE& eResult, const ULONG ulJobID);
	BOOL				QueryStatus(MPC_SVCSTATE& eSvcState, UINT& nJobCount, MPC_JobGuageArray& arrJobInfo);	
	BOOL				ConfigManage(MPC_RESULTTYPE& eResult, CString& strRemark, MPC_AttachArray& arrConfigs, const BOOL bForceReboot, const BOOL bForQuery);
	void				UnknownMethod(const CString& strMethod, const BSTR& bstrXml);
	BOOL				HiveServiceStatus(int nType, int nValue, const CString& strText);

protected:
	afx_msg void		OnSize(UINT nType, int cx, int cy);
	afx_msg void		OnDestroy();
	afx_msg void		OnBnClickedClear();
	afx_msg void		OnBnClickedClose();
	afx_msg void		OnBnClickedSet();
	afx_msg LRESULT		OnDispatchShutdown(WPARAM wParam, LPARAM lParam); //�������Ĺر�֪ͨ��Ϣ
	afx_msg LRESULT		OnActorStatusUpdate(WPARAM wParam, LPARAM lParam); //����֪ͨ��Ϣ
	afx_msg void	    OnTimer(UINT_PTR nIDEvent);
	virtual void		OnCancel();
	void				ClearData();
	LRESULT				WorkFinished(WPARAM wParam, LPARAM lParam);
	BOOL				IsTerminateProcess();
public:
	BOOL					m_bWorkOver;
	int						m_bWorkStatus;
	int						m_nUpdateStatus;
	BOOL					FillMediaFileOut();
};
