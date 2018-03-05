--公布出来的类
TOrderInfo = require "TOrderInfo";
TLuaFuns = require "TLuaFuns";

function inspect(table, name)
  print ("--- " .. name .. " consists of");
  for n,v in pairs(table) do print(n, v) end;
  print();
end

inspect(TOrderInfo, "TOrderInfo");
inspect(TLuaFuns, "TLuaFuns");
--[[
--订单的状态
tsNormal 	 = 100;
tsStart 	 = 0; 
tsSuccess 	 = 1;
tsDoing 	 = 2;
tsSuspend 	 = 3;
tsTargetFail = 4
tsFail 		 = 5;
tsKillTask   = 6;

--公共变量
GEnterGameTick = 0;

--根据窗口标题关闭该窗口
local function CloseWindowByTitle(title)
    local cmd = [[taskkill /F /FI "WINDOWTITLE eq %s"]]
    cmd = string.format(cmd, title)
    os.execute(cmd)
end

--根据进程名关闭窗口
local function CloseWindowByProcessName(name)
    local cmd  = [[taskkill /F /FI "IMAGENAME eq %s"]]
    cmd = string.format(cmd, name)
    os.execute(cmd)
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
			return 0;
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
	print('修复游戏');
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
	while true do
		TLuaFuns:MsSleep(100);
		iRet = TLuaFuns:MsCreateProcess();
		if (0 == iRet) then
			print('启动游戏失败');
			return 0;
		end 
		
		hGame, iRet = fnCheckStartTarget();
		
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
	print('选择游戏区服');
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
	print('等待选择区服');
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
		print('选择服务器超时');
		TLuaFuns:MsPostStatus('选择服务器超时', tsFail);
		return 0;
	end
	
	--点击登陆游戏按钮
    TLuaFuns:MsClick(X, Y);
	
	bRet = false;
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			return 0;
		end
		
		X, Y, iRet = TLuaFuns:MsFindStringEx('您选择的大区延迟过大|该服务器正在维护，无法进入|该服务器已经爆满', 'ffffff-000000');
		if 0 == iRet then
			TLuaFuns:MsClick(X + 100, Y + 120);
		end
		if 1 == iRet then
			TLuaFuns:MsPostStatus('该服务器正在维护，无法进入', tsFail);
			return 0;
		end
		if 2 == iRet then
			TLuaFuns:MsClick(X + 70, Y + 120);
		end
		
		X, Y, iRet = TLuaFuns:MsFindImgEx('DelayBig.bmp|IssnLogin.bmp|InSelArea.bmp', 0.8);
		if 0 == iRet then 
			print('大区延时过大...');
			TLuaFuns:MsClick(X + 100, Y + 120);
			TLuaFuns:MsPressEnter();
		end	
		if 1 == iRet then 
			bRet = true;
			break;
		end
		if 2 == iRet then 
			TLuaFuns:MsClick(X, Y);
		end
	end
	
	if not bRet then
		TLuaFuns:MsPostStatus('选择服务器超时', tsFail);
		return 0;
	end
	
	TLuaFuns:MsPostStatus('选择服务器成功');
	TLuaFuns:MsPostStatus('等待安全检查');

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
	
	print('安全检查完成');
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
		
		iX, iY, iRet = TLuaFuns:MsFindStringEx('请输入帐号|请输入密码|客户端安全', 'f4dcaf-000000|fcc45c-000000|ffffff-000000', 1.0, 2);			
		if 0 == iResult then
			TLuaFuns:MsPostStatus('QQ账号为空', tsFail, false);
			return 0;
		end
		if 1 == iResult then
			TLuaFuns:MsPostStatus('密码为空', tsFail, false);
			return 0;
		end
		if 2 == iResult then
			TLuaFuns:MsPostStatus('客户端安全组件加载失败', tsFail, false);
			return 0;
		end
		
		iX, iY, iRet = TLuaFuns:MsFindImgEx('PwdError.bmp|AccError.bmp|NeedDm.bmp', 0.8, 2);
		if 0 == iRet then
			TLuaFuns:MsPostStatus('账号或密码不正确', tsFail, false);
			return 0;
		end
		if 1 == iRet then
			TLuaFuns:MsPostStatus('您的QQ暂时无法登录，请恢复正常使用', tsFail, false);
			return 0;
		end
		if 2 == iRet then
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
					TLuaFuns:MsClick(iX + 300, iY - 40);
					TLuaFuns:MsSleep(500);
					TLuaFuns:MsPressString(hLogin, sCode);
					TLuaFuns:MsSleep(500);
					TLuaFuns:MsPressEnter();
					print('验证码输入完成');
				end
			end
		end
	end
end


--登录游戏
function fnLoginGame()
	print('开始登陆...');

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
	
	--关闭游戏广告
	--CloseWindowByTitle('DNF视频播放器');
	CloseWindowByProcessName('AdvertDialog.exe');
	
	hGameHandle = TLuaFuns:MsFindWindow('','地下城与勇士登录程序');
	if 0 == TLuaFuns:MsIsWindow(hGameHandle) then
		TLuaFuns:MsPostStatus('登陆窗口异常退出', tsFail);
		return 0;
	end
	
	TLuaFuns:MsSetGameHandle(hGameHandle);
	TLuaFuns:MsPostStatus('开始登录[%s|%s]...', sAccount, sAreaName);

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
	TLuaFuns:MsFrontWindow(hGameHandle);
	TLuaFuns:MsClick(iLeft, iTop);
	TLuaFuns:MsSleep(500);
	TLuaFuns:MsPressPassWord(TOrderInfo:GetPassWord());
	TLuaFuns:MsSleep(200);
	TLuaFuns:MsPressEnter();
	print('密码输入完成...');
	
	--登录判断
	if 0 == fnLoginValidate() then
		return 0;
	end
	
	return 1;
end

--选择频道
function fnSelChannel()
	print('进入游戏,等待选择频道.');
	TLuaFuns:MsPostStatus('进入游戏,等待选择频道.');
	local iRet = 0;
	local hGame = 0;
	local hLogin = 0;
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = TLuaFuns:MsGetDelay('进入游戏等待');
	dwWaitTick = (dwWaitTick + TLuaFuns:MsGetDelay('安全验证等待')) * 1000;		
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		--找到主窗口 break;
		hGame = TLuaFuns:MsFindWindow('地下城与勇士','地下城与勇士');
		if 0 ~= TLuaFuns:MsIsWindow(hGame) then
			break;
		end
		
		--主窗口还没找到，登录窗口消失，则异常退出
		hLogin = TLuaFuns:MsFindWindow('','地下城与勇士登录程序');
		if 0 == TLuaFuns:MsIsWindow(hLogin) then
			TLuaFuns:MsPostStatus('登陆窗口异常退出', tsFail);
			return 0;
		end
	end
	
	if 0 == TLuaFuns:MsIsWindow(hGame) then
		TLuaFuns:PostStatus('选择频道超时...', tsFail);
		return 0;
	end
		
	TLuaFuns:MsSetGameHandle(hGame);
	
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
		TLuaFuns:PostStatus('选择频道超时...', tsFail);
		return 0;
	end
	
	local iPosX = -1;
	local iPosY = -1;
	print('开始选择频道');
	TLuaFuns:MsPostStatus('开始选择频道');
	
	for i=0, 3 do
		if i > 0 then
			-- 下一页
			TLuaFuns:MsClick(425, 475);
			iRet = TLuaFuns:MsFindString('顺畅|良好|普通|拥挤|爆满', TLuaFuns:MsGetPianSe('登陆_选择频道'), 1.0, 50);			
			if iRet == 0 then
				break;
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

	print('点击频道...');
	print(iPosX, iPosY);
	TLuaFuns:MsDbClick(iPosX, iPosY);
	TLuaFuns:MsSleep(100);
	TLuaFuns:MsDbClick(iPosX, iPosY);
	TLuaFuns:MsSleep(500);
	--[[
	--告诉控制台,我选择的频道信息
	iRet = TLuaFuns:MsFindString('当前频道人数已满', 'ffffff-000000', 0.9, 5);
    if iRet == 0 then
		TLuaFuns:Ms:PostStatus('所有频道爆满', tsFail);
		return 0;
    end	
	]]
	return 1;	
end

--选择角色
function fnSelRole()
	print('等待选择角色.');
	TLuaFuns:MsPostStatus('等待选择角色.');
	local iX = -1;
	local iY = -1;
	local iRet = -1;
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = TLuaFuns:MsGetDelay('选择角色等待') * 1000;
	local sRoleName = TOrderInfo:GetRole();
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			return 0;
		end
		iX, iY = TLuaFuns:MsFindImgEx('Cancel.bmp', 0.8);
		if (iX ~= -1) and (iY ~= -1) then
			TLuaFuns:MsClick(iX + 5, iY + 5);
			Sleep(100);
			TLuaFuns:MsClick(iX + 5, iY + 5);
			Sleep(100);
		end
		
		iX, iY, iRet = TLuaFuns:MsFindStringEx('连接失败！|取消后将无法再推荐|正在连接服务器', 'ffffff-000000');
		if 0 == iRet then
			TLuaFuns:MsPostStatus('连接失败', tsFail);
			return 0;
		end
		if 1 == iRet then
			TLuaFuns:MsClick(iX + 40, iY + 60);
			Sleep(100);
			TLuaFuns:MsClick(iX + 40, iY + 60);
			Sleep(100);
		end
		if 2 ~= iRet then
			TLuaFuns:MsPostStatus(string.format('查找角色[%s]',sRoleName));
			-- TODO  Role.bmp ，名字可能要变
			iX, iY = TLuaFuns:MsFindImgEx('Role.bmp');
			if (iX ~= -1) and (iY ~= -1) then
				break;
			end
		end
	end
	
	if (iX == -1) or (iY == -1) then
		TLuaFuns:MsPostStatus(string.format('角色[%s]不存在！', sRoleName), tsFail, False);
		return 0;
    end;
	
	GEnterGameTick = TLuaFuns:MsGetTickCount();
	TLuaFuns:MsPostStatus(string.format('找到角色[%s]位置%d %d', sRoleName, iX, iY));
	TLuaFuns:MsDbClick(iX, iY);
	TLuaFuns:MsSleep(200);
	TLuaFuns:MsDbClick(iX, iY);
	TLuaFuns:MsSleep(200);
	TLuaFuns:MsDbClick(iX, iY);
	TLuaFuns:MsSleep(200);
	return 1;
end

--退回到角色界面
function fnBackToRoler()
	local iX, iY;
	local iRet = 0;
	local dwWait = 15 * 1000;
	local dwTickCount = TLuaFuns:MsGetTickCount();
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		iRet = TLuaFuns:MsFindImg('SelRole.bmp', 0.8, 1);
		if 0 ~= iRet then 
			break;
			return 1;
		end
		TLuaFuns:MsPressEsc();
		TLuaFuns:MsSleep(100);
		if 0 == TLuaFuns:MsFindString('游戏菜单(Esc)', 'ffffff-000000') then
			iX, iY = TLuaFuns:MsFindString('选择角色', TLuaFuns:MsGetPianSe('菜单_选择角色'));
			if (-1 ~= iX) and (-1 ~= iY) then
				TLuaFuns:MsClick(iX + 5, iY + 2);
			end
		end
	end
end

--判断是否进入游戏
function fnIsEnterTheGame(iDelay)
	local hGame = TLuaFuns:MsGetGameHandle();
	if 0 == TLuaFuns:MsIsWindow(hGame) then
		return 0;
	end	
	return TLuaFuns:MsFindImg('LoginSuccess.bmp', 0.7, iDelay);
end

--进入游戏
function fnEnterTheGame()
	local bRet = false;
	local sRoleName = TOrderInfo:GetRole();
	print(string.format('等待角色[%s]进入游戏', sRoleName));
	TLuaFuns:MsPostStatus(string.format('等待角色[%s]进入游戏', sRoleName));
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
	while (TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick) or
		  (TLuaFuns:MsGetTickCount() - GEnterGameTick <= 60 * 1000) do
		TLuaFuns:MsSleep(100);
		bRet = false;
		print(string.format('进入游戏[%d]...', dwWaitTick));
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		iRet = fnIsEnterTheGame(1);
		IsEnterTheGame = iRet == 1;
		TLuaFuns:MsFrontWindow(hGame);
		TLuaFuns:MsSleep(100);
		TLuaFuns:MsPressEsc();
		TLuaFuns:MsSleep(100);
		TLuaFuns:MsPressEsc();
		
		iX, iY, iRet = TLuaFuns:MsFindImgEx('Ok.bmp|GiveUp.bmp|Enter.bmp|NextStep.bmp', 0.7);
		if -1 ~= iRet then
			TLuaFuns:MsClick(iX + 5, iY + 5);
			bRet = true;
		end  
		----------          -------------------------
		iX, iY, iRet = TLuaFuns:MsFindStringEx('确认|关闭|接受礼物|林纳斯的礼物|私人秘书梦娜', TLuaFuns:MsGetPianSe('登陆_关闭广告'));
		if (0 == iRet) or (1 == iRet) then
			TLuaFuns:MsClick(iX + 5, iY + 5);
			bRet = true;
		end
		if 2 == iRet then
			TLuaFuns:MsClick(iX + 150, iY + 10);
			bRet = true;
		end
		if (3 == iRet) or (4 == iRet) then
			TLuaFuns:MsClick(iX + 390, iY + 5);
			bRet = true;
		end
		TLuaFuns:MsSleep(100);
		TLuaFuns:MsPressChar('L');
		TLuaFuns:MsSleep(1000);
		TLuaFuns:MsPressChar('L');
		TLuaFuns:MsSleep(500);
		
		if (not bRet) and (IsEnterTheGame) then 
			break;
		end
		
	end
	
	if not IsEnterTheGame then
		print('角色进入游戏超时...');
		TLuaFuns:MsPostStatus('角色进入游戏超时...', tsFail);
		return 0;
	end	
	print('角色进入游戏...');
	TLuaFuns:MsPostStatus('角色进入游戏...');
	return 1;
end

--打开邮件箱
function fnOpenMailBox()
	local iRet = 0;
	local iX = -1;
	local iY = -1;
	local bRet = false;
	local sPianSe = '';
	iRet = TLuaFuns:MsFindString('游戏菜单(Esc)|好友(L)', TLuaFuns:MsGetPianSe('菜单_普通标题'));
	if 0 ~= iRet then
		TLuaFuns:MsPressEsc();
	end
	
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
			print('点击邮件箱X[%d]Y[%d]', iX, iY);
			TLuaFuns:MsClick(iX + 10, iY + 5);
			TLuaFuns:MsSleep(100);
			TLuaFuns:MsClick(iX + 10, iY + 5);
			TLuaFuns:MsSleep(1000);
		end
	end
	
	if not bRet then
		TLuaFuns:MsPostStatus('打开邮件箱失败', tsFail);
		return 0;
	end
	return 1;
end

--点击发送邮件标签
function fnClickSendMailLabel()
	local iRet = 0;
	local bRet = false;
	local hGame = TLuaFuns:MsGetGameHandle();
	local iX = -1; local iY = -1;
	iX, iY = TLuaFuns:MsGetTopLeft(hGame);
	if (iX == -1) or (iY == -1) then
		TLuaFuns:MsPostStatus('游戏已自动关闭', tsFail);
		return 0;
	end
	for i=1, 3 do
		iRet = TLuaFuns:MsFindString('发送邮件', TLuaFuns:MsGetPianSe('邮寄_邮件箱_已选中'));
		if 0 ~= iRet then
			bRet = true;
			break;
		end
		TLuaFuns:MsClick(iX + 310, iY + 155);
		TLuaFuns:MsSleep(500);
	end
	
	if not bRet then
		TLuaFuns:MsPostStatus('打开邮件箱失败', tsFail);
		return 0;
	end
	return 1;
end

--输入角色额名
function fnInputRoleName(sRoleName)
	--local iRet = 0;
	local bRet = 0;
	local iX = -1;
	local iY = -1;
	for i=1, 3 do
		bRet = false;
		iX, iY = TLuaFuns:MsFindStringEx('发送邮件', TLuaFuns:MsGetPianSe('邮寄_邮件箱_已选中'));
		if (iX ~= -1) and (iY ~= -1) then
			TLuaFuns:MsClick(iX + 75, iY + 25);
			bRet = true;
			break;
		end 
	end
	
	if not bRet then
		TLuaFuns:MsPostStatus('没有打开邮件箱', tsFail);
		return 0;
	end
	
	local hGame = TLuaFuns:MsGetGameHandle(); 
	
	TLuaFuns:MsSleep(500);
	TLuaFuns:MsPressDel(12);
	TLuaFuns:MsSleep(500);
	TLuaFuns:MsPressString(hGame, sRoleName);
	TLuaFuns:MsSleep(500);
	return 1;
end

--输入金额
function fnInputMoney(AX, AY, ANum)
	print('输入金额');
	local hGame = TLuaFuns:MsGetGameHandle();
	local iX = -1;
	local iY = -1;
	local iRet = -1;
	iX, iY = TLuaFuns:MsGetTopLeft(hGame);
	for i=1, 3 do
		if i > 1 then
			iRet = TLuaFuns:MsGetNumber(iX + 290, iY + 380, iX + 410, iY + 410, 'ffffff-000000');
			print(iRet, ANum);
			if ANum == iRet then
				return 1;				
			end
		end
		TLuaFuns:MsClick(AX, AY);
		TLuaFuns:MsSleep(200);
		TLuaFuns:MsClick(AX, AY);
		TLuaFuns:MsSleep(500);
		TLuaFuns:MsPressDel(20);
		TLuaFuns:MsSleep(500);
		local sMoney = string.format('%d', ANum);
		TLuaFuns:MsPressString(hGame, sMoney);
	end
	print('输入金额错误');
	return 0;
end

--获取背包金额
function fnGetBagMoney()
	local iRet = -1;
	local hGame = TLuaFuns:MsGetGameHandle();	
	
	local iX = -1;
	local iY = -1;
	
	iX, iY = TLuaFuns:MsGetTopLeft(hGame);
	for i=0, 9 do
		iRet = TLuaFuns:MsFindString('装备栏(I)', TLuaFuns:MsGetPianSe('菜单_普通标题'));
		if 0 ~= iRet then
			iRet = TLuaFuns:MsGetNumber(iX + 580, iY + 520, iX + 710, iY + 550, TLuaFuns:MsGetPianSe('邮寄_背包金额'));
			if iRet ~= -1 then
				break;
			end
		end	
		TLuaFuns:MsSleep(500);
	end
	
	if iRet ~= -1 then
		TLuaFuns:MsPostStatus('获取背包金额失败', tsFail);
	end 
	
	return iRet;
end

-- TODO 上传截图
function fnPostImg()
	local iRet = 0;
	print('开始上传截图...');
	iRet = TLuaFuns:MsPostImg();
	return iRet;
end

--校验角色
function fnCheckRoleInfo()
	print('校验角色');
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = 5 * 1000;
	local iX = -1;
	local iY = -1;
	local sRoleName = TOrderInfo:GetRole();
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		
		iX, iY = TLuaFuns:MsFindStringEx('发送邮件', TLuaFuns:MsGetPianSe('邮寄_邮件箱_已选中'));
		if (iX ~= -1) and (iY ~= -1) then
			break;
		end 
	end
	print(iX, iY);
	dwTickCount = TLuaFuns:MsGetTickCount();
	dwWaitTick = TLuaFuns:MsGetDelay('检测角色存在等待') * 1000;
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		print('校验角色名...');
		TLuaFuns:MsClick(iX + 120, iY + 25);
		
		TLuaFuns:MsSleep(1000);
		iX, iY = TLuaFuns:MsFindStringEx('公告', TLuaFuns:MsGetPianSe('菜单_普通标题'));
		if (iX ~= -1) and (iY ~= -1) then
			break;
		end
	end
	print(iX, iY);
	if (iX == -1) or (iY == -1) then
		TLuaFuns:MsPostStatus('角色名输入失败', tsFail);
		return 0;
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
			TLuaFuns:MsPostStatus(string.format('对方角色[%s]不存在',sRoleName), tsTargetFail, false);
			return 0;
		end
	end
	if (iX == -1) or (iY == -1) then
		TLuaFuns:MsPostStatus(string.format('对方角色[%s]不存在',sRoleName), tsTargetFail, false);
		return 0;
	end	
	
	-- TODO 如果订单里边需要检验等级	
	if true then
		local iLevel = -1;
		--获取等级
		for i=1, 3 do
			iLevel = TLuaFuns:MsGetNumber(iX, iY + 5, iX + 100, iY + 30, 'ffffff-000000');
			if iLevel > -1 then
				print(string.format('获取对方角色等级为: %d', iLevel));
				break;
			end
		end
		
		if iLevel == -1 then
			--TODO
			TLuaFuns:MsPostStatus(string.format('获取角色[%s]的等级失败', '123'), tsFail);
			return 0;
		end
		--TODO
		if 订单等级 <> iLevel then
			TLuaFuns:MsPostStatus(string.format('角色[%s]订单等级[%d]与实际等级[%d]不符，不予处理', '123'), tsTargetFail, false);
			return 0;
		end
	end
	
	return 1;
end

--发送邮件时打码
function fnDaMaOfSendMail(hGameHandle)
	local iRet = -1;
	local iX = -1;
	local iY = -1;
	local bRet = false;
	for i=1, 3 do
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		iX, iY = TLuaFuns:MsFindImgEx('MailInputCheckCode.bmp', 0.9);
		
		if (iX ~= -1) and (iY ~= -1) then
			iRet = TLuaFuns:MsCaptureArea(iX - 212, iY - 24, iX - 82, iY + 29, 'CheckCode.bmp');
			if 0 ~= iRet then
				break;
			end
		end		
	end

	if iRet == 0 then
		print('获取验证码失败...');
		return 0;
	end
	
	for i=1, 3 do
		bRet = false;
		TLuaFuns:MsPostStatus('发送邮件验证码到打码机');
		local sRet = TLuaFuns:MsDaMa('CheckCode.bmp', 12);
		print(sRet);
		if sRet ~= '' then
			print('输入验证码...');
			TLuaFuns:MsPressString(hGameHandle, sRet);
			TLuaFuns:MsSleep(500);
			--TODO
			TLuaFuns:MsCaptureGame('3.bmp');
			if 0 == TLuaFuns:MsCheck() then
				return 0;
			end
			print('点击确定按钮');
			for j=1, 3 do
				TLuaFuns:MsClick(iX - 120, iY + 130);
				TLuaFuns:MsSleep(3000);
				iRet = TLuaFuns:MsFindImg('CheckCode.bmp');
				print(string.format('iRet: %d', iRet));
				if 0 == iRet then
					bRet = true;
					break;
				end
			end	
			if bRet then
				break;
			end
		end
	end
	
	if not bRet then	
		return 0;
	end
	return 1;
end

--等待邮件发送结果 
function fnCheckSendResult()
	local iResult = -1;
	local iRet = 0;
	local x, y;
	local hGame = TLuaFuns:MsGetGameHandle();
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = TLuaFuns:MsGetDelay('邮件验证码窗口等待') * 1000;
	while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
		TLuaFuns:MsSleep(100);
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		
		if 0 ~= TLuaFuns:MsFindImg('MailCheckCodeDlg.bmp', 0.9) then
			iRet = 1;
			break;
		end
		
		x, y, iResult = TLuaFuns:MsFindStringEx('已成功发送邮件|您在对方的黑名单内|已超出金币的使用限制', 'ffffff-000000');			
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
	end
	
	if iRet == 0 then
		TLuaFuns:MsPostStatus('等待发送结果超时', tsFail);
		return 0;
	end
	
	if iRet == 1 then
		iRet = fnDaMaOfSendMail(hGame);
		
		if iRet == 0 then
			print('远程打码失败...');
			return iRet;
		end
		
		local dwTickCount = TLuaFuns:MsGetTickCount();
		local dwWaitTick = TLuaFuns:MsGetDelay('检测结果等待') * 1000;
		while TLuaFuns:MsGetTickCount() - dwTickCount <= dwWaitTick do
			TLuaFuns:MsSleep(100);
			if 0 == TLuaFuns:MsCheck() then
				return 0;
			end
			
			x, y, iResult = TLuaFuns:MsFindStringEx('已成功发送邮件|您在对方的黑名单内|已超出金币的使用限制', 'ffffff-000000');			
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
		end
	end
	
	if iRet == 2 then
		--订单数量
		TLuaFuns:MsPostStatus(string.format('订单[%s]已发货[%d]', TOrderInfo.GetOrderNo(), 10000));		
		local iX = -1; local iY = -1;
		iX, iY = TLuaFuns:MsGetTopLeft(hGame);
		TLuaFuns:MsClick(iX + 375, iY + 175);
		TLuaFuns:MsSleep(1000);
		-- TODO 图片路径
		TLuaFuns:MsCaptureGame('2.bmp');
		TLuaFuns:MsSleep(1000);
		TLuaFuns:MsClick(x + 45, y + 35);
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
	TLuaFuns:MsPostStatus('检测是否需要解安全...');
	if 0 == TLuaFuns:MsFindString('确定解除', 'ddc593-000000') then
		print('不需要解安全');
		return 1;
	end
	
	iX,iY = TLuaFuns:MsGetTopLeft(TLuaFuns:MsGetGameHandle());
	TLuaFuns:MsClick(iX + 435, iY + 335);
	TLuaFuns:MsPostStatus('账号需要解绑，程序开始解安全');
	--TODO TLuaFuns:MsQuitSafe()
	iRet = TLuaFuns:MsQuitSafe();
	
	if 0 == iRet then
		print('解安全失败');
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
	print('解安全完成');
	return 2;
end

--一次发货操作，订单可能会分批处理
function fnSingleSend(ASendNum, AIsFirst)
	local iRet = 0;	
	if 0 == TLuaFuns:MsCheck() then
		return 0;
	end
	--判断有没有打开邮件箱
	iRet = TLuaFuns:MsFindString('邮件箱', 'ffffff-000000', 1.0, 3);
	if 0 == iRet then
		if 0 == fnOpenMailBox() then 
			return 0;
		end
		
		if 0 == fnClickSendMailLabel() then
			return 0;
		end
	end
	
	print('开始获取库存金额');	
	local iBagMoney = fnGetBagMoney();
	if iBagMoney == -1 then
		TLuaFuns:MsPostStatus('获取背包金额失败', tsFail);
		return 0;
	end
	
	--iBagMoney = iBagMoney / 10000;
	TLuaFuns:MsPostStatus(string.format('当前库存: %d', iBagMoney));
	if iBagMoney - 20000 < ASendNum then 
		TLuaFuns:MsPostStatus(string.format('背包金额[%d]小于需要交易的金额[%d]', iBagMoney, ASendNum), tsFail, False);
        return 0;
	end
	-- TODO 系统库存到时候得定义, 还有仓库浮动
	if AIsFirst and (math.abs(iBagMoney - TOrderInfo:GetStock() * 10000) > 1500000) then
		TLuaFuns:MsPostStatus(string.format('实际库存[%d]与系统库存[%d]误差大于系统设置误差[%d]', iBagMoney, 10000, 1500000), tsFail, False);
        return 0;
	end	

	if 0 == fnInputRoleName(TOrderInfo:GetReceiptRole()) then
		TLuaFuns:MsPostStatus('输入角色名失败', tsFail);
        return 0;
	end
	
	if 0 == fnCheckRoleInfo() then 
		return 0;
	end

	local hGame = TLuaFuns:MsGetGameHandle();
	local iX = -1;
	local iY = -1;
	iX, iY = TLuaFuns:MsGetTopLeft(hGame);
	fnInputMoney(iX + 400, iY + 395, ASendNum());
	TLuaFuns:MsSleep(1000);
	-- TODO 截图保存路径
	TLuaFuns:MsCaptureGame('1.bmp');
	for i=1, 3 do
		print(i);
		if 0 == TLuaFuns:MsCheck() then
			return 0;
		end
		
		TLuaFuns:MsClick(iX + 260, iY + 460);
		TLuaFuns:MsSleep(100);
		TLuaFuns:MsClick(iX + 260, iY + 460);
		TLuaFuns:MsSleep(1000);
		if AIsFirst then
			iRet = fnQuitSafe();

			if iRet == 3 then
				-- TODO 暂停发货， 让人手动解除安全
				-- GSharedInfo.AutoSend.Status := 2;
				TLuaFuns:MsPostStatus('解安全失败');
				if 0 == TLuaFuns:MsCheck() then
					return 0;
				end
			end
			
			if iRet == 2 then
				print('需要解安全，并且解安全成功了，再次点击发送按钮');  
				TLuaFuns:MsClick(iX + 260, iY + 460);
				Sleep(100);
				TLuaFuns:MsClick(iX + 260, iY + 460);
			end	
		end
		print('查找验证码弹出框');
		iRet = fnCheckSendResult();
		if iRet == 1 then
			break;
		end
	end
	return 1;
end

function fnSendMail()
	local iOrderNum = TOrderInfo:GetSendNum();
	local iDispatchNum = TOrderInfo:GetEachNum();
	local iOddNum = 0;
	
	if iDispatchNum >= iOrderNum then
		iDispatchNum = iOrderNum;
	end
	iOddNum = iOrderNum;
	
	while true do
		TLuaFuns:MsSleep(100);
		
		iRet = fnSingleSend(iDispatchNum * 10000, true);
		
		if 0 == iRet then
			return 0;
		end
		iOddNum = iOddNum - iDispatchNum;
		print(string.format('结果=%d 已发货数量= %d 剩余数量 = %d 发货完成', iRet, iOrderNum - iOddNum, iOddNum));
				
		if iOddNum <= 0 then
			break;
		end
		
		if iOddNum < iDispatchNum then
			iDispatchNum = iOddNum;
		end
	end
	return 1;
end

function fnDispatchOrder()
	--如果游戏OnLine，则返回角色界面选取角色
	local iRet = 0;
--[[	
	local bRet = false;
	if 0 ~= fnIsEnterTheGame(5) then
		if 0 ~= fnBackToRoler() then
			bRet = true;
		end
	end
	
	if not bRet then
--]]	
		iRet = fnStartGame();
		if 0 == iRet then
			return 0;
		end    
--[[
		iRet = fnSelGameArea();
		if 0 == iRet then
			return 0;
		end

		iRet = fnLoginGame();
		if 0 == iRet then
			return 0;
		end
		
		iRet = fnSelChannel();
		if 0 == iRet then
			return 0;
		end
	end
	
	iRet = fnSelRole();
	if 0 == iRet then
		return 0;
	end
	
	iRet = fnEnterTheGame();
	if 0 == iRet then
		return 0;
	end	
	
	iRet = fnSendMail();
	if 0 == iRet then
		return 0;
	end
--]]	
	return 1;
end

fnDispatchOrder();
--]]
print ('发货结束...');