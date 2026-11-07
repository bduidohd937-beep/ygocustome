-- 오션 테일 - 마린
Duel.LoadScript("ocean_tale_v41.lua")
local ot=OceanTaleV41
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetType(EFFECT_TYPE_IGNITION)
 e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
 e1:SetCountLimit(1,{id,1})
 e1:SetCondition(s.spcon)
 e1:SetTarget(s.sptg)
 e1:SetOperation(s.spop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
 e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
 e2:SetProperty(EFFECT_FLAG_DELAY)
 e2:SetCode(EVENT_SUMMON_SUCCESS)
 e2:SetCountLimit(1,{id,2})
 e2:SetTarget(s.thtg)
 e2:SetOperation(s.thop)
 c:RegisterEffect(e2)
 local e2b=e2:Clone();e2b:SetCode(EVENT_SPSUMMON_SUCCESS);c:RegisterEffect(e2b)
 local e3=Effect.CreateEffect(c)
 e3:SetDescription(aux.Stringid(id,2))
 e3:SetCategory(CATEGORY_TOGRAVE)
 e3:SetType(EFFECT_TYPE_IGNITION)
 e3:SetRange(LOCATION_MZONE)
 e3:SetCountLimit(1,{id,3})
 e3:SetTarget(s.lvtg)
 e3:SetOperation(s.lvop)
 c:RegisterEffect(e3)
end
s.listed_series={ot.SET}
function s.water(c) return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) end
function s.spcon(e,tp)
 return not Duel.IsExistingMatchingCard(function(c) return not s.water(c) end,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end
function s.spop(e,tp)
 local c=e:GetHandler()
 if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
function s.thf(c) return ot.lv5(c) and c:IsAbleToHand() end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(s.thf,tp,LOCATION_DECK,0,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp) ot.search(tp,s.thf) end
function s.millf(c) return ot.lv5(c) and c:IsAbleToGrave() end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(s.millf,tp,LOCATION_DECK,0,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.lvop(e,tp)
 local c=e:GetHandler()
 if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
 local g=Duel.SelectMatchingCard(tp,s.millf,tp,LOCATION_DECK,0,1,1,nil)
 if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
 local e1=Effect.CreateEffect(c)
 e1:SetType(EFFECT_TYPE_SINGLE)
 e1:SetCode(EFFECT_UPDATE_LEVEL)
 e1:SetValue(1)
 e1:SetReset(RESET_EVENT|RESETS_STANDARD)
 c:RegisterEffect(e1)
end
