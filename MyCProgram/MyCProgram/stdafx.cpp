// stdafx.cpp : ֻ������׼�����ļ���Դ�ļ�
// MyCProgram.pch ����ΪԤ����ͷ
// stdafx.obj ������Ԥ����������Ϣ

#include "stdafx.h"

// TODO: �� STDAFX.H ��
// �����κ�����ĸ���ͷ�ļ����������ڴ��ļ�������




void Say(char* szWords,int nLen)
{
    strcpy(szWords,"Hello,World!");
    strcat(szWords,"\0");
}

float Sum(float fNum1,float fNum2)
{
    return fNum1+fNum2;
}

bool Test1(int a,OBJECT_SUMMARY & b,BSTR c ,int length)
{
		return a;
}