--公布出来的类
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

local GCapturePath = '';
local GPassWord = '';
local GAccount = '';

local VK_RETURN = 13;
local VK_ESCAPE = 27;
local VK_LEFT   = 37;
local VK_UP     = 38;
local VK_RIGHT  = 39;
local VK_DOWN   = 40;

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
		iRet = TLuaFuns:MsFindString('游戏菜单(Esc)', 'ffffff-000000|b3b3b3-000000');
		if iRet ~= 0 then return 1; end
		TLuaFuns:MsPressEsc();
		TLuaFuns:MsSleep(500);
	end
	return 0;
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
			return 0;
		end
		X, Y = TLuaFuns:MsFindImgEx('InSelArea.bmp', 0.8);
		if (X ~= -1) and (Y ~= -1) then 
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
    	TLuaFuns:MsClick(X, Y, 100, 10);
	
	bRet = false;
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			return 0;
		end
		
		X, Y, iRet = TLuaFuns:MsFindStringEx('您选择的大区延迟过大|该服务器正在维护，无法进入|该服务器已经爆满', 'ffffff-000000');
		if 0 == iRet then
			TLuaFuns:MsClick(X + 100, Y + 120, 10, 5);
		end
		if 1 == iRet then
			TLuaFuns:MsPostStatus('该服务器正在维护，无法进入', tsFail);
			return 0;
		end
		if 2 == iRet then
			TLuaFuns:MsClick(X + 70, Y + 120, 10, 5);
		end
		
		X, Y, iRet = TLuaFuns:MsFindImgEx('DelayBig.bmp|InLogin.bmp|InSelArea.bmp', 0.8);
		if 0 == iRet then
			print('大区延时过大');
			TLuaFuns:MsClick(X + 80, Y + 110, 10, 5);
			TLuaFuns:MsPressEnter();
		end	
		if 1 == iRet then 
			bRet = true;
			break;
		end
		if 2 == iRet then 
			TLuaFuns:MsClick(X, Y, 60, 12);
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
		
		if TLuaFuns:MsFindImg('WaitCheck.bmp', 0.8) == 0 then
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
		
		iX, iY, iRet = TLuaFuns:MsFindStringEx('请输入帐号|请输入密码|客户端安全|您的QQ暂时无法登录', 'f4dcaf-000000|fcc45c-000000|ffffff-000000|ffffff-000000', 1.0, 2);			
		if 0 == iRet then
			TLuaFuns:MsPostStatus('QQ账号为空', tsFail, false);
			return 0;
		elseif 1 == iRet then
			TLuaFuns:MsPostStatus('密码为空', tsFail, false);
			return 0;
		elseif 2 == iRet then
			TLuaFuns:MsPostStatus('客户端安全组件加载失败', tsFail, false);
			return 0;
		elseif 3 == iRet then
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
			iRet = TLuaFuns:MsCaptureArea(iX, iY - 70, iX + 125, iY - 20, 'CheckCode.bmp');
			if iRet ~= 0 then
				--打码兔打码
				print('开始打码...');
				sCode = TLuaFuns:MsDaMa('CheckCode.bmp', 12);
				print(string.format('验证码: %s', sCode));
				if sCode ~= '' then
					TLuaFuns:MsPostStatus(string.format('打码机传过来的码值: %s', sCode));
					--输入验证码
					print('输入验证码...');
					TLuaFuns:MsClick(iX + 300, iY - 40, 10, 5);
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
	local hGameHandle = 0; -- = TLuaFuns:MsGetGameHandle();
	local hPwd = 0;
	local X1 = 0;
	local X2 = 0;
	local Y1 = 0;
	local Y2 = 0;
	local iTop = 0;
	local iLeft = 0;
	local iCount = 0;
	print(1);
	--关闭游戏广告
	--CloseWindowByTitle('DNF视频播放器');
	--CloseWindowByProcessName('AdvertDialog.exe');
	--TLuaFuns:MsPostStatus('关闭广告弹窗...');
	local hAdvert = TLuaFuns:MsFindWindow('','DNF视频播放器');
	if 0 ~= TLuaFuns:MsIsWindow(hAdvert) then 
		TLuaFuns:MsSendMessage(hAdvert, 16);
	end
	print(2);
	hGameHandle = TLuaFuns:MsFindWindow('','地下城与勇士登录程序');
	if 0 == TLuaFuns:MsIsWindow(hGameHandle) then
		TLuaFuns:MsPostStatus('登陆窗口异常退出', tsFail);
		return 0;
	end
	print(3);
	TLuaFuns:MsSetGameHandle(hGameHandle);
	--TLuaFuns:MsPostStatus('开始输入账号密码...');
	print(4);
	TLuaFuns:MsPostStatus(string.format('开始登录[%s]...',GAccount));
	if TLuaFuns:MsCheck() == 0 then
		return 0;
	end
	print(5);
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
	TLuaFuns:MsFrontWindow(hGameHandle);
	TLuaFuns:MsClick(iLeft, iTop);
	TLuaFuns:MsSleep(500);
	TLuaFuns:MsPressPassWord(GPassWord);
	TLuaFuns:MsSleep(500);
	TLuaFuns:MsPressEnter();
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

--选择角色
function fnSelRole()
	local iX = -1;
	local iY = -1;
	local iRet = -1;
	local IsEnterRolePage = false;
	local dwTickCount = TLuaFuns:MsGetTickCount();
	--选择频道步骤取消了， 但是游戏进入角色界面还是需要时间， 所以， 把时间加到了这里
	local dwSelRoleDelay = TLuaFuns:MsGetDelay('选择角色等待') * 1000;
	local dwSelChannelDelay = TLuaFuns:MsGetDelay('选择频道等待') * 1000;
	local dwWaitTick = dwSelRoleDelay + dwSelChannelDelay;
	TLuaFuns:MsPostStatus(string.format('等待选择角色[%s]...',GRoleName));
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		::lblSelRole::
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			return 0;
		end
		iX, iY, iRet = TLuaFuns:MsFindImgEx('SelRole.bmp', 1.0, 5);
		if -1 == iRet then
			goto lblSelRole;
		end
		
		IsEnterRolePage = true;
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
		
		iX, iY, iRet = TLuaFuns:MsFindImgEx('frozen.bmp', 1.0, 5);
		if -1 == iRet then
			goto lblSelRole;
		end
	end
	
	if not IsEnterRolePage then
		print('进入角色页面超时');
		return 0;
	end
	print('校验完成');
	return 1;
end
---------------------------------------------------------------------------------
function fnDispatchOrder()

	print('开始执行脚本');
	
	GAccount = '275175822';
	GPassWord = 'a09137320286';

	--如果游戏OnLine，则返回角色界面选取角色
	local iRet = 0;
	print('开始执行脚本1');
	local bRet = false;

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

	print('开始执行脚本6');
	iRet = fnSelRole();
	if 0 == iRet then
		return 0;
	end

	return 1;
end

fnDispatchOrder();

--[[
function Test()
	TLuaFuns:MsCreateBmp('该账号被停封','AccFengTing',255,255,255);
end
 
Test();
--]]

