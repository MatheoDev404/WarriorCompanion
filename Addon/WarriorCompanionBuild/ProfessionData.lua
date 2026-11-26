local _,B=...
-- Donnees metiers (Forever 1.60.1). Source principalement :
-- https://foreverchanges.pro/fr/professions/mining
-- https://zephras.com/forever/enUS/profession-guide/164/
-- Aucun circuit ou point exact de filon invente.
-- Les recettes du client, si disponibles, remplacent ces fiches de reference.
B.professionGuides={
 {id="leveling",name="Leveling 1-60",type="leveling"},
 {id="mining",name="Minage 1-300",type="profession",skills={"mining"}},
 {id="smithing",name="Forge 1-300",type="profession",skills={"smithing"}},
 {id="combo",name="Minage + Forge 1-300",type="profession",
   skills={"mining","smithing"}},
}
B.professionNames={
 mining={name="Minage",en="Mining",line=186},
 smithing={name="Forge",en="Blacksmithing",line=164}
}
-- minLevel est une estimation de confort SOLO, pas une condition du jeu.
-- Les zones listees ne garantissent pas la presence d'un filon au point precis.
B.miningBands={
 {from=1,to=65,node="Filon de cuivre",required=1,
  zones={{name="Durotar",map=1411,minLevel=1},
         {name="Forêt des Pins argentés",map=1421,minLevel=10}}},
 {from=65,to=125,node="Filon d'étain et filon d'argent",required=65,
  zones={{name="Forêt des Pins argentés",map=1421,minLevel=18},
         {name="Hautes-terres d'Arathi",map=1417,minLevel=30}}},
 {from=125,to=175,node="Gisement de fer et filon d'or",required=125,
  zones={{name="Hautes-terres d'Arathi",map=1417,minLevel=31},
         {name="Vallée de Strangleronce",map=1434,minLevel=33},
         {name="Montagnes d'Alterac",map=1416,minLevel=33}}},
 {from=175,to=245,node="Gisement de mithril",required=175,
  zones={{name="Montagnes d'Alterac",map=1416,minLevel=35},
         {name="Terres ingrates",map=1418,minLevel=39},
         {name="Les Hinterlands",map=1425,minLevel=42}}},
 {from=245,to=275,node="Petit filon de thorium",required=245,
  zones={{name="Marais des Chagrins",map=1435,minLevel=46},
         {name="Berceau-de-l'Hiver",map=1452,minLevel=56}}},
 {from=275,to=300,node="Riche filon de thorium",required=275,
  zones={{name="Azshara",map=1447,minLevel=49},
         {name="Berceau-de-l'Hiver",map=1452,minLevel=56}}},
}
B.miningVeins={
 {skill=1,name="Cuivre",ore=2770},
 {skill=65,name="Etain",ore=2771},
 {skill=75,name="Argent",ore=2775},
 {skill=125,name="Fer",ore=2772},
 {skill=155,name="Or",ore=2776},
 {skill=175,name="Mithril",ore=3858},
 {skill=230,name="Vrai-argent",ore=7911},
 {skill=245,name="Thorium (petit)",ore=10620},
 {skill=275,name="Thorium (riche)",ore=10620},
}
-- output est l'objet, ore les intrants de fonte; q est le nombre cree.
-- La fonte peut devenir grise et ne donne alors plus de point de metier.
B.smelting={
 [2840]={name="Barre de cuivre",skill=1,q=1,mats={{2770,1}}},
 [3576]={name="Barre d'étain",skill=65,q=1,mats={{2771,1}}},
 [2841]={name="Barre de bronze",skill=65,q=2,
   mats={{2840,1},{3576,1}}},
 [2842]={name="Barre d'argent",skill=75,q=1,mats={{2775,1}}},
 [3575]={name="Barre de fer",skill=125,q=1,mats={{2772,1}}},
 [3577]={name="Barre d'or",skill=155,q=1,mats={{2776,1}}},
 [3859]={name="Barre d'acier",skill=165,q=1,
   mats={{3575,1},{3857,1}}},
 [3860]={name="Barre de mithril",skill=175,q=1,mats={{3858,1}}},
 [6037]={name="Barre de vrai-argent",skill=230,q=1,mats={{7911,1}}},
 [12359]={name="Barre de thorium",skill=250,q=1,mats={{10620,1}}},
}
B.professionTrainers={
 mining={
  {skill=50,cap=150,name="Compagnon",level=10},
  {skill=125,cap=225,name="Expert",level=20},
  {skill=200,cap=300,name="Artisan",level=35}
 },
 smithing={
  {skill=50,cap=150,name="Compagnon",level=10},
  {skill=125,cap=225,name="Expert",level=20},
  {skill=200,cap=300,name="Artisan",level=35}
 }
}
-- Forgeron et mineur Horde confirmes a Orgrimmar, mais pas de /way
-- tant que les coordonnees exactes Forever ne sont pas etablies.
B.professionTrainersHorde={
 mining="Makaru (Vallee de l'Honneur, Orgrimmar)",
 smithing="Ug'thok (Orgrimmar); rang artisan : verifier le maitre"
}
-- Fourchettes de progression et composants de base recoupes sur Zephras.
-- Les nombres a fabriquer ne sont PAS fixes : le moteur planifie un petit
-- lot, puis relit la competence, car jaune/vert ne donnent pas 100 % de gain.
-- Si le client indique une autre recette ou une autre formule, le client prime.
B.smithingBands={
 {from=1,to=35,item=2862,name="Pierre a aiguiser brute",
  mats={{2835,1}},source="apprise au depart",kind="consumable"},
 {from=35,to=85,item=3470,name="Pierre a broyer brute",
  mats={{2835,2}},source="maitre",kind="component"},
 {from=85,to=100,item=2865,name="Jambieres en bronze brut",
  mats={{2841,6}},source="maitre",kind="armor"},
 {from=100,to=111,item=2871,name="Pierre a aiguiser lourde",
  mats={{2838,1}},source="maitre",kind="consumable"},
 {from=111,to=125,item=2865,name="Jambieres en bronze brut",
  mats={{2841,6}},source="maitre",kind="armor"},
 {from=125,to=129,item=7071,name="Boucle en fer",
  mats={{3575,1}},source="maitre",kind="component"},
 {from=129,to=140,item=2868,name="Brassards en bronze ouvrage",
  mats={{2841,5},{3478,2}},source="maitre",kind="armor"},
 {from=140,to=175,item=3835,name="Brassards en fer vert",
  mats={{3575,6},{2605,1}},source="maitre",kind="armor",
  note="+4 Force / +5 Endurance; garder un exemplaire si utile au Guerrier."},
 {from=175,to=185,item=7964,name="Pierre a aiguiser solide",
  mats={{7912,1}},source="maitre",kind="consumable"},
 {from=185,to=190,item=6040,name="Brassards en ecailles dorees",
  mats=nil,source="maitre",kind="armor",
  note="Ouvrir Forge pour confirmer les composants du client avant d'acheter."},
 {from=190,to=208,item=7919,name="Gantelets lourds en mithril",
  mats={{3860,6},{4338,4}},source="maitre",kind="armor"},
 {from=208,to=225,item=7931,name="Camail en mithril",
  mats={{3860,10},{4338,6}},source="maitre",kind="armor"},
 {from=225,to=235,item=12404,name="Pierre a aiguiser dense",
  mats={{12365,1}},source="maitre",kind="consumable"},
 {from=235,to=267,item=7947,name="Lame d'ebene",
  mats={{3860,12},{6037,6},{7910,2},{7966,1},{4304,2}},
  source="plan",kind="weapon",note="Plan rare, ne pas prevoir ces achats avant de le connaitre."},
 {from=267,to=292,item=12773,name="Hachette ornee en thorium",
  mats={{12359,20},{12799,2},{12644,2},{8170,4}},
  source="plan",kind="weapon",note="Arme 1 main Force, plan non garanti. Alternative a verifier."},
 {from=292,to=300,item=12775,name="Grande hache de bataille en thorium",
  mats={{12359,40},{12644,6},{8170,6}},
  source="plan",kind="weapon",note="Arme 2 mains, craft uniquement pour le metier; ne pas equiper en Furie ambidextre."},
}
B.professionSourceURLs={
 "https://foreverchanges.pro/fr/professions/mining",
 "https://foreverchanges.pro/fr/professions/blacksmithing",
 "https://zephras.com/forever/enUS/profession-guide/164/",
 "https://github.com/sjdodge123/mailworthy",
}
function B:GuideRegistry()
 return self.professionGuides
end
function B:GuideDefinition(id)
 for _,guide in ipairs(self.professionGuides) do
  if guide.id==id then return guide end
 end
 return nil
end
