
local L = tdCore:NewLocale(..., 'zhCN')
if not L then return end

L['Enable Chat Messages'] = '启用聊天窗口显示错误信息'
L['Enable Sound'] = '启用声音提示'
L['Sound Path'] = '声音文件路径'
L['Taiduo\'s Error Frame'] = '太多错误列表'
L['%s blocked from using %s'] = [[插件[%s]对接口'%s'的调用导致界面行为失效]]
L['Macro blocked from using %s'] = [[宏代码对接口'%s'的调用导致界面行为失效]]
L['%s forbidden from using %s (Only usable by Blizzard)'] = [[插件[%s]试图调用接口'%s'，该功能只对暴雪的UI开放。]]
L['Macro forbidden from using %s (Only usable by Blizzard)'] = [[宏代码试图调用接口'%s'，该功能只对暴雪的UI开放。]]
L['Count:'] = '计数: '
L['Call Stack:'] = '调用栈: '
