local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end
local Server = AIO.AddHandlers("WEEKLY_REWARDS", {})

local WeeklyRewards = WeeklyRewards or { }
local C_WeeklyRewards = C_WeeklyRewards or { }

local player = player or { }
function player:SetData( name, value )
    if ( not self.Data ) then self.Data = { } end
    if ( not name or not value ) then
        return
    end
    self.Data[ name ] = value
end

function player:GetData( name )
    return self.Data[ name ] or nil
end

function C_WeeklyRewards.GetActivities()
    return WeeklyRewards.Activities
end

function C_WeeklyRewards.CanClaimRewards()
    for _, data in pairs(WeeklyRewards.Activities) do
        for _, reward in pairs(data.Rewards) do
            return reward.Claimed
        end
    end
end

function C_WeeklyRewards.HasAvailableRewards()
    for name, data in pairs(WeeklyRewards.Activities) do
        for index, reward in pairs(data.Rewards) do
            return not reward.Claimed and not reward.Locked
        end
    end
end

function C_WeeklyRewards.ClaimReward(category, index)
    WeeklyRewards.Activities[category].Rewards[index].Claimed = true
end

function C_WeeklyRewards.UpdateActivity(category, index, data)
    WeeklyRewards.Activities[category].Rewards[index] = data
end

function C_WeeklyRewards:OrderPlayerData()
    local data = player:GetData( "WeeklyRewards" );
    if ( not data ) then return end

    for activityName, activityData in pairs( data ) do
        player:SetData( activityName, activityData );
    end
    player:SetData( "WeeklyRewards", nil );
end

function C_WeeklyRewards:SetActivityRewarded()
    local activity = player:GetData( "Selected" );
    if (not activity) then return false end

    local category = WeeklyRewards["Category_".. activity.name];
    if (not category) then return false end

    category.AvailableReward = category.AvailableReward + 1;

    local data = player:GetData( activity.name );
    if (not data) then return false end

    activity.Claimed             = true;
    data[activity.index].claimed = true;

    player:SetData( activity.name, data );
    WeeklyRewards:FullRefresh();

    return true;
end

local WEEKLY_REWARDS_CATEGORY_TYPE = {
    [1] = "Raids",
    [2] = "Dungeons",
    [3] = "PvP"
}

local NUM_COLUMNS = 3;

StaticPopupDialogs[ "CONFIRM_SELECT_WEEKLY_REWARD" ] = {
    text = "Êtes vous sûr de vouloir récupérer vos récompenses ?",
    button1 = "Oui!",
    button2 = "Non",
    OnAccept = function()
        local rewardClaim = false;
        local activity = player:GetData("Selected");

        if ( activity ) then
            rewardClaim = C_WeeklyRewards:SetActivityRewarded();
            if ( rewardClaim ) then
                PlaySoundFile( "Sound\\Interface\\ui_80_azeriteloot_toast.ogg" );
            end
        end
    end,
    timeout = 0,
    showAlertGear = 1,
    whileDead = false,
    hideOnEscape = true
}

local WEEKLY_REWARDS_CATEGORY = {
    Raids = {
        texture = "weeklyrewards-background-raid", pos = { 56, -152 }
    },
    Dungeons = {
        texture = "weeklyrewards-background-mythic", pos = { 56, -307 }
    },
    PvP = {
        texture = "weeklyrewards-background-pvp", pos = { 56, -462 }
    }
}

local COLOR = {
    [0] = { 1, 0, 0, 1 },
    [1] = { 1, 0.5, 0, 1 },
    [2] = { 1, 0.5, 0, 1 },
    [3] = { 0, 1, 0, 1 },
}

function WeeklyRewards:CreateWeeklyRewardsFrame()
    local frame = CreateFrame("Frame", "WeeklyRewardsFrame", UIParent);
        frame:SetSize(1165, 657);
        frame:SetPoint("CENTER");
        frame:SetMovable(false);
        frame:EnableMouse(true);
        frame:SetClampedToScreen(true);
        frame:SetToplevel(true);
        frame:Show();

    local texture = frame:CreateTexture("BackgroundTile", "BACKGROUND");
        texture = Atlas.SetAtlas(texture, "UI-Frame-Dragonflight-BackgroundTile", true);
        texture:SetAllPoints(frame);

    local divider1 = frame:CreateTexture("Divider1", "BORDER");
        divider1 = Atlas.SetAtlas( divider1, "dragonflight-weeklyrewards-divider", true );
        divider1:SetPoint( "TOP", frame, 0, -291 );

    local divider2 = frame:CreateTexture("Divider1", "BORDER");
        divider2 = Atlas.SetAtlas( divider2, "dragonflight-weeklyrewards-divider", true );
        divider2:SetPoint( "TOP", frame, 0, -446 );

    -- close button
    local closeButton = CreateFrame( "Button", "closeButton", frame, "UIPanelCloseButton" );
        closeButton:SetPoint( "TOPRIGHT", -3, -3 );

    self.main = frame;
    self:GenerateNineSlice();
    self:GenerateHeader();
    self:GenerateCategory();

    tinsert( UISpecialFrames, "WeeklyRewardsFrame" );
end

function WeeklyRewards:GenerateNineSlice()
    local textures = { };

    local NineSliceTopLeftCorner = self.main:CreateTexture("NineSliceTopLeftCorner", "BORDER");
        NineSliceTopLeftCorner = Atlas.SetAtlas( NineSliceTopLeftCorner, "Dragonflight-NineSlice-CornerTopLeft", true );
        NineSliceTopLeftCorner:SetPoint("TOPLEFT", self.main, "TOPLEFT", -6, 6);

    local NineSliceTopRightCorner = self.main:CreateTexture("NineSliceTopRightCorner", "BORDER");
        NineSliceTopRightCorner = Atlas.SetAtlas( NineSliceTopRightCorner, "Dragonflight-NineSlice-CornerTopRight", true );
        NineSliceTopRightCorner:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", 6, 6);

    local NineSliceBottomLeftCorner = self.main:CreateTexture("NineSliceBottomLeftCorner", "BORDER");
        NineSliceBottomLeftCorner = Atlas.SetAtlas( NineSliceBottomLeftCorner, "Dragonflight-NineSlice-CornerBottomLeft", true );
        NineSliceBottomLeftCorner:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", -6, -6);

    local NineSliceBottomRightCorner = self.main:CreateTexture("NineSliceBottomRightCorner", "BORDER");
        NineSliceBottomRightCorner = Atlas.SetAtlas( NineSliceBottomRightCorner, "Dragonflight-NineSlice-CornerBottomRight", true );
        NineSliceBottomRightCorner:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", 6, -6);

    local NineSliceTopEdge = self.main:CreateTexture("NineSliceTopEdge", "BORDER");
        NineSliceTopEdge = Atlas.SetAtlas( NineSliceTopEdge, "_Dragonflight-Nineslice-EdgeTop", true );
        NineSliceTopEdge:SetPoint("TOPLEFT", NineSliceTopLeftCorner, "TOPRIGHT", 0, 0);
        NineSliceTopEdge:SetVertTile(false);
        NineSliceTopEdge:SetSize(845, 30);

    local NineSliceBottomEdge = self.main:CreateTexture("NineSliceBottomEdge", "BORDER");
        NineSliceBottomEdge = Atlas.SetAtlas( NineSliceBottomEdge, "_Dragonflight-Nineslice-EdgeBottom", true );
        NineSliceBottomEdge:SetPoint("BOTTOMLEFT", NineSliceBottomLeftCorner, "BOTTOMRIGHT", 0, 0);
        NineSliceBottomEdge:SetVertTile(false);
        NineSliceBottomEdge:SetSize(845, 30);

    local NineSliceLeftEdge = self.main:CreateTexture("NineSliceLeftEdge", "BORDER");
        NineSliceLeftEdge = Atlas.SetAtlas( NineSliceLeftEdge, "!Dragonflight-NineSlice-EdgeLeft", true );
        NineSliceLeftEdge:SetPoint("TOPLEFT", NineSliceTopLeftCorner, "BOTTOMLEFT", 0, 0);
        NineSliceLeftEdge:SetHorizTile(false);
        NineSliceLeftEdge:SetSize(30, 337);

    local NineSliceRightEdge = self.main:CreateTexture("NineSliceRightEdge", "BORDER");
        NineSliceRightEdge = Atlas.SetAtlas( NineSliceRightEdge, "!Dragonflight-NineSlice-EdgeRight", true );
        NineSliceRightEdge:SetPoint("TOPRIGHT", NineSliceTopRightCorner, "BOTTOMRIGHT", 0, 0);
        NineSliceRightEdge:SetHorizTile(false);
        NineSliceRightEdge:SetSize(30, 337);

    textures["NineSliceTopLeftCorner"] = NineSliceTopLeftCorner;
    textures["NineSliceTopRightCorner"] = NineSliceTopRightCorner;
    textures["NineSliceBottomLeftCorner"] = NineSliceBottomLeftCorner;
    textures["NineSliceBottomRightCorner"] = NineSliceBottomRightCorner;
    textures["NineSliceTopEdge"] = NineSliceTopEdge;
    textures["NineSliceBottomEdge"] = NineSliceBottomEdge;
    textures["NineSliceLeftEdge"] = NineSliceLeftEdge;
    textures["NineSliceRightEdge"] = NineSliceRightEdge;

    return textures;
end

function WeeklyRewards:GenerateHeader()
    local frame = CreateFrame("Frame", "Header", self.main);
        frame:SetSize(1056, 85);
        frame:SetPoint("TOP", self.main, "TOP", 0, -42);
        frame:Show()

    local textureLeft = frame:CreateTexture("Left", "BORDER");
        textureLeft = Atlas.SetAtlas( textureLeft, "UI-Frame-Dragonflight-TitleLeft", true );
        textureLeft:SetPoint("LEFT", frame);

    local textureRight = frame:CreateTexture("Right", "BORDER");
        textureRight = Atlas.SetAtlas( textureRight, "UI-Frame-Dragonflight-TitleRight", true );
        textureRight:SetPoint("RIGHT", frame);

    local textureMiddle = frame:CreateTexture( "Middle", "BACKGROUND" )
        textureMiddle = Atlas.SetAtlas( textureMiddle, "_UI-Frame-Dragonflight-TitleMiddle", true )
        textureMiddle:SetPoint( "LEFT", textureLeft, "RIGHT", -60, 0 )
        textureMiddle:SetPoint( "RIGHT", textureRight, "LEFT", 60, 0 )
        textureMiddle:SetVertTile( false );
        textureMiddle:SetHorizTile( true );

    local text = frame:CreateFontString( "Text", "OVERLAY", "GameFontNormal" )
        text:SetFont( "Fonts\\FRIZQT__.TTF", 20 );
        text:SetJustifyH( "CENTER" );
        text:SetText( "Weekly Rewards" );
        text:SetPoint("CENTER", frame, "CENTER", 0, 0);
        text:SetText( "Weekly Rewards" );

    return frame;
end

function WeeklyRewards:GenerateCategory()
    for _, name in pairs(WEEKLY_REWARDS_CATEGORY_TYPE) do
        local category = CreateFrame("Frame", string.format("%sFrame", name), self.main);
            category:SetSize(326, 131);
            category:SetMovable(false);
            category:EnableMouse(true);
            category:SetClampedToScreen(true);
            category:SetToplevel(true);
            category:SetPoint("TOPLEFT", self.main, unpack(WEEKLY_REWARDS_CATEGORY[name].pos));

        local category_border = category:CreateTexture("Border", "BORDER");
            category_border = Atlas.SetAtlas( category_border, "dragonflight-weeklyrewards-frame-mode", true );
            category_border:SetPoint("LEFT", category, 0, 0);

        local category_background = category:CreateTexture("Background", "BACKGROUND");
            category_background:SetPoint( "LEFT", category, 2, 0 )
            category_background = Atlas.SetAtlas( category_background, WEEKLY_REWARDS_CATEGORY[name].texture, true );

        local category_name = category:CreateFontString( "Name", "ARTWORK", "GameFontNormal" )
            category_name:SetFont( "Fonts\\FRIZQT__.TTF", 20 );
            category_name:SetJustifyH( "LEFT" );
            category_name:SetPoint("TOPLEFT", category, "TOPLEFT", 28, -18);
            category_name:SetTextColor( 1, 0.82, 0, 1 );
            category_name:SetShadowColor( 0, 0, 0, 1 );
            category_name:SetShadowOffset( 1, -1 );
            category_name:SetWidth( 150 );
            category_name:SetText(name);

        local category_available_reward = category:CreateFontString( nil, "OVERLAY" );
            category_available_reward:SetFont( "Fonts\\FRIZQT__.TTF", 12 );
            category_available_reward:SetPoint( "BOTTOMLEFT", category, 20, 20 );
            category_available_reward:SetText( "0 / 3 récupérées" );
            category_available_reward:SetTextColor(unpack(COLOR[0]));
            category_available_reward:SetShadowColor( 0, 0, 0, 1 );
            category_available_reward:SetShadowOffset( 1, -1 );
            category_available_reward:SetJustifyH( "LEFT" );
            category_available_reward:SetWidth( 150 );

        self["Category_"..name]   = category;
        category.Border           = category_border;
        category.Background       = category_background;
        category.Name             = category_name;
        category.AvailableText    = category_available_reward;
        category.AvailableReward  = 0;

        self:SetUpActivity( category, name, _ )
    end
end

function WeeklyRewards:SetUpActivity( activityTypeFrame, name, activityType )
    local prevFrame;
    local player_data = player:GetData( name )
    local activites = self.Activities or {};
    for index = 1, NUM_COLUMNS do
        local reward = CreateFrame( "FRAME", string.format("Reward_%s", name), self.main );
        reward:SetSize(219, 126);
        reward:EnableMouse(true);

        if prevFrame then reward:SetPoint("LEFT", prevFrame, "RIGHT", 9, 0); else
            reward:SetPoint("LEFT", activityTypeFrame, "RIGHT", 56, 3); end

        self:GenerateRewardItem(reward);
        self:GenerateRewardTexture(reward);
        self:GenerateRewardAnimation(reward);

        reward:SetScript("OnEnter", function(self)
            if (not self.Locked) then
                self.SelectedTexture:Show();
            end
        end);

        reward:SetScript("OnMouseDown", function(self)
            if (not self.Claimed and not self.Locked) then
                player:SetData("Selected", reward);
                StaticPopup_Show( "CONFIRM_SELECT_WEEKLY_REWARD" );
            end
        end);

        reward:SetScript("OnLeave", function(self)
            self.SelectedTexture:Hide();
        end);

        reward.Locked       = player_data[ index ].locked;
        reward.Claimed      = player_data[ index ].claimed;

        if (reward.Claimed) then
            activityTypeFrame.AvailableReward = activityTypeFrame.AvailableReward + 1;
        end

        reward.Item         = player_data[ index ].item;

        reward.type         = activityType;
        reward.index        = index;
        reward.name         = name;

        prevFrame           = reward;
        table.insert( activites, reward );
    end
    self.Activities = activites;
end

function WeeklyRewards:GenerateRewardTexture(reward)
    local Border = reward:CreateTexture("Border", "BORDER");
        Border:SetAllPoints(reward);
        Border = Atlas.SetAtlas( Border, "weeklyrewards-frame-reward-locked", true );

    local Background = reward:CreateTexture(nil, "BACKGROUND");
        Background:SetAllPoints(reward);
        Background = Atlas.SetAtlas( Background, "weeklyrewards-background-reward-locked", true );

    local Orb = reward:CreateTexture("Orb", "BORDER");
        Orb = Atlas.SetAtlas( Orb, "weeklyrewards-orb-locked", true );
        Orb:SetPoint("BOTTOMRIGHT");

    local OrbSpin = reward:CreateTexture("OrbSpin", "OVERLAY");
        OrbSpin = Atlas.SetAtlas( OrbSpin, "oribos-weeklyrewards-orb-dialog", true );
        OrbSpin:SetPoint("BOTTOMRIGHT", -75, -10);
        OrbSpin:SetAlpha(.5);
        OrbSpin:SetBlendMode("ADD");
        OrbSpin:Hide();

    local LockIcon = reward:CreateTexture("LockIcon", "ARTWORK");
        LockIcon = Atlas.SetAtlas( LockIcon, "weeklyrewards-icon-incomplete", true );
        LockIcon:SetPoint("TOPLEFT", 9, -6);

   local ItemGlow = reward:CreateTexture("ItemGlow", "BORDER");
        ItemGlow = Atlas.SetAtlas( ItemGlow, "weeklyrewards-glow-redeem-epic", true );
        ItemGlow:SetPoint("CENTER", 2, -7);
        ItemGlow:Hide();

    local SelectedTexture = reward:CreateTexture("SelectedTexture", "OVERLAY");
        SelectedTexture = Atlas.SetAtlas( SelectedTexture, "weeklyrewards-frame-reward-selected", true );
        SelectedTexture:SetPoint("CENTER", 2, -2);
        SelectedTexture:Hide();

    local GlowBurst = reward:CreateTexture("GlowBurst", "OVERLAY");
        GlowBurst = Atlas.SetAtlas( GlowBurst, "weeklyrewards-frame-burst", true );
        GlowBurst:SetBlendMode("ADD");
        GlowBurst:SetPoint("CENTER");
        GlowBurst:SetAlpha(0);
        GlowBurst:Hide();

    local Sheen = reward:CreateTexture("Sheen", "OVERLAY");
        Sheen = Atlas.SetAtlas( Sheen, "weeklyrewards-frame-sheen", true );
        Sheen:SetBlendMode("ADD");
        Sheen:SetAlpha(0);
        Sheen:SetPoint("LEFT", -20, -3);
        Sheen:Hide();

    reward.Border           = Border;
    reward.Background       = Background;
    reward.Orb              = Orb;
    reward.OrbSpin          = OrbSpin;
    reward.LockIcon         = LockIcon;
    reward.ItemGlow         = ItemGlow;
    reward.GlowBurst        = GlowBurst;
    reward.Sheen            = Sheen;
    reward.SelectedTexture  = SelectedTexture;
end

function WeeklyRewards:GenerateRewardAnimation(reward)
    local SheenAnimGroup = reward.Sheen:CreateAnimationGroup();
        SheenAnimGroup:SetScript("OnPlay", function() reward.Sheen:Show(); end);
        SheenAnimGroup:SetScript("OnFinished", function() reward.Sheen:Hide(); end);
        SheenAnimGroup:SetScript("OnStop", function() reward.Sheen:Hide(); end);

        local SheenAnimationDelay = SheenAnimGroup:CreateAnimation("Alpha");
            SheenAnimationDelay:SetChange(0);
            SheenAnimationDelay:SetDuration(0);
            SheenAnimationDelay:SetOrder(1);

        local SheenAnimation = SheenAnimGroup:CreateAnimation("Alpha");
            SheenAnimation:SetChange(1);
            SheenAnimation:SetDuration(0.2);
            SheenAnimation:SetSmoothing("IN");
            SheenAnimation:SetOrder(2);

            SheenAnimation = SheenAnimGroup:CreateAnimation("Translation")
            SheenAnimation:SetDuration(.85);
            SheenAnimation:SetOffset(150, 0);
            SheenAnimation:SetOrder(3);

            SheenAnimation = SheenAnimGroup:CreateAnimation("Alpha");
            SheenAnimation:SetChange(-1);
            SheenAnimation:SetDuration(0.5);
            SheenAnimation:SetSmoothing("OUT");
            SheenAnimation:SetStartDelay(0.35);
            SheenAnimation:SetOrder(3);

    local GlowAnimGroup = reward.GlowBurst:CreateAnimationGroup();
        GlowAnimGroup:SetScript("OnPlay", function() reward.GlowBurst:Show(); end);
        GlowAnimGroup:SetScript("OnFinished", function() reward.GlowBurst:Hide(); end);
        GlowAnimGroup:SetScript("OnStop", function() reward.GlowBurst:Hide(); end);

        local GlowAnimationDelay = GlowAnimGroup:CreateAnimation("Alpha");
            GlowAnimationDelay:SetChange(0);
            GlowAnimationDelay:SetDuration(0);
            GlowAnimationDelay:SetOrder(1);

        local GlowAnimation = GlowAnimGroup:CreateAnimation("Alpha");
            GlowAnimation:SetChange(1);
            GlowAnimation:SetDuration(.6);
            GlowAnimation:SetSmoothing("IN");
            GlowAnimation:SetOrder(2);

        GlowAnimation = GlowAnimGroup:CreateAnimation("Alpha");
            GlowAnimation:SetChange(-1);
            GlowAnimation:SetDuration(0.5);
            GlowAnimation:SetSmoothing("OUT");
            GlowAnimation:SetOrder(3);

    local OrbSpinAnimGroup = reward.OrbSpin:CreateAnimationGroup();
    OrbSpinAnimGroup:SetLooping("REPEAT");

    local OrbSpinAnimation = OrbSpinAnimGroup:CreateAnimation("Rotation");
        OrbSpinAnimation:SetDegrees(-360);
        OrbSpinAnimation:SetDuration(20);

    reward.SheenAnim = SheenAnimGroup;
    reward.SheenAnimDelay = SheenAnimationDelay;
    reward.GlowAnim  = GlowAnimGroup;
    reward.GlowAnimDelay = GlowAnimationDelay;

    reward.OrbSpinAnim = OrbSpinAnimGroup;
end

function WeeklyRewards:GenerateRewardItem(reward)
    local ItemFrame = CreateFrame( "BUTTON", "ItemFrame", reward );
        ItemFrame:SetSize( 155, 49 );
        ItemFrame:SetPoint("CENTER", 2 -7)
        ItemFrame:SetFrameLevel(10)
        ItemFrame:Hide();
        ItemFrame:SetScript("OnEnter", function(self)
            if (reward.Item) then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                GameTooltip:SetHyperlink( select( 2, GetItemInfo( reward.Item ) ) )
                GameTooltip:Show();
            end
            reward.SelectedTexture:Show();
        end);

        ItemFrame:SetScript("OnMouseDown", function(self)
            player:SetData("Selected", reward);
            StaticPopup_Show( "CONFIRM_SELECT_WEEKLY_REWARD" );
        end);

        ItemFrame:SetScript("OnLeave", function(self)
            GameTooltip:Hide();
            reward.SelectedTexture:Hide();
        end);

    local Icon = ItemFrame:CreateTexture("Icon", "BORDER");
        Icon:SetSize( 37, 37 );
        Icon:SetPoint("LEFT", 4, 0);

    local GlowSpin = ItemFrame:CreateTexture("GlowSpin", "BACKGROUND");
        GlowSpin = Atlas.SetAtlas( GlowSpin, "services-ring-large-glowspin", true );
        GlowSpin:SetPoint("CENTER", Icon);
        GlowSpin:SetSize(37 * 3, 37 * 3);

    local Glow = ItemFrame:CreateTexture("Glow", "BACKGROUND");
        Glow = Atlas.SetAtlas( Glow, "services-ring-large-glow", true );
            Glow:SetPoint("CENTER", Icon);
            Glow:SetSize(37 * 3, 37 * 3);

    local ItemBorder = ItemFrame:CreateTexture("ItemBorder", "ARTWORK");
        ItemBorder = Atlas.SetAtlas( ItemBorder, "weeklyrewards-frame-item-epic", true );
            ItemBorder:SetPoint("CENTER");

    local IconOverlay = ItemFrame:CreateTexture("IconOverlay", "ARTWORK");
        IconOverlay:SetSize(37, 37);
        IconOverlay:SetPoint("CENTER", Icon);
        IconOverlay:Show()

    local Name = ItemFrame:CreateFontString("Name", "ARTWORK", "GameFontHighlight");
        Name:SetJustifyH("LEFT");
        Name:SetPoint("LEFT", ItemFrame, 51, 0);
        Name:SetSize(92, 0);
        Name:Show();

    local GlowSpinAnimGroup = GlowSpin:CreateAnimationGroup();
        GlowSpinAnimGroup:SetLooping("REPEAT");

    local GlowSpinAnimation = GlowSpinAnimGroup:CreateAnimation("Rotation");
        GlowSpinAnimation:SetDegrees(-360);
        GlowSpinAnimation:SetDuration(15);

    reward.ItemFrame            = ItemFrame;
    ItemFrame.Name              = Name;
    ItemFrame.Icon              = Icon;
    ItemFrame.Glow              = Glow;
    ItemFrame.GlowSpin          = GlowSpin;
    ItemFrame.ItemBorder        = ItemBorder;
    ItemFrame.IconOverlay       = IconOverlay;
--[[    ItemFrame.UnselectedFrame   = unselectedFrame;]]
    ItemFrame.GlowSpinAnim      = GlowSpinAnimGroup;
end

function WeeklyRewards:GetActivityFrame(activityType, index)
    for i, frame in ipairs(self.Activities) do
        if frame.type == activityType and frame.index == index then
            return frame;
        end
    end
end

function WeeklyRewards:UpdateRewardText(activities)
    local actualCategory;
    for _, activityInfo in ipairs(activities) do
        local frame = self:GetActivityFrame(activityInfo.type, activityInfo.index);
        local name = WEEKLY_REWARDS_CATEGORY_TYPE[activityInfo.type];
        local category = self["Category_"..name];

        if (actualCategory ~= category) then
            local rewards = 0;
            if (not frame.Locked and frame.Claimed) then
                rewards = category.AvailableReward;
            end
            category.AvailableText:SetTextColor(unpack(COLOR[rewards]));
            category.AvailableText:SetFormattedText("%d / 3 récupérées", rewards);
        end

        actualCategory = category;
    end
end

function WeeklyRewards:UpdateTexture(activities)
    for _, activityInfo in ipairs(activities) do
        local frame = self:GetActivityFrame(activityInfo.type, activityInfo.index);
        if (not frame.Locked) then
            frame.Border = Atlas.SetAtlas(frame.Border, "weeklyrewards-frame-reward-unlocked", true);
            frame.Background = Atlas.SetAtlas(frame.Background, "weeklyrewards-background-reward-unlocked", true);
            frame.LockIcon = Atlas.SetAtlas(frame.LockIcon, "weeklyrewards-icon-unlocked", true);

            if (frame.Claimed) then
                frame.ItemGlow:Hide();
                frame.ItemFrame:Hide();

                frame.Orb = Atlas.SetAtlas(frame.Orb, "oribos-weeklyrewards-orb-unlocked", true);
                frame.Orb:Show()
                frame.OrbSpin:Show();
            else
                frame.Orb:Hide();
                frame.ItemFrame.Icon:SetTexture( GetItemIcon( frame.Item ) );
                frame.ItemFrame.Name:SetText( select( 2, GetItemInfo( frame.Item ) ) );

                frame.ItemGlow:Show();
                frame.ItemFrame:Show();
            end
        end
    end
end

function WeeklyRewards:UpdateAnimation(activities)
    for _, activityInfo in ipairs(activities) do
        local frame = self:GetActivityFrame(activityInfo.type, activityInfo.index);
        local startDelay = (frame.index - 1) * .7;
        frame.SheenAnimDelay:SetDuration(startDelay);
        frame.SheenAnim:Play()

        if (not frame.Locked) then
            if (frame.Claimed) then
                frame.OrbSpinAnim:Play();
            else
                frame.GlowAnimDelay:SetDuration(startDelay);
                frame.GlowAnim:Play()
                frame.ItemFrame.GlowSpinAnim:Play();
            end
        end
    end
end

function WeeklyRewards:FullRefresh()
    local activities = C_WeeklyRewards.GetActivities();

    self:UpdateTexture(activities)
    self:UpdateAnimation(activities)
    self:UpdateRewardText(activities)
end

function WeeklyRewards:Refesh()
    local canClaimRewards = C_WeeklyRewards.CanClaimRewards();

    local activities = C_WeeklyRewards.GetActivities();
    for i, activityInfo in ipairs(activities) do
        local frame = self:GetActivityFrame(activityInfo.type, activityInfo.index);
        -- hide current progress for current week if rewards are present
        if canClaimRewards and #activityInfo.rewards == 0 then
            activityInfo.progress = 0;
        end
        if playSheenAnims then
            frame:MarkForPendingSheenAnim();
        end
        frame:Refresh(activityInfo);
    end

    if C_WeeklyRewards.HasAvailableRewards() then
        self.main:SetHeight(737);
    else
        self.main:SetHeight(657);
    end

    self:FullRefresh();
end

function Server.ShowFrame(_, data)
    self = WeeklyRewards;

    player:SetData( "WeeklyRewards", data.Activities )
    C_WeeklyRewards:OrderPlayerData()

    if ( not WeeklyRewards.main ) then
        self:CreateWeeklyRewardsFrame();
    end

    self:FullRefresh()
    self.main:Show();
end