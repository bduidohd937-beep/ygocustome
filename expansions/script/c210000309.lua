-- 오션 테일 - 모험의 시작
Duel.LoadScript("ocean_tale_v41.lua")
local ot=OceanTaleV41
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_RELEASE|CATEGORY_TOGRAVE)
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_FREE_CHAIN)
 e1:SetCountLimit(1,id)
 e1:SetTarget(s.rittg)
 e1:SetOperation(s.ritop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetCategory(CATEGORY_TOHAND)
 e2:SetType(EFFECT_TYPE_IGNITION)
 e2:SetRange(LOCATION_GRAVE)
 e2:SetCountLimit(1,{id,2})
 e2:SetCost(s.grcost)
 e2:SetTarget(s.grtg)
 e2:SetOperation(s.grop)
 c:RegisterEffect(e2)
end
s.listed_series={ot.SET}
function s.ritmon(c,e,tp)
 return ot.ritual(c) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.mat(c) return c:IsMonster() and c:IsReleasable() and c:HasLevel() end
function s.deckmat(c) return c:IsMonster() and c:IsAbleToGrave() and c:HasLevel() end
function s.hasEnough(tp,rc)
 local total=0
 local ag=Duel.GetMatchingGroup(s.mat,tp,LOCATION_HAND|LOCATION_MZONE,0,rc)
 for mc in aux.Next(ag) do total=total+mc:GetLevel() end
 return total>=rc:GetLevel()
end
function s.can(tp,e)
 local rituals=Duel.GetMatchingGroup(function(c) return s.ritmon(c,e,tp) end,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil)
 for rc in aux.Next(rituals) do
  if s.hasEnough(tp,rc) then return true end
  if Duel.GetFlagEffect(tp,id+100)==0 and Duel.IsExistingMatchingCard(s.deckmat,tp,LOCATION_DECK,0,1,rc) then return true end
 end
 return false
end
function s.rittg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and s.can(tp,e) end
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.ritop(e,tp)
 local rituals=Duel.GetMatchingGroup(function(c) return s.ritmon(c,e,tp) end,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil)
 local candidates=rituals:Filter(function(rc)
  return s.hasEnough(tp,rc) or
   (Duel.GetFlagEffect(tp,id+100)==0 and Duel.IsExistingMatchingCard(s.deckmat,tp,LOCATION_DECK,0,1,rc))
 end,nil)
 if #candidates==0 then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
 local rc=candidates:Select(tp,1,1,nil):GetFirst();local need=rc:GetLevel()
 local useDeck=false;local total=0
 local all=Duel.GetMatchingGroup(s.mat,tp,LOCATION_HAND|LOCATION_MZONE,0,rc)
 for mc in aux.Next(all) do total=total+mc:GetLevel() end
 if total<need then useDeck=true
 elseif Duel.GetFlagEffect(tp,id+100)==0 and Duel.IsExistingMatchingCard(s.deckmat,tp,LOCATION_DECK,0,1,rc) then
  useDeck=Duel.SelectYesNo(tp,aux.Stringid(id,0))
 end
 local virtual=0
 if useDeck then
  local dg=Duel.GetMatchingGroup(s.deckmat,tp,LOCATION_DECK,0,rc)
  if #dg==0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
  local dc=dg:Select(tp,1,1,nil):GetFirst();virtual=dc:GetLevel()
  if Duel.SendtoGrave(dc,REASON_EFFECT)==0 then return end
 end
 local remainder=math.max(0,need-virtual)
 local chosen=Group.CreateGroup();local level=0
 while level<remainder do
  local pool=Duel.GetMatchingGroup(s.mat,tp,LOCATION_HAND|LOCATION_MZONE,0,rc)
  pool:Sub(chosen)
  if #pool==0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
  local mc=pool:Select(tp,1,1,nil):GetFirst();chosen:AddCard(mc);level=level+mc:GetLevel()
 end
 if #chosen>0 and Duel.Release(chosen,REASON_EFFECT|REASON_RITUAL|REASON_MATERIAL)==0 then return end
 rc:SetMaterial(chosen)
 if Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
  rc:CompleteProcedure()
  Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
 end
end
function s.grcost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and e:GetHandler():GetTurnID()~=Duel.GetTurnCount() end
 Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.grf(c) return ot.archetype(c) and c:IsAbleToHand() end
function s.grtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.grf(chkc) end
 if chk==0 then return Duel.IsExistingTarget(s.grf,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
 local g=Duel.SelectTarget(tp,s.grf,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.grop(e,tp)
 local tc=Duel.GetFirstTarget()
 if tc and tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT);Duel.ConfirmCards(1-tp,tc) end
end
