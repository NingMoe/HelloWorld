/*********************************************************
* Filename: MPCSvcFrame.h
* Contents: Service frame proxy class for MPC service interface
* Authors: Tanghai Xi
* Date: Mar., 18, 2006
* Revised: 
* All Rights Reserved
* MPC Develop Group
* Sobey Inc, P.R.China
**********************************************************/
#pragma once
#include <comutil.h>

#ifdef MPCHIVESERVICEFRAME
#define MPCHIVESERVICEFRAME_API __declspec(dllexport)
#else
#define MPCHIVESERVICEFRAME_API __declspec(dllimport)
#endif


class CHiveServiceFrame;
class MPCHIVESERVICEFRAME_API CMPCHiveSvcFrame
{
public:
	CMPCHiveSvcFrame(void);
	~CMPCHiveSvcFrame(void);
	//��ʼ��
	MPC_FRAMERESULT	InitilizeForHive(
		/*in*/const CString&		strDispatchIp,			//�������ڻ���IP��ַ	
		/*in*/const CString&		strLocalIPAddr,			//���ؼ���IP��ַ	
		/*in*/const CString&		strSvcName,				//��������
		/*in*/const CStringArray&	saSvcTypes,				//���������б�
		/*in*/const CStringArray&	saAttachTypes,			//�÷�����Ҫ���յ�������Ϣ��
		/*in*/const UINT			nMaxTaskCount = 1,		//�÷�������ͬʱ��������������Ŀ
		/*out*/CString*				pstrSvcGuid	= NULL		//����÷���ע���GUID
		);	

	//ָʾ��ʼ�����̽�������Ҫע�ᵽ���Ȳ��ҽ��յ�������
	MPC_FRAMERESULT	StartWork(void);

	//���������
	MPC_FRAMERESULT	FinishTask(/*in*/const ULONG ulJobID, 
		/*in*/const MPC_RESULTTYPE eResult, 
		/*in*/const MPC_AttachArray& arrTaskinfo, 
		/*in*/const MPC_MediaFileArray& arrMediaFile, 
		/*in*/const CString& strRemark);
	//��������
	MPC_FRAMERESULT	FeedbackGuage(/*in*/const ULONG ulJobID,
		/*in*/const int nPercentage);

	//��������ʱ�ص�����
	MPC_FRAMERESULT	SetCallBackProc2(/*in*/const AssignTask fnAssignTask, 
		/*in*/const CancelTask fnCancelTask, 
		/*in*/const PauseTask fnPauseTask, 
		/*in*/const ResumeTask fnResumeTask, 
		/*in*/const QueryStatus fnQueryStatus,
		/*in*/const ConfigManage fnConfigManage,
		/*in*/const UnknownMethod fnUnknownMethod,
		/*in*/const LPVOID lpUserData);

	//ж��
	MPC_FRAMERESULT	Uninitilize(void);


	//��ʼ��SNMP�����������Ҫ���ؽ��Ȳŵ��øú�����
	MPC_FRAMERESULT	InitSnmp(void);

	//��������ʱ�ص�����
	MPC_FRAMERESULT	SetCallBackProc(/*in*/const AssignTask fnAssignTask, 
		/*in*/const CancelTask fnCancelTask, 
		/*in*/const PauseTask fnPauseTask, 
		/*in*/const ResumeTask fnResumeTask, 
		/*in*/const QueryStatus fnQueryStatus,
		/*in*/const LPVOID lpUserData);

	//����֪ͨ�¼�֪ͨ��Ϣ���������������߹ر�ʱ��
	MPC_FRAMERESULT	SetNotifyMsg(/*in*/const HWND hMsgWnd,
		/*in*/const UINT uGwShutdownMsgID = WM_NULL,
		/*in*/const UINT uGwStartupMsgID = WM_NULL);

	//���û�����������������Ҫ��������������Դ������ʹ�������ʽ�����û��ⷽʽ)
	MPC_FRAMERESULT	SetMutex(/*in*/const CString& strMutexType);

	//���������
	MPC_FRAMERESULT	PostAirInfo(/*in*/const ULONG ulJobID,
		/*in*/BOOL bRealtime,
		/*in*/const MPC_MediaFileArray& arrOutFile, 
		/*in*/const CString& strRemark = _T(""));

	MPC_RESULTTYPE	PausedTask(/*in*/const ULONG ulJobID);
	MPC_RESULTTYPE	SuspendedTask(/*in*/const ULONG ulJobID, 
		/*int*/const LPMPC_ATTACH pBreakpack = NULL);
	MPC_RESULTTYPE	ResumedTask(/*in*/const ULONG ulJobID);

	//�����ؼ���Դ
	MPC_FRAMERESULT FeedbackKeyResource(/*in*/const CString& strTaskGUID,
		/*in*/ const CString& strTaskName, 
		/*in*/ const LONG& lJobID, 
		/*in*/ const MPC_KEYRESITEMArray& arrKeyResItem);

	//�ֶ�����
	void			ManualMessage(_variant_t vtMsg);

	//���ã��������õ���IP��ַ/MQ����/����IP��ַ��
	static void		SvcFrameSetup(/*in*/const int nMaxTaskCount,
		/*in*/const HWND hParentWnd = NULL,
		/*out*/BOOL* pbNeedRestart = NULL);


	//��������ȷ����Զ�����Ϣ
	MPC_FRAMERESULT	PostUserMessage(/*in*/const CString& strMethod,
		/*in*/const _bstr_t& bstrMsgBody);


MPC_FRAMERESULT	SetCallBackHiveServiceStatus(const FunHiveServiceStatus fnHiveServiceStatus, LPVOID lpUserData); 

private:
	CHiveServiceFrame*	m_pServiceFrame;
};
