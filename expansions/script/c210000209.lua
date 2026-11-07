-- Isobar Xyz: 210000209
Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 Xyz.AddProcedure(c,s.matfilter,4,3)
 c:EnableReviveLimit()
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 e1:SetProperty(EFFECT_FLAG_DELAY)
 e1:SetCode(EVENT_SPSUMMON_SUCCESS)
 e1:SetCountLimit(1,id)
 e1:SetCondition(s.wxcon)
 e1:SetTarget(s.wxtg)
 e1:SetOperation(s.wxop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetCategory(CATEGORY_TOHAND)
 e2:SetType(EFFECT_TYPE_IGNITION)
 e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e2:SetRange(LOCATION_MZONE)
 e2:SetCountLimit(1,id+1000)
 e2:SetCost(s.cost)
 e2:SetTarget(s.target)
 e2:SetOperation(s.operation)
 c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c)
 e3:SetDescription(aux.Stringid(id,2))
 e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 e3:SetCode(EVENT_BATTLE_DESTROYING)
 e3:SetCountLimit(1,id+2000)
 e3:SetOperation(s.atkop)
 c:RegisterEffect(e3)
end
s.listed_series={ISOBAR.SET}
function s.matfilter(c) return c:IsRace(RACE_MACHINE) end
function s.wxcon(e,tp,eg,ep,ev,re,r,rp)
 return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and ISOBAR.Field(tp)~=nil
end
function s.wxtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return ISOBAR.State(tp)~=ISOBAR.STORM end
end
function s.wxop(e,tp,eg,ep,ev,re,r,rp) ISOBAR.Change(tp,ISOBAR.STORM,e) end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
 e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.filter(c) return c:IsAbleToHand() end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.filter(chkc) end
 if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
 local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
 local tc=Duel.GetFirstTarget()
 if tc and tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
 local c=e:GetHandler()
 if not c:IsFaceup() then return end
 local e1=Effect.CreateEffect(c)
 e1:SetType(EFFECT_TYPE_SINGLE)
 e1:SetCode(EFFECT_UPDATE_ATTACK)
 e1:SetValue(500)
 e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
 c:RegisterEffect(e1)
end
