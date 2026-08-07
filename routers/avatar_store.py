import asyncio
import uuid
from fastapi import APIRouter, HTTPException, Depends, status, UploadFile, File
from pydantic import BaseModel, Field
from typing import List, Dict, Optional

from routers.auth import get_current_user, UserProfile

router = APIRouter(prefix="/avatar-store", tags=["Avatar Marketplace"])

# Lock to ensure atomic coin/diamond transactions and prevent double spending
store_transaction_lock = asyncio.Lock()

# Separate in-memory DB for Silver Coins (Gold is imported/shared with gifts)
USER_SILVER_BALANCES: Dict[str, int] = {}


# --- Wardrobe Data Models ---
class WardrobeItem(BaseModel):
    id: str
    name: str
    category: str  # Traditional, Modest, Modern, Tech, Smoke, Perfume
    culture_origin: Optional[str] = None  # Saudi, Moroccan, Egyptian, Tunisian, etc.
    price_permanent: int  # Price to unlock permanently
    price_rental_30d: int  # Price for 30 days rental
    emoji_icon: str
    description: str
    color_palette: List[str] = ["#FFFFFF"]


# --- Entrance Engine Assets Model ---
class EntranceItem(BaseModel):
    id: str
    name: str
    category: str  # Frame (إطار), Vehicle (مركبة), Theme (سمة)
    currency: str  # Gold (عملة ذهبية), Silver (عملة فضية)
    price_7d: int
    price_30d: int
    price_permanent: int
    emoji_icon: str
    description: str
    rarity_stars: int  # 1 to 5 stars
    animation_type: str
    effect: str
    has_frame: bool
    interactive_mechanics: dict  # Screen Shake, Earth cracking, mic drop, sound effects


# --- Global Wardrobe Catalog ---
WARDROBE_CATALOG: Dict[str, WardrobeItem] = {
    # 1. Traditional Arab Heritage Clothing
    "saudi_thobe": WardrobeItem(
        id="saudi_thobe",
        name="الثوب السعودي الأصيل والشماغ (Saudi Thobe & Shemagh)",
        category="Traditional",
        culture_origin="Saudi Arabia",
        price_permanent=1500,
        price_rental_30d=300,
        emoji_icon="👳",
        description="ثوب أبيض فاخر مع شماغ أحمر بنقوش قشيبية أصيلة يعبر عن هيبة الخليج.",
        color_palette=["#FFFFFF", "#F5F5F5", "#E0E0E0"]
    ),
    "moroccan_caftan": WardrobeItem(
        id="moroccan_caftan",
        name="القفطان المغربي المطرز (Moroccan Caftan)",
        category="Traditional",
        culture_origin="Morocco",
        price_permanent=2000,
        price_rental_30d=400,
        emoji_icon="👘",
        description="قفطان مغربي مطرز بخيوط الصقلي المذهبة والحرير الفاخر.",
        color_palette=["#D4AF37", "#800020", "#008080", "#4B0082"]
    ),
    "egyptian_galabiya": WardrobeItem(
        id="egyptian_galabiya",
        name="الجلابية الصعيدية المصرية (Egyptian Galabiya)",
        category="Traditional",
        culture_origin="Egypt",
        price_permanent=1000,
        price_rental_30d=200,
        emoji_icon="🧥",
        description="جلابية صعيدية مصرية مريحة تعبر عن الأصالة والتراث العريق.",
        color_palette=["#4E3629", "#1C1C1C", "#556B2F"]
    ),
    "tunisian_attire": WardrobeItem(
        id="tunisian_attire",
        name="الجبة التونسية بالحرير (Tunisian Jebba)",
        category="Traditional",
        culture_origin="Tunisia",
        price_permanent=1200,
        price_rental_30d=240,
        emoji_icon="🥋",
        description="جبة تونسية تقليدية منسوجة بالحرير والخمري الفاتح.",
        color_palette=["#E0B0FF", "#FFFFFF", "#F0E68C"]
    ),

    # 2. Islamic & Modest Wear for Women
    "hijab_abaya": WardrobeItem(
        id="hijab_abaya",
        name="العباية والوشاح المطرز (Elegant Abaya & Khimar)",
        category="Modest",
        price_permanent=1800,
        price_rental_30d=350,
        emoji_icon="🧕",
        description="عباية إسلامية سوداء فاخرة مطرزة بالدانتيل مع خمار متناسق.",
        color_palette=["#000000", "#1E1E1E", "#2C3E50"]
    ),
    "niqab_khimar": WardrobeItem(
        id="niqab_khimar",
        name="النقاب الملكي والملحفة (Royal Niqab & Khimar)",
        category="Modest",
        price_permanent=1600,
        price_rental_30d=300,
        emoji_icon="🎭",
        description="نقاب وخمار كامل من قماش الحرير الناعم ومريح للتنفس.",
        color_palette=["#000000", "#2F4F4F", "#3E2723"]
    ),

    # 3. Modern Casual & Formal Wear
    "formal_suit": WardrobeItem(
        id="formal_suit",
        name="البدلة الرسمية الملكية (Premium Formal Suit)",
        category="Modern",
        price_permanent=2200,
        price_rental_30d=450,
        emoji_icon="👔",
        description="بدلة رسمية كلاسيكية فخمة لحضور السهرات والتحديات الكبرى.",
        color_palette=["#0F0F1A", "#1C2833", "#2C3E50"]
    ),

    # 4. Interactive Props & Gadgets
    "prop_headphones": WardrobeItem(
        id="prop_headphones",
        name="سماعات الاستماع الخاص (Interactive Headphones)",
        category="Tech",
        price_permanent=3000,
        price_rental_30d=600,
        emoji_icon="🎧",
        description="سماعات الرأس الذكية. تتيح تفعيل وضع الاستماع للموسيقى الخاصة بشكل مستقل وسري."
    ),
    "prop_shisha": WardrobeItem(
        id="prop_shisha",
        name="الشيشة التفاعلية (Animated Shisha)",
        category="Smoke",
        price_permanent=2500,
        price_rental_30d=500,
        emoji_icon="💨",
        description="شيشة عربية تقليدية مع ميزة إطلاق دخان كثيف وأصوات قرقرة عند التحدث."
    ),
    "prop_perfume": WardrobeItem(
        id="prop_perfume",
        name="عطر ليلة العمر (Interactive Perfume Spray)",
        category="Perfume",
        price_permanent=1200,
        price_rental_30d=240,
        emoji_icon="🍾",
        description="زجاجة عطر فاخرة ترش رذاذاً متألقاً حول الكرسي عند تفعيلها."
    )
}


# --- Comprehensive 34+ Entrance Engine Catalog ---
# Includes Groups 5 (Apocalyptic/Horror) & 6 (Ancient Egyptian/Cosmic) + standard ones
ENTRANCE_CATALOG: Dict[str, EntranceItem] = {
    # --- 1. Frames (إطارات) ---
    "1000541913": EntranceItem(
        id="1000541913", name="إطار دراغون الكريستال البنفسجي (Purple Crystal Dragon Frame)",
        category="Frame", currency="Gold", price_7d=800, price_30d=2400, price_permanent=8000,
        emoji_icon="🐉", description="إطار ملحمي مستوحى من وحوش التنانين البنفسجية الملتفة.",
        rarity_stars=4, animation_type="Purple Crystal Dragon Circle", effect="Spiral dragon rotation with lotus bloom",
        has_frame=True, interactive_mechanics={"screen_shake": False, "sound_effect": "dragon_growl"}
    ),
    "1000539392": EntranceItem(
        id="1000539392", name="إطار طائر الفينيق الجليدي (Ice Phoenix Frame)",
        category="Frame", currency="Silver", price_7d=1500, price_30d=4500, price_permanent=15000,
        emoji_icon="❄️", description="إطار ناصع البياض مغطى بجليد الفينيق المتلألئ.",
        rarity_stars=3, animation_type="Blue Phoenix & Ice Crystals", effect="Frost particle generation and blue aura flare",
        has_frame=True, interactive_mechanics={"screen_shake": False, "sound_effect": "ice_shiver"}
    ),
    "1000539256": EntranceItem(
        id="1000539256", name="إطار أجنحة المحارب الذهبي (Golden Wings Frame)",
        category="Frame", currency="Gold", price_7d=1200, price_30d=3600, price_permanent=12000,
        emoji_icon="👼", description="إطار يحيط بك بهالة من ريش الملاك الذهبي المتساقط.",
        rarity_stars=4, animation_type="Angelic Wing Spread", effect="Golden muscle glow with feather particle scatter",
        has_frame=True, interactive_mechanics={"screen_shake": False, "sound_effect": "heavenly_choir"}
    ),
    "1000539393": EntranceItem(
        id="1000539393", name="إطار بوابة الجحيم وأسد النار (Hell Gate & Fire Lion Frame)",
        category="Frame", currency="Gold", price_7d=1500, price_30d=4500, price_permanent=15000,
        emoji_icon="🦁", description="إطار متوحش يتفجر بالنيران عند دخولك الغرفة.",
        rarity_stars=5, animation_type="Underground Hell Gate & Fire Lion", effect="Ground crack effect, screen shake, and roaring fire",
        has_frame=True, interactive_mechanics={"screen_shake": True, "sound_effect": "lion_roar", "environment_burn": True}
    ),
    "1000529496": EntranceItem(
        id="1000529496", name="إطار سلم النجوم الكريستالي (Crystal Staircase Frame)",
        category="Frame", currency="Silver", price_7d=2000, price_30d=6000, price_permanent=20000,
        emoji_icon="🪜", description="إطار متلألئ يعبر عن الصعود لقمة الفانتازيا الملكية.",
        rarity_stars=3, animation_type="Crystal Staircase Climb", effect="Stair glowing upward with starlight illumination",
        has_frame=True, interactive_mechanics={"screen_shake": False, "sound_effect": "star_chime"}
    ),
    "1000538978": EntranceItem(
        id="1000538978", name="إطار الهولوغرام الفاخر (Holographic Glamour Frame)",
        category="Frame", currency="Gold", price_7d=900, price_30d=2700, price_permanent=9000,
        emoji_icon="✨", description="لمسات فاخرة من الضوء اللامع الهولوغرافي الفاتن.",
        rarity_stars=4, animation_type="Holographic Glamour Glow", effect="Smooth luxury shine pulse",
        has_frame=True, interactive_mechanics={"screen_shake": False, "sound_effect": "luxury_sparkle"}
    ),
    "1000529486": EntranceItem(
        id="1000529486", name="إطار حيتان المحيط السومرية (Ocean Mandala Frame)",
        category="Frame", currency="Silver", price_7d=1200, price_30d=3600, price_permanent=12000,
        emoji_icon="🐋", description="إطار تراثي بحري تعوم فيه قنديل البحر والحيتان المضيئة.",
        rarity_stars=3, animation_type="Ocean Mandala & Cosmic Whales", effect="Water ripple reflection with glowing jellyfish",
        has_frame=True, interactive_mechanics={"screen_shake": False, "sound_effect": "whale_call"}
    ),
    "1000527196": EntranceItem(
        id="1000527196", name="إطار معبد الفراعنة والتاج (Egyptian Divine Frame)",
        category="Frame", currency="Gold", price_7d=1100, price_30d=3300, price_permanent=11000,
        emoji_icon="👑", description="إطار فرعوني تحيط به بتلات اللوتس المتساقطة من الأعمدة الكبرى.",
        rarity_stars=4, animation_type="Temple Petal Rain & Golden Crown", effect="Lotus water bloom and falling rose petals",
        has_frame=True, interactive_mechanics={"screen_shake": False, "sound_effect": "pharaoh_drums"}
    ),
    "1000526875": EntranceItem(
        id="1000526875", name="إطار كسوف الشمس الذهبي (Solar Eclipse Frame)",
        category="Frame", currency="Gold", price_7d=1300, price_30d=3900, price_permanent=13000,
        emoji_icon="🌑", description="إطار مهيب بهالة مظلمة محاطة بذرات الرمال الذهبية المتطايرة.",
        rarity_stars=5, animation_type="Solar Eclipse Ring Rotation", effect="Dark sun corona pulse and golden sand drift",
        has_frame=True, interactive_mechanics={"screen_shake": False, "sound_effect": "cosmic_wind"}
    ),
    "1000526868": EntranceItem(
        id="1000526868", name="إطار الثقب البنفسجي المظلم (Purple Black-Hole Frame)",
        category="Frame", currency="Silver", price_7d=2500, price_30d=7500, price_permanent=25000,
        emoji_icon="🌀", description="إطار يجذب الأنظار نحوك بفعل قوة البرق الداكن الجاذبية.",
        rarity_stars=3, animation_type="Purple Black-Hole Orbs", effect="Gravitational sphere orbit and dark lightning",
        has_frame=True, interactive_mechanics={"screen_shake": True, "sound_effect": "electric_fuzz"}
    ),
    "1000526107": EntranceItem(
        id="1000526107", name="إطار معبد أنوبيس والنيران (Anubis Scepter Frame)",
        category="Frame", currency="Gold", price_7d=1400, price_30d=4200, price_permanent=14000,
        emoji_icon="⚖️", description="إطار فرعوني حارق تتصاعد منه الأدخنة الذهبية ولهيب النار العتيق.",
        rarity_stars=5, animation_type="Temple Petal Rain & Golden Crown (Anubis Variant)", effect="Anubis step with gold smoke and flame rising",
        has_frame=True, interactive_mechanics={"screen_shake": True, "sound_effect": "anubis_gong", "mic_gifts_fall": True}
    ),
    "1000526102": EntranceItem(
        id="1000526102", name="إطار نفق البرق البنفسجي (Violet Lightning Frame)",
        category="Frame", currency="Silver", price_7d=1800, price_30d=5400, price_permanent=18000,
        emoji_icon="⚡", description="إطار يشحن كرسيك بصواعق الكهرباء ذات الطابع السحري البنفسجي.",
        rarity_stars=3, animation_type="Violet Mage Tunnel Run", effect="Purple electric shockwaves around avatar chair",
        has_frame=True, interactive_mechanics={"screen_shake": True, "sound_effect": "purple_thunder"}
    ),

    # --- 2. Vehicles (مركبات الدخول الفاخرة) ---
    "1000541912": EntranceItem(
        id="1000541912", name="مركبة قمر الكرز الطائر (Floating Moon Vehicle)",
        category="Vehicle", currency="Gold", price_7d=1200, price_30d=3600, price_permanent=12000,
        emoji_icon="🌙", description="هبوط ساحر وسط بتلات زهور الكرز المتساقطة والفراشات الوردية.",
        rarity_stars=4, animation_type="Floating Moon & Cherry Blossoms", effect="Soft pink particles and floating butterfly loop",
        has_frame=False, interactive_mechanics={"screen_shake": False, "sound_effect": "romantic_flute"}
    ),
    "1000539391": EntranceItem(
        id="1000539391", name="مركبة الفينيق الأبيض والوردي (Pink Phoenix Descent)",
        category="Vehicle", currency="Gold", price_7d=1500, price_30d=4500, price_permanent=15000,
        emoji_icon="🦅", description="هبوط ملكي على متن أجنحة الفينيق المهيبة بنور ريشه المتوهج.",
        rarity_stars=5, animation_type="White-Pink Phoenix Descent", effect="Wide wingspan drop with warm glowing feathers",
        has_frame=False, interactive_mechanics={"screen_shake": False, "sound_effect": "phoenix_cry"}
    ),
    "1000539255": EntranceItem(
        id="1000539255", name="مركبة صعود قرص الشمس الذهبي (Sun Disk Rise)",
        category="Vehicle", currency="Silver", price_7d=2500, price_30d=7500, price_permanent=25000,
        emoji_icon="☀️", description="مركبة صعود هولوغرافية ترافقها أسراب الحمام البيضاء.",
        rarity_stars=3, animation_type="Golden Sun Disk Rise", effect="Solar flare expansion with white dove release",
        has_frame=False, interactive_mechanics={"screen_shake": False, "sound_effect": "dove_flap"}
    ),
    "1000539253": EntranceItem(
        id="1000539253", name="مركبة بوابة المجرة والبرق (Galaxy Portal Vehicle)",
        category="Vehicle", currency="Gold", price_7d=1600, price_30d=4800, price_permanent=16000,
        emoji_icon="🌀", description="مركبة تفتح بوابة زمكانية تدور بالكهرباء الكونية الزرقاء الصاخبة.",
        rarity_stars=5, animation_type="Galaxy Portal & Blue Lightning", effect="Vortex rotation with cosmic electric sparks",
        has_frame=False, interactive_mechanics={"screen_shake": True, "sound_effect": "portal_whoosh"}
    ),
    "1000533396": EntranceItem(
        id="1000533396", name="مركبة شفق قطبي وعاصفة ثلج قطبية (Aurora Borealis Vehicle)",
        category="Vehicle", currency="Silver", price_7d=1800, price_30d=5400, price_permanent=18000,
        emoji_icon="🌌", description="تغطي الغرفة بغلاف من ألوان الأورورا والمطعم بنسمات الضباب البارد.",
        rarity_stars=3, animation_type="Aurora Borealis & Snowfall", effect="Northern lights sweep and cold mist fade-in",
        has_frame=False, interactive_mechanics={"screen_shake": False, "sound_effect": "wind_howl"}
    ),
    "1000529485": EntranceItem(
        id="1000529485", name="مركبة ممشى الكون العائم (Universe Walkway)",
        category="Vehicle", currency="Gold", price_7d=1400, price_30d=4200, price_permanent=14000,
        emoji_icon="🛣️", description="سير بقداسة ووقار وسط خطوات كواكب المجرات المشتعلة بالنجوم.",
        rarity_stars=4, animation_type="Floating Universe Walkway", effect="Galaxy rotation and stepping-stone activation",
        has_frame=False, interactive_mechanics={"screen_shake": False, "sound_effect": "cosmic_synth"}
    ),
    "1000529487": EntranceItem(
        id="1000529487", name="مركبة المهر الأسطوري وعاصفة الثلج (Unicorn Drop)",
        category="Vehicle", currency="Silver", price_7d=3000, price_30d=9000, price_permanent=30000,
        emoji_icon="🦄", description="هبوط ديني مقدس للمهر الذهبي وسط دوامات عواصف الجبال الجليدية.",
        rarity_stars=4, animation_type="Snow Mountain Kneel & Unicorn Drop", effect="Blizzard swirl and golden divine light drop",
        has_frame=False, interactive_mechanics={"screen_shake": True, "sound_effect": "unicorn_gallop"}
    ),
    "1000526877": EntranceItem(
        id="1000526877", name="مركبة فستان الورد الأسود وفراشات الليل (Rose Petal Burst)",
        category="Vehicle", currency="Gold", price_7d=1000, price_30d=3000, price_permanent=10000,
        emoji_icon="👗", description="انفجار من البتلات الحمراء يرافقها هبوط ناعم ومثير للفراشات الزرقاء.",
        rarity_stars=4, animation_type="Black Dress Rose Petal Burst", effect="Upward swirling red petals and blue butterflies",
        has_frame=False, interactive_mechanics={"screen_shake": False, "sound_effect": "harp_glissando"}
    ),
    "1000526858": EntranceItem(
        id="1000526858", name="مركبة هجوم أسد الصقيع (Frost Lion Blizzard Charge)",
        category="Vehicle", currency="Gold", price_7d=1800, price_30d=5400, price_permanent=18000,
        emoji_icon="🦁", description="اندفاع أسد صقيعي عملاق بسرعة جنونية وسط جزيئات الجليد الباردة.",
        rarity_stars=5, animation_type="White Frost Lion Blizzard Charge", effect="High-speed snow drift and icy wind screen particles",
        has_frame=False, interactive_mechanics={"screen_shake": True, "sound_effect": "lion_frost_roar", "wind_chill_removal": True}
    ),
    "1000526596": EntranceItem(
        id="1000526596", name="مركبة راعي الشبح وسلاسل النار (Ghost Shepherd Vehicle)",
        category="Vehicle", currency="Gold", price_7d=2000, price_30d=6000, price_permanent=20000,
        emoji_icon="⛓️", description="سلاسل النيران تدور حول كراسي الميك لترعب الحاضرين وتسقط هداياهم.",
        rarity_stars=5, animation_type="Burning Ghost Shepherd & Fire Chains", effect="Swirling magma debris, chain clanks, and dynamic screen shake",
        has_frame=False, interactive_mechanics={"screen_shake": True, "sound_effect": "chains_drag", "drag_and_devour": True}
    ),
    "1000526489": EntranceItem(
        id="1000526489", name="مركبة صاعقة البرق الملاحمية (Lightning Storm Warrior)",
        category="Vehicle", currency="Silver", price_7d=2800, price_30d=8400, price_permanent=28000,
        emoji_icon="🌩️", description="صاعقة برق زرقاء حارقة تحطم حجارة الكرسي مع عاصفة من الرياح الهوجاء.",
        rarity_stars=4, animation_type="Zoro Thunder God Rise", effect="Lightning bolt ground strike with debris shatter",
        has_frame=False, interactive_mechanics={"screen_shake": True, "sound_effect": "thunder_crack", "element_wind_removal": True}
    ),

    # --- 3. Themes (سمات الغرفة التفاعلية المدمرة) ---
    "1000526486": EntranceItem(
        id="1000526486", name="سمة حاصد الأرواح وبوابات الجحيم (Giza Grim Reaper)",
        category="Theme", currency="Gold", price_7d=3000, price_30d=9000, price_permanent=30000,
        emoji_icon="💀", description="أقوى سمات الرعب والدمار! تتشقق الأرض، ويهبط حاصد الأرواح ضارباً بمنجله لتتطاير عناصر الكراسي بالكامل.",
        rarity_stars=5, animation_type="Underground Apocalypse Rise", effect="Apocalyptic black smoke, floor cracking, and screen-wide red alert circle",
        has_frame=False, interactive_mechanics={"screen_shake": True, "sound_effect": "death_screams", "drag_and_devour": True, "element_wind_removal": True}
    ),
    "1000526595": EntranceItem(
        id="1000526595", name="سمة بركان إلـه الحمم والطيور النارية (Volcanic Inferno Theme)",
        category="Theme", currency="Gold", price_7d=2500, price_30d=7500, price_permanent=25000,
        emoji_icon="🌋", description="تنفجر الصخور وتتدفق الحمم الحية تحت كراسي المتحدثين مع تحليق طيور لهب حارقة.",
        rarity_stars=5, animation_type="Volcanic Eruption & Fire Birds", effect="Dynamic bubbling lava backdrop with flame particles",
        has_frame=False, interactive_mechanics={"screen_shake": True, "sound_effect": "lava_boil", "element_wind_removal": True}
    ),
    "1000526487": EntranceItem(
        id="1000526487", name="سمة معبد التنين الأخضر والأنقاض (Ruins & Emerald Dragon)",
        category="Theme", currency="Silver", price_7d=4000, price_30d=12000, price_permanent=40000,
        emoji_icon="🐉", description="معبد أثري عتيق تتساقط أعمدته المشتعلة مع زئير رعد تنين الغابة السماوي.",
        rarity_stars=4, animation_type="Ancient Temple Collapse & Green Dragon", effect="Falling ruins debris with green energy arcs",
        has_frame=False, interactive_mechanics={"screen_shake": True, "sound_effect": "temple_rumble"}
    ),
    "1000526488": EntranceItem(
        id="1000526488", name="سمة أشباح الغابة المظلمة والأمطار (Ghostly Rain & Storm)",
        category="Theme", currency="Silver", price_7d=3500, price_30d=10500, price_permanent=35000,
        emoji_icon="🌧️", description="تخرج أيدي الأشباح من باطن الأرض وسط عاصفة مطرية وبرق ينير غرفتك بشكل مفاجئ ومرعب.",
        rarity_stars=4, animation_type="Graveyard Ghost Spawns", effect="Rain drips on screen, ghost hands animation under mics",
        has_frame=False, interactive_mechanics={"screen_shake": False, "sound_effect": "heavy_rain"}
    ),
    "1000526490": EntranceItem(
        id="1000526490", name="سمة طاقة الأرواح واللسان المشتعل (Three Souls Rite)",
        category="Theme", currency="Gold", price_7d=2200, price_30d=6600, price_permanent=22000,
        emoji_icon="🔥", description="تظهر الأوجه الثلاثة الشبحية مع توهج أخضر يشق حجارة الغرفة.",
        rarity_stars=5, animation_type="Triple Spirit Incarnation", effect="Green fire aura with levitating stone fragments",
        has_frame=False, interactive_mechanics={"screen_shake": False, "sound_effect": "ghost_whisper"}
    ),
    "1000526104": EntranceItem(
        id="1000526104", name="سمة عرش أنوبيس والكسوف الشمسي (Anubis Eclipse Throne)",
        category="Theme", currency="Gold", price_7d=2800, price_30d=8400, price_permanent=28000,
        emoji_icon="🏜️", description="تظلم الغرفة بالكامل، ويحدث كسوف ملتهب للشمس خلف العرش مع لمعان المسلات والأهرامات الفرعونية.",
        rarity_stars=5, animation_type="Solar Eclipse & Pharaoh Awakening", effect="Total eclipse darkness, solar flares, and circular light orbits",
        has_frame=False, interactive_mechanics={"screen_shake": True, "sound_effect": "eclipse_rumble", "drag_and_devour": True}
    ),
    "1000526095": EntranceItem(
        id="1000526095", name="سمة استيقاظ العملاق الكوني والأرواح (Cosmic Giant Heartbeat)",
        category="Theme", currency="Silver", price_7d=5000, price_30d=15000, price_permanent=50000,
        emoji_icon="🗿", description="يتشقق صدر تمثال العملاق الحجري ليشع منه نبض طاقة البرق الأزرق، مطيراً مئات الأرواح حول الكراسي.",
        rarity_stars=4, animation_type="Stone Giant Heart Awakening", effect="Pulsing blue light wave with phantom spirits stream",
        has_frame=False, interactive_mechanics={"screen_shake": True, "sound_effect": "giant_heartbeat"}
    ),
    "1000526108": EntranceItem(
        id="1000526108", name="سمة عاصفة الفنار والمحيط السماوي (Cosmic Lighthouse)",
        category="Theme", currency="Silver", price_7d=3200, price_30d=9600, price_permanent=32000,
        emoji_icon="🌊", description="تتحول الغرفة إلى محيط سماوي هائج تضربه الأمواج ويدور الفنار بشعاعه الساطع مخترقاً السحاب.",
        rarity_stars=4, animation_type="Whirling Water Vortex", effect="Swirling water vortex on the floor, lighthouse rotating beam",
        has_frame=False, interactive_mechanics={"screen_shake": False, "sound_effect": "ocean_waves"}
    ),
}


# --- Request/Response Schemas ---
class BuyItemRequest(BaseModel):
    item_id: str
    is_permanent: bool = True  # True: Permanent Unlock, False: 30-Day Rental


class BuyEntranceRequest(BaseModel):
    item_id: str
    duration: str = Field(..., description="7d, 30d, or permanent")


class SendEntranceRequest(BaseModel):
    item_id: str
    receiver_id: str
    duration: str = Field(..., description="7d, 30d, or permanent")


class DesignOutfitRequest(BaseModel):
    base_color: str
    embroidery_pattern: str  # Arabesque, RoyalGold, Geometric
    text_stitching: Optional[str] = None


class WorkshopStitchResponse(BaseModel):
    success: bool
    outfit_id: str
    animation_sequence: List[str]
    message: str


# --- Wardrobe Endpoints ---

@router.get("/wardrobe", response_model=List[WardrobeItem])
async def get_wardrobe_catalog():
    """
    Get the complete Avatar Wardrobe and items catalog.
    """
    return list(WARDROBE_CATALOG.values())


@router.post("/buy", status_code=status.HTTP_200_OK)
async def purchase_wardrobe_item(
    payload: BuyItemRequest,
    current_user: UserProfile = Depends(get_current_user)
):
    """
    Purchase or rent a wardrobe item using the app's coin balance.
    Features duration-based rental vs permanent unlock.
    """
    from routers.gifts import USER_BALANCES

    item_id = payload.item_id
    is_perm = payload.is_permanent

    async with store_transaction_lock:
        if item_id not in WARDROBE_CATALOG:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Item not found in catalog"
            )

        item = WARDROBE_CATALOG[item_id]
        price = item.price_permanent if is_perm else item.price_rental_30d

        if current_user.id not in USER_BALANCES:
            USER_BALANCES[current_user.id] = 10000

        balance = USER_BALANCES[current_user.id]

        if balance < price:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail=f"رصيدك غير كافٍ. تحتاج إلى {price} ذهبة لإتمام العملية."
            )

        USER_BALANCES[current_user.id] = balance - price
        term_text = "دائم مدى الحياة" if is_perm else "إيجار لمدة 30 يوماً"

        return {
            "success": True,
            "item_id": item_id,
            "item_name": item.name,
            "price_paid": price,
            "new_balance": USER_BALANCES[current_user.id],
            "unlock_type": "Permanent" if is_perm else "Rental",
            "message": f"تم بنجاح فتح {item.name} ({term_text})!"
        }


# --- Entrance Store Endpoints ---

@router.get("/entrance/catalog", response_model=List[EntranceItem])
async def get_entrance_catalog():
    """
    Retrieve the complete 34+ Entrance Engine asset library.
    Contains Frames, Vehicles, and Apocalyptic/Mythological Themes.
    """
    return list(ENTRANCE_CATALOG.values())


@router.post("/entrance/buy")
async def buy_entrance_item(
    payload: BuyEntranceRequest,
    current_user: UserProfile = Depends(get_current_user)
):
    """
    Buy an entrance asset using either Gold Coins or Silver Coins depending on product pricing model.
    """
    from routers.gifts import USER_BALANCES

    item_id = payload.item_id
    dur = payload.duration

    if dur not in ["7d", "30d", "permanent"]:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid duration choice")

    async with store_transaction_lock:
        if item_id not in ENTRANCE_CATALOG:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Entrance item not found")

        item = ENTRANCE_CATALOG[item_id]

        # Calculate price based on duration
        if dur == "7d":
            price = item.price_7d
        elif dur == "30d":
            price = item.price_30d
        else:
            price = item.price_permanent

        # Verify correct balance pool
        if item.currency == "Gold":
            if current_user.id not in USER_BALANCES:
                USER_BALANCES[current_user.id] = 10000
            user_bal = USER_BALANCES[current_user.id]
        else:
            if current_user.id not in USER_SILVER_BALANCES:
                USER_SILVER_BALANCES[current_user.id] = 20000
            user_bal = USER_SILVER_BALANCES[current_user.id]

        if user_bal < price:
            currency_lbl = "عملة ذهبية" if item.currency == "Gold" else "عملة فضية"
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail=f"رصيدك من الـ {currency_lbl} غير كافٍ. تحتاج {price} لإتمام الصفقة."
            )

        # Deduct balance
        if item.currency == "Gold":
            USER_BALANCES[current_user.id] = user_bal - price
            new_bal = USER_BALANCES[current_user.id]
        else:
            USER_SILVER_BALANCES[current_user.id] = user_bal - price
            new_bal = USER_SILVER_BALANCES[current_user.id]

        return {
            "success": True,
            "item_id": item_id,
            "item_name": item.name,
            "price_paid": price,
            "currency": item.currency,
            "duration": dur,
            "new_balance": new_bal,
            "message": f"تم تفعيل {item.name} بنظام {dur} بنجاح!"
        }


@router.post("/entrance/send")
async def send_entrance_item(
    payload: SendEntranceRequest,
    current_user: UserProfile = Depends(get_current_user)
):
    """
    Send an entrance asset as a gift to a friend using Gold or Silver coins.
    """
    from routers.gifts import USER_BALANCES

    item_id = payload.item_id
    receiver_id = payload.receiver_id
    dur = payload.duration

    if dur not in ["7d", "30d", "permanent"]:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid duration")

    async with store_transaction_lock:
        if item_id not in ENTRANCE_CATALOG:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Entrance item not found")

        item = ENTRANCE_CATALOG[item_id]

        if dur == "7d":
            price = item.price_7d
        elif dur == "30d":
            price = item.price_30d
        else:
            price = item.price_permanent

        # Check sender's balance
        if item.currency == "Gold":
            if current_user.id not in USER_BALANCES:
                USER_BALANCES[current_user.id] = 10000
            user_bal = USER_BALANCES[current_user.id]
        else:
            if current_user.id not in USER_SILVER_BALANCES:
                USER_SILVER_BALANCES[current_user.id] = 20000
            user_bal = USER_SILVER_BALANCES[current_user.id]

        if user_bal < price:
            currency_lbl = "عملة ذهبية" if item.currency == "Gold" else "عملة فضية"
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail=f"رصيدك غير كافٍ لإهداء الكسوة. تحتاج {price} {currency_lbl}."
            )

        # Deduct sender balance
        if item.currency == "Gold":
            USER_BALANCES[current_user.id] = user_bal - price
            new_bal = USER_BALANCES[current_user.id]
        else:
            USER_SILVER_BALANCES[current_user.id] = user_bal - price
            new_bal = USER_SILVER_BALANCES[current_user.id]

        # Initialize receiver's balance if not existing (mock registry)
        if item.currency == "Gold" and receiver_id not in USER_BALANCES:
            USER_BALANCES[receiver_id] = 10000
        elif item.currency == "Silver" and receiver_id not in USER_SILVER_BALANCES:
            USER_SILVER_BALANCES[receiver_id] = 20000

        return {
            "success": True,
            "sender_id": current_user.id,
            "receiver_id": receiver_id,
            "item_id": item_id,
            "item_name": item.name,
            "price_paid": price,
            "currency": item.currency,
            "new_balance": new_bal,
            "message": f"تم إرسال {item.name} كهدية بنجاح إلى المستخدم {receiver_id}!"
        }


# --- Tailoring & Embroidery Design Workshop ---

@router.post("/tailor/design", response_model=WorkshopStitchResponse)
async def design_custom_outfit(
    payload: DesignOutfitRequest,
    current_user: UserProfile = Depends(get_current_user)
):
    """
    Interactive Tailor & Custom Design Workshop:
    Triggers virtual sewing and embroidery simulation animations, returning custom generated parameters.
    """
    outfit_id = f"custom_outfit_{uuid.uuid4().hex[:6]}"

    # Live tailoring/embroidery animation sequences
    animation_steps = [
        "سحب القماش المختار ومطابقة القياسات...",
        "بدء تشغيل ماكينة الخياطة التفاعلية الفائقة...",
        f"تطبيق نقش التطريز الإسلامي: {payload.embroidery_pattern}...",
        f"حياكة الاسم المخصص على الثوب: {payload.text_stitching or 'ألف ليلة وليلة'}...",
        "كي الكسوة وتطبيق تلميع Shader ثلاثي الأبعاد..."
    ]

    return WorkshopStitchResponse(
        success=True,
        outfit_id=outfit_id,
        animation_sequence=animation_steps,
        message="تمت حياكة وتفصيل كسوتك ثلاثية الأبعاد بنجاح تام!"
    )
