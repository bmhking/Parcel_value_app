# Parcel_value_app
A web app that shows property value per sqft per parcel for the county of San Diego.

Why this is important:  
The city is responsible for the maintenace of the infrastructure. Most of it is (supposed) to be funded by local property taxes. However, it turns out that this is highly unrealistic. For example:

San Diego has around 2900 miles of road and 3300 miles of pipe. Based on the following advantageous assumptions:
- No maintenance is ever needed for infrastructure.
- Re-install time is 25 years (irl it's 25 years if it's well maintained)
- No other infrastructure is needed

Under market price (780k per mile for a road and 75 dollars per feet of water line), the total cost for the infrastructure is:  
```math
2900mi\times$780k/mi+3300mi\times5280ft/mi\times$75/ft=$3,568,800,000
```

Spread to 25 years, that requires $`\$3,568,800,000/25yr=\$142,752,000/yr`$.

The adopted budget for the city of San Diego for 2022-2023 states that property tax revenue is $`\$744,138,493`$. This means that the city requires 20$ of property tax revenue to pay for its infrastructure - this is impossible because usually the city gets less than 20% of its property tax revenue back to begin with.

Let this sink in:  
*Assuming that you never need to maintain for your infrastructure, the city of San Diego still spends more on infrastructure than the revenue it can create.*

This has multiple consequences:
- Since the city can never pay back its infrastructure, it needs to borrow. For the city of San Diego, the general fund (the revenue that the city can raise) is around 40% of its "revenue" in the budget book. The rest of the "revenue" is in fact grants and loans.
- Since the city can never pay back its infrastructure, it needs to select what part of the city to maintain. Naturally this means that affluent parts of the city will receive more funding for infrastructure, while poorer areas will not have the political resources to fight for more funding.

The cost of infrastructure is actually pretty stable. For plots of land close to each other (therefore similar in climate, terrain, etc.), generally speaking the only factor that significantly affects the cost of infrastructure is its size. There are still two things that can affect the cost:
- The county of San Diego is very hilly, and it costs more to pump water to the hills because of gravity. That means infrastructure cost is higher on the hill - where usually rich people live.
- The more transit friendly an area is, the cost of roads decreases, because there is less need to maintain road infrastructure. The damage public transit does to asphalt roads is minimal compared to private vehicles, because on average the weight required to move people is less when on a bus, not to mention rail where the damage done is less because you don't have rubber tires and the material you're damaging, steel, is more durable than asphalt. In San Diego, downtown is more transit friendly than suburban areas.

For the case of this analysis, we will still assume that infrastructure cost is consistent per sqft for simplicity, even if this will benefit more affluent people because their lifestyles require more infrastructure. The city of San Diego spans $`372.4sqmi`$ which means that for every sqft the infrastructure cost is
```math
\frac{\$142,752,000/yr}{372.4mi^2\times2.788e+7sqft/sqmi}=\$0.01375/yr/sqft
```
Assuming 10% of property tax revenue goes into infrastructure (an unrealisticly high percentage), that means you need to generate $`\$0.1375/yr/sqft`$ of property tax. Now the city can only generate $`\frac{\$744,138,493/yr}{372.4mi^2\times2.788e+7sqft/sqmi}=\$0.07167/yr/sqft`$ of property tax revenue.

This is barely 50% of revenue required. In the state of California, property tax revenue is much smaller than what it should be not just because of the 1% ceiling because of Prop 13, but also because of another clause in Prop 13: that reassessment cannot happen without change in ownership or new construction. In reality this means that even assuming a 1% property tax rate, most of the potential property tax income is not collectable (no city in the county of San Diego is able to recover more than 40% of its potential property tax pool). Prop 13 is overwhelmingly supported by homeowners, who are on average more affluent than renters. This means that Prop 13 is a weapon for homeowners to underpay their financial obligations while still forcing the city government to pay for their infrastructure in its full glory. In that process, infrastructure for poorer neighborhoods (which are usually majority-minority, more likely to have renters, have higher housing density, and have had their communities destroyed by the Federal Highway Act and urban renewal campaigns) are forced to be degraded, the schools and parks are defunded, social injustice has increased.

Generally speaking, the more resources you demand, the more you need to be able to pay it back in. However, this is not the case with infrastructure. Throughout this country, rich neighborhoods consistently choose the least productive method of buildings - sprawl, while costing more. This is somewhat mitigated in San Diego because a lot of rich people live along the coastline, a place where it is generally understood to have sparse land so even when detached single-family houses are built, they are generally closely aligned to each other. However, the app will still show that:

- In the entire county, mixed-use/multi-family buildings produce on average 3x the property value per sqft of that of single family houses
- In the entire city, mixed-use/multi-family buildings produce on average 1.5x the property value per sqft of that of single family houses

Single family houses are not only worse for the environment and housing affordability, but is also less valuable. This is especially serious in cities like Poway or communities like Rancho Santa Fe or Ramona, where the extreme sprawl means that the single family houses are barely producing any value. These houses do not contribute to the city. Instead, they are bleeding the coffers dry, while their owners live out their self-made American dream.


## Appendix 1: The Cost of Highways
The detrimental effects of the Federal Highway Act cannot be understated. It rammed through the cities of the United States with such a force of destruction that only the nuclear bombs can rival, that even its main benefactor, President Dwight D. Eisenhower was reported to be disturbed by the ruins it left(likely because of his logistics officer background, he understood how money flows). Furthermore, the funding structure of it is unsustainable - the federal government would pay for 90% of its construction cost, which meant that local governments were never able to fully understand the financial cost of these highways. When the time came to repave the highways, governments of all levels were unable to pay back the cost without using debt. And while all projects go over the budget, the highways went extremely over the budget - by more than 400%. Meanwhile the Shinkansen, built around the same time, was only 200% over the budget, and CAHSR can't even get enough funding because for trains, the federal government is only willing to pay 10% of the cost. The financial ruin of these highways are reflected in the analysis of the county of San Diego - whereever the highway pierced through, valuable buildings were destroyed, leaving no financial productivity that can sustain such infrastructure. Even worse, as governments doubled down on road construction (often due to racist reasons to block black people from easy access to white neighborhoods), the federal government kept encouraging such financial suicide by giving out free money for local governments to destroy their own tax base to build costly structures. For San Diego, this means that the county needs to maintain more than 10 highways, which cause congestion, noise pollution, air pollution, and high quantity of pedestrian deaths along the exits.
