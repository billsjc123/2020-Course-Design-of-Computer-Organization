#include<cstdio>

int M[1005];
int R0,R1,R2,R3;
void print(int x)
{
	printf("==============%X==============\n",x);
	printf("R0:%X  ",R0);
	printf("R1:%X  ",R1);
	printf("R2:%X  ",R2);
	printf("R3:%X\n",R3);
	for(int i=0x60;i<=0x62;i++) printf("[%X]=%X  ",i,M[i]);puts("");
	for(int i=0x80;i<=0x83;i++) printf("[%X]=%X  ",i,M[i]);puts("");
	for(int i=0xFD;i<=0xFF;i++) printf("[%X]=%X  ",i,M[i]);puts("");
	puts("");
	puts("");
}
int main()
{
	R0=0,R1=0;
	R2=0x60,R3=0xFD;
	M[0x60]=0x67;
	M[0x61]=0x80;
	M[0x62]=0xFD;
	M[0x80]=0x60;
	M[0xFE]=0x03;
	M[0xFF]=0x03;
	bool C=0,Z=0;
	L00:
		R0=M[R2];
		print(0x00);
	L01:
		R2++;
		if(R2>255) R2-=256,C=1,Z=1;
		else C=0,Z=0;
		print(0x01);
	L02:
		R1=M[R2];
		print(0x02);
	L03:
		R0+=R1;
		if(R0>255)
		{
			R0-=256;
			C=1;
		}
		else C=0;
		print(0x03);
	L04:
		if(C) goto L06;
	L05:
		R1&=R0;
		print(0x05);
	L06:
		R0-=R2;
		if(R0<0) R0+=256,C=1;
		else C=0;
		print(0x06);
	L07:
		R1++;
		if(R1>255) R1-=256,C=1,Z=1;
		else C=0,Z=0;
		print(0x07);
	L08:
		M[R1]=R0;
		print(0x08);
	L09:
		R3++;
		if(R3>255) R3-=256,C=1,Z=1;
		else Z=0,C=0;
		print(0x09);
	L0A:
		if(Z) goto L0D;
	L0B:
		R2=M[R3];
		print(0x0B);
	L0C:
		if(R2==1) goto L01;
		if(R2==2) goto L02;
		if(R2==3) goto L03;
		if(R2==4) goto L04;
		if(R2==5) goto L05;
		if(R2==6) goto L06;
		if(R2==7) goto L07;
		if(R2==8) goto L08;
		if(R2==9) goto L09;
		if(R2==10) goto L0A;
		if(R2==11) goto L0B;
	L0D:
		R3++;
		print(0x0D);
	L0E:
		R3++;
		print(0x0E);
	L0F:
		R0-=R2;
		print(0x0F);
	L10:
		R2=M[R0];
		print(0x10);
	L11:
		R3+=R2;
		print(0x11);
	L12:
		R3=M[R3];
		print(0x12);
		
} 
