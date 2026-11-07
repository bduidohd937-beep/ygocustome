-- 오션 테일 - 고래와 소녀
Duel.LoadScript("ocean_tale_v41.lua")
local ot=OceanTaleV41
local s,id=GetID()
function s.initial_effect(c)
 c:EnableReviveLimit()
 Link.AddProcedure(c,ot.monster,2,2)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_TOHAND)
 e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
 e1:SetCode(EVENT_SPSUMMON_SUCCESS)
 e1:SetCountLimit(1,{id,1})
 e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
 e1:SetTarget(s.retg)
 e1:SetOperation(s.reop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetCategory(CATEGORY_NEGATE|CATEGORY_REMOVE)
 e2:SetType(EFFECT_TYPE_QUICK_O)
 e2:SetCode(EVENT_CHAINING)
 e2:SetRange(LOCATION_MZONE)
 e2:SetCountLimit(1,{id,2})
 e2:SetCondition(s.negcon)
 e2:SetCost(s.negcost)
 e2:SetTarget(s.negtg)
 e2:SetOperation(s.negop)
 c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c)
 e3:SetDescription(aux.Stringid(id,2))
 e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
 e3:SetType(EFFECT_TYPE_QUICK_O)
 e3:SetCode(EVENT_FREE_CHAIN)
 e3:SetRange(LOCATION_MZONE)
 e3:SetCountLimit(1,{id,3})
 e3:SetCondition(function() return Duel.IsMainPhase() end)
 e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e3:SetTarget(s.lvtg)
 e3:SetOperation(s.lvop)
 c:RegisterEffect(e3)
end
s.listed_series={ot.SET}
s.listed_names={ot.LEVIATHAN}
function s.retf(c) return ot.monster(c) and c:IsAbleToHand() end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(s.retf,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.reop(e,tp) ot.recover(tp,s.retf) end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
 if rp==tp or ev<=1 or not Duel.IsChainNegatable(ev) then return false end
 local previous=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
 local previous_player=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER)
 local handler=previous and previous:GetHandler()
 return previous and handler and previous_player==tp and handler:IsSetCard(ot.SET)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
 Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsChainNegatable(ev) end
 Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
 if not Duel.NegateActivation(ev) then return end
 local tc=re and re:GetHandler()
 if not tc or not tc:IsAbleToRemove() then return end
 if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT|REASON_TEMPORARY)>0 then
  ot.registerTempReturn(tc,tp)
 end
end
function s.lvf(c,e,tp)
 return c:IsCode(ot.LEVIATHAN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.lvf(chkc,e,tp) end
 if chk==0 then return ot.levirule(tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
  and Duel.IsExistingTarget(s.lvf,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
 local g=Duel.SelectTarget(tp,s.lvf,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,1-tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.lvop(e,tp)
 if not ot.levirule(tp) or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
 local tc=Duel.GetFirstTarget()
 if tc and tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP_ATTACK) end
end
