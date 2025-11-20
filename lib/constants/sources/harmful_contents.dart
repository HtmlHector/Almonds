class HarmfulContent {
  final String name;
  final String description;

  const HarmfulContent({required this.name, required this.description});
}

final List<HarmfulContent> harmfulIngredients = [
  // ===== Artificial Colors =====
  HarmfulContent(
    name: 'red 40',
    description:
        'A synthetic red dye used in candies, cereals, and drinks. Linked to hyperactivity and allergic reactions in sensitive individuals. Some studies suggest possible carcinogenic effects.',
  ),
  HarmfulContent(
    name: 'yellow 5',
    description:
        'Also called tartrazine, this dye is used in chips, snacks, and sodas. May trigger hyperactivity and allergic reactions in those sensitive to aspirin or benzoates.',
  ),
  HarmfulContent(
    name: 'yellow 6',
    description:
        'Also known as sunset yellow, used in candies, baked goods, and beverages. Linked in animal studies to adrenal and kidney problems.',
  ),
  HarmfulContent(
    name: 'blue 1',
    description:
        'Bright blue coloring found in drinks, candy, and desserts. Some evidence suggests potential allergic and neurological effects.',
  ),
  HarmfulContent(
    name: 'blue 2',
    description:
        'Indigo carmine dye used in sweets and snacks. Linked in animal studies to possible brain tumors at high exposure levels.',
  ),
  HarmfulContent(
    name: 'green 3',
    description:
        'Synthetic green dye used in mint candies and snacks. Associated with bladder and thyroid effects in animal tests.',
  ),
  HarmfulContent(
    name: 'red 3',
    description:
        'Erythrosine dye used in cherries and icings. Shown to cause thyroid tumors in animals and banned from cosmetics.',
  ),

  // ===== Artificial Sweeteners =====
  HarmfulContent(
    name: 'aspartame',
    description:
        'Low-calorie sweetener found in diet snacks and drinks. Must be avoided by those with PKU. Linked to headaches and mood changes in sensitive individuals.',
  ),
  HarmfulContent(
    name: 'sucralose',
    description:
        'Artificial sweetener sold as Splenda. May disrupt gut bacteria and affect insulin response when consumed often.',
  ),
  HarmfulContent(
    name: 'saccharin',
    description:
        'Oldest artificial sweetener used in sugar-free gums and diet foods. Linked to bladder cancer in early studies, though considered safe in small amounts today.',
  ),
  HarmfulContent(
    name: 'acesulfame k',
    description:
        'Artificial sweetener often combined with aspartame or sucralose. May impact metabolism and gut bacteria based on some studies.',
  ),
  HarmfulContent(
    name: 'neotame',
    description:
        'Powerful artificial sweetener similar to aspartame. Limited long-term data; may affect metabolism in high amounts.',
  ),
  HarmfulContent(
    name: 'advantame',
    description:
        'Newer sweetener derived from aspartame. Limited research but some concern about metabolic side effects.',
  ),

  // ===== Preservatives =====
  HarmfulContent(
    name: 'sodium nitrite',
    description:
        'Used to preserve meats like bacon and sausages. Can form nitrosamines, carcinogenic compounds when cooked at high heat.',
  ),
  HarmfulContent(
    name: 'sodium nitrate',
    description:
        'Preservative and color stabilizer in cured meats. Linked to increased colorectal cancer risk.',
  ),
  HarmfulContent(
    name: 'sodium benzoate',
    description:
        'Used in sodas and acidic foods. When mixed with vitamin C, can form benzene, a known carcinogen.',
  ),
  HarmfulContent(
    name: 'potassium sorbate',
    description:
        'Mold-preventing preservative in cheeses and baked goods. May cause skin irritation in sensitive people.',
  ),
  HarmfulContent(
    name: 'bha',
    description:
        'Butylated hydroxyanisole, a fat preservative found in chips and cereals. Classified as a possible human carcinogen.',
  ),
  HarmfulContent(
    name: 'bht',
    description:
        'Butylated hydroxytoluene, used with BHA to prevent rancidity. May disrupt hormones and cause organ effects in animals.',
  ),
  HarmfulContent(
    name: 'propyl gallate',
    description:
        'Used in oils and processed foods to prevent spoilage. May cause allergic reactions and hormone disruption.',
  ),
  HarmfulContent(
    name: 'sodium metabisulfite',
    description:
        'Preservative in dried fruits, wines, and snack seasonings. Can cause asthma or allergic reactions.',
  ),
  HarmfulContent(
    name: 'calcium propionate',
    description:
        'Mold inhibitor in bread and bakery products. Linked to hyperactivity and migraines in some people.',
  ),
  HarmfulContent(
    name: 'sodium erythorbate',
    description:
        'Used with nitrites in meats. High intake can strain kidneys and cause metabolic imbalance.',
  ),

  // ===== Flavor Enhancers =====
  HarmfulContent(
    name: 'monosodium glutamate',
    description:
        'Flavor enhancer in soups, noodles, and chips. Some report headaches or flushing after high intake.',
  ),
  HarmfulContent(
    name: 'disodium inosinate',
    description:
        'Flavor enhancer often paired with MSG. Can cause mild throat irritation in sensitive individuals.',
  ),
  HarmfulContent(
    name: 'disodium guanylate',
    description:
        'Used with MSG to intensify savory flavors. May cause allergic reactions or sensitivity in some.',
  ),
  HarmfulContent(
    name: 'hydrolyzed vegetable protein',
    description:
        'Flavor additive containing free glutamates similar to MSG. Can cause headaches or allergic responses in sensitive individuals.',
  ),

  // ===== Unhealthy Fats =====
  HarmfulContent(
    name: 'partially hydrogenated oil',
    description:
        'Main source of trans fats in processed foods. Raises bad cholesterol and lowers good cholesterol, contributing to heart disease.',
  ),
  HarmfulContent(
    name: 'refined palm oil',
    description:
        'Cheap oil used in baked goods and chips. Overheating produces oxidation compounds harmful to heart health.',
  ),
  HarmfulContent(
    name: 'interesterified fat',
    description:
        'Modified fat used as a trans-fat substitute. Can disrupt insulin sensitivity and lipid metabolism.',
  ),

  // ===== Other Additives =====
  HarmfulContent(
    name: 'artificial flavoring',
    description:
        'Synthetic chemicals used to mimic natural flavors. Can trigger allergies and digestive irritation in some individuals.',
  ),
  HarmfulContent(
    name: 'high fructose corn syrup',
    description:
        'Sweetener in sodas and processed snacks. Overconsumption leads to insulin resistance, obesity, and liver fat buildup.',
  ),
  HarmfulContent(
    name: 'maltodextrin',
    description:
        'Highly processed carbohydrate filler. Rapidly spikes blood sugar and can disrupt gut health.',
  ),
  HarmfulContent(
    name: 'titanium dioxide',
    description:
        'Whitening agent used in candies and sauces. Classified as possibly carcinogenic and may cause DNA damage in large amounts.',
  ),
  HarmfulContent(
    name: 'carrageenan',
    description:
        'Thickener from seaweed used in dairy and vegan foods. Degraded forms can cause gut inflammation.',
  ),
  HarmfulContent(
    name: 'polysorbate 80',
    description:
        'Emulsifier in ice cream and sauces. Linked to gut barrier disruption and fertility issues in animal studies.',
  ),
  HarmfulContent(
    name: 'propylene glycol',
    description:
        'Used to retain moisture in snacks. Overexposure can irritate skin and may be toxic in large quantities.',
  ),
  HarmfulContent(
    name: 'sodium phosphate',
    description:
        'Used in processed meats and baked snacks. High intake burdens kidneys and affects calcium levels.',
  ),
  HarmfulContent(
    name: 'potassium bromate',
    description:
        'Dough conditioner used in breads. Classified as a possible human carcinogen; banned in several countries.',
  ),
  HarmfulContent(
    name: 'aluminum sulfate',
    description:
        'Used in baking powders and processed cheese. Excess aluminum exposure can affect brain and bone health.',
  ),
  HarmfulContent(
    name: 'sodium aluminum phosphate',
    description:
        'Leavening agent in baked products. Contributes to aluminum accumulation when consumed frequently.',
  ),
  HarmfulContent(
    name: 'sodium hexametaphosphate',
    description:
        'Used to prevent discoloration in foods. Long-term consumption can deplete calcium and essential minerals.',
  ),
  HarmfulContent(
    name: 'azodicarbonamide',
    description:
        'Flour bleaching and dough-improving agent. Breaks down into potentially harmful compounds and is banned in many countries.',
  ),
  HarmfulContent(
    name: 'propylene glycol alginate',
    description:
        'Thickener used in salad dressings and desserts. Large doses may affect liver and kidney function.',
  ),
  HarmfulContent(
    name: 'sodium caseinate',
    description:
        'Milk protein used as an emulsifier in snacks. Can cause reactions in people with dairy allergies.',
  ),
  HarmfulContent(
    name: 'calcium disodium edta',
    description:
        'Preservative and stabilizer in dressings and canned foods. Excess use may deplete essential minerals like zinc and iron.',
  ),
  HarmfulContent(
    name: 'benzaldehyde',
    description:
        'Artificial almond flavoring found in sweets. High doses can cause nausea and nervous system effects.',
  ),
  HarmfulContent(
    name: 'ethyl vanillin',
    description:
        'Artificial vanilla flavoring. Can cause mild allergic reactions in sensitive people.',
  ),
  HarmfulContent(
    name: 'dimethylpolysiloxane',
    description:
        'Anti-foaming agent in fried snacks and oils. Generally safe in small doses but can contain impurities from processing.',
  ),
  HarmfulContent(
    name: 'sodium stearoyl lactylate',
    description:
        'Emulsifier used in baked goods. May cause digestive irritation when consumed frequently.',
  ),
  HarmfulContent(
    name: 'calcium chloride',
    description:
        'Used to firm canned vegetables and pickled foods. High intake may cause stomach irritation or raise calcium levels excessively.',
  ),
];
