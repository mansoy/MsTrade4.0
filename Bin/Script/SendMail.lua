--公布出来的类
TOrderInfo = require "TOrderInfo";
TLuaFuns = require "TLuaFuns";

--订单的状态
tsNormal 	   = 100;
tsStart 	   = 0; 
tsSuccess 	 = 1;
tsDoing 	   = 2;
tsSuspend 	 = 3;
tsTargetFail = 4;
tsFail 		   = 5;
tsKillTask   = 6;

--公共变量
local GEnterGameTick = 0;      --账号进入游戏起始时间
local GChildInitBagMoney = 0;  --子号初始化背包金额
local GChildDurability = 0;    --子号附魔装备恢复耐久度
local GTaskType = 0;		   --任务类型

local GRoleName = '';
local GTargetRoleName = '';
local GSendNum = 0; --每次交易金币数
local GEachNum = 0; --此任务交易次数
local GCapturePath = '';

local GFeeX = -1;
local GFeeY = -1;

local VK_RETURN = 13;
local VK_ESCAPE = 27;
local VK_LEFT   = 37;
local VK_UP     = 38;
local VK_RIGHT  = 39;
local VK_DOWN   = 40;

local rsNormal       = 0;
local rsStallFinish  = 1; --子号摆摊完成，主号到达附魔地点
local rsEnchatFinish = 2; --主号附魔完成
local rsRecMoneyOk   = 3; --子号收到金币
local rsRecMoneyFail = 4; --子号未收到金币
local rsTargetFail   = 5; --对方任务失败，直接结束
local rsFinish       = 6; --子号任务结束

function fnGetStepNameById(id)
	local sRet = '';
	if id == 0 then sRet = '初始状态'; end;
	if id == 1 then sRet = '子号摆摊完成，主号到达附魔地点'; end;
	if id == 2 then sRet = '主号附魔完成'; end;
	if id == 3 then sRet = '子号收到金币'; end;
	if id == 4 then sRet = '子号未收到金币'; end;
	if id == 5 then sRet = '对方任务失败，直接结束'; end;
	if id == 6 then sRet = '子号任务结束'; end;
	
	return sRet;
end

--[[
function inspect(table, name) 
  print ("--- " .. name .. " consists of");
  for n,v in pairs(table) do print(n, v) end;
  print();
end

inspect(TOrderInfo, "TOrderInfo");
inspect(TLuaFuns, "TLuaFuns");
--]]

--[[
	--分割字符串的用法
	local str = "A,B,C,D,E,F,G,H,I"  
	local ta  = lua_string_split(str,",")  
	
	for key, value in ipairs(ta) do      
		print(key, value, ta[key]);   
	end  
	  
	--local size = table.getn(ta)  
	for i = 1, #ta do  
	  print(ta[i])  
	end 
--]]

--分割字符串
function string.split(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil;
	end
	
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result;
end

--根据窗口标题关闭该窗口
function CloseWindowByTitle(title)
    local cmd = [[taskkill /F /FI "WINDOWTITLE eq %s"]];
    cmd = string.format(cmd, title);
    os.execute(cmd)
end

--根据进程名关闭窗口
function CloseWindowByProcessName(name)
    local cmd  = [[taskkill /F /FI "IMAGENAME eq %s"]];
    cmd = string.format(cmd, name);
    os.execute(cmd);
end

--取随机数
function fnGetRandom(iFrom, iEnd)
	math.randomseed(os.time());
	local rand = math.random(iFrom, iEnd);
	if (rand < iFrom) or (rand > iEnd) then
		return -1;
	end
	return rand;
end

function fnOpenMenu()
	local iRet = 0;
	local iX = -1;
	local iY = -1;
	for i = 1,9 do
		--iRet = TLuaFuns:MsFindString('游戏菜单(Esc)', TLuaFuns:MsGetPianSe('菜单_普通标题'));
		iRet = TLuaFuns:MsFindString('结束游戏', 'e6c89b-000000');
		if iRet ~= 0 then return 1; end
		TLuaFuns:MsPressEsc();
		TLuaFuns:MsSleep(500);
	end
	return 0;
end

function fnCloseMenu()
	local iRet = 0;
	local iX = -1;
	local iY = -1;
	for i = 1,9 do
		--iRet = TLuaFuns:MsFindString('游戏菜单(Esc)', TLuaFuns:MsGetPianSe('菜单_普通标题'));
		iRet = TLuaFuns:MsFindString('结束游戏', 'e6c89b-000000');
		print(i, iRet);
		if iRet == 0 then return 1; end
		TLuaFuns:MsPressEsc();
		TLuaFuns:MsSleep(500);
	end
	return 0;
end

function fnOpenMap()
	local iRet = 0;
	fnCloseMenu();
	for i=0,9 do
		if TLuaFuns:MsFindImg('Map.bmp', 0.8) == 1 then
			iRet = 1;
			break;
		end
		TLuaFuns:MsPressChar('N');
		TLuaFuns:MsSleep(500);
	end
	if (iRet == 0) then
		TLuaFuns:MsPostStatus('打开地图未找到暗黑城！', tsFail);
		return 0;
	end
	return 1;
end

function fnCloseMap()
	local iRet = 0;
	for i=0,9 do
		TLuaFuns:MsPressEsc();
		TLuaFuns:MsSleep(500);
		if TLuaFuns:MsFindImg('Map.bmp', 0.8) == 0 then
			iRet = 1;
			break;
		end
	end
	if (iRet == 0) then
		TLuaFuns:MsPostStatus('关闭地图失败！', tsFail);
		return 0;
	end
	return 1;
end

--检测启动目标0: 启动超时 1：登录窗口 2：修复窗口
function fnCheckStartTarget()
	print('检测启动目标...');
	local hDengLu = 0; 
	local hXiuFu = 0;
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = TLuaFuns:MsGetDelay('启动游戏等待') * 1000;
	print(string.format('CurTick: %d WaitTick: %d', dwTickCount, dwWaitTick));	
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck(0) == 0 then
			return -1, 0;
		end
		hXiuFu = TLuaFuns:MsFindWindow('', '地下城与勇士修复工具');
		if TLuaFuns:MsIsWindow(hXiuFu) == 1 then
			break;	
		end	
			
		hDengLu = TLuaFuns:MsFindWindow('', '地下城与勇士登录程序');
		if TLuaFuns:MsIsWindow(hDengLu) == 1 then
			break;	
		end
	end
	
	if (TLuaFuns:MsIsWindow(hDengLu) == 0) and (TLuaFuns:MsIsWindow(hXiuFu) == 0) then      
		TLuaFuns:MsPostStatus('启动游戏超时', tsFail);
        return 0, 0;
    end

	if (TLuaFuns:MsIsWindow(hDengLu) == 1) then      
        print('打开的是登录窗口');
        return hDengLu, 1;
    end 
	
	if TLuaFuns:MsIsWindow(hXiuFu) == 1 then      
        print('打开的是修复窗口');
        return hXiuFu, 2;
    end
end

--修复游戏
function fnRepairGame()
	TLuaFuns:MsPostStatus('开始修复游戏文件');
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = TLuaFuns:MsGetDelay('安全验证等待') * 1000;
	local bRepairOK = false;
	local hXiufu = TLuaFuns:MsGetGameHandle();
	while TLuaFuns:MsGetTickCount() - dwTickCount < dwWaitTick do
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			return 0;
		end
		if TLuaFuns:MsFindImg('RepairOk.bmp') ~= 0 then
			--点击去顶按钮
			TLuaFuns:MsSleep(1000);
			break;
		end
	end
	if not bRepairOK then
		TLuaFuns.MsPostStatus('游戏文件修复超时', tsFail);
        return 0;
	end
	print('修复文件完成');
	return 1;
end

--登陆时检测弹窗，并关闭
function fnCloseLoginPopupWindow()
	local hPopup = 0;
	
	hPopup = TLuaFuns:MsFindWindow('TWINCONTROL', 'DNF视频播放器');
	if 1 == TLuaFuns:MsIsWindow(hPopup) then
	end  
end

--启动游戏
function fnStartGame()
	local iRet = 0;
	local hGame = 0;
	TLuaFuns:MsPostStatus('启动游戏...');
	while true do
		TLuaFuns:MsSleep(100);
		iRet = TLuaFuns:MsStartGame();
		if (0 == iRet) then
			print('启动游戏失败');
			return 0;
		end 
		
		hGame, iRet = fnCheckStartTarget();
		if -1 == hGame then
			return 0;
		end
		if (0 == iRet) and (TLuaFuns:MsIsWindow(hGame) == 0) then
			TLuaFuns:MsPostStatus('启动游戏超时', tsFail);
			return 0;
		end
		
		TLuaFuns:MsSetGameHandle(hGame);
		print('设置登录窗口句柄');		
		if iRet == 1 then
			return 1;	
		end 
		
		if iRet == 2 then 
			fnRepairGame();
		end
	end
end

--选择区服
function fnSelGameArea()
	TLuaFuns:MsPostStatus('等待游戏更新');
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = TLuaFuns:MsGetDelay('游戏更新等待') * 1000;
	local X = -1;
	local Y = -1;
	local iRet = -1;
	local bRet = false;
	local hLogin = TLuaFuns:MsGetGameHandle();	
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			print('更新中断');
			return 0;
		end
		X, Y = TLuaFuns:MsFindImgEx('InSelArea.bmp', 0.8);
		if (X ~= -1) and (Y ~= -1) then 
			print('更新完成');
			break;
		end
	end
	
	if (X == -1) or (Y == -1) then 
		TLuaFuns:MsPostStatus('游戏更新超时', tsFail);
		return 0;
	end	
	TLuaFuns:MsPostStatus('等待选择区服');
	
	dwTickCount = TLuaFuns:MsGetTickCount();
	dwWaitTick = TLuaFuns:MsGetDelay('选择区服等待') * 1000;
	
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			return 0;
		end
		
		if (0 == TLuaFuns:MsFindString('正在连接服务器...', 'ffffff-000000')) then  
			bRet = true;
			break;
		end
	end
	
	if not bRet then
		TLuaFuns:MsPostStatus('选择服务器超时', tsFail);
		return 0;
	end
	
	--点击登陆游戏按钮
    TLuaFuns:MsClick(X+30, Y+60, 150, 20);
	
	bRet = false;
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			return 0;
		end
		
		X, Y, iRet = TLuaFuns:MsFindImgEx('SvrFill.bmp');
		if (X ~= -1) and  (Y ~= -1) then
			TLuaFuns:MsClick(X + 70, Y + 115, 20, 10);
		end
				
		X, Y, iRet = TLuaFuns:MsFindStringEx('您选择的大区延迟过大|该服务器正在维护，无法进入|该服务器已经爆满', 'ffffff-000000');
		if 0 == iRet then
			TLuaFuns:MsClick(X + 50, Y + 120, 10, 5);
		end
		if 1 == iRet then
			TLuaFuns:MsPostStatus('该服务器正在维护，无法进入', tsFail);
			return 0;
		end
		if 2 == iRet then
			TLuaFuns:MsClick(X + 70, Y + 120, 10, 5);
		end
		
		X, Y, iRet = TLuaFuns:MsAreaFindImgEx(530, 280, 780, 360, 'DelayBig.bmp', 0.8);
		if 0 == iRet then
			print('大区延时过大');
			TLuaFuns:MsClick(X + 50, Y + 120, 20, 5);
			--TLuaFuns:MsPressEnter();
		end	
		
		X, Y, iRet = TLuaFuns:MsFindImgEx('InLogin.bmp|InSelArea.bmp', 0.9);
		if 0 == iRet then 
			bRet = true;
			break;
		end
		if 1 == iRet then 
			--TLuaFuns:MsClick(X, Y, 60, 12);
			TLuaFuns:MsClick(X+30, Y+60, 100, 20);
		end
	end
	
	if not bRet then
		TLuaFuns:MsPostStatus('选择服务器超时', tsFail);
		return 0;
	end
	
	TLuaFuns:MsPostStatus('选择服务器成功');
	TLuaFuns:MsPostStatus('等待安全检查...');
	bRet = false;
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = TLuaFuns:MsGetDelay('安全验证等待') * 1000;
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			return 0;
		end
		--X, Y, iRet = TLuaFuns:MsFindImgEx('WaitCheck.bmp', 0.8, 5);
		X,Y,iRet = TLuaFuns:MsAreaFindImgEx(1210,600,1290,700, 'WaitCheck.bmp', 0.8, 5);
		print(X, Y, iRet);
		if iRet == -1 then
			bRet = true;
			break;
		end
	end	
	
	if not bRet then
		TLuaFuns:MsPostStatus('安全检查超时', tsFail);
		return 0;
	end
	
	TLuaFuns:MsPostStatus('安全检查完成');
	return 1;
end

--登录判断
function fnLoginValidate()
	print('登录判断...');
	--local sAccount = TOrderInfo.GetAccount();
	--local sPassword = TOrderInfo.GetPassWord();
	local hGame = 0;
	local bRet = false;
	local bNeedDaMa = false;
	local iRet = 0;
	local iX = -1;
	local iY = -1;
	local sCode = '';
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = TLuaFuns:MsGetDelay('异地登陆检测等待') * 1000;
	local hLogin = TLuaFuns:MsGetGameHandle();
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		--主窗口出现，登录完成
		hGame = TLuaFuns:MsFindWindow('地下城与勇士','地下城与勇士');
		if TLuaFuns:MsIsWindow(hGame) ~= 0 then
			TLuaFuns:MsSetGameHandle(hGame);
			return 1;
		end
		
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		iRet = TLuaFuns:MsFindImg('ComponentFail.bmp');
		if 0 ~= iRet then
			TLuaFuns:MsPostStatus('客户端安全组件加载失败', tsFail);
			return 0;
		end
		iX, iY, iRet = TLuaFuns:MsFindStringEx('请输入帐号|请输入密码|您的QQ暂时无法登录', 'f4dcaf-000000|fcc45c-000000|ffffff-000000', 1.0, 2);			
		if 0 == iRet then
			TLuaFuns:MsPostStatus('QQ账号为空', tsFail, false);
			return 0;
		elseif 1 == iRet then
			TLuaFuns:MsPostStatus('密码为空', tsFail, false);
			return 0;
		--elseif 2 == iRet then
		--	TLuaFuns:MsPostStatus('客户端安全组件加载失败', tsFail, false);
		--	return 0;
		elseif 2 == iRet then
			TLuaFuns:MsPostStatus('您的QQ暂时无法登录，请恢复正常使用', tsFail, false);
			return 0;
		end
		bNeedDaMa = false;
		iX, iY, iRet = TLuaFuns:MsFindImgEx('PwdError.bmp|NeedDm.bmp', 0.8, 2);
		if 0 == iRet then
			TLuaFuns:MsClick(iX + 128, iY + 125, 10, 5);			
			return 99;
		end
		if 1 == iRet then
			bNeedDaMa = true;
			bRet = false;
			TLuaFuns:MsPostStatus('发现异地登录验证请求');
			--截取验证码图片
			print('截取验证码图片');
			--iRet = TLuaFuns:MsCaptureArea(iX, iY - 70, iX + 125, iY - 20, 'CheckCode.bmp');
			iRet = TLuaFuns:MsCaptureArea(iX, iY - 60, iX + 135, iY-5, 'CheckCode.bmp');
			if iRet ~= 0 then
				--打码兔打码
				print('开始打码...');
				sCode = TLuaFuns:MsDaMa('CheckCode.bmp', 12);
				print(string.format('验证码: %s', sCode));
				if sCode ~= '' then
					TLuaFuns:MsPostStatus(string.format('打码机传过来的码值: %s', sCode));
					--输入验证码
					print('输入验证码...');
					--TLuaFuns:MsClick(iX + 300, iY - 40, 10, 5);
					TLuaFuns:MsClick(iX + 250, iY - 30, 10, 5);
					TLuaFuns:MsSleep(500);
					TLuaFuns:MsPressString(hLogin, sCode);
					TLuaFuns:MsSleep(500);
					TLuaFuns:MsPressEnter();
					print('验证码输入完成');
					bRet = true;
				end
			end
			dwTickCount = TLuaFuns:MsGetTickCount();
		end
	end
	if bNeedDaMa and (bRet == false) then
		TLuaFuns:MsPostStatus('打码兔打码失败', tsFail);
		return 0;
	end
end

--登录游戏
function fnLoginGame()
	TLuaFuns:MsPostStatus('等待输入账号密码...');
	local sAccount = TOrderInfo.GetAccount();
	local sAreaName = TOrderInfo.GetAreaName();
	local hGameHandle = 0; -- = TLuaFuns:MsGetGameHandle();
	local hPwd = 0;
	local X1 = 0;
	local X2 = 0;
	local Y1 = 0;
	local Y2 = 0;
	local iTop = 0;
	local iLeft = 0;
	local iCount = 0;
	
	--关闭游戏广告
	--CloseWindowByTitle('DNF视频播放器');
	--CloseWindowByProcessName('AdvertDialog.exe');
	--TLuaFuns:MsPostStatus('关闭广告弹窗...');
	local hAdvert = TLuaFuns:MsFindWindow('','DNF视频播放器');
	if 0 ~= TLuaFuns:MsIsWindow(hAdvert) then 
		TLuaFuns:MsSendMessage(hAdvert, 16);
	end
	
	hGameHandle = TLuaFuns:MsFindWindow('','地下城与勇士登录程序');
	if 0 == TLuaFuns:MsIsWindow(hGameHandle) then
		TLuaFuns:MsPostStatus('登陆窗口异常退出', tsFail);
		return 0;
	end
	
	TLuaFuns:MsSetGameHandle(hGameHandle);
	TLuaFuns:MsPostStatus(string.format('开始登录[%s|%s]...',TOrderInfo:GetAccount(), TOrderInfo:GetAreaName()));
	if TLuaFuns:MsCheck() == 0 then
		return 0;
	end
	
	local hTmp = TLuaFuns:MsFindWindowEx(hGameHandle, 0, 'Normal', '');
	local hChild = TLuaFuns:MsFindWindowEx(hTmp, 0, 'Edit', '');

	if TLuaFuns:MsIsWindow(hChild) ~= 0 then
		hPwd = hChild;
		X1, Y1, X2, Y2 = TLuaFuns:MsGetClientRect(hChild);
		iTop = Y1;
		iLeft = X1;
	end

	print(X1, Y1, hPwd);
	hChild = TLuaFuns:MsFindWindowEx(hTmp, hPwd, 'Edit', '');
	if TLuaFuns:MsIsWindow(hChild) ~= 0 then
		X1, Y1, X2, Y2 = TLuaFuns:MsGetClientRect(hChild);
	end

	if iTop < Y1 then
		hPwd = hChild;
		iLeft = X1;
		iTop = Y1;
	end
	print(X1, Y1, hPwd);
	iLeft = iLeft + 30;
	iTop = iTop + 5;
	print(iLeft, iTop);
	::lbPwdRePress::
	
	TLuaFuns:MsSleep(3000);
	TLuaFuns:MsFrontWindow(hGameHandle);
	TLuaFuns:MsClick(iLeft, iTop);
	print('创建IoPress.exe进程');
	TLuaFuns:MsPressPassWord(0, TOrderInfo:GetPassWord());
	print('创建IoPress.exe进程完成');
	TLuaFuns:MsFrontWindow(hGameHandle);
	TLuaFuns:MsClick(iLeft, iTop);
	TLuaFuns:MsSleep(5000);
	print('点击回车');
	--TLuaFuns:MsPressEnter();
	TLuaFuns:MsClick(iLeft, iTop+120);
	TLuaFuns:MsPostStatus('密码输入完成，开始登陆校验...');
	--登录判断
	iRet = fnLoginValidate();
	if 0 == iRet then
		return 0;
	elseif 99 == iRet then
		if iCount >= 2 then
			TLuaFuns:MsPostStatus(string.format('账号或密码不正确'), tsFail, false);
			return 0;
		end
		iCount = iCount + 1;
		goto lbPwdRePress;
	end
	return 1;
end

--选择频道
function fnSelChannel()
	TLuaFuns:MsPostStatus('进入游戏,等待选择频道...');
	local iRet = 0;
	local hGame = 0;
	local hLogin = 0;
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = TLuaFuns:MsGetDelay('进入游戏等待');
	dwWaitTick = (dwWaitTick + TLuaFuns:MsGetDelay('安全验证等待')) * 1000;	
	--local dwNoLoginWindow = TLuaFuns:MsGetTickCount();
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		--找到主窗口 break;
		hGame = TLuaFuns:MsFindWindow('地下城与勇士','地下城与勇士');
		if 0 ~= TLuaFuns:MsIsWindow(hGame) then
			break;
		end
		
		--主窗口还没找到，登录窗口消失，则异常退出
		--[[20160705colin
		hLogin = TLuaFuns:MsFindWindow('','地下城与勇士登录程序');
		if 0 == TLuaFuns:MsIsWindow(hLogin) then
			TLuaFuns:MsPostStatus('登陆窗口异常退出', tsFail);
			return 0;
		end
		--]]
		--if TLuaFuns:MsCheck() == 0 then
		--	return 0;
		--end
	end
	if 0 == TLuaFuns:MsIsWindow(hGame) then
		TLuaFuns:MsPostStatus('选择频道超时...', tsFail);
		return 0;
	end
	TLuaFuns:MsSetGameHandle(hGame);
	--[[
	dwTickCount = TLuaFuns:MsGetTickCount();
	dwWaitTick = TLuaFuns:MsGetDelay('选择频道等待') * 1000;
	print(dwTickCount, dwWaitTick);
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			return 0;
		end		
		iRet = TLuaFuns:MsFindString('顺畅|良好|普通|拥挤|爆满', TLuaFuns:MsGetPianSe('登陆_选择频道'));
		if iRet ~= 0 then
			break;
		end
	end
	if iRet == 0 then
		TLuaFuns:MsPostStatus('选择频道超时...', tsFail);
		return 0;
	end
	local iPosX = -1;
	local iPosY = -1;
	TLuaFuns:MsPostStatus('开始选择频道...');
	
	print('点击频道...');

	if GTaskType == 1 then
		--分仓点击固定坐标
		TLuaFuns:MsDbClick(580, 450);
	elseif GTaskType == 0 then
		iRet = 0;
		for i=0, 3 do
			if i > 0 then
				-- 下一页
				TLuaFuns:MsClick(425, 475);
				iRet = TLuaFuns:MsFindString('顺畅|良好|普通|拥挤|爆满', TLuaFuns:MsGetPianSe('登陆_选择频道'), 1.0, 50);			
				if iRet == 1 then
					--break;
				end
			end
			iPosX, iPosY = TLuaFuns:MsFindStringEx('顺畅|良好|普通|拥挤', TLuaFuns:MsGetPianSe('登陆_选择频道'));
			if (iPosX ~= -1) and (iPosY ~= -1) then
				break;
			end
		end
		if (iPosX == -1) or (iPosY == -1) then
			TLuaFuns:MsPostStatus('所有频道爆满', tsFail);
			return 0;
		end
		TLuaFuns:MsDbClick(iPosX, iPosY);
		--TLuaFuns:MsDbClick(iPosX, iPosY);
		--TLuaFuns:MsSleep(500);
	end
	TLuaFuns:MsSleep(100);		
	--]]
	TLuaFuns:MsPostStatus('选择频道完成');
	return 1;	
end

--选择角色
function fnSelRole()
	local iX = -1;
	local iY = -1;
	local iRet = -1;
	local IsEnterRolePage = false;
	local dwTickCount = TLuaFuns:MsGetTickCount();
	--选择频道步骤取消了， 但是游戏进入角色界面还是需要时间， 所以， 把时间加到了这里
	--local dwSelRoleDelay = TLuaFuns:MsGetDelay('选择角色等待') * 1000;
	local dwSelChannelDelay = TLuaFuns:MsGetDelay('选择频道等待') * 1000;
	--local dwWaitTick = dwSelRoleDelay + dwSelChannelDelay;
	local dwWaitTick = dwSelChannelDelay;
	local sRoleBmpName = TOrderInfo:GetRoleImgName();
	TLuaFuns:MsPostStatus(string.format('等待选择角色[%s]...',GRoleName));
	
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		::lblSelRole::
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			return 0;
		end
		iX, iY, iRet = TLuaFuns:MsFindImgEx('SelRole.bmp', 1.0, 5);
		if -1 == iRet then
			iX, iY = TLuaFuns:MsFindStringEx('顺畅|良好|普通|拥挤|爆满', TLuaFuns:MsGetPianSe('登陆_选择频道'));
			if (iX ~= -1) and (iY ~= -1) then
				if GTaskType == 1 then
					TLuaFuns:MsDbClick(580, 450);
				elseif GTaskType == 0 then
					TLuaFuns:MsDbClick(iX + 5, iY + 5);
				end				
				TLuaFuns:MsSleep(100);
			end
			goto lblSelRole;
		end
		
		if  IsEnterRolePage == false then
			IsEnterRolePage = true;
			--刚开始选择角色的时候，先将滚动条拉直最顶端
			TLuaFuns:MsClick(130, 230);
			TLuaFuns:MsSleep(500);
			TLuaFuns:MsPressKey(38);	--按上箭头
			TLuaFuns:MsSleep(300);
			TLuaFuns:MsPressKey(38);
			TLuaFuns:MsSleep(300);
			TLuaFuns:MsPressKey(38);
		end
			
		iX, iY = TLuaFuns:MsFindImgEx('Cancel.bmp', 0.8);
		if (iX ~= -1) and (iY ~= -1) then
			TLuaFuns:MsClick(iX + 5, iY + 5, 10, 5);
			TLuaFuns:MsSleep(100);
			TLuaFuns:MsClick(iX + 5, iY + 5, 10, 5);
			TLuaFuns:MsSleep(100);
		end
		
		iX, iY, iRet = TLuaFuns:MsFindStringEx('此ID已在游戏中|连接失败！|取消后将无法再推荐|正在连接服务器', 'ffffff-000000');
		
		if 0 == iRet then
			TLuaFuns:MsPostStatus('此ID已在游戏中', tsFail, false);
			return 0;
		end
		
		if 1 == iRet then
			TLuaFuns:MsPostStatus('连接失败', tsFail);
			return 0;
		end
		if 2 == iRet then
			TLuaFuns:MsClick(iX + 40, iY + 60, 10, 5);
			TLuaFuns:MsSleep(100);
			TLuaFuns:MsClick(iX + 40, iY + 60, 10, 5);
			TLuaFuns:MsSleep(100);
		end
		if 3 == iRet then
			goto lblSelRole;
		end
				
		print(string.format('角色图片[%s]', sRoleBmpName));
		iX, iY = TLuaFuns:MsFindImgEx(sRoleBmpName);
		if (iX ~= -1) and (iY ~= -1) then
			--20160707colin
			if 0 ~= TLuaFuns:MsFindImg('FreezeMoney.bmp', 1.0, 3) then
				TLuaFuns:MsPostStatus('资产冻结', tsFail, False);
				return 0;
			end
			--
			break;
		end
		--[[iX, iY = TLuaFuns:MsFindStringEx(GRoleName, TLuaFuns:MsGetPianSe('登陆_选择角色'), 0.7);
		if (iX ~= -1) and (iY ~= -1) then
			--20160707colin
			if 0 ~= TLuaFuns:MsFindImg('FreezeMoney.bmp', 1.0, 3) then
				TLuaFuns:MsPostStatus('资产冻结', tsFail, False);
				return 0;
			end
			--
			break;
		end--]]
		--如果没有找到角色图片，则下拉查找
		TLuaFuns:MsClick(130, 230);
		TLuaFuns:MsSleep(500);
		TLuaFuns:MsPressKey(40);
		TLuaFuns:MsSleep(500);
		TLuaFuns:MsPressKey(40);
	end
	
	if not IsEnterRolePage then
		TLuaFuns:MsPostStatus('进入角色页面超时', tsFail);
		return 0;
	end
	
	if (iX == -1) or (iY ==	-1) then
		print('没有找到角色，下拉再试下');

		TLuaFuns:MsClick(130, 230);
		TLuaFuns:MsSleep(500);
		TLuaFuns:MsPressKey(40);
		TLuaFuns:MsSleep(500);
		TLuaFuns:MsPressKey(40);
		
--[[		local hGame = 0;
		local iTop = -1;
		local iLeft = -1;
		hGame = TLuaFuns:MsGetGameHandle();
		
		iLeft, iTop = TLuaFuns:MsGetTopLeft(hGame);
		TLuaFuns:MsClick(iLeft + 580, iTop  + 495);--]]
		iX, iY, iRet = TLuaFuns:MsFindImgEx(sRoleBmpName, 1.0, 5);	
		print(iX, iY, iRet);
	end
	
	if (iX == -1) or (iY == -1) then
		TLuaFuns:MsPostStatus(string.format('卖家角色[%s]不存在！', GRoleName), tsFail, False);
		return 0;
    end;
	print(string.format('角色位置 X[%d]Y[%d]', iX, iY));
	GEnterGameTick = TLuaFuns:MsGetTickCount();
	TLuaFuns:MsPostStatus(string.format('找到角色[%s]', GRoleName));		
	TLuaFuns:MsDbClick(iX + math.random(1,20), iY  + math.random(1,20));
	TLuaFuns:MsSleep(300);
	TLuaFuns:MsDbClick(iX + math.random(1,20), iY  + math.random(1,20));
	TLuaFuns:MsSleep(300);
	TLuaFuns:MsDbClick(iX + math.random(1,20), iY  + math.random(1,20));
	TLuaFuns:MsSleep(300);
	TLuaFuns:MsPostStatus('角色选择完成');
	return 1;
end

--退回到角色界面
function fnBackToRoler()
	TLuaFuns:MsPostStatus('等待返回角色界面...');
	local iX, iY;
	local iRet = 0;
	local dwWaitTick = 30 * 1000;
	local dwTickCount = TLuaFuns:MsGetTickCount();
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		iRet = TLuaFuns:MsFindImg('SelRole.bmp');
		if 0 ~= iRet then 
			TLuaFuns:MsPostStatus('返回角色界面完成');
			return 1;
		end
		
		fnOpenMenu();
		iX, iY, iRet = TLuaFuns:MsFindImgEx('CloseGame.bmp');
		if (iX ~= -1) and (iY ~= -1) then
			TLuaFuns:MsClick(iX - 135, iY - 10, 3, 3);
		end
		fnCloseMenu();
	end
	if 0 == iRet then 
		TLuaFuns:MsPostStatus('返回角色界面超时', tsFail);
		return 0;
	end
end

--判断是否进入游戏
function fnIsEnterTheGame(iDelay)	
	local hGame = TLuaFuns:MsFindWindow('地下城与勇士', '地下城与勇士');
	if 0 == TLuaFuns:MsIsWindow(hGame) then
		return -1;
	end	
	TLuaFuns:MsSetGameHandle(hGame);
	local iRet = -1;
	local iX = -1;
	local iY = -1;
	local dwWaitTick = iDelay * 1000;
	local dwTickCount = TLuaFuns:MsGetTickCount();
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		fnOpenMenu();
		iX, iY, iRet = TLuaFuns:MsFindImgEx('CloseGame.bmp|MagicRatio.bmp|MailBox.bmp|LoginSuccess.bmp|LoginSuccess1.bmp', 1.0, 1);
		fnCloseMenu();
		if iRet ~= -1 then break; end
	end
	if iRet == -1 then
		
	end
	print('IsEnterTheGame:', iRet, iX, iY);
	return iRet;
end

--进入游戏
function fnEnterTheGame()
	TLuaFuns:MsPostStatus('等待角色进入游戏...');
	local bRet = false;
	local iX = -1;
	local iY = -1;
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = TLuaFuns:MsGetDelay('进入游戏等待') * 1000;
	local IsEnterTheGame = false;
	local iRet = 0;
	local hGame = TLuaFuns:MsGetGameHandle();
	if 0 == TLuaFuns:MsIsWindow(hGame) then
		hGame = TLuaFuns:MsFindWindow('地下城与勇士', '地下城与勇士');
		TLuaFuns:MsSetGameHandle(hGame);
	end
	while (TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick) do
		bRet = false;
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		
		TLuaFuns:MsSleep(100);
		TLuaFuns:MsPressEsc();
		TLuaFuns:MsSleep(200);
		TLuaFuns:MsPressEsc();
		
		iX, iY, iRet = TLuaFuns:MsFindImgEx('Ok.bmp|GiveUp.bmp|Enter.bmp|NextStep.bmp');
		if -1 ~= iRet then
			TLuaFuns:MsClick(iX + 5, iY + 5, 10, 5);
			bRet = true;
		end  
		----------          -------------------------
		iX, iY, iRet = TLuaFuns:MsFindStringEx('确认|关闭|接受礼物|林纳斯的礼物|私人秘书梦娜', TLuaFuns:MsGetPianSe('登陆_关闭广告'));
		if (0 == iRet) or (1 == iRet) then
			TLuaFuns:MsClick(iX + 5, iY + 5, 10, 5);
			bRet = true;
		end
		if 2 == iRet then
			TLuaFuns:MsClick(iX + 150, iY + 10, 10, 5);
			bRet = true;
		end
		if (3 == iRet) or (4 == iRet) then
			TLuaFuns:MsClick(iX + 390, iY + 5, 10, 5);
			bRet = true;
		end
		TLuaFuns:MsSleep(100);
		TLuaFuns:MsPressChar('L');
		TLuaFuns:MsSleep(200);
		TLuaFuns:MsPressChar('L');
		TLuaFuns:MsSleep(100);
		
		if not IsEnterTheGame then
			iRet = fnIsEnterTheGame(1);
			IsEnterTheGame = iRet ~= -1;
		end

		fnCloseMenu();
		if (not bRet) and IsEnterTheGame then 
			if (TLuaFuns:MsGetTickCount() - dwTickCount > 15 * 1000) then break; end
		end
	end
	
	if not IsEnterTheGame then
		TLuaFuns:MsPostStatus('角色进入游戏超时', tsFail);
		return 0;
	end	

	TLuaFuns:MsPostStatus('角色进入游戏完成');
	return 1;
end


--打开邮件箱。不在房间的时候按Esc打开邮件箱
function fnOpenMailBoxByEsc()
	local iRet = 0;
	local iX = -1;
	local iY = -1;
	local bOpen = false;
	iX, iY, iRet = TLuaFuns:MsFindImgEx('NoSet.bmp');
	TLuaFuns:MsClick(iX, iY);
	for i=1, 5 do
		--Foxit By ManSoy 2017-09-21
		--iX, iY, iRet = TLuaFuns:MsFindImgEx('MailBox.bmp');
		iX, iY, iRet = TLuaFuns:MsFindImgEx('CloseGame.bmp');
		print(iX, iY, iRet);
		if (iX ~= -1) and (iY ~= -1) then
			TLuaFuns:MsClick(iX - 185, iY - 220);
			print(string.format('邮件箱位置(%d,%d)', iX-135, iY-220));
			--TLuaFuns:MsPostStatus(string.format('邮件箱位置(%d,%d)', iX-135, iY-220));
			TLuaFuns:MsSleep(500);
			iX, iY, iRet = TLuaFuns:MsFindStringEx('邮件保管箱', TLuaFuns:MsGetPianSe('邮寄_邮件箱_未选中'));
			if (0 == iRet) then
				bOpen = true;
				break;
			end
		end
		TLuaFuns:MsPressEsc();
		TLuaFuns:MsSleep(500);
	end	
	
	if not bOpen then
		TLuaFuns:MsPostStatus('打开邮件箱失败', tsFail);
		return 0;
	end
	--关闭提示框
	iX, iY, iRet = TLuaFuns:MsFindStringEx('邮箱中存在未接收的邮件', 'ffffff-000000');
	if (iX ~= -1) and (iY ~= -1) then
		TLuaFuns:MsClick(iX + 75, iY + 65, 10, 5);
	end
	TLuaFuns:MsPostStatus('打开邮件箱完成');
	return 1;
end

--打开邮件箱
function fnOpenMailBox()
	TLuaFuns:MsPostStatus('等待打开邮件箱...');
	local iRet = 0;
	local iX = -1;
	local iY = -1;
	local bRet = false;
	local sPianSe = '';
	--iRet = TLuaFuns:MsFindString('游戏菜单(Esc)|好友(L)', TLuaFuns:MsGetPianSe('菜单_普通标题'));
	iRet = TLuaFuns:MsFindString('结束游戏|好友(L)', TLuaFuns:MsGetPianSe('菜单_普通标题'));
	if 0 ~= iRet then
		TLuaFuns:MsPressEsc();
	end	
	--fnCloseMenu();
	
	sPianSe = string.format('%s|%s', TLuaFuns:MsGetPianSe('邮寄_邮件箱_未选中'), TLuaFuns:MsGetPianSe('邮寄_邮件箱_NPC'));
	for i=1, 3 do
		TLuaFuns:MsSleep(200);
		iX, iY, iRet = TLuaFuns:MsFindStringEx('邮件保管箱|邮件箱', sPianSe);
		if 0 == iRet then
			--已经打开
			bRet = true;
			break;
		end
		if 1 == iRet then
			print(string.format('点击邮件箱X[%d]Y[%d]', iX, iY));
			TLuaFuns:MsClick(iX + 20, iY + 50, 10, 5);
			TLuaFuns:MsSleep(100);
			TLuaFuns:MsClick(iX + 20, iY + 50, 10, 5);
			TLuaFuns:MsSleep(1000);
		end
	end
	
	if not bRet then
		TLuaFuns:MsPostStatus('打开邮件箱失败', tsFail);
		return 0;
	end
	--关闭提示框
	iX, iY, iRet = TLuaFuns:MsFindStringEx('邮箱中存在未接收的邮件', 'ffffff-000000');
	if (iX ~= -1) and (iY ~= -1) then
		TLuaFuns:MsClick(iX + 75, iY + 65, 10, 5);
	end
	TLuaFuns:MsPostStatus('打开邮件箱完成');
	return 1;
end

--点击发送邮件标签
function fnClickSendMailLabel()
	TLuaFuns:MsPostStatus('等待点击发送邮件页签...');
	local iRet = 0;
	local bRet = false;
	local iX = -1; local iY = -1;
	iX, iY = TLuaFuns:MsFindStringEx('发送邮件', TLuaFuns:MsGetPianSe('邮寄_邮件箱_未选中'), 1.0, 5);
	if (iX == -1) or (iY == -1) then
		TLuaFuns:MsPostStatus('游戏已自动关闭', tsFail);
		return 0;
	end
	for i=1, 3 do
		iRet = TLuaFuns:MsFindImg('SendMail_1.bmp');
		if 0 ~= iRet then
			bRet = true;
			break;
		end
		TLuaFuns:MsClick(iX, iY, 40, 8);
		TLuaFuns:MsSleep(2200);
	end
	
	if not bRet then
		TLuaFuns:MsPostStatus('点击发送邮件页签失败', tsFail);
		return 0;
	end
	TLuaFuns:MsPostStatus('点击发送邮件页签完成');
	return 1;
end

--输入角色名
function fnInputRoleName(sRoleName)
	TLuaFuns:MsPostStatus('等待输入对方角色名...');
	local bRet = false;
	local iX = -1;
	local iY = -1;
	for i=1, 3 do
		bRet = false;
		iX, iY = TLuaFuns:MsFindImgEx('SendMail_1.bmp');
		if (iX ~= -1) and (iY ~= -1) then
			bRet = true;
			break;
		end 
	end
	
	if not bRet then
		TLuaFuns:MsPostStatus('没有打开邮件箱', tsFail);
		return 0;
	end
	local hGame = TLuaFuns:MsGetGameHandle();
	local sReceiptRoleImg = TOrderInfo:GetReceiptRoleImgName();	
	for i=1, 3 do		
		--输入角色名
		TLuaFuns:MsClick(iX + 50, iY + 27, 20, 5);
		TLuaFuns:MsSleep(500);
		TLuaFuns:MsPressDel(12);
		TLuaFuns:MsSleep(500);
		TLuaFuns:MsPressString(hGame, sRoleName);
		TLuaFuns:MsSleep(500);
		
		iRet = TLuaFuns:MsFindImg(sReceiptRoleImg);
		if (iRet ~= 0) then
			TLuaFuns:MsPostStatus('对方角色名输入完成');
			return 1;
		end
		TLuaFuns:MsSleep(500);
	end
	TLuaFuns:MsPostStatus('对方角色名输入失败');
	return 0;
end

--输入金额
function fnInputMoney(ANum)
	TLuaFuns:MsPostStatus('等待输入金额...');
	local hGame = TLuaFuns:MsGetGameHandle();
	local iX = -1;
	local iY = -1;
	local iRet = -1;
	for i=1, 3 do
		iX, iY, iRet = TLuaFuns:MsFindImgEx('SendMoney.bmp');
		
		if i > 1 then
			TLuaFuns:MsPostStatus('等待输入的金额与订单金额验证...');
			iRet = TLuaFuns:MsGetNumber(iX + 50, iY - 5, iX + 170, iY + 15, 'ffffff-000000');
			print(iRet, ANum);
			if ANum == iRet then
				TLuaFuns:MsPostStatus('输入的金额与订单金额验证完成');
				return 1;				
			end
		end
		TLuaFuns:MsClick(iX + 140, iY + 6);
		TLuaFuns:MsSleep(500);
		TLuaFuns:MsClick(iX + 140, iY + 6);
		TLuaFuns:MsSleep(500);
		TLuaFuns:MsClick(iX + 100, iY + 6, 60, 1);
		TLuaFuns:MsSleep(500);
		TLuaFuns:MsPressDel(20);
		TLuaFuns:MsSleep(500);
		local sMoney = string.format('%d', ANum);
		TLuaFuns:MsPressString(hGame, sMoney);
		TLuaFuns:MsPostStatus('金额输入完成');
	end
	return 0;
end

--获取背包金额
function fnGetBagMoney()
	local iRet = -1;
	local iMoney = -1;
	local iX = -1;
	local iY = -1;
	
	for i=0, 9 do
		iX, iY, iRet = TLuaFuns:MsFindStringEx('装备栏(I)', TLuaFuns:MsGetPianSe('菜单_普通标题'));
		if (iX ~= -1) and (iY ~= -1) then
			iMoney = TLuaFuns:MsGetNumber(iX + 30, iY + 475, iX + 130, iY + 505, TLuaFuns:MsGetPianSe('邮寄_背包金额'));
			if iMoney ~= -1 then
				TLuaFuns:MsPostStatus('获取背包金额完成');
				break;
			end
		end	
		TLuaFuns:MsPressChar('I');
		TLuaFuns:MsSleep(500);
	end
	return iMoney;
end

function fnIsCrossSvr()
	local sRecGameSvr = TOrderInfo:GetReceiptGameSvr();
	local sGameSvr = TOrderInfo:GetAreaName();
	
	if string.find(sGameSvr, sRecGameSvr) == nil then
		--如果能在发货区服中找到收获区服，说明是同区发货，直接点击确定就可以了， 如果找不到，说明不同区，需要选择区服
		return true;
	end
	print('123');
	return false;
end

function fnSelRecGameSvr()
	local iX = -1;
	local iY = -1;
	local bSelOk = true;
	local iRet = -1;
	local iResult = -1;
	for i=0, 9 do
		iX, iY, iRet = TLuaFuns:MsFindStringEx('请选择接收人的大区|角色名称|该ID不存在', 'ffffff-000000', 1.0, 2);
		if iRet == 0 then			
			if fnIsCrossSvr() then
				bSelOk = false;
				--如果能在发货区服中找到收获区服，说明是同区发货，直接点击确定就可以了， 如果找不到，说明不同区，需要选择区服
				TLuaFuns:MsClick(iX + 135, iY + 31, 2, 2);
				local iTmpX = -1;
				local iTmpY = -1;
				for n=0,9 do
					iTmpX, iTmpY = TLuaFuns:MsFindImgEx('RecGameSvr_1.bmp', 1.0, 1);
					if (iTmpX ~= -1) and (iTmpY ~= -1) then
						TLuaFuns:MsClick(iTmpX + 15, iTmpY + 5, 20, 5);
						break;
					end
					for m=0,4 do
						TLuaFuns:MsMoveTo(iX + 80, iY + 60);
						TLuaFuns:MsSleep(30);
						TLuaFuns:MsWheelDown();
					end
				end
				iTmpX, iTmpY = TLuaFuns:MsFindImgEx('RecGameSvr_2.bmp', 1.0, 2);
				if (iTmpX ~= -1) and (iTmpY ~= -1) then
					bSelOk = true;
				end
			end
			if bSelOk then
				--选择完成后点击确定按钮
				TLuaFuns:MsClick(iX + 60, iY + 53, 20, 10);
				TLuaFuns:MsSleep(500);
			end
		elseif -1 ~= iRet then
			iResult = 1;
			break;
		end
	end
	return iResult;
end

--校验对方角色
function fnCheckRoleInfo(ASendNum, IsCheckRole)
	TLuaFuns:MsPostStatus('等待校验对方角色名...');
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = 5 * 1000;
	local iX = -1;
	local iY = -1;
	local iPosX = -1;
	local iPosY = -1;
	
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		
		iX, iY = TLuaFuns:MsFindStringEx('确定', TLuaFuns:MsGetPianSe('邮寄_邮件箱_未选中'));
		if (iX ~= -1) and (iY ~= -1) then
			TLuaFuns:MsClick(iX + 10, iY + 5);
			TLuaFuns:MsSleep(1000);
		end 
		
		iX, iY = TLuaFuns:MsFindStringEx('发送邮件', TLuaFuns:MsGetPianSe('邮寄_邮件箱_已选中'));
		if (iX ~= -1) and (iY ~= -1) then
			break;
		end 
	end
	
	dwTickCount = TLuaFuns:MsGetTickCount();
	dwWaitTick = TLuaFuns:MsGetDelay('检测角色存在等待') * 1000 + 30000;
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do		
		TLuaFuns:MsSleep(100);
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end		
		TLuaFuns:MsClick(iX + 120, iY + 25);
		
		--TLuaFuns:MsSleep(1000);		
		--Add 20171221, 选择收货角色区服
		
		--iPosX, iPosY = TLuaFuns:MsFindStringEx('请选择接收人的大区', 'ffffff-000000', 1);
		--if (iPosX ~= -1) and (iPosY ~= -1) then	
		--	TLuaFuns:MsClick(iPosX + 60, iPosY + 53, 20, 10);
		--	TLuaFuns:MsSleep(500);
		--end
		
		fnSelRecGameSvr();
				
		iPosX = -1;
		iPosY = -1;
		
		iPosX, iPosY = TLuaFuns:MsFindStringEx('选择', 'ffffff-000000')
		
		if (iPosX ~= -1) and (iPosY ~= -1) then			
			TLuaFuns:MsPressKey(13);
			TLuaFuns:MsPressKey(10);
			TLuaFuns:MsSleep(500);
			TLuaFuns:MsPressKey(13);
			TLuaFuns:MsPressKey(10)
		else
			iPosX, iPosY = TLuaFuns:MsFindStringEx('公告', TLuaFuns:MsGetPianSe('菜单_普通标题'));
			if (iPosX ~= -1) and (iPosY ~= -1) then
				break;			
			end
		end
		iPosX = -1; iPosY = -1;
	end
		
	if (iPosX == -1) or (iPosY == -1) then
		TLuaFuns:MsPostStatus('任务暂停，请关闭角色选择框...', tsSuspend);
		TLuaFuns:MsSleep(1000);
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		--TLuaFuns:MsPostStatus('角色名输入失败', tsFail);
		--return 0;
	end
	
	if not IsCheckRole then
		return 1;
	end
	
	dwTickCount = TLuaFuns:MsGetTickCount();
	dwWaitTick = 5 * 1000;
	local iRet = -1;
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end

		iX, iY, iRet = TLuaFuns:MsFindStringEx('角色名称|无法找到该角色', 'ffffff-000000');
		if 0 == iRet then
			break;
		end
		if 1 == iRet then
			TLuaFuns:MsPostStatus(string.format('对方角色[%s]不存在',GTargetRoleName), tsTargetFail, false);
			return 0;
		end
	end
	if (iX == -1) or (iY == -1) then
		TLuaFuns:MsPostStatus(string.format('对方角色[%s]不存在',GTargetRoleName), tsTargetFail, false);
		return 0;
	end	
	
	--获取等级
	local iLevel = 0;
	print(iX, iY + 5, iX + 150, iY + 35);
	for i=1, 3 do
		iLevel = TLuaFuns:MsGetNumber(iX, iY + 5, iX + 150, iY + 35, 'ffffff-000000');
		if iLevel > -1 then
			print(string.format('获取对方角色等级为: %d 坐标：%d %d', iLevel, iX, iY));
			break;
		end
	end
	
	if iLevel == -1 then
		TLuaFuns:MsPostStatus(string.format('获取角色[%s]的等级失败', GTargetRoleName), tsFail);
		return 0;
	end
	
	if iLevel <= 20 then		
		TLuaFuns:MsPostStatus(string.format('对方角色[%s]等级过低，超出携带量，请换号', GTargetRoleName), tsFail);
		return 0;
	end
	
	TLuaFuns:MsPostStatus('判断携带量');
	if iLevel > 0 then
		--判断携带量
		local iCarry = -1; --TLuaFuns:MsGetCarryAmount(iLevel);
		print(iCarry);
		print(ASendNum);
		if iCarry > 0 then
			if iCarry < ASendNum then
				TLuaFuns:MsPostStatus('发货数量超过对方的携带量，任务终止', tsFail, False);
				return 0;
			end
		end
	end
	
	TLuaFuns:MsPostStatus('校验对方角色名完成');
		
	if 1 == TOrderInfo:GetCheckLevel() then
		TLuaFuns:MsPostStatus('等待校验对方角色等级...');
		local iReceiptLevel = TOrderInfo:GetReceiptLevel();
		TLuaFuns:MsPostStatus(string.format('等待校验对方角色等级,自己的等级[%d]对方等级[%d]...',iLevel,iReceiptLevel));
		if iLevel ~= iReceiptLevel then
			TLuaFuns:MsPostStatus(string.format('角色[%s]订单等级[%d]与实际等级[%d]不符，不予处理', GTargetRoleName, iReceiptLevel, iLevel), tsTargetFail, false);
			return 0;
		end
		TLuaFuns:MsPostStatus('校验对方角色等级完成');
	end
	
	return 1;
end

--发送邮件时打码
function fnDaMaOfSendMail(hGameHandle, ATimes)
	local iRet = 0;
	local iX = -1;
	local iY = -1;
	local bRet = false;
	for i=1, 3 do
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		iX, iY = TLuaFuns:MsFindImgEx('MailCheckCodeDlg.bmp', 0.8);
		print(iX,iY);
		if (iX ~= -1) and (iY ~= -1) then
			iRet = TLuaFuns:MsCaptureArea(iX - 205, iY - 148, iX - 82, iY - 97, 'CheckCode.bmp');
			print(iRet);
			if 0 ~= iRet then
				break;
			end
		end			
	end

	if iRet == 0 then
		print('获取验证码失败...');
		return 0;
	end
	
	for i=1, 9 do
		bRet = false;
		TLuaFuns:MsPostStatus('发送邮件验证码到打码机');
		local sRet = TLuaFuns:MsDaMa('CheckCode.bmp', 12);
		print(sRet);
		if sRet ~= '' then
			print('输入验证码...');
			TLuaFuns:MsPressString(hGameHandle, sRet);
			TLuaFuns:MsSleep(500);
			
			--截图1（输完验证码）
			local sCaptureName = string.format('%s%s_%d_%d_1.bmp', GCapturePath, TOrderInfo:GetOrderNo(), TOrderInfo:GetRoleID(), ATimes+1);
			TLuaFuns:MsCaptureGame(sCaptureName);
			print(string.format('输完验证码_截图1_%s', sCaptureName));
			
			if 0 == TLuaFuns:MsCheck() then
				return 0;
			end
			print('点击确定按钮');
			for j=1, 3 do
				TLuaFuns:MsClick(iX - 150, iY + 2, 50, 10);
				TLuaFuns:MsPostStatus(string.format('发送邮件按钮坐标[X=%d,Y=%d]',iX - 150, iY + 2));
				TLuaFuns:MsSleep(2000);
				iRet = TLuaFuns:MsFindImg('MailCheckCodeDlg.bmp', 0.8, 2);
				if 0 == iRet then
					bRet = true;
					break;
				end
			end	
			if bRet then
				break;
			end
		end
		TLuaFuns:MsSleep(1);
	end
	
	if not bRet then
		TLuaFuns:MsPostStatus('打码兔打码失败', tsFail);
		return 0;
	end
	return 1;
end

--等待邮件发送结果 
function fnCheckSendResult(ATimes)
	TLuaFuns:MsPostStatus('等待等待邮件发送结果...');
	local iResult = -1;
	local iRet = 0;
	local x, y;
	local hGame = TLuaFuns:MsGetGameHandle();
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = TLuaFuns:MsGetDelay('邮件验证码窗口等待') * 1000;
	dwWaitTick = dwWaitTick + 5000;
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		
		if 0 ~= TLuaFuns:MsFindImg('MailCheckCodeDlg.bmp', 0.8, 2) then
			iRet = 1;
			break;
		end
		x, y, iResult = TLuaFuns:MsFindStringEx('已成功发送邮件|您在对方的黑名单内|已超出金币的使用限制|相比收件人的', 'ffffff-000000');			
		if 0 == iResult then
			iRet = 2;
			break;
		end
		if 1 == iResult then
			TLuaFuns:MsPostStatus('您在对方的黑名单内，无法进行操作', tsFail, False);
			return 0;
		end
		if 2 == iResult then
			TLuaFuns:MsPostStatus('已超出金币的使用限制', tsFail, False);
			return 0;
		end
		if 3 == iResult then
			TLuaFuns:MsPostStatus('发货数量超过对方的携带量，任务终止', tsFail, False);
			return 0;
		end
	end
	
	if iRet == 0 then
		TLuaFuns:MsPostStatus('等待发送结果超时', tsFail);
		return 0;
	end
	
	if iRet == 1 then
		iRet = fnDaMaOfSendMail(hGame, ATimes);
		
		if iRet == 0 then
			print('远程打码失败...');
			return 99;  --这里返回99的话， 说明就不在继续处理
		end
		iRet = 0;
		local dwTickCount = TLuaFuns:MsGetTickCount();
		local dwWaitTick = TLuaFuns:MsGetDelay('检测结果等待') * 1000;
		while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
			TLuaFuns:MsSleep(100);
			if 0 == TLuaFuns:MsCheck() then
				return 0;
			end
			
			x, y, iResult = TLuaFuns:MsFindStringEx('已成功发送邮件|您在对方的黑名单内|已超出金币的使用限制|相比收件人的', 'ffffff-000000');			
			if 0 == iResult then
				iRet = 2;
				break;
			end
			if 1 == iResult then
				TLuaFuns:MsPostStatus('您在对方的黑名单内，无法进行操作', tsFail, False);
				return 0;
			end
			if 2 == iResult then
				TLuaFuns:MsPostStatus('已超出金币的使用限制', tsFail, False);
				return 0;
			end
			if 3 == iResult then
				TLuaFuns:MsPostStatus('发货数量超过对方的携带量，任务终止', tsFail, False);
				return 0;
			end
		end            
	end
	
	if iRet == 2 then		
		--截图2（邮件发送成功）
		local sCaptureName = string.format('%s%s_%d_%d_2.bmp', GCapturePath, TOrderInfo:GetOrderNo(), TOrderInfo:GetRoleID(), ATimes+1);
		TLuaFuns:MsCaptureGame(sCaptureName);
		TLuaFuns:MsPostStatus(string.format('邮件发送成功_截图2_%s', sCaptureName));
		--TLuaFuns:MsSleep(1000);
		--TLuaFuns:MsClick(x + 45, y + 35, 10, 5);
		return 1;
	end
	return 0;
end

--解安全
--1: 成功，不需要解安全 2: 成功，需要解安全 3: 失败， 需要解安全
function fnQuitSafe()
	local iRet = 3;
	local dwWaitTick = 0;
	local iX,iY;
	local sRet;
	TLuaFuns:MsPostStatus('检测是否需要解安全...');
	iX, iY = TLuaFuns:MsFindStringEx('确定解除', 'ddc593-000000');
	if (iX == -1) or (iY == -1) then
		print('不需要解安全');
		return 1;
	end
	--iX,iY = TLuaFuns:MsGetTopLeft(TLuaFuns:MsGetGameHandle());
	TLuaFuns:MsClick(iX + 100, iY + 5);
	TLuaFuns:MsPostStatus('账号需要解绑，程序开始解安全...');
	sRet = TLuaFuns:MsQuitSafe();

	if 'OK' ~= sRet then
		TLuaFuns:MsPostStatus(sRet, tsSuspend);
		return 3;
	end
	
	dwWaitTick = TLuaFuns:MsGetDelay('解绑成功后等待') * 1000;
	dwTickCount = TLuaFuns:MsGetTickCount();
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		if 0 ~= TLuaFuns:MsFindString('您的账户已成功退出安全模式', 'ffffff-000000') then
			TLuaFuns:MsPressEnter();
			TLuaFuns:MsSleep(100);
		end
	end
	TLuaFuns:MsPostStatus('解安全完成');
	return 2;
end

--一次发货操作，订单可能会分批处理
function fnSingleSend(ASendNum, ATimes)
	local iRet = 0;	
	local iSysStock = TOrderInfo:GetStock() * 10000;
	if 0 == TLuaFuns:MsCheck() then
		return 0;
	end
	--判断有没有打开邮件箱
	iRet = TLuaFuns:MsFindImg('CloseGame.bmp', 1.0, 3);
	if 0 == iRet then
		if 0 == fnOpenMailBoxByEsc() then 
			return 0;
		end
		
		if 0 == fnClickSendMailLabel() then
			return 0;
		end
	end
	
	print('获取库存金额');	
	local iBagMoney = fnGetBagMoney();
	if iBagMoney == -1 then
		TLuaFuns:MsPostStatus('获取背包金额失败', tsFail);
		return 0;
	end
	
	--iBagMoney = iBagMoney / 10000;
	local iStockFloat = TOrderInfo:GetStockFloat() * 10000;
	local iExpendNum = math.ceil(ASendNum * 0.05);
	TLuaFuns:MsPostStatus(string.format('当前库存: %d 系统库存: %d', iBagMoney, iSysStock));
	if iBagMoney - math.ceil(ASendNum * 0.05) < ASendNum then 
		TLuaFuns:MsPostStatus(string.format('背包金额[%d]小于需要交易的金额[%d]+消数量[%d]', iBagMoney, ASendNum, iExpendNum), tsFail, False);
        return 0;
	end

	if (ATimes == 0) and (math.abs(iBagMoney - iSysStock) > iStockFloat) then
		TLuaFuns:MsPostStatus(string.format('实际库存[%d]与系统库存[%d]误差大于系统设置误差[%d]', iBagMoney, iSysStock, iStockFloat), tsFail, False);
        return 0;
	end	
	
	--输入对方角色名
	TLuaFuns:MsPostStatus('开始校验对方角色名长度...');
	if 12 < string.len(GTargetRoleName) then
		TLuaFuns:MsPostStatus('对方角色名长度不符合规定', tsTargetFail, false);
		return 0;
	end
	if 0 == fnInputRoleName(GTargetRoleName) then
		--TLuaFuns:MsPostStatus('角色名输入失败', tsFail);
        return 0;
	end
	if 0 == fnCheckRoleInfo(ASendNum, true) then 
		return 0;
	end
	
	--输入金额
	--local hGame = TLuaFuns:MsGetGameHandle();
	--local iX = -1;
	--local iY = -1;
	--iX, iY = TLuaFuns:MsGetTopLeft(hGame);
	--if 0 == fnInputMoney(iX + 320, iY + 412, ASendNum) then
	if 0 == fnInputMoney(ASendNum) then
		TLuaFuns:MsPostStatus('输入金额失败', tsFail);
		return 0;
	end
	
	--[[
	--核对对方角色名字是否和订单一致
	local custRolerImg = TOrderInfo:GetReceiptRoleImgName();
	TLuaFuns:MsPostStatus(string.format('校验输入的对方角色名[%s]和订单是否一致...',GTargetRoleName));
	iRet = TLuaFuns:MsFindImg(custRolerImg);
	if 0 == iRet then
		TLuaFuns:MsPostStatus(string.format('输入的对方角色[%s]和订单不一致',GTargetRoleName), tsTargetFail, false);
		return 0;
	end
	--]]
	
	
	--截图0（输完金额）
	local sCaptureName = string.format('%s%s_%d_%d_0.bmp', GCapturePath, TOrderInfo:GetOrderNo(), TOrderInfo:GetRoleID(), ATimes+1);
	TLuaFuns:MsCaptureGame(sCaptureName);
	print(string.format('输完金额_截图0_%s', sCaptureName));
	
	for i=1, 9 do
		print(i);
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		
		if 0 == ATimes then
			TLuaFuns:MsPostStatus('60秒安全等待开始...');
			while TLuaFuns:MsGetTickCount() - GEnterGameTick < 55000 do
				TLuaFuns:MsSleep(10);
			end
			TLuaFuns:MsPostStatus('60秒安全等待结束...');
		end
		
		if i > 1 then
			if 0 == fnCheckRoleInfo(0, false) then
				return 0;
			end
		end
		
		--点 发送 按钮
		print('点击鼠标，发送邮件');
		--TLuaFuns:MsSleep(5000);
		
		--fnCloseZhuangBeiLan();		
		--fnDragMailBox();
		--fnDragRoleBox();
		
		iX, iY, iRet = TLuaFuns:MsFindImgEx('SendMoney.bmp', 1.0, 5);
		print(iX, iY, iRet);
		TLuaFuns:MsClick(iX + 15, iY + 50, 20, 10);
		TLuaFuns:MsSleep(100);
		TLuaFuns:MsClick(iX + 15, iY + 50, 20, 10);
		--TLuaFuns:MsClick(iX + 260, iY + 465, 10, 5);
		--TLuaFuns:MsSleep(100);
		--TLuaFuns:MsClick(iX + 260, iY + 465, 10, 5);
		TLuaFuns:MsSleep(1000);
		if 0 == ATimes then
			iRet = fnQuitSafe();

			if iRet == 3 then
				if 0 == TLuaFuns:MsCheck() then
					return 0;
				end
			end
			
			if iRet == 2 then
				print('需要解安全，并且解安全成功了，再次点击发送按钮');  
				if 0 == fnCheckRoleInfo(0, false) then
					return 0;
				end
				TLuaFuns:MsSleep(100);
				TLuaFuns:MsClick(iX + 15, iY + 50, 20, 10);
				TLuaFuns:MsSleep(100);
				TLuaFuns:MsClick(iX + 15, iY + 50, 20, 10);
				--TLuaFuns:MsClick(iX + 260, iY + 465, 10, 5);
				--TLuaFuns:MsSleep(100);
				--TLuaFuns:MsClick(iX + 260, iY + 465, 10, 5);
			end	
		end
		print('查找验证码弹出框');
		iRet = fnCheckSendResult(ATimes);
		if 99 == iRet then
			--打码失败
			--TLuaFuns:MsPostStatus(string.format('订单[%s]已发货[%d]', TOrderInfo.GetOrderNo(), ASendNum));
			return 0;
		end;
		
		if 0 ~= iRet then
			TLuaFuns:MsPostStatus(string.format('订单[%s]已发货[%d]', TOrderInfo.GetOrderNo(), ASendNum));
			return 1;
		end;
	end
	return 0;
end

function fnSendMail()
	local iOrderNum = TOrderInfo:GetSendNum();
	local iDispatchNum = TOrderInfo:GetEachNum();
	local iOddNum = 0;
	local iTimes = 0;
	if iDispatchNum >= iOrderNum then
		iDispatchNum = iOrderNum;
	end
	iOddNum = iOrderNum;
	while true do
		TLuaFuns:MsSleep(100);
		iRet = fnSingleSend(iDispatchNum * 10000, iTimes);
		
		if 0 == iRet then
			return 0;
		end
		iOddNum = iOddNum - iDispatchNum;
		print(string.format('结果=%d 已发货数量= %d 剩余数量 = %d', iRet, iOrderNum - iOddNum, iOddNum));	
		if iOddNum <= 0 then
			break;
		end
		
		if iOddNum < iDispatchNum then
			iDispatchNum = iOddNum;
		end
		
		iTimes = iTimes + 1;
	end
	
	local iBagMoney = fnGetBagMoney();
	if iBagMoney ~= -1 then
		local iNewBagMoney = math.floor(iBagMoney/10000);
		TOrderInfo:SetReStock(iNewBagMoney);
	end
	TLuaFuns:MsPostStatus('发货完成...', tsSuccess, False);
	return 1;
end

function fnSwitchChannel()
	
	local iX = -1;
	local iY = -1;
	local iRet = -1;
	local bRet = false;
	if not fnIsCrossSvr() then
		--如果是同区发货， 就没有必要切换频道
		return 1;
	end
	
	iX, iY, iRet = TLuaFuns:MsFindImgEx('DefChannel.bmp|Trade_Auction.bmp', 1.0, 2);
	if iRet == -1 then
		return 1;
	end
	
	TLuaFuns:MsPostStatus('开始切换频道');
		
	for i=0,3 do
		TLuaFuns:MsClick(iX + 20, iY + 2, 20, 5);
		local iTmpX = -1; 
		local iTmpY = -1;
		local iTmpRet = -1;
		
		iTmpX, iTmpY, iTmpRet = TLuaFuns:MsFindImgEx('GenArea_1.bmp|GenArea_2.bmp', 1.0, 2);
		
		if iTmpRet ~= -1 then
			bRet = true;
			break;
		end		
	end
	
	if not bRet then
		TLuaFuns:MsPostStatus('切换频道失败，任务暂停', tsSuspend);
		TLuaFuns:MsSleep(1000);
		--任务暂停后， 人为手动处理完成， 脚本就认为频道已经切换成功
		TLuaFuns:MsCheck();
		return 1;
	end
	
	bRet = false;
	
	iX, iY, iRet = TLuaFuns:MsFindImgEx('GenArea_1.bmp|GenArea_2.bmp', 1.0, 2);	
	if iRet == 0 then
		for i=0,3 do
			TLuaFuns:MsClick(iX + 20, iY + 2, 20, 5);
			local iTmpX = -1; 
			local iTmpY = -1;
			local iTmpRet = -1;
			
			iTmpX, iTmpY, iTmpRet = TLuaFuns:MsFindImgEx('GenArea_1.bmp|GenArea_2.bmp', 1.0, 2);
			
			if iTmpRet == 1 then
				bRet = true;
				break;
			end		
		end
	end
	
	if not bRet then
		TLuaFuns:MsPostStatus('切换频道失败，任务暂停', tsSuspend);
		TLuaFuns:MsSleep(1000);
		--任务暂停后， 人为手动处理完成， 脚本就认为频道已经切换成功
		TLuaFuns:MsCheck();
		return 1;
	end
	
	bRet = false;
	for i= 0,3 do
		iX, iY, iRet = TLuaFuns:MsFindImgEx('SwitchChannel.bmp', 1.0, 2);
		print(iX, iY, iRet);
		if iRet == 0 then
			TLuaFuns:MsDbClick(iX + 25, iY + 5);
			local iTmpX = -1; 
			local iTmpY = -1;
			local iTmpRet = -1;
			
			iTmpX, iTmpY, iTmpRet = TLuaFuns:MsFindImgEx('ConSvr.bmp', 1.0, 2);
			if iTmpRet == 0 then
				bRet = true;
				break;
			end
		end
	end
	
	if not bRet then
		TLuaFuns:MsPostStatus('切换频道失败，任务暂停', tsSuspend);
		TLuaFuns:MsSleep(1000);
		--任务暂停后， 人为手动处理完成， 脚本就认为频道已经切换成功
		TLuaFuns:MsCheck();
		return 1;
	end
	
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = TLuaFuns:MsGetDelay('进入游戏等待') * 1000;
	
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		::lblSelRole::
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			return 0;
		end
		
		if -1 ~= fnIsEnterTheGame(1) then
			TLuaFuns:MsPostStatus('切换频道完成');
			return 1;
		end		
	end

	return 0;
end

---------------------------------------------------------------------------------
function fnDispatchOrder()

	print('开始执行脚本');
	
	GRoleName = TOrderInfo:GetRole();
	GTargetRoleName = TOrderInfo:GetReceiptRole();
	GSendNum = TOrderInfo:GetSendNum()*10000; --每次交易金币数
	GEachNum = TOrderInfo:GetEachNum();       --此任务交易次数
	GTaskType = TOrderInfo:GetTaskType();
	GCapturePath = TOrderInfo:GetCapturePath();
	
	TLuaFuns:MsCreateBmp('该服务器已经爆满','SvrFull',255,255,255);

	--如果游戏OnLine，则返回角色界面选取角色
	local iRet = 0;
	print('开始执行脚本1');
	local bRet = false;
	if -1 ~= fnIsEnterTheGame(5) then
		if 0 ~= fnBackToRoler() then
			bRet = true;
		end
	end
	print('开始执行脚本2');
	if not bRet then
		iRet = fnStartGame();
		if 0 == iRet then
			return 0;
		end    
		print('开始执行脚本3');
		iRet = fnSelGameArea();
		if 0 == iRet then
			return 0;
		end
		print('开始执行脚本4');
		iRet = fnLoginGame();
		if 0 == iRet then
			return 0;
		end
		print('开始执行脚本5');
		iRet = fnSelChannel();
		if 0 == iRet then
			return 0;
		end
	end
	print('开始执行脚本6');
	iRet = fnSelRole();
	if 0 == iRet then
		return 0;
	end
	print('开始执行脚本7');
	iRet = fnEnterTheGame();
	if 0 == iRet then
		return 0;
	end	
	
	iRet = fnSwitchChannel();
	if 0 == iRet then
		return 0;
	end	

	print('开始发货');
	iRet = fnSendMail();
	return iRet;
end

fnDispatchOrder();
--[[
function Test()
	print('开始测试...');
	--os.execute("start IoPress.exe 1 a2V5YX4hQCMkfiUkfiVeKiYoKCkpeWEiOiIuPzwvLg==");
	--TLuaFuns:MsPressPassWord(TOrderInfo:GetPassWord());
	local hGame = 0;
	local iY = -1; 
	local iX = -1; 
	local iRet = -1;
	TLuaFuns:MsCreateBmp('该服务器已经爆满','SvrFull',255,255,255);
	hGame = TLuaFuns:MsFindWindow('','地下城与勇士登录程序');
	if TLuaFuns:MsIsWindow(hGame) == 0 then
		print('游戏没有打开');
		return;
	end
	iX, iY = TLuaFuns:MsFindImgEx('SvrFull.bmp');
	print(iX, iY);
	print('设置游戏句柄完成');
end

Test();
--]]