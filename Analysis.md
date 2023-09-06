# Parcel_value_app
A web app that shows property value per sqft per parcel for the county of San Diego.

Why this is important:  
The city is responsible for the maintenace of the infrastructure. Most of it is (supposed) to be funded by local property taxes. However, it turns out that this is highly unrealistic. For example:

San Diego has around 2900 miles of road and 3300 miles of pipe. Based on the following advantageous assumptions:
- No maintenance is ever needed for water pipes
- Re-install time is 25 years (irl it's 25 years if it's well maintained)
- No other infrastructure is needed

## Cost of Infrastructure
### Water pipes
The city has approximately 3000 miles of PVC pipes. According to the 2023 county guidelines for price, assuming all the pipes are 12-inch pipes ($86.88/ft by county guidelines), the total cost is
```math
3000mi\times5280ft/mi\times$86.88/ft=$1,376,179,200
```
Assuming a 50 year lifespan, that means the annual cost of pipes is $`\$1,376,179,200/50yr=\$27,523,584/yr`$

### Sewer pipes
In 2023, the city inspected 2320 miles of sewer pipes, a number we'll assume to be the actual length of sewer pipes in the city. According to the 2023 county guidelines for price, assuming all the pipes are 12-inch pipes ($100.03/ft by county guidelines), the total cost is
```math
2320mi\times5280ft/mi\times$100.03/ft=$1,225,327,488
```
Assuming a 50 year lifespan, that means the annual cost of pipes is $`\$1,225,327,488/50yr=\$24,506,549.76/yr`$

### Roads
According to the Reason Foundation's latest highway report, the annual lane-mile maintenace cost of roads in california is $44,831. Assuming that all roads are three lanes (definitely lower than actual average), that means that annual maintenance cost is about  

```math
2900mi\times$44831/mi/yr\times3=$390,029,700/yr
```

This means that annual infrastructure cost for San Diego is $`\$27,523,584/yr+\$24,506,549.76/yr+\$390,029,700/yr=\$442,059,833.76$

The adopted budget for the city of San Diego for 2022-2023 states that property tax revenue is $`\$744,138,493`$. This means that the city requires ~60% of property tax revenue to pay for its heavily underestimated infrastructure - this is impossible because usually the city gets less than 20% of its property tax revenue back to begin with.

Let this sink in:  
*The city will never be able to pay back its infrastructure cost.*

This has multiple consequences:
- Since the city can never pay back its infrastructure, it needs to borrow. For the city of San Diego, the general fund (the revenue that the city can raise) is around 40% of its "revenue" in the budget book. The rest of the "revenue" is in fact grants and loans.
- Since the city can never pay back its infrastructure, it needs to select what part of the city to maintain. Naturally this means that affluent parts of the city will receive more funding for infrastructure, while poorer areas will not have the political resources to fight for more funding.

The cost of infrastructure is actually pretty stable. For plots of land close to each other (therefore similar in climate, terrain, etc.), generally speaking the only factor that significantly affects the cost of infrastructure is its size. There are still two things that can affect the cost:
- The county of San Diego is very hilly, and it costs more to pump water to the hills because of gravity. That means infrastructure cost is higher on the hill - where usually rich people live.
- The more transit friendly an area is, the cost of roads decreases, because there is less need to maintain road infrastructure. The damage public transit does to asphalt roads is minimal compared to private vehicles, because on average the weight required to move people is less when on a bus, not to mention rail where the damage done is less because you don't have rubber tires and the material you're damaging, steel, is more durable than asphalt. In San Diego, downtown is more transit friendly than suburban areas.

For the case of this analysis, we will still assume that infrastructure cost is consistent per sqft for simplicity, even if this will benefit more affluent people because their lifestyles require more infrastructure. The city of San Diego spans $`372.4sqmi`$ which means that for every sqft the infrastructure cost is
```math
\frac{\$442,059,833.76/yr}{372.4mi^2\times2.788e+7sqft/sqmi}=\$0.04258/yr/sqft
```
Assuming 10% of property tax revenue goes into infrastructure (an unrealisticly high percentage), that means you need to generate $`\$0.4258/yr/sqft`$ of property tax. Now the city can only generate $`\frac{\$744,138,493/yr}{372.4mi^2\times2.788e+7sqft/sqmi}=\$0.07167/yr/sqft`$ of property tax revenue.

This is not even 20% of revenue required. In the state of California, property tax revenue is much smaller than what it should be not just because of the 1% ceiling because of Prop 13, but also because of another clause in Prop 13: that reassessment cannot happen without change in ownership or new construction. In reality this means that even assuming a 1% property tax rate, most of the potential property tax income from homeowners is not collectable as long as it is not traded (no city in the county of San Diego is able to recover more than 40% of its potential property tax pool). For example, for the city of San Diego, it can only recover 27.53% of its potential property tax base. Prop 13 is overwhelmingly supported by homeowners, who are on average more affluent than renters.

This means that Prop 13 is a de facto financial weapon for homeowners to underpay their obligations while still forcing the city government to pay for their infrastructure in its full glory. In that process, infrastructure for poorer neighborhoods (which are usually majority-minority, more likely to have renters, have higher housing density, and have had their communities destroyed by the Federal Highway Act and urban renewal campaigns) is forced to be degraded, schools are defunded and privatized, and parks are abandoned.

Generally speaking, the more resources you demand, the more you need to be able to pay it back in. However, this is not the case with infrastructure. Throughout this country, rich neighborhoods consistently choose the least productive method of buildings - sprawl, while costing more to maintain. This is somewhat mitigated in San Diego because a lot of rich people live along the coastline, a place where it is generally understood to have sparse land so even when detached single-family houses are built, they are generally closely aligned to each other. However, the app will still show that:

- In the entire county, mixed-use/multi-family buildings produce on average 3x the property value per sqft of that of single family houses
- In the entire city, mixed-use/multi-family buildings produce on average 1.5x the property value per sqft of that of single family houses (city SFHs are generally denser than regular SFHs)

Single family houses are not only worse for the environment and housing affordability, but is also less valuable. This is especially serious in cities like Poway or communities like Rancho Santa Fe or Ramona, where the extreme sprawl means that the single family houses are barely producing any value. These houses do not contribute to the city. Instead, they are bleeding the coffers dry, while their owners live out their self-made American dream. For example, the average single family house in the city San Diego pays for infrastructure per sqft under the same 10% assumption:
```math
$74.14/sqft\times1\%\times27.53\%\times0.1=$0.02041/sqft
```
That is only not even 50% of the infrastructure cost required under the best assumptions, and this trend can be observed throughout the county. There is no financial justification not to repeal Prop 13 and upzone the county.
