-- Isobar: 210000205
Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
 e1:SetType(EFFECT_TYPE_IGNITION)
 e1:SetRange(LOCATION_HAND)
 e1:SetCountLimit(1,id)
 e1:SetTarget(s.sptg)
 e1:SetOperation(s.spop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 e2:SetCode(EVENT_TO_GRAVE)
 e2:SetProperty(EFFECT_FLAG_DELAY)
 e2:SetCountLimit(1,id+1000)
 e2:SetCondition(s.weathercon)
 e2:SetTarget(s.weathertg)
 e2:SetOperation(s.weatherop)
 c:RegisterEffect(e2)
end
s.listed_series={ISOBAR.SET}
function s.ally(c) return c:IsFaceup() and ISOBAR.Monster(c) end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
 local c=e:GetHandler()
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingMatchingCard(s.ally,tp,LOCATION_MZONE,0,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
 local c=e:GetHandler()
 if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
function s.weathercon(e,tp,eg,ep,ev,re,r,rp)
 return e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY) and ISOBAR.State(tp)>0
end
function s.weathertg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return ISOBAR.State(tp)>0 end
end
function s.weatherop(e,tp,eg,ep,ev,re,r,rp)
 local old=ISOBAR.State(tp)
 if old>0 then ISOBAR.Change(tp,ISOBAR.Choose(tp,old),e) end
end
