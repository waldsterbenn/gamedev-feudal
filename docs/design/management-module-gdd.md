
Game Design Document (GDD) — Management Module
Project Working Title: Wilderness Fief
Setting: Feudal Europe (c. 1300–1400)
Perspective: 3D Open World (Physical NPC Agents)
1. Module Overview & Core Loop
The management module handles the transformation of a raw, unsettled wilderness into a structured, economically viable feudal estate. The player acts as a lowborn nobleman sent to the frontier by royal decree to build a foothold for the King.
NPC workers are physical agents visible in the 3D world—referred to as Populants within the management context—who live, consume, commute, and labor based on macro-economic data tables calculated by this module.
The Core Management Loop (Phase One)
[Survey Wilderness Node] ➔ [Deploy Work Camp] ➔ [Construct Extraction Buildings] ➔ [Gather Raw Resources] ➔ [Upgrade Settlement Status]

2. Territory & World Map (Node-Based System)
Instead of an arbitrary tile grid, the world map is represented as an organic network of discrete Territory Nodes. Each node acts as a distinct point of geographical interest, a clearing, or an economic hub, serving as the absolute lowest unit of land that can be controlled, leased, or contracted.
2.1 Node Properties & Fertilities
Every node contains all agricultural and environmental fertility attributes. Regional biomes alter the decimal strength of these attributes rather than binary spawning them.
Fertility Range: All values are represented as a float from 0.0 (completely barren) to 1.0 (ideal paradise).
Dynamic Forestry System: Wood management is a live ecological system rather than a static resource node. It is split into two metrics:
Timber Fertility: The static capacity of the soil to grow trees ($0.0$ to $1.0$). Dictates the natural regeneration speed of the forest canopy.
Canopy Density: The current physical volume of standing wood on the node ($0.0$ to $1.0$). Clear-cutting depletes this value.
Agricultural Suppression & Ecosystem Interaction: High tree coverage chokes out fields. Conversely, clear-cutting a forest strips away the shade required by sensitive wild resources.
Effective crop yield is calculated as:
$$Fertility_{effective} = Fertility_{base} \times (1.0 - CanopyDensity)$$
Wild foraging yields (like mushrooms) scale down as canopy protection is removed.
3. Settlement Tiers & Evolution
Every settled node exists in an administrative state toggled manually by the player during Phase One.
3.1 Phase One Settlement Tiers
Wilderness: Unclaimed territory. Yields no taxes, cannot support buildings, carries high exploration risks, and remains completely dormant in the background data registry.
Work Camp: The mandatory first step of colonization. It represents a transient, survival-focused outpost for extracting raw resources. It consists of primitive structures (tents, dugout huts, charcoal woodstacks) serving as live-in workplaces for laborers who must operate far from established towns. Establishing a camp starts completely bare—with no starter resources or free jobs.
Village: A permanent, stable civilian community centered around agricultural production and basic processing. Unlocks advanced blueprints.
Town: A major administrative and commercial hub focused on free artisans, trade, market commerce, and high-tier manufacturing.
3.2 Future Feature Blueprint: The Great Branch (Farm vs. Village)
Note: This is a planned Phase Two feature. Phase One must lay the structural hooks to support this split.
Upon upgrading a Work Camp, the player faces a permanent socio-economic choice regarding how the node's property and social hierarchy evolve:
                ┌──> [Farm] ───────> [Manor / Fortified Seat] (Feudal Path)
[Wilderness] ───>┤
                 └──> [Village] ───> [Town] (Communal / Burgher Path)

Path A: The Village & Town Path (Communal / Commercial)
Property Model: Divided into individual Burgage Plots rented by free citizens.
Social Track: Inhabitants evolve down the Burgher path. Free artisans and merchants move here independently to purchase plots and operate private workshops.
Rights: These nodes are uniquely eligible to receive legal charters, grant market rights, and form self-governing town councils.
Path B: The Farm & Manor Path (Private / Feudal Enterprise)
Property Model: The entire node is operated as a single, top-down agricultural enterprise. There are no private plots.
Social Track: Inhabited by a single head manager (tenant farmer) and the direct employees/laborers who live on-site. Artisans can reside here, but only as direct servants of the farm master.
Evolution: Can grow into massive agricultural complexes (barns, stables, worker quarters). If managed directly by a nobleman (like the player character), it can be elevated to a Manor House, unlocking defensive fortifications (palisades, moats, stone keeps) subject to royal permission.
Starting Condition: The player is intended to establish a private Farm for themselves during the initial phase of the early game.
4. Phase One Building System (Open List Architecture)
To maximize performance and accelerate development prototyping, Phase One drops all building slot limits and structural position requirements. Once a node is controlled, the player can construct any available building blueprint instantly, provided they have the required resources in their inventory.
Primitive Camp Structures
Leather Tents / Dugouts: Extremely low-cost housing using only raw hides or unrefined timber. Low comfort metrics.
Charcoal Woodstacks: Functional camp workspace that slowly converts raw timber into charcoal for winter fuel and basic smelting.
Covered Work Area: Basic covered work zones allowing carpenters and masonry workers to bypass negative weather modifiers without requiring heavy stone infrastructure.
5. Workforce & Labor Allocation System
The workforce system decouples individual physical characters from specific daily tasks. Instead, it relies on a Supply and Demand Matching Model handled entirely at the node level.
5.1 Characters, Residing, and Commuting
The Population Pipeline: Populants do not materialize automatically out of thin air. The player must find NPCs wandering the open world, actively recruit them to their faction, and then manually assign them to reside at a controlled node.
Residential Lock: When a Populant is assigned to a node, that node becomes their primary residence. They consume food from its inventory and use its local housing (tents/hovels).
The Commuting Rule: A Populant assigned to Node A can fulfill a job slot on Node A OR any directly connected neighboring node on the world map graph. This allows a central Village node to act as a residential hub while its workers commute out to a neighboring mining or logging Camp.
5.2 How Job Openings are Created
Job slots are generated via three distinct sources:
Node-Based Default Jobs: As long as a node has at least Camp status, the player can manually open environmental jobs via the UI (e.g., foraging, woodcutting, or gathering surface stone).
Construction Orders: Ordering a building automatically generates temporary Builder/Carpenter job slots on that node until construction is complete.
Building-Driven Jobs: Completing a specialized structure automatically registers its permanent job slots to the node (e.g., a finished Smithy creates a "Smith" job slot).
6. Phase One Jobs & Resource Ecosystem
6.1 Forager
Gathers seasonal flora from the woodland landscape.
Yield Pools: Extracts Berries and Mushrooms.
Environmental Modifier: Mushroom production drops heavily if the surrounding canopy_density falls, reflecting a loss of shaded, damp soil.
6.2 Woodcutter
Fells trees to clear ground and accumulate raw construction stock.
Yield Pools: Extracts Timber.
Environmental Modifier: Directly degrades the node's canopy_density with every unit gathered, leading to structural deforestation and diminishing yield returns over time.
6.3 Localized Inventory & Logistics
Phase One utilizes a Localized Inventory Model. Each territory node tracks and holds its own physical commodities. Production happens locally, and consumption pulls locally.
The Pull Rule: When constructing a building on a node, the system checks the local stockpile first. If resources are missing, it can automatically pull them from any directly connected neighboring node at a slight speed penalty.
The Push Rule: Workers harvesting in a node always deposit raw resources into the stockpile where the workplace sits.


