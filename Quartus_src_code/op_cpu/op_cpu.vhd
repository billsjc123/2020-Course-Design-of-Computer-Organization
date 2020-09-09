LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY op_cpu IS
PORT (
      SWC : IN STD_LOGIC; --控制台模式
      SWB : IN STD_LOGIC;
      SWA : IN STD_LOGIC;
      CLR : IN STD_LOGIC; -- 复位
      T3 : IN STD_LOGIC;
      W3 : IN STD_LOGIC; --W3节拍
      W2 : IN STD_LOGIC; --W2节拍
      W1 : IN STD_LOGIC; --W1节拍
      IR : IN STD_LOGIC_VECTOR(7 DOWNTO 4);
      C : IN STD_LOGIC;
      Z : IN STD_LOGIC;
      S : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --运算类型
      M : OUT STD_LOGIC;
      CIN : OUT STD_LOGIC; --进位
      SEL3 : OUT STD_LOGIC; 
      SEL2 : OUT STD_LOGIC; -- ALU A
      SEL1 : OUT STD_LOGIC;
      SEL0 : OUT STD_LOGIC; -- ALU B
      SELCTL : OUT STD_LOGIC;
      LIR : OUT STD_LOGIC; --DBUS打入IR
      LDC : OUT STD_LOGIC; --在T3上升沿,保存进位
      LDZ : OUT STD_LOGIC; --在T3上升沿,保存结果为0标志
      LAR : OUT STD_LOGIC; --在T3上升沿,将DBUS打入AR
      LPC : OUT STD_LOGIC; --在T3上升沿,将DBUS打入PC
      PCINC : OUT STD_LOGIC; --在T3上升沿,将PC自增
      PCADD : OUT STD_LOGIC; --PC加偏移量
      ARINC : OUT STD_LOGIC; --在T3上升沿,将IR自增
      LONG : OUT STD_LOGIC; --长指令(W1 W2 W3)
      SHORT : OUT STD_LOGIC; --短指令(W1)
      ABUS : OUT STD_LOGIC; --运算器结果打入总线
      MBUS : OUT STD_LOGIC; --双端口RAM左端打入总线
      SBUS : OUT STD_LOGIC; --S打入总线
      DRW : OUT STD_LOGIC; --在T3上升沿,将总线数据写入SEL3SEL2选中的寄存器
      MEMW : OUT STD_LOGIC; --为1时,将总线数据写入AR指向的存储单元,为0时读存储器
      STOP : OUT STD_LOGIC --暂停信号
      );
END op_cpu ;

ARCHITECTURE logic of op_cpu is
   SIGNAL ST0 : STD_LOGIC := '0';
   SIGNAL SST0 : STD_LOGIC := '0';
   SIGNAL SW : STD_LOGIC_VECTOR (2 DOWNTO 0);
BEGIN
	SW <= SWC & SWB & SWA;
	PROCESS(SST0, T3, SW, CLR)
	BEGIN
		IF (CLR = '0') THEN 
			ST0 <= '0';
		ELSIF (T3'EVENT AND T3 = '0') THEN
			IF (SST0 = '1') THEN
				ST0 <= '1';
			END IF;
			IF (ST0 = '1' AND W2 = '1' AND SW = "100") THEN
				ST0 <= '0';
			END IF;
		END IF;
	END PROCESS;
	PROCESS(IR, ST0, W1, W2, W3, SW, C, Z)
	BEGIN
		S <= "0000";
		M <= '0';
		CIN <= '0';
		SEL3 <= '0';
		SEL2 <= '0';
		SEL1 <= '0';
		SEL0 <= '0';
		SELCTL <= '0';
		LIR <= '0';
		LDC <= '0';
		LDZ <= '0';
		LPC <= '0';
		LAR <= '0';
		PCINC <= '0';
		PCADD <= '0';
		ARINC <= '0';
		LONG <= '0';
		SHORT <= '0';
		ABUS <= '0';
		MBUS <= '0';
		SBUS <= '0';
		DRW <= '0';
		MEMW <= '0';
		STOP <= '0';
		SST0 <= '0';
		
		CASE SW IS
			WHEN "100" =>
				SBUS <= '1';
				SEL3 <= ST0;
				SEL2 <= W2;
				SEL1 <= (NOT ST0 AND W1) OR (ST0 AND W2);
				SEL0 <= W1;
				SELCTL <= '1';
				DRW <= '1';
				STOP <= '1';
				SST0 <= NOT ST0 AND W2;
			WHEN "011" =>
				SEL3 <= W2;
				SEL2 <= '0';
				SEL1 <= W2;
				SEL0 <= '1';
				SELCTL <= '1';
				STOP <= '1';
			WHEN "010" =>
				SBUS <= NOT ST0 AND W1;
				LAR <= NOT ST0 AND W1;
				SST0 <= NOT ST0 AND W1;
				STOP <= W1;
				SHORT <= W1;
				SELCTL <= W1;
				MBUS <= ST0 AND W1;
				ARINC <= ST0 AND W1;
			WHEN "001" =>
				SBUS <= W1;
				LAR <= NOT ST0 AND W1;
				SST0 <= NOT ST0 AND W1;
				STOP <= W1;
				SHORT <= W1;
				SELCTL <= W1;
				MEMW <= ST0 AND W1;
				ARINC <= ST0 AND W1;
			WHEN "000" =>
				IF (ST0 = '0') THEN
					SBUS <= W1;
					LPC <= W1;
					SHORT <= W1;
					SST0 <= W1;
				ELSIF (ST0 = '1') THEN
					LIR <= (W1 AND ((NOT IR(6) AND IR(5)) OR
									(NOT IR(7) AND NOT IR(6)) OR
									(NOT IR(7) AND NOT IR(5) AND NOT IR(4)) OR
									(NOT C AND NOT IR(7) AND IR(6) AND IR(5) AND IR(4)) OR
									(NOT Z AND IR(7) AND NOT IR(6) AND NOT IR(5) AND NOT IR(4)))) OR
							(W2 AND ((NOT IR(7) AND IR(6) AND NOT IR(5) AND IR(4)) OR
									(NOT IR(7) AND IR(6) AND IR(5) AND NOT IR(4)) OR
									(IR(7) AND NOT IR(6) AND NOT IR(5) AND IR(4)) OR
									(C AND NOT IR(7) AND IR(6) AND IR(5) AND IR(4)) OR
									(Z AND IR(7) AND NOT IR(6) AND NOT IR(5) AND NOT IR(4))));
									
					PCINC <= (W1 AND ((NOT IR(6) AND IR(5)) OR
									(NOT IR(7) AND NOT IR(6)) OR
									(NOT IR(7) AND NOT IR(5) AND NOT IR(4)) OR
									(NOT C AND NOT IR(7) AND IR(6) AND IR(5) AND IR(4)) OR
									(NOT Z AND IR(7) AND NOT IR(6) AND NOT IR(5) AND NOT IR(4)))) OR
							(W2 AND ((NOT IR(7) AND IR(6) AND NOT IR(5) AND IR(4)) OR
									(NOT IR(7) AND IR(6) AND IR(5) AND NOT IR(4)) OR
									(IR(7) AND NOT IR(6) AND NOT IR(5) AND IR(4)) OR
									(C AND NOT IR(7) AND IR(6) AND IR(5) AND IR(4)) OR
									(Z AND IR(7) AND NOT IR(6) AND NOT IR(5) AND NOT IR(4))));
									
					S(3) <= (W1 AND ((NOT IR(6) AND IR(4)) OR
									(NOT IR(7) AND NOT IR(5) AND IR(4)) OR
									(NOT IR(7) AND IR(6) AND IR(5) AND NOT IR(4)))) OR
							(W2 AND (NOT IR(7) AND IR(6) AND IR(5) AND NOT IR(4)));
							
					S(2) <= W1 AND ((NOT IR(6) AND IR(5) AND NOT IR(4)) OR
									(NOT IR(7) AND IR(5) AND NOT IR(4)) OR
									(IR(7) AND NOT IR(6) AND IR(4)) OR
									(IR(7) AND NOT IR(6) AND IR(5)));
									
					S(1) <= (W1 AND ((NOT IR(6) AND IR(5)) OR
									(NOT IR(7) AND IR(5) AND NOT IR(4)) OR
									(IR(7) AND NOT IR(6) AND IR(4)) OR
									(NOT IR(7) AND IR(6) AND NOT IR(5) AND IR(4)))) OR
							(W2 AND (NOT IR(7) AND IR(6) AND IR(5) AND NOT IR(4)));
					
					S(0) <= W1 AND ((NOT IR(6) AND IR(4)) OR
									(NOT IR(7) AND IR(6) AND IR(5) AND NOT IR(4)));
									
					CIN <= W1 AND ((NOT IR(7) AND NOT IR(6) AND NOT IR(5) AND IR(4)) OR
									(IR(7) AND NOT IR(6) AND IR(5) AND IR(4)));
						
					ABUS <= (W1 AND ((NOT IR(6) AND IR(4)) OR
									(NOT IR(6) AND IR(5)) OR
									(NOT IR(7) AND NOT IR(5) AND IR(4)) OR
									(NOT IR(7) AND IR(5) AND NOT IR(4)) OR
									(NOT IR(7) AND IR(6) AND NOT IR(4)) OR
									(NOT IR(7) AND IR(6) AND NOT IR(5)))) OR
							(W2 AND (NOT IR(7) AND IR(6) AND IR(5) AND NOT IR(4)));
					
					DRW <= (W1 AND ((NOT IR(6) AND IR(5)) OR
									(NOT IR(7) AND NOT IR(6) AND IR(4)) OR
									(NOT IR(7) AND IR(6) AND NOT IR(5) AND NOT IR(4)))) OR
							(W2 AND (NOT IR(7) AND IR(6) AND NOT IR(5) AND IR(4)));
					
					LDZ <= W1 AND ((NOT IR(6) AND IR(5)) OR
									(NOT IR(7) AND NOT IR(6) AND IR(4)) OR
									(NOT IR(7) AND IR(6) AND NOT IR(5) AND NOT IR(4)));
					
					LDC <= W1 AND ((NOT IR(7) AND NOT IR(6) AND NOT IR(5) AND IR(4)) OR
									(NOT IR(7) AND NOT IR(6) AND IR(5) AND NOT IR(4)) OR
									(NOT IR(7) AND IR(6) AND NOT IR(5) AND NOT IR(4)) OR
									(IR(7) AND NOT IR(6) AND IR(5) AND IR(4)));
					
					M <= (W1 AND ((NOT IR(7) AND NOT IR(6) AND IR(5) AND IR(4)) OR
									(NOT IR(7) AND IR(6) AND NOT IR(5) AND IR(4)) OR
									(NOT IR(7) AND IR(6) AND IR(5) AND NOT IR(4)) OR
									(IR(7) AND NOT IR(6) AND NOT IR(5) AND IR(4)) OR
									(IR(7) AND NOT IR(6) AND IR(5) AND NOT IR(4)))) OR
							(W2 AND (NOT IR(7) AND IR(6) AND IR(5) AND NOT IR(4)));
					
					LAR <= W1 AND ((NOT IR(7) AND IR(6) AND NOT IR(5) AND IR(4)) OR
									(NOT IR(7) AND IR(6) AND IR(5) AND NOT IR(4)));
					
					SHORT <= W1 AND ((NOT IR(6) AND IR(5)) OR
									(NOT IR(7) AND NOT IR(6)) OR
									(NOT IR(7) AND NOT IR(5) AND NOT IR(4)) OR
									(IR(7) AND IR(5) AND NOT IR(4)) OR
									(NOT C AND NOT IR(7) AND IR(6) AND IR(5) AND IR(4)) OR
									(NOT Z AND IR(7) AND NOT IR(6) AND NOT IR(5) AND NOT IR(4)));
					
					MBUS <= W2 AND (NOT IR(7) AND IR(6) AND NOT IR(5) AND IR(4));
					
					MEMW <= W2 AND (NOT IR(7) AND IR(6) AND IR(5) AND NOT IR(4));
					
					PCADD <= W1 AND ((C AND NOT IR(7) AND IR(6) AND IR(5) AND IR(4)) OR
									(Z AND IR(7) AND NOT IR(6) AND NOT IR(5) AND NOT IR(4)));
							
					LPC <= W1 AND (IR(7) AND NOT IR(6) AND NOT IR(5) AND IR(4));
					
					STOP <= W1 AND (IR(7) AND IR(6) AND IR(5) AND NOT IR(4));
				END IF;
			WHEN OTHERS => NULL;
		END CASE;
	END PROCESS;
END logic;
