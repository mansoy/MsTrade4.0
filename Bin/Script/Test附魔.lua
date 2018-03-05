--公布出来的类
TOrderInfo = require "TOrderInfo";
TLuaFuns = require "TLuaFuns";

function inspect(table, name)
  print ("--- " .. name .. " consists of");
  for n,v in pairs(table) do print(n, v) end;
  print();
end


local VK_RETURN = 13;
local VK_ESCAPE = 27;
local VK_LEFT   = 37;
local VK_DOWN   = 40;

--获取游戏句柄
function fnGetGameHandle()
	local hGame = 0;
	hGame = TLuaFuns:MsFindWindow('地下城与勇士','地下城与勇士');
		if 0 == TLuaFuns:MsIsWindow(hGame) then
			TLuaFuns:MsPostStatus('游戏窗口异常退出！', tsFail);
			return 0;
		end
	TLuaFuns:MsSetGameHandle(hGame);
	return 1;
end

--走出房间
function fnWalkOutOfRoom() 
	local iRet = 0;
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = 20 * 1000;
	while TLuaFuns:MsGetTickCount() - dwTickCount < dwWaitTick do
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			return 0;
		end
		TLuaFuns:MsTheKeysWalk(VK_DOWN, 500);	
		TLuaFuns:MsSleep(2000);
		
		iRet = TLuaFuns:MsFindString('布告栏', TLuaFuns:MsGetPianSe('附魔_布告栏'));
    if iRet == 1 then
			break;	
    end
	end
	
	if iRet == 0 then
		TLuaFuns:MsPostStatus('走出房间超时', tsFail);
		return 0;
	end
	
	TLuaFuns:MsTheKeysWalk(VK_DOWN, 1000);	
	return 1;
end

--走到摆摊地点
function fnWalkToStallPlace()
	local iRet = 0;
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = 20 * 1000;
	while TLuaFuns:MsGetTickCount() - dwTickCount < dwWaitTick do
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			return 0;
		end
		TLuaFuns:MsTheKeysWalk(VK_LEFT, 500);	
		TLuaFuns:MsSleep(2000);
		
		iRet = TLuaFuns:MsFindString('高等袖珍罐商人', TLuaFuns:MsGetPianSe('附魔_商人'));
    if iRet == 1 then
			break;	
    end
	end
	
	if iRet == 0 then
		TLuaFuns:MsPostStatus('走到摆摊地点超时', tsFail);
		return 0;
	end
	
	TLuaFuns:MsTheKeysWalk(VK_DOWN, 1000);
	TLuaFuns:MsSleep(100);
	TLuaFuns:MsTheKeysWalk(VK_LEFT, 1200);	
	return 1;
end

--摆摊
function fnStall()
	local iX = -1;
	local iY = -1; 
	local iRet = 0;
	local iRoleX = 0;  
	local iRoleY = 0;
	local sRole = TOrderInfo:GetRole();
	
	iX,iY,iRet = TLuaFuns:MsFindStringEx(sRole, 'ffffff-000000');
	if (-1 ~= iX) and (-1 ~= iY) then
		TLuaFuns:MsPostStatus('角色名错误', tsFail, false);
		return 0;
	end
	
	--记录角色坐标
	iRoleX = iX;
	iRoleY = iY + 130;
	
	--在角色身上点击
	TLuaFuns:MsClick(iX, iY+50);
	iX,iY,iRet = TLuaFuns:MsFindStringEx('副职业', 'ffffff-000000');
	if (-1 ~= iX) and (-1 ~= iY) then
		TLuaFuns:MsPostStatus('摆摊-在角色身上点击失败！', tsFail);
		return 0;
	end
	
	--点击“副职业”
	TLuaFuns:MsClick(iX+30, iY+10);
	TLuaFuns:MsSleep(1000);
	iX,iY,iRet = TLuaFuns:MsFindStringEx('开设附魔商店', TLuaFuns:MsGetPianSe('附魔_开设附魔商店'));
	if (-1 ~= iX) and (-1 ~= iY) then
		TLuaFuns:MsPostStatus('摆摊-打开副职业失败！', tsFail);
		return 0;
	end
  
	--点击“开设附魔商店”
  TLuaFuns:MsClick(iX+30, iY+10);
	TLuaFuns:MsSleep(1000);
	iX,iY,iRet = TLuaFuns:MsFindStringEx('手续费', 'ffffff-000000');
	if (-1 ~= iX) and (-1 ~= iY) then
		TLuaFuns:MsPostStatus('摆摊-打开附魔商店失败！', tsFail);
		return 0;
	end

	--输入手续费
	local hGame = TLuaFuns:MsGetGameHandle();
	TLuaFuns:MsPressString(hGame, '10000000');
	TLuaFuns:MsSleep(500);
	TLuaFuns:MsPressEnter();

	--鼠标点在地上摆摊
	local r = 30;       --半径
	local a = 30;       --角度 30° 60° 90° 120° 150°
  local x0 = 0;       --假设原点(0,0)
	local y0 = 0; 
	local i = 0;
	local j = 0;
	local bOk = false;
	for i = 1, 5 do
		r = r+20;
    j = 0;
    a = 30; 
		for j = 1, 5 do
			if j*a ~= 90 then
				x1= Round(cos(j*a*math.pi/180)*r);
				y1= Round(sin(j*a*math.pi/180)*r);
				x1= iRoleX + x1;
				y1= iRoleY - y1;
				TLuaFuns:MsClick(x1, y1);
				TLuaFuns:MsSleep(2000);
				--如果点到别的地方了，则按一下Esc
				iX,iY,iRet = TLuaFuns:MsFindStringEx('副职业|土罐|与NPC太过接近|邀请组队', 'ffffff-000000|68d5ed-000000');
				if iRet ~= -1 then
					TLuaFuns:MsPressEsc();
				end
				iRet = TLuaFuns:MsFindString('手续费', TLuaFuns:MsGetPianSe('附魔_附魔'));
				if iRet == 1 then
					bOk = true;
					break;	
				end
			end
		end
		if bOk then break; end
	end

	if iRet == 0 then
		TLuaFuns:MsPostStatus('没有找到摆摊位置！', tsFail);
		return 0;
	end 

	TLuaFuns:MsPostStatus('摆摊完成！');
	return 1;
end

--摆摊账号工作
function fnStallDoWork()
	local iRet = 0;
	TLuaFuns:MsSleep(5000);
	
	iRet = fnGetGameHandle();
	if iRet == 0 then return 0; end
	
	iRet = fnWalkOutOfRoom();
	if iRet == 0 then return 0; end
	
	iRet = fnWalkToStallPlace();
	if iRet == 0 then return 0; end
	
	iRet = fnStall();
	if iRet == 0 then return 0; end
	
	return 1;
end

-----------------------------------附魔-----------------------------------------------------
--走到附魔地点
function fnWalkToEnchantPlace()
	local iRet = 0;
	local dwTickCount = TLuaFuns:MsGetTickCount();
	local dwWaitTick = 20 * 1000;
	while TLuaFuns:MsGetTickCount() - dwTickCount < dwWaitTick do
		TLuaFuns:MsSleep(100);
		if TLuaFuns:MsCheck() == 0 then
			return 0;
		end
		TLuaFuns:MsTheKeysWalk(VK_LEFT, 500);	
		TLuaFuns:MsSleep(2000);
		
		iRet = TLuaFuns:MsFindString('高等袖珍罐商人', TLuaFuns:MsGetPianSe('附魔_商人'));
    if iRet == 1 then
			break;	
    end
	end
	
	if iRet == 0 then
		TLuaFuns:MsPostStatus('到达摆摊地点超时', tsFail);
		return 0;
	end
	
	--走到摆摊的玩家跟前
	TLuaFuns:MsTheKeysWalk(VK_DOWN, 500);
	TLuaFuns:MsSleep(100);
	TLuaFuns:MsTheKeysWalk(VK_LEFT, 800);	
	return 1;
end

--获取附魔角色背包金额
function fnGetEnchatBagMoney()
	local iRet = -1;
	local hGame = TLuaFuns:MsGetGameHandle();	
	
	local iX = -1;
	local iY = -1;
	
	TLuaFuns:MsPressChar('I');
	TLuaFuns:MsSleep(1000);
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
	TLuaFuns:MsPressEsc();
	return iRet;
end

--检查附魔角色背包金额是否足够附魔
function fnCheckEnchatRoleBagMoney()
	local iEnchatRoleBagMoney = fnGetBagMoney(); --附魔角色背包金额
	if iBagMoney == -1 then
		TLuaFuns:MsPostStatus('获取附魔角色背包金额！', tsFail);
		return 0;
	end;
	local iEnchatNum = TOrderInfo:GetSendNum(); --附魔次数
	local iEnchatMoney = iEnchatNum * 10000000; --附魔总金额
	
	if iEnchatRoleBagMoney < iEnchatMoney then
		TLuaFuns:MsPostStatus('附魔角色背包金额是不足！', tsFail, false);
		return 0;
	end
	return 1;
end

--重置附魔操作
function fnResetEnchat()
	if TLuaFuns:MsFindString('请放入附魔用到的装备或卡片', 'ffffff-000000', 0.9, 3) == 0 then
		return 0;
	end
	TLuaFuns:MsPressEsc();
	TLuaFuns:MsSleep(500);
	return 1;
end

--附魔
function fnEnchant()
	local iX = -1;
	local iY = -1; 
	local iRet = 0;
	local sStallRole = '④齿≠如齐贝';
	
	if TLuaFuns:MsCheck() == 0 then
		return 0;
	end
		
	--找玩家
	iX,iY,iRet = TLuaFuns:MsFindString(sStallRole, 'ffffff-000000', 0.9, 3);
	if iRet == 0 then
		TLuaFuns:MsPostStatus(string.format('没有找到摆摊的玩家[%s]', sStallRole), tsFail);	
		return 0;
	end
	
	--找玩家的摊位
	iX,iY,iRet = TLuaFuns:MsAreaFindString(iX-5, iY-80, iX+50, iY, '手续费', TLuaFuns:MsGetPianSe('附魔_附魔'), 0.9, 3);
	if iRet == 0 then
		TLuaFuns:MsPostStatus('玩家[%s]没有摆摊', tsFail);	
		return 0;
	end

	--打开附魔界面
	TLuaFuns:MsClick(iX, iY);
	TLuaFuns:MsSleep(2000);
	iX, iY, iRet = TLuaFuns:MsFindString('请放入附魔用到的装备或卡片', 'ffffff-000000', 0.9, 3);
	if iRet == 0 then
		TLuaFuns:MsPostStatus('打开附魔界面失败！', tsFail);	
		return 0;
	end
	
	local iEnchatRoleBagMoney_before = fnGetBagMoney(); --附魔前背包金额
	
	--检查装备栏1、装备栏2有无附魔的装备和卡片
	if TLuaFuns:MsFindImg('Bar1IsNull.bmp', 1.0) ~= 0 then
		TLuaFuns:MsPostStatus('装备栏1没有装备！', tsFail, false);
		return 0
	end
	if TLuaFuns:MsFindImg('Bar2IsNull.bmp', 1.0) ~= 0 then
		TLuaFuns:MsPostStatus('装备栏2没有卡片！', tsFail, false);
		return 0
	end
	
	--拖动装备栏1(iX+10, iY+360)的装备到指定位置(iX+30, iY-20)
	TLuaFuns:MsDragMouse(iX+10, iY+360, iX+30, iY-20);
	TLuaFuns:MsSleep(1000);
	if TLuaFuns:MsFindString('只能放入装备', 'ffffff-000000') ~= 0 then
		TLuaFuns:MsPostStatus('装备栏1的物品不是装备！', tsFail, false);
		TLuaFuns:MsPressEnter();
		return 0;
	end
	if TLuaFuns:MsFindString('该装备原有的附魔效果将会消失', 'ffffff-000000') ~= 0 then
		TLuaFuns:MsPressEnter();
	end
	
	--拖动装备栏2(iX+40, iY+360)的卡片到指定位置(iX+130, iY-20)
	TLuaFuns:MsDragMouse(iX+40, iY+360, iX+130, iY-20);
	TLuaFuns:MsSleep(1000);
	if TLuaFuns:MsFindString('只能放入怪物卡片', 'ffffff-000000') ~= 0 then
		TLuaFuns:MsPostStatus('装备栏2的物品不是怪物卡片！', tsFail, false);
		TLuaFuns:MsPressEnter();
		return 0;
	end
	if TLuaFuns:MsFindString('怪物卡片与装备类别不符', 'ffffff-000000') ~= 0 then
		TLuaFuns:MsPostStatus('怪物卡片与装备类别不符！', tsFail, false);
		TLuaFuns:MsPressEnter();
		return 0;
	end
	
	--点击“附魔”按钮
	iX,iY = TLuaFuns:MsFindImg('Enchant.bmp');
	if (-1 == iX) or (-1 == iY) then
		TLuaFuns:MsPostStatus('没有找到附魔按钮！', tsFail, false);
		return 0;
	end
	TLuaFuns:MsClick(iX, iY);
	TLuaFuns:MsSleep(1000);
	iX,iY,iRet = TLuaFuns:MsFindStringEx('确定要附魔以上装备吗', 'ffffff-000000');
	if (-1 == iX) or (-1 == iY) then
		TLuaFuns:MsPostStatus('打开附魔确定界面失败！', tsFail);
		return 0;
	end
	
	--判断附魔材料是否足够
	if TLuaFuns:MsFindImg('OkGray.bmp') ~= 0 then
		TLuaFuns:MsPostStatus('附魔材料不足！', tsFail);
		return 0;
	end
	
	--确定
	TLuaFuns:MsClick(iX+30, iY+185);
	TLuaFuns:MsSleep(1000);
	
	--确认
	iX,iY,iRet = TLuaFuns:MsFindStringEx('确定要附魔以上装备吗', 'ffffff-000000');
	if (-1 == iX) or (-1 == iY) then
		TLuaFuns:MsPostStatus('打开附魔确认界面失败！', tsFail);
		return 0;
	end
	TLuaFuns:MsClick(iX+20, iY+150);
	TLuaFuns:MsSleep(1000);
	
	--判断附魔是否成功
	local iEnchatRoleBagMoney_after = fnGetBagMoney(); --附魔后的背包金额
	if iEnchatRoleBagMoney_after == iEnchatRoleBagMoney_before then
		TLuaFuns:MsPostStatus('附魔失败！', tsFail);
		return 0;
	end
	
	TLuaFuns:MsPostStatus('附魔成功！');
	return 1;
end

--附魔账号工作
function fnEnchantDoWork()
	TLuaFuns:MsSleep(5000);
	
	if fnGetGameHandle() == 0 then return 0; end
	
	if fnWalkOutOfRoom() == 0 then return 0; end
	
	if fnWalkToEnchantPlace() == 0 then return 0; end
	
	if fnCheckEnchatRoleBagMoney() == 0 then return 0; end
	
	local iEnchatNum = TOrderInfo:GetSendNum();
	for i=1,iEnchatNum do
		fnResetEnchat();
		if fnEnchant() == 0 then return 0; end
	end
end

--fnStallDoWork();
--fnEnchantDoWork();


inspect(TLuaFuns,'func');