// stdafx.h : ��׼ϵͳ�����ļ��İ����ļ���
// ���Ǿ���ʹ�õ��������ĵ�
// �ض�����Ŀ�İ����ļ�
//

#pragma once

#include "targetver.h"
#include "ole2.h"

#define WIN32_LEAN_AND_MEAN             // �� Windows ͷ���ų�����ʹ�õ�����
// Windows ͷ�ļ�:
#include <windows.h>

typedef /* [public][public][public][public] */ struct  __MIDL___MIDL_itf_AKEnvelopeCom_0000_0026
    {
    BSTR strSrcAKGroup;
    BSTR strObjectName;
    BSTR strObjectCategory;
    BSTR strInstanceID;
    int nFileNumber;
    }	OBJECT_SUMMARY;

// TODO: �ڴ˴����ó�����Ҫ������ͷ�ļ�
extern "C" void Say(char* szWords,int nLen);                           //����Say��������
extern "C" float Sum(float fNum1,float fNum2);						   //����Sum��������
extern "C" bool Test1(int a,OBJECT_SUMMARY & b,BSTR c);

