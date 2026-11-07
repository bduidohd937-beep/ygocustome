-- Deathfire Volt V2: 210000103
local s,id=GetID()
local SET=0x1df0
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_TOGRAVE)
 e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 e1:SetProperty(EFFECT_FLAG_DELAY)
 e1:SetCode(EVENT_SUMMON_SUCCESS)
 e1:SetCountLimit(1,id)
 e1:SetTarget(s.tgtg)
 e1:SetOperation(s.tgop)
 c:RegisterEffect(e1)
 local e2=e1:Clone()
 e2:SetCode(EVENT_SPSUMMON_SUCCESS)
 c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c)
 e3:SetDescription(aux.Stringid(id,1))
 e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
 e3:SetType(EFFECT_TYPE_IGNITION)
 e3:SetRange(LOCATION_GRAVE)
 e3:SetCountLimit(1,id+1000)
 e3:SetCost(aux.bfgcost)
 e3:SetTarget(s.sptg)
 e3:SetOperation(s.spop)
 c:RegisterEffect(e3)
end
s.listed_series={SET}
function s.tgfilter(c)
 return c:IsSetCard(SET) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
 local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
 if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
 local e1=Effect.CreateEffect(e:GetHandler())
 e1:SetType(EFFECT_TYPE_FIELD)
 e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
 e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
 e1:SetTargetRange(1,0)
 e1:SetTarget(s.exlimit)
 e1:SetReset(RESET_PHASE+PHASE_END)
 Duel.RegisterEffect(e1,tp)
end
function s.exlimit(e,c)
 return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_THUNDER)
end
function s.spfilter(c,e,tp)
 return c:IsSetCard(SET) and c:IsMonster() and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
 if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
 local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
 local tc=g:GetFirst()
 if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_DISABLE)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
  tc:RegisterEffect(e1)
  local e2=e1:Clone()
  e2:SetCode(EFFECT_DISABLE_EFFECT)
  tc:RegisterEffect(e2)
 end
end
