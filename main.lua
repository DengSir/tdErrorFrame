
local Addon = tdCore:NewAddon(...)
local L = Addon:GetLocale()
local errors = {}

local ErrorFrame = Addon:NewModule('ErrorFrame', tdCore('GUI')('MainFrame'):New(UIParent), 'Event')

function Addon:OnInit()
    self:InitDB('TDDB_TDERRORFRAME', {
        chat = true, sound = true, soundPath = [[Sound\Character\PlayerExertions\GnomeMaleFinal\GnomeMaleMainDeathA.wav]],
    })
    
    self:InitMinimap{
        icon = [[Interface\Buttons\UI-MicroButton-MainMenu-Up]],
        iconCoord = {0.09375, 0.90625, 0.46875, 0.89375},
        notGroup = true, angle = -253,
        scripts = {
            OnCall = function()
                self:GetModule('ErrorFrame'):Show()
            end
        }
    }
    
    local label = self:GetMinimap():GetLabelFontString()
    label:ClearAllPoints()
    label:SetPoint('CENTER', -1, 1)
    label:SetTextColor(1, 0, 0)
    
    self:InitOption{
        type = 'Widget',
        {
            type = 'CheckBox', label = L['Enable Chat Messages'],
            profile = {self:GetName(), 'chat'},
        },
        {
            type = 'CheckBox', label = L['Enable Sound'],
            profile = {self:GetName(), 'sound'},
        },
        {
            type = 'LineEdit', label = L['Sound Path'],
            profile = {self:GetName(), 'soundPath'},
        },
    }
end

function ErrorFrame:OnInit()
    self:SetLabelText(L['Taiduo\'s Error Frame'])
    self:SetSize(600, 500)
    self:SetAllowEscape(true)
    self:SetPoint('CENTER')
    self:HookScript('OnShow', self.Refresh)
    
    local ErrorList = tdCore('GUI')('ListWidget'):New(self)
    ErrorList:SetPoint('TOPLEFT', 20, -50)
    ErrorList:SetPoint('TOPRIGHT', -20, -50)
    ErrorList:SetHeight(140)
    ErrorList:SetSelectMode('RADIO')
    ErrorList:SetLabelText(ERRORS)
    ErrorList:SetItemList(errors)
    ErrorList:SetHandle('OnItemClick', function(o, index)
        self:SetErr(o:GetItemList():GetItem(index))
    end)
    
    local ErrorInfo = tdCore('GUI')('TextEdit'):New(self)
    ErrorInfo:SetLabelText(QUEST_DESCRIPTION)
    ErrorInfo:SetPoint('TOPLEFT', ErrorList, 'BOTTOMLEFT', 5, -25)
    ErrorInfo:SetPoint('BOTTOMRIGHT', -25, 45)
    ErrorInfo:SetReadOnly(true)
    
    local exitButton = tdCore('GUI')('Button'):New(self)
    exitButton:SetLabelText(CLOSE)
    exitButton:SetPoint('BOTTOMRIGHT', -20, 15)
    exitButton:SetScript('OnClick', function() self:Hide() end)
    
    local clearButton = tdCore('GUI')('Button'):New(self)
    clearButton:SetLabelText(CLEAR_ALL)
    clearButton:SetPoint('RIGHT', exitButton, 'LEFT', -5, 0)
    clearButton:SetScript('OnClick', function() wipe(errors) self:Refresh() end)
    
    local settingButton = tdCore('GUI')('Button'):New(self)
    settingButton:SetLabelText(SETTINGS)
    settingButton:SetPoint('BOTTOMLEFT', 20, 15)
    settingButton:SetScript('OnClick', function() Addon:ToggleOption() end)
    
    self.ErrorList = ErrorList
    self.ErrorInfo = ErrorInfo
    self.soundTime = 0
    
    self:RegisterEvent('ADDON_ACTION_BLOCKED')
    self:RegisterEvent('MACRO_ACTION_BLOCKED')
    self:RegisterEvent('ADDON_ACTION_FORBIDDEN')
    self:RegisterEvent('MACRO_ACTION_FORBIDDEN')
    seterrorhandler(function(err)
        self:AddError(err, 4)
    end)
    self:Refresh()
end

function ErrorFrame:ADDON_ACTION_BLOCKED(addon, port)
    self:AddError(format(L['%s blocked from using %s'], addon, port), 4)
end

function ErrorFrame:ADDON_ACTION_FORBIDDEN(port)
    self:AddError(format(L['Macro blocked from using %s'], port), 4)
end

function ErrorFrame:MACRO_ACTION_BLOCKED(addon, port)
    self:AddError(format(L['%s forbidden from using %s (Only usable by Blizzard)'], addon, port), 4)
end

function ErrorFrame:MACRO_ACTION_FORBIDDEN(port)
    self:AddError(format(L['Macro forbidden from using %s (Only usable by Blizzard)'], port), 4)
end

function ErrorFrame:AddError(err, retrace)
    for i, v in ipairs(errors) do
        if v.text == err then
            v.count = v.count + 1
            return
        end
    end
    tinsert(errors, {text = err, count = 1, stack = debugstack(retrace)})
    self:Refresh()
    
    if Addon:GetProfile().chat then
        print(('|cff45afd3tdErrorFrame|r: |cffcc1919%s|r'):format(err))
    end
    if Addon:GetProfile().sound and (GetTime() > self.soundTime) then
		PlaySoundFile(Addon.GetProfile().soundPath);
		self.soundTime = GetTime() + 1;
    end
end

local MESSAGE_FORMAT = '%s\n'..L['Count:']..' %d\n\n'..L['Call Stack:']..'\n%s'
function ErrorFrame:SetErr(value)
    self.ErrorInfo:SetText(value and MESSAGE_FORMAT:format(value.text, value.count, value.stack) or '')
end

function ErrorFrame:Refresh()
    if #errors > 0 then
        self.ErrorList:SetSelected(1)
        self.ErrorList:Refresh()
        self:SetErr(errors[1])
        Addon:GetMinimap():Show()
        Addon:GetMinimap():SetLabelText(#errors)
    else
        Addon:GetMinimap():Hide()
        self:Hide()
    end
end
