// ConsoleApplication3.cpp : �������̨Ӧ�ó������ڵ㡣
//

#include "stdafx.h"
#include "ETNXVideoStandardDef.h"


int _tmain(int argc, _TCHAR* argv[])
{
	printf("sss");
   	
	ET_VIDEO_HS_CLASS result =  ET_VideoStandardGetHSClass(1109461057);
	printf("result = %d",result);
	printf("sss");
	return 0;
}

