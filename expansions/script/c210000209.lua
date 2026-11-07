Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 Xyz.AddProcedure(c,function(tc) return tc:IsLevel(4) and tc:IsRace(RACE_MACHINE) end,4,2,nil,nil,3); c:EnableReviveLimit()
 local e1=Effect.CreateEffect(c); e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O); e1:SetProperty(EFFECT_FLAG_DELAY); e1:SetCode(EVENT_SPSUMMON_SUCCESS); e1:SetCountLimit(1,id); e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and ISOBAR.Field(e:GetHandlerPlayer())~=nil end); e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return ISOBAR.State(tp)~=ISOBAR.STORM end end); e1:SetOperation(function(e,tp) ISOBAR.Change(tp,ISOBAR.STORM,e) end); c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c); e2:SetType(EFFECT_TYPE_QUICK_O); e2:SetCode(EVENT_FREE_CHAIN); e2:SetRange(LOCATION_MZONE); e2:SetCountLimit(1,id+1000); e2:SetCost(s.cost); e2:SetTarget(s.ntg); e2:SetOperation(s.nop); c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c); e3:SetType(EFFECT_TYPE_QUICK_O); e3:SetCode(EVENT_FREE_CHAIN); e3:SetRange(LOCATION_MZONE); e3:SetCountLimit(1,id+2000); e3:SetProperty(EFFECT_FLAG_CARD_TARGET); e3:SetCondition(function(e,tp) return not ISOBAR.Is(tp,ISOBAR.STORM) end); e3:SetCost(s.cost); e3:SetTarget(s.tgt); e3:SetOperation(s.op); c:RegisterEffect(e3)
 local e4=Effect.CreateEffect(c); e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O); e4:SetCode(EVENT_BATTLE_DESTROYING); e4:SetCountLimit(1,id+3000); e4:SetOperation(function(e) local c=e:GetHandler(); local x=Effect.CreateEffect(c); x:SetType(EFFECT_TYPE_SINGLE); x:SetCode(EFFECT_UPDATE_ATTACK); x:SetValue(500); x:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END); c:RegisterEffect(x); if c:GetOverlayCount()>=3 then local y=Effect.CreateEffect(c); y:SetType(EFFECT_TYPE_SINGLE); y:SetCode(EFFECT_EXTRA_ATTACK); y:SetValue(1); y:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END); c:RegisterEffect(y) end end); c:RegisterEffect(e4)
end
s.listed_series={ISOBAR.SET}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end; e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST) end
function s.ntg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return ISOBAR.Is(tp,ISOBAR.STORM) and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end end
function s.nop(e,tp) local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil); if #g>0 then Duel.SendtoHand(g:Select(tp,1,1,nil),nil,REASON_EFFECT) end end
function s.tfilter(c) return c:IsAbleToHand() end
function s.tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc) if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.tfilter(chkc) end; if chk==0 then return Duel.IsExistingTarget(s.tfilter,tp,0,LOCATION_ONFIELD,1,nil) end; Duel.SelectTarget(tp,s.tfilter,tp,0,LOCATION_ONFIELD,1,1,nil) end
function s.op(e,tp) local c=Duel.GetFirstTarget(); if c and c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end end
