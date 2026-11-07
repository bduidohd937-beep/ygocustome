Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c); e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O); e1:SetProperty(EFFECT_FLAG_DELAY); e1:SetCode(ISOBAR.EVENT); e1:SetRange(LOCATION_HAND+LOCATION_GRAVE); e1:SetCountLimit(1,id); e1:SetCondition(function(e,tp) return ISOBAR.Field(tp)~=nil end); e1:SetTarget(s.sptg); e1:SetOperation(s.spop); c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c); e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O); e2:SetProperty(EFFECT_FLAG_DELAY); e2:SetCode(EVENT_BE_MATERIAL); e2:SetCountLimit(1,id+1000); e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r&REASON_XYZ~=0 end); e2:SetOperation(s.gain); c:RegisterEffect(e2)
end
s.listed_names={210000210}; s.listed_series={ISOBAR.SET}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler(); if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end end
function s.spop(e,tp) local c=e:GetHandler(); local fromgrave=c:IsLocation(LOCATION_GRAVE); if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and fromgrave then local a=Effect.CreateEffect(c); a:SetType(EFFECT_TYPE_SINGLE); a:SetCode(EFFECT_LEAVE_FIELD_REDIRECT); a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE); a:SetReset(RESET_EVENT+RESETS_REDIRECT); a:SetValue(LOCATION_REMOVED); c:RegisterEffect(a,true) end end
function s.gain(e,tp,eg,ep,ev,re,r,rp)
 local rc=e:GetHandler():GetReasonCard()
 if not rc or not rc:IsFaceup() or not rc:IsType(TYPE_XYZ) or not rc:IsSetCard(ISOBAR.SET) then return end
 local x=Effect.CreateEffect(rc); x:SetDescription(aux.Stringid(id,1)); x:SetCategory(CATEGORY_NEGATE); x:SetType(EFFECT_TYPE_QUICK_O); x:SetCode(EVENT_CHAINING); x:SetRange(LOCATION_MZONE); x:SetCountLimit(1,id+2000); x:SetCondition(function(xe,xt,eg2,ep2,ev2,re2,r2,rp2) return rp2==1-xt and re2:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev2) and xe:GetHandler():GetOverlayGroup():IsContains(e:GetHandler()) end); x:SetCost(function(xe,xt,eg2,ep2,ev2,re2,r2,rp2,chk) if chk==0 then return xe:GetHandler():CheckRemoveOverlayCard(xt,1,REASON_COST) end; xe:GetHandler():RemoveOverlayCard(xt,1,1,REASON_COST) end); x:SetTarget(function(xe,xt,eg2,ep2,ev2,re2,r2,rp2,chk) if chk==0 then return true end; Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg2,1,0,0) end); x:SetOperation(function(xe,xt,eg2,ep2,ev2,re2,r2,rp2) Duel.NegateEffect(ev2) end); x:SetReset(RESET_EVENT+RESETS_STANDARD); rc:RegisterEffect(x)
end
