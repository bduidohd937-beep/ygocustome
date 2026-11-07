-- 오션 테일 - 바다와 소녀
Duel.LoadScript("ocean_tale_v41.lua")
local ot=OceanTaleV41
local s,id=GetID()
function s.initial_effect(c)
 c:EnableReviveLimit()
 Link.AddProcedure(c,ot.monster,1,1)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
 e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
 e1:SetCode(EVENT_SPSUMMON_SUCCESS)
 e1:SetCountLimit(1,{id,1})
 e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
 e1:SetTarget(s.stg)
 e1:SetOperation(s.sop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
 e2:SetType(EFFECT_TYPE_IGNITION)
 e2:SetRange(LOCATION_MZONE)
 e2:SetCountLimit(1,{id,2})
 e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e2:SetTarget(s.sptg)
 e2:SetOperation(s.spop)
 c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c)
 e3:SetDescription(aux.Stringid(id,2))
 e3:SetType(EFFECT_TYPE_QUICK_O)
 e3:SetCode(EVENT_FREE_CHAIN)
 e3:SetRange(LOCATION_MZONE)
 e3:SetCountLimit(1,{id,3})
 e3:SetCondition(function() return Duel.IsBattlePhase() end)
 e3:SetCost(s.imcost)
 e3:SetOperation(s.imop)
 c:RegisterEffect(e3)
end
s.listed_series={ot.SET}
function s.stf(c) return ot.archetype(c) and c:IsAbleToHand() end
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(s.stf,tp,LOCATION_DECK,0,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sop(e,tp) ot.search(tp,s.stf) end
function s.spfilter(c,e,tp) return ot.monster(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 local zones=e:GetHandler():GetLinkedZone(tp)&0x1f
 if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
 if chk==0 then return zones~=0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
 local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp)
 local tc=Duel.GetFirstTarget();local zones=e:GetHandler():GetLinkedZone(tp)&0x1f
 if tc and tc:IsRelateToEffect(e) and zones~=0 then
  Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zones)
 end
end
function s.imcost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
 Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.imop(e,tp)
 local e1=Effect.CreateEffect(e:GetHandler())
 e1:SetType(EFFECT_TYPE_FIELD)
 e1:SetCode(EFFECT_IMMUNE_EFFECT)
 e1:SetTargetRange(LOCATION_MZONE,0)
 e1:SetTarget(function(e,c) return ot.monster(c) end)
 e1:SetValue(ot.immune)
 e1:SetReset(RESET_PHASE|PHASE_BATTLE)
 Duel.RegisterEffect(e1,tp)
end
